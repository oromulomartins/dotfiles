# git-multi-pull

Local automation for updating multiple Git repositories under a base directory through one reusable command.

## Requirements

- bash
- git
- find
- sed
- openssh (`ssh-agent`, `ssh-add`)
- make

## Installed layout

- `~/.local/share/automation/git-multi-pull/Makefile`
- `~/.local/share/automation/git-multi-pull/scripts/git-pull-all.sh`
- `~/.local/bin/git-pull-all`

## How it works

The automation:

- searches for Git repositories under a chosen base directory
- skips repositories with detached HEAD
- skips branches without upstream
- skips repositories with local changes
- optionally runs `git fetch --all --prune`
- runs `git pull --ff-only`
- prints a final summary

It reuses the current `ssh-agent` when one is already available. If no key is loaded, you can provide one with `SSH_KEY=/path/to/key`.

## Usage

Run against the current directory:

```bash
git-pull-all
```

Run against a specific directory:

```bash
git-pull-all pull-all ~/workspace
```

Simulate without changing repositories:

```bash
git-pull-all dry-run ~/workspace
```

Pass optional overrides through environment variables:

```bash
SSH_KEY=~/.ssh/id_ed25519 MAX_DEPTH=6 git-pull-all pull-all ~/workspace
```

Use the Makefile directly:

```bash
make -C ~/.local/share/automation/git-multi-pull pull-all BASE_DIR=~/workspace
```

Override the SSH key when needed:

```bash
make -C ~/.local/share/automation/git-multi-pull pull-all \
  BASE_DIR=~/workspace \
  SSH_KEY=~/.ssh/id_ed25519
```
