#!/usr/bin/env bash
set -uo pipefail

BASE_DIR="${BASE_DIR:-.}"
SSH_KEY="${SSH_KEY:-}"
MAX_DEPTH="${MAX_DEPTH:-10}"
DRY_RUN="${DRY_RUN:-false}"
FETCH_FIRST="${FETCH_FIRST:-true}"
INCLUDE_HIDDEN="${INCLUDE_HIDDEN:-false}"

TOTAL_REPOS=0
UPDATED_REPOS=0
SKIPPED_REPOS=0
FAILED_REPOS=0

UPDATED_LIST=()
SKIPPED_LIST=()
FAILED_LIST=()

if [ -t 1 ]; then
  RED='\033[0;31m'
  GREEN='\033[0;32m'
  YELLOW='\033[1;33m'
  BLUE='\033[0;34m'
  NC='\033[0m'
else
  RED=''
  GREEN=''
  YELLOW=''
  BLUE=''
  NC=''
fi

log_info() {
  printf "%b[INFO]%b %s\n" "$BLUE" "$NC" "$*"
}

log_warn() {
  printf "%b[WARN]%b %s\n" "$YELLOW" "$NC" "$*"
}

log_error() {
  printf "%b[ERROR]%b %s\n" "$RED" "$NC" "$*" >&2
}

log_success() {
  printf "%b[OK]%b %s\n" "$GREEN" "$NC" "$*"
}

usage() {
  cat <<'EOF'
Usage:
  git-pull-all.sh [options]

Options:
  --base-dir DIR         Base directory to search (default: .)
  --ssh-key PATH         SSH key to add when no key is loaded
  --max-depth N          Maximum directory depth to search (default: 10)
  --dry-run              Print what would be updated without running git pull
  --no-fetch             Skip git fetch --all --prune before pull
  --include-hidden       Include hidden directories in the search
  -h, --help             Show this help message
EOF
}

ensure_dependencies() {
  command -v git >/dev/null 2>&1 || {
    log_error 'git was not found in PATH.'
    exit 1
  }

  command -v find >/dev/null 2>&1 || {
    log_error 'find was not found in PATH.'
    exit 1
  }

  command -v sed >/dev/null 2>&1 || {
    log_error 'sed was not found in PATH.'
    exit 1
  }

  command -v ssh-add >/dev/null 2>&1 || {
    log_error 'ssh-add was not found in PATH.'
    exit 1
  }
}

ensure_ssh_agent() {
  if [ -n "${SSH_AUTH_SOCK:-}" ]; then
    return 0
  fi

  command -v ssh-agent >/dev/null 2>&1 || {
    log_error 'ssh-agent was not found in PATH.'
    exit 1
  }

  log_info 'ssh-agent not detected. Starting a temporary agent for this run.'
  eval "$(ssh-agent -s)" >/dev/null
}

ensure_ssh_key_loaded() {
  local status

  ssh-add -l >/dev/null 2>&1
  status=$?

  if [ "$status" -eq 0 ]; then
    log_info 'Using key(s) already loaded in ssh-agent.'
    return 0
  fi

  if [ "$status" -ne 1 ]; then
    log_error 'Unable to inspect keys loaded in ssh-agent.'
    exit 1
  fi

  if [ -z "$SSH_KEY" ]; then
    log_error 'No SSH key is loaded. Load one in ssh-agent first or set SSH_KEY=/path/to/key.'
    exit 1
  fi

  if [ ! -f "$SSH_KEY" ]; then
    log_error "SSH_KEY does not exist: $SSH_KEY"
    exit 1
  fi

  log_info "No key loaded in ssh-agent. Adding SSH key: $SSH_KEY"
  ssh-add "$SSH_KEY"
}

is_git_repo() {
  local dir="$1"
  git -C "$dir" rev-parse --is-inside-work-tree >/dev/null 2>&1
}

has_local_changes() {
  local dir="$1"
  ! git -C "$dir" diff --quiet || ! git -C "$dir" diff --cached --quiet
}

current_branch() {
  local dir="$1"
  git -C "$dir" branch --show-current 2>/dev/null
}

has_upstream() {
  local dir="$1"
  git -C "$dir" rev-parse --abbrev-ref --symbolic-full-name '@{u}' >/dev/null 2>&1
}

discover_repos() {
  if [ "$INCLUDE_HIDDEN" = 'true' ]; then
    find "$BASE_DIR" -maxdepth "$MAX_DEPTH" -type d -name '.git' 2>/dev/null | sed 's|/\.git$||' | sort
  else
    find "$BASE_DIR" -maxdepth "$MAX_DEPTH" -type d -name '.git' -not -path '*/.*/*' 2>/dev/null | sed 's|/\.git$||' | sort
  fi
}

