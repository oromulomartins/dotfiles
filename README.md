# [PT-BR]
# 🏠 Dotfiles

Repositório contendo meus dotfiles para provisionar rapidamente um
ambiente de desenvolvimento consistente, reproduzível e versionado.

------------------------------------------------------------------------

## 📁 Estrutura do Repositório

    dotfiles/
    ├── alacritty/
    │   └── .config/alacritty/
    ├── asdf/
    │   ├── .tool-versions
    │   ├── .asdfrc
    │   └── plugins.txt
    ├── lvim/
    │   └── .config/lvim/
    ├── p10k/
    │   └── .p10k.zsh
    ├── tmux/
    │   └── .tmux.conf
    ├── zsh/
    │   ├── .zshrc
    │   └── .zshenv
    └── README.md

------------------------------------------------------------------------

## ✅ Pré-requisitos

Instale previamente:

-   Git\
-   GNU Stow (`brew install stow`)\
-   Alacritty\
-   asdf\
-   LunarVim\
-   Powerlevel10k\
-   tmux\
-   Zsh

------------------------------------------------------------------------

## 🚀 Instalação

### 1. Clonar repositório

``` bash
git clone https://github.com/romulomartinspicpay/dotfiles.git ~/dotfiles
cd ~/dotfiles
```

### 2. Aplicar links simbólicos

``` bash
stow alacritty asdf lvim p10k tmux zsh
```

Ou ignorando Markdown:

``` bash
stow --ignore='\.md$' alacritty asdf lvim p10k tmux zsh
```

### 3. Instalar plugins e versões do ASDF

``` bash
xargs -L1 asdf plugin add < asdf/plugins.txt
asdf install
```

### 4. Recarregar shell

``` bash
exec $SHELL
```

------------------------------------------------------------------------

## 📦 Pacotes

-   **alacritty** → Configuração do terminal\
-   **asdf** → Versões de linguagens\
-   **lvim** → Configurações do LunarVim\
-   **p10k** → Tema Powerlevel10k\
-   **tmux** → Multiplexador\
-   **zsh** → Shell

------------------------------------------------------------------------

## 💡 Boas práticas

-   Manter `.tool-versions` atualizado\
-   Não versionar binários\
-   Commits pequenos

------------------------------------------------------------------------


# [EN-US]
# 🏠 Dotfiles

Repository containing my dotfiles to quickly provision a consistent,
reproducible, and versioned development environment.

------------------------------------------------------------------------

## 📁 Repository Structure

    dotfiles/
    ├── alacritty/
    ├── asdf/
    ├── lvim/
    ├── p10k/
    ├── tmux/
    ├── zsh/
    └── README.md

------------------------------------------------------------------------

## ✅ Requirements

-   Git\
-   GNU Stow\
-   Alacritty\
-   asdf\
-   LunarVim\
-   Powerlevel10k\
-   tmux\
-   Zsh

------------------------------------------------------------------------

## 🚀 Installation

``` bash
git clone https://github.com/romulomartinspicpay/dotfiles.git ~/dotfiles
cd ~/dotfiles
stow alacritty asdf lvim p10k tmux zsh
xargs -L1 asdf plugin add < asdf/plugins.txt
asdf install
exec $SHELL
```

------------------------------------------------------------------------

## 📦 Packages

-   alacritty → Terminal config\
-   asdf → Language versions\
-   lvim → LunarVim config\
-   p10k → Theme\
-   tmux → Multiplexer\
-   zsh → Shell

------------------------------------------------------------------------

## 📄 License

MIT
