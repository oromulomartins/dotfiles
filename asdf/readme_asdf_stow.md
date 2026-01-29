# [PT-BR]
# 📦 README - Gerenciamento de Dotfiles do ASDF com GNU Stow

Este documento descreve o fluxo recomendado para preparar, aplicar e
manter as configurações do ASDF utilizando GNU Stow, garantindo um
ambiente de desenvolvimento reproduzível, versionado e portátil entre
máquinas.

------------------------------------------------------------------------

## ✅ Pré-requisitos

-   Git\
-   asdf\
-   GNU Stow

``` bash
brew install stow
```

------------------------------------------------------------------------

## 📁 Estrutura esperada

    dotfiles/
     └─ asdf/
         ├─ .tool-versions
         ├─ .asdfrc            (opcional)
         ├─ plugins.txt        (opcional)
         └─ .stow-local-ignore

------------------------------------------------------------------------

## 1️⃣ Antes de rodar o stow

``` bash
git clone git@github.com:romulomartinspicpay/dotfiles.git ~/dotfiles
```

Verifique em \~/dotfiles/asdf:

-   .tool-versions\
-   .asdfrc (opcional)\
-   plugins.txt (opcional)

Gerar plugins:

``` bash
asdf plugin list --urls > plugins.txt
```

Criar arquivo ignore:

``` bash
touch ~/dotfiles/asdf/.stow-local-ignore
```

Conteúdo:

    .*\.md$

------------------------------------------------------------------------

## 2️⃣ Executando

``` bash
cd ~/dotfiles
stow asdf
```

Ou:

``` bash
stow --ignore='\.md$' asdf
```

------------------------------------------------------------------------

## 3️⃣ Depois

``` bash
source ~/.asdf/asdf.sh
source ~/.asdf/completions/asdf.bash
asdf install
asdf list
asdf reshim
source ~/.zshrc
```

------------------------------------------------------------------------

## 🔁 Manutenção

``` bash
xargs -L1 asdf plugin add < ~/dotfiles/asdf/plugins.txt
asdf install
```

------------------------------------------------------------------------

## 💡 Boas práticas

-   Manter .tool-versions e plugins.txt sincronizados
-   Não versionar shims

------------------------------------------------------------------------

# [EN-US]

# 📦 README - ASDF Dotfiles Management with GNU Stow

This document describes how to manage ASDF configuration using GNU Stow,
ensuring a reproducible and portable development environment.

------------------------------------------------------------------------

## ✅ Requirements

-   Git\
-   asdf\
-   GNU Stow

``` bash
brew install stow
```

------------------------------------------------------------------------

## 📁 Expected Structure

    dotfiles/
     └─ asdf/
         ├─ .tool-versions
         ├─ .asdfrc
         ├─ plugins.txt
         └─ .stow-local-ignore

------------------------------------------------------------------------

## 1️⃣ Before running stow

``` bash
git clone git@github.com:romulomartinspicpay/dotfiles.git ~/dotfiles
```

Generate plugin list:

``` bash
asdf plugin list --urls > plugins.txt
```

Ignore markdown files:

    .*\.md$

------------------------------------------------------------------------

## 2️⃣ Run stow

``` bash
cd ~/dotfiles
stow asdf
```

------------------------------------------------------------------------

## 3️⃣ After

``` bash
source ~/.asdf/asdf.sh
source ~/.asdf/completions/asdf.bash
asdf install
asdf list
asdf reshim
source ~/.zshrc
```

------------------------------------------------------------------------

## 🔁 Maintenance

``` bash
xargs -L1 asdf plugin add < ~/dotfiles/asdf/plugins.txt
asdf install
```

------------------------------------------------------------------------

## 💡 Best practices

-   Keep .tool-versions and plugins.txt in sync
-   Do not commit shims