print_summary() {
  printf '\n========================= SUMMARY =========================\n'
  printf 'Total found:   %s\n' "$TOTAL_REPOS"
  printf 'Updated:       %s\n' "$UPDATED_REPOS"
  printf 'Skipped:       %s\n' "$SKIPPED_REPOS"
  printf 'Failed:        %s\n' "$FAILED_REPOS"

  if [ "${#UPDATED_LIST[@]}" -gt 0 ]; then
    printf '\nUpdated:\n'
    for item in "${UPDATED_LIST[@]}"; do
      printf '  - %s\n' "$item"
    done
  fi

  if [ "${#SKIPPED_LIST[@]}" -gt 0 ]; then
    printf '\nSkipped:\n'
    for item in "${SKIPPED_LIST[@]}"; do
      printf '  - %s\n' "$item"
    done
  fi

  if [ "${#FAILED_LIST[@]}" -gt 0 ]; then
    printf '\nFailed:\n'
    for item in "${FAILED_LIST[@]}"; do
      printf '  - %s\n' "$item"
    done
  fi

  printf '==========================================================\n'
}

pull_repo() {
  local repo="$1"
  local branch output rc=0

  TOTAL_REPOS=$((TOTAL_REPOS + 1))

  printf '\n==========================================================\n'
  printf 'Repository: %s\n' "$repo"

  branch="$(current_branch "$repo")"

  if [ -z "$branch" ]; then
    log_warn 'No active branch detected (detached HEAD). Skipping.'
    SKIPPED_REPOS=$((SKIPPED_REPOS + 1))
    SKIPPED_LIST+=("$repo | detached HEAD")
    return 0
  fi

  log_info "Current branch: $branch"

  if ! has_upstream "$repo"; then
    log_warn 'Branch has no upstream configured. Skipping.'
    SKIPPED_REPOS=$((SKIPPED_REPOS + 1))
    SKIPPED_LIST+=("$repo | no upstream")
    return 0
  fi

  if has_local_changes "$repo"; then
    log_warn 'Local changes detected. Skipping.'
    SKIPPED_REPOS=$((SKIPPED_REPOS + 1))
    SKIPPED_LIST+=("$repo | local changes")
    return 0
  fi

  if [ "$DRY_RUN" = 'true' ]; then
    log_info "[dry-run] Would update: $repo"
    SKIPPED_REPOS=$((SKIPPED_REPOS + 1))
    SKIPPED_LIST+=("$repo | dry-run")
    return 0
  fi

  if [ "$FETCH_FIRST" = 'true' ]; then
    log_info 'Running git fetch --all --prune...'
    if ! git -C "$repo" fetch --all --prune; then
      log_error 'git fetch failed.'
      FAILED_REPOS=$((FAILED_REPOS + 1))
      FAILED_LIST+=("$repo | fetch failed")
      return 1
    fi
  fi

  log_info 'Running git pull --ff-only...'
  output="$(git -C "$repo" pull --ff-only 2>&1)" || rc=$?

  if [ "$rc" -ne 0 ]; then
    log_error 'git pull failed.'
    printf '%s\n' "$output"
    FAILED_REPOS=$((FAILED_REPOS + 1))
    FAILED_LIST+=("$repo | pull failed")
    return 1
  fi

  printf '%s\n' "$output"

  if printf '%s' "$output" | grep -Eqi 'Already up to date'; then
    log_success 'Repository already up to date.'
    SKIPPED_REPOS=$((SKIPPED_REPOS + 1))
    SKIPPED_LIST+=("$repo | already up to date")
  else
    log_success 'Repository updated successfully.'
    UPDATED_REPOS=$((UPDATED_REPOS + 1))
    UPDATED_LIST+=("$repo")
  fi
}

while [ $# -gt 0 ]; do
  case "$1" in
    --base-dir)
      BASE_DIR="$2"
      shift 2
      ;;
    --ssh-key)
      SSH_KEY="$2"
      shift 2
      ;;
    --max-depth)
      MAX_DEPTH="$2"
      shift 2
      ;;
    --dry-run)
      DRY_RUN='true'
      shift
      ;;
    --no-fetch)
      FETCH_FIRST='false'
      shift
      ;;
    --include-hidden)
      INCLUDE_HIDDEN='true'
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      log_error "Invalid argument: $1"
      usage
      exit 1
      ;;
  esac
done

if [ ! -d "$BASE_DIR" ]; then
  log_error "Base directory does not exist: $BASE_DIR"
  exit 1
fi

ensure_dependencies

if [ "$DRY_RUN" != 'true' ]; then
  ensure_ssh_agent
  ensure_ssh_key_loaded
fi

log_info "Searching for Git repositories in: $BASE_DIR"
mapfile -t REPOS < <(discover_repos)

if [ "${#REPOS[@]}" -eq 0 ]; then
  log_warn 'No Git repositories found.'
  exit 0
fi

for repo in "${REPOS[@]}"; do
  if is_git_repo "$repo"; then
    pull_repo "$repo"
  fi
done

print_summary

if [ "$FAILED_REPOS" -gt 0 ]; then
  exit 2
fi

exit 0

