#!/usr/bin/env bash
# Sets up a new Mac: Nix, Home Manager and the dotfiles. It does not sign in to anything.
#
#   curl -fsSL https://raw.githubusercontent.com/mridang/dotfiles/master/install.sh | bash
#   curl -fsSL https://raw.githubusercontent.com/mridang/dotfiles/master/install.sh | bash -s -- --yes
#
# Options:
#   -y, --yes       Run without any prompts.
#   --dir PATH      Where to keep the dotfiles (default: ~/dotfiles, or $DOTFILES_DIR).
#   --repo SLUG     GitHub repository to clone (default: mridang/dotfiles, or $DOTFILES_REPO).
#
# For a private repository without a prompt, export GH_TOKEN before running.

set -euo pipefail

DOTFILES_DIR="${DOTFILES_DIR:-$HOME/dotfiles}"
DOTFILES_REPO="${DOTFILES_REPO:-mridang/dotfiles}"
ASSUME_YES=0

while [ $# -gt 0 ]; do
  case "$1" in
  -y | --yes) ASSUME_YES=1 ;;
  --dir)
    DOTFILES_DIR="$2"
    shift
    ;;
  --repo)
    DOTFILES_REPO="$2"
    shift
    ;;
  -h | --help)
    sed -n '2,14p' "$0"
    exit 0
    ;;
  *)
    echo "Unknown option: $1" >&2
    exit 2
    ;;
  esac
  shift
done

# When piped from curl, stdin is the script, so questions go through the terminal.
INTERACTIVE=0
if [ "$ASSUME_YES" -eq 0 ] && [ -r /dev/tty ] && [ -w /dev/tty ]; then
  INTERACTIVE=1
fi

say() { printf '\n==> %s\n' "$*"; }

confirm() {
  [ "$INTERACTIVE" -eq 1 ] || return 0
  local answer
  printf '%s [Y/n] ' "$1" >/dev/tty
  read -r answer </dev/tty || return 0
  case "$answer" in [nN]*) return 1 ;; *) return 0 ;; esac
}

load_nix() {
  local daemon=/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
  # shellcheck disable=SC1090
  [ -e "$daemon" ] && . "$daemon"
  export PATH="$HOME/.nix-profile/bin:/nix/var/nix/profiles/default/bin:$PATH"
}

[ "$(uname -s)" = "Darwin" ] || {
  echo "This installer is for macOS." >&2
  exit 1
}

echo "This will install Nix and Home Manager, clone $DOTFILES_REPO to $DOTFILES_DIR and apply it."
confirm "Continue?" || exit 0

say "Checking the command line tools"
if ! xcode-select -p >/dev/null 2>&1; then
  # Asking softwareupdate for the tools avoids the dialog that xcode-select --install opens.
  marker=/tmp/.com.apple.dt.CommandLineTools.installondemand.in-progress
  touch "$marker"
  label="$(softwareupdate -l 2>/dev/null | sed -n 's/.*Label: \(Command Line Tools.*\)/\1/p' | tail -1)"
  [ -n "$label" ] || {
    rm -f "$marker"
    echo "Could not find the command line tools to install." >&2
    exit 1
  }
  sudo softwareupdate -i "$label"
  rm -f "$marker"
fi

say "Installing Nix"
load_nix
if ! command -v nix >/dev/null 2>&1; then
  curl -fsSL https://nixos.org/nix/install | sh -s -- --daemon --yes
  load_nix
else
  echo "Nix is already installed."
fi

say "Fetching the dotfiles"
if [ -d "$DOTFILES_DIR/.git" ]; then
  echo "$DOTFILES_DIR already exists."
elif GIT_TERMINAL_PROMPT=0 git clone "https://github.com/$DOTFILES_REPO.git" "$DOTFILES_DIR" 2>/dev/null; then
  :
else
  echo "The repository is private; signing in to GitHub."
  if [ -z "${GH_TOKEN:-}" ] && [ "$INTERACTIVE" -eq 0 ]; then
    echo "Set GH_TOKEN to clone a private repository without prompts." >&2
    exit 1
  fi
  if [ -z "${GH_TOKEN:-}" ]; then
    nix --extra-experimental-features 'nix-command flakes' shell nixpkgs#gh -c \
      gh auth login --hostname github.com --git-protocol https --web </dev/tty >/dev/tty
  fi
  nix --extra-experimental-features 'nix-command flakes' shell nixpkgs#gh -c bash -c \
    "gh auth setup-git && gh repo clone '$DOTFILES_REPO' '$DOTFILES_DIR'"
fi

cd "$DOTFILES_DIR"

say "Adding the Nix channels"
make install-deps

say "Applying the configuration"
make apply
load_nix

say "Installing the global Devbox tools"
devbox global install

say "Installing the apps"
install-apps

say "Setup complete. Open a new terminal to pick up the new shell."
echo "Still to do by hand: ssh-keygen, gh auth login, gcloud auth login, aws configure sso, docker login, atuin login."
