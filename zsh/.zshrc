# =========================
# ZSH cross-platform (macOS | Linux | WSL)
# by Romulo + ChatGPT (2025-10) - versão hardening
# =========================

# --- Helpers & Platform flags ---
is_macos() { [[ "$OSTYPE" == darwin* ]]; }
is_linux() { [[ "$OSTYPE" == linux*  ]]; }
is_wsl()   { [[ -e /proc/sys/fs/binfmt_misc/WSLInterop ]] || grep -qi microsoft /proc/version 2>/dev/null; }

# Add path only if missing
add_path() { case ":$PATH:" in *":$1:"*) ;; *) PATH="$1:$PATH";; esac; }

# XDG base dirs (fallback)
: "${XDG_DATA_HOME:=$HOME/.local/share}"
: "${XDG_CACHE_HOME:=$HOME/.cache}"

# --- Config básica de PATH/ambiente que é segura até para shell não-interativo ---

# Homebrew (macOS)
if is_macos; then
  if [[ -x /opt/homebrew/bin/brew ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
  elif [[ -x /usr/local/bin/brew ]]; then
    eval "$(/usr/local/bin/brew shellenv)"
  fi
fi

# asdf (version 0.18.1 or up) (Linux: /opt/asdf-vm | $HOME/.asdf ; macOS: brew
if [[ -r /usr/share/asdf-vm/asdf.sh ]]; then
  source /usr/share/asdf-vm/asdf.sh
elif [[ -r "$HOME/.asdf/asdf.sh" ]]; then
  source "$HOME/.asdf/asdf.sh"
elif is_macos && command -v brew >/dev/null 2>&1 && [[ -r "$(brew --prefix asdf 2>/dev/null)/libexec/asdf.sh" ]]; then
  source "$(brew --prefix asdf)/libexec/asdf.sh"
fi

# Rust via asdf
if command -v asdf >/dev/null 2>&1; then
  _RUST_BIN="$(asdf where rust 2>/dev/null)/bin"
  [[ -n "$_RUST_BIN" ]] && add_path "$_RUST_BIN"
fi

# asdf shims
add_path "$HOME/.asdf/shims"
add_path "$HOME/.asdf/bin"

add_path "$HOME/.local/bin"

# Se o shell NÃO for interativo, para aqui.
# Isso evita que VS Code/WSL/ scripts não interativos que usam zsh
# tenham que carregar tema, plugins, fzf, etc., reduzindo chance de erro code 1.
[[ $- != *i* ]] && return

# =========================
# Daqui pra baixo: só para shell interativo
# =========================

# --- p10k instant prompt (desligado por padrão, mais seguro em WSL) ---
typeset -g POWERLEVEL9K_INSTANT_PROMPT=off
# Se quiser testar depois:
# typeset -g POWERLEVEL9K_INSTANT_PROMPT=quiet

# --- zinit (plugin manager) ---
ZINIT_HOME="${XDG_DATA_HOME}/zinit/zinit.git"
if [[ ! -d "$ZINIT_HOME" ]]; then
  mkdir -p "${ZINIT_HOME%/*}" 2>/dev/null
  if command -v git >/dev/null 2>&1; then
    git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME" 2>/dev/null || true
  fi
fi

if [[ -r "$ZINIT_HOME/zinit.zsh" ]]; then
  source "$ZINIT_HOME/zinit.zsh"

  # Tema p10k (depth=1 para clone leve)
  zinit ice depth=1
  zinit light romkatv/powerlevel10k

  # Plugins (ordem: autosuggestions -> fzf-tab -> completions -> syntax-highlighting por último)
  zinit light zsh-users/zsh-autosuggestions
  zinit light Aloxaf/fzf-tab
  zinit light zsh-users/zsh-completions
  zinit light zsh-users/zsh-syntax-highlighting

  # Snippets do Oh My Zsh (OMZP::<plugin>)
  zinit snippet OMZP::git
  zinit snippet OMZP::sudo
  zinit snippet OMZP::archlinux
  zinit snippet OMZP::aws
  zinit snippet OMZP::kubectl
  zinit snippet OMZP::kubectx
  zinit snippet OMZP::command-not-found
fi

# --- Completion (antes do cdreplay) ---
autoload -Uz compinit
if ! compinit -C 2>/dev/null; then
  compinit -i
fi

# Reaplica compdefs gravados pelos plugins (agora compinit já rodou)
if typeset -f zinit >/dev/null 2>&1; then
  zinit cdreplay -q
fi

# --- Powerlevel10k (tema) ---
[[ -r "$HOME/.p10k.zsh" ]] && source "$HOME/.p10k.zsh"

# --- Keybindings ---
bindkey -e
bindkey '^f' autosuggest-accept
bindkey '^p' history-search-backward
bindkey '^n' history-search-forward

# --- Histórico ---
HISTSIZE=5000
SAVEHIST=$HISTSIZE
HISTFILE="$HOME/.zsh_history"
setopt appendhistory sharehistory hist_ignore_space hist_ignore_all_dups \
       hist_save_no_dups hist_ignore_dups hist_find_no_dups

# --- Estilos de completion ---
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' menu no
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls --color $realpath'
zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview 'ls --color $realpath'

# --- Integrações opcionais (só ativam se instaladas) ---

# fzf
if command -v fzf >/dev/null 2>&1; then
  eval "$(fzf --zsh)"
fi

# zoxide
if command -v zoxide >/dev/null 2>&1; then
  eval "$(zoxide init --cmd cd zsh)"
fi

# ls com ícones (exa/eza)
if command -v exa >/dev/null 2>&1; then
  alias ls="exa --icons"
elif command -v eza >/dev/null 2>&1; then
  alias ls="eza --icons"
fi

# Angular CLI completion (protegido contra erro)
if command -v ng >/dev/null 2>&1; then
  if ng completion script >/dev/null 2>&1; then
    source <(ng completion script)
  fi
fi

# --- Ajustes específicos por plataforma ---

if is_wsl; then
  # Aqui você pode colocar coisas específicas de WSL futuramente.
  :
fi

if is_macos; then
  # macOS: preferir GNU coreutils se instalados (opcional)
  for p in coreutils findutils gnu-tar gnu-sed gnu-which grep gawk; do
    if command -v brew >/dev/null 2>&1 && [[ -d "$(brew --prefix $p 2>/dev/null)/libexec/gnubin" ]]; then
      add_path "$(brew --prefix $p)/libexec/gnubin"
    fi
  done
fi

# opencode
export PATH=/home/romulo/.opencode/bin:$PATH
