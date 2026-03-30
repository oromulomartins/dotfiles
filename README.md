# [PT-BR]
# Dotfiles

Repositorio contendo meus dotfiles para provisionar rapidamente um
ambiente de desenvolvimento consistente, reproduzivel e versionado.

------------------------------------------------------------------------

## Estrutura do Repositorio

    dotfiles/
    ├── alacritty/
    │   └── .config/alacritty/
    ├── asdf/
    │   ├── .tool-versions
    │   ├── .asdfrc
    │   └── plugins.txt
    ├── automation/
    │   └── .local/share/automation/
    │       └── git-multi-pull/
    ├── bin/
    │   └── .local/bin/
    │       └── git-pull-all
    ├── lvim/
    │   └── .config/lvim/
    ├── p10k/
    │   └── .p10k.zsh
    ├── tmux/
    │   └── .tmux.config
    ├── zsh/
    │   ├── .zprofile
    │   ├── .zshenv
    │   └── .zshrc
    └── README.md

------------------------------------------------------------------------

## Pre-requisitos

Instale previamente:

- Git
- GNU Stow (`brew install stow`)
- Alacritty
- asdf
- LunarVim
- Powerlevel10k
- tmux
- Zsh
- make
- OpenSSH

------------------------------------------------------------------------

## Instalacao

### 1. Clonar repositorio

```bash
git clone https://github.com/oromulomartins/dotfiles.git ~/dotfiles
cd ~/dotfiles
```

### 2. Aplicar links simbolicos

```bash
stow alacritty asdf automation bin lvim p10k tmux zsh
```

Ou ignorando Markdown:

```bash
stow --ignore='\.md$' alacritty asdf automation bin lvim p10k tmux zsh
```

### 3. Instalar plugins e versoes do ASDF

```bash
xargs -L1 asdf plugin add < asdf/plugins.txt
asdf install
```

### 4. Recarregar shell

```bash
exec $SHELL
```

------------------------------------------------------------------------

## Pacotes

- **alacritty** -> Configuracao do terminal
- **asdf** -> Versoes de linguagens
- **automation** -> Automacoes locais versionadas
- **bin** -> Comandos globais em `~/.local/bin`
- **lvim** -> Configuracoes do LunarVim
- **p10k** -> Tema Powerlevel10k
- **tmux** -> Multiplexador
- **zsh** -> Shell

------------------------------------------------------------------------

## Exemplo rapido

```bash
git-pull-all dry-run ~/workspace
```

------------------------------------------------------------------------

## Boas praticas

- Manter `.tool-versions` atualizado
- Nao versionar binarios
- Commits pequenos

------------------------------------------------------------------------

# [EN-US]
# Dotfiles

Repository containing my dotfiles to quickly provision a consistent,
reproducible, and versioned development environment.

------------------------------------------------------------------------

## Repository Structure

    dotfiles/
    ├── alacritty/
    │   └── .config/alacritty/
    ├── asdf/
    │   ├── .tool-versions
    │   ├── .asdfrc
    │   └── plugins.txt
    ├── automation/
    │   └── .local/share/automation/
    │       └── git-multi-pull/
    ├── bin/
    │   └── .local/bin/
    │       └── git-pull-all
    ├── lvim/
    │   └── .config/lvim/
    ├── p10k/
    │   └── .p10k.zsh
    ├── tmux/
    │   └── .tmux.config
    ├── zsh/
    │   ├── .zprofile
    │   ├── .zshenv
    │   └── .zshrc
    └── README.md

------------------------------------------------------------------------

## Requirements

- Git
- GNU Stow
- Alacritty
- asdf
- LunarVim
- Powerlevel10k
- tmux
- Zsh
- make
- OpenSSH

------------------------------------------------------------------------

## Installation

```bash
git clone https://github.com/oromulomartins/dotfiles.git ~/dotfiles
cd ~/dotfiles
stow alacritty asdf automation bin lvim p10k tmux zsh
xargs -L1 asdf plugin add < asdf/plugins.txt
asdf install
exec $SHELL
```

------------------------------------------------------------------------

## Packages

- alacritty -> Terminal config
- asdf -> Language versions
- automation -> Versioned local automations
- bin -> Global commands in `~/.local/bin`
- lvim -> LunarVim config
- p10k -> Theme
- tmux -> Multiplexer
- zsh -> Shell

------------------------------------------------------------------------

## Quick example

```bash
git-pull-all pull-all ~/workspace
```

------------------------------------------------------------------------

## License

MIT
