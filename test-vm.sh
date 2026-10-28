#!/usr/bin/env bash
# Proves a clean Mac can be set up from this repository: boots a throwaway macOS VM with
# Tart, runs install.sh --yes in it over SSH and checks the result. No screen is needed.
#
#   make test-vm              Run once and delete the VM afterwards.
#   ./test-vm.sh --keep       Leave the VM running for a look around (admin / admin).
#
# Needs Apple Silicon and about 60 GB of free disk space. The first run downloads a ~20 GB
# image into $TART_HOME (default: a temporary directory, so nothing lands in your home folder).

set -euo pipefail

IMAGE="${TEST_VM_IMAGE:-ghcr.io/cirruslabs/macos-sequoia-vanilla:latest}"
VM="dotfiles-test-$$"
KEEP=0
[ "${1:-}" = "--keep" ] && KEEP=1

if ! command -v tart >/dev/null 2>&1 || ! command -v sshpass >/dev/null 2>&1; then
  command -v nix-shell >/dev/null 2>&1 || {
    echo "Install Nix first (make prepare)." >&2
    exit 1
  }
  # Tart is source-available rather than free software, so allow it for this shell only.
  NIXPKGS_ALLOW_UNFREE=1 exec nix-shell --impure -p tart sshpass --run "$(printf '%q ' "$0" "$@")"
fi

[ "$(uname -m)" = "arm64" ] || {
  echo "Tart needs an Apple Silicon Mac." >&2
  exit 1
}

export TART_HOME="${TART_HOME:-${TMPDIR:-/tmp}/dotfiles-tart}"
REPO="$(cd "$(dirname "$0")" && pwd)"
WORK="$(mktemp -d)"
IP=""

say() { printf '\n==> %s\n' "$*"; }

cleanup() {
  if [ "$KEEP" -eq 1 ]; then
    echo "Keeping $VM (ssh admin@$IP, password admin). Remove it with: tart delete $VM"
    return
  fi
  tart stop "$VM" >/dev/null 2>&1 || true
  tart delete "$VM" >/dev/null 2>&1 || true
  rm -rf "$WORK"
}
trap cleanup EXIT

# The image's public admin account; SSH keys in the agent are skipped to avoid lockouts.
ssh_opts=(-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o LogLevel=ERROR
  -o PubkeyAuthentication=no -o PreferredAuthentications=password)
vm() { sshpass -p admin ssh "${ssh_opts[@]}" "admin@$IP" "$@"; }
vmtty() { sshpass -p admin ssh -tt "${ssh_opts[@]}" "admin@$IP" "$@"; }

say "Preparing the VM"
tart pull "$IMAGE"
tart clone "$IMAGE" "$VM"
tart run --no-graphics "$VM" >"$WORK/vm.log" 2>&1 &
# The address can be stale right after boot, so look it up again on every try.
for _ in $(seq 1 60); do
  IP="$(tart ip "$VM" --wait 10 2>/dev/null || true)"
  [ -n "$IP" ] && vm true 2>/dev/null && break
  sleep 5
done
vm true

# Right after boot, logins are sometimes refused for a short while, so retry a few times.
retry() {
  local tries=0
  until "$@"; do
    tries=$((tries + 1))
    [ "$tries" -lt 6 ] || return 1
    sleep 10
  done
}

# For commands that are safe to repeat: try again when ssh itself fails (exit 255), as the
# VM's login sometimes flakes under load, but report a real failure of the command at once.
vmr() {
  local rc tries=0
  while :; do
    vm "$@" </dev/null && return 0
    rc=$?
    { [ "$rc" -eq 255 ] && [ "$tries" -lt 5 ]; } || return "$rc"
    tries=$((tries + 1))
    sleep 10
  done
}

say "Copying the committed repository (no history, no credentials)"
git clone -q --depth 1 "file://$REPO" "$WORK/dotfiles"
copy_repo() { tar -C "$WORK/dotfiles" -cf - . | vm 'mkdir -p dotfiles && tar -C dotfiles -xf -'; }
retry copy_repo

say "Running the installer (apps are installed one at a time below)"
vm 'cd ~/dotfiles && INSTALL_APPS_LIST=/dev/null ./install.sh --yes'

# The image's disk cannot hold every app at once, so each app is installed, verified and
# removed before the next one. Every app in apps.txt still has to install and pass Gatekeeper.
say "Installing and verifying each app"
app_failures=0
while read -r token extra || [ -n "$token" ]; do
  case "$token" in "" | \#*) continue ;; esac
  echo "-- $token"
  # ssh would otherwise read the rest of apps.txt from the loop's stdin.
  vmr "echo '$token $extra' > ~/one.txt"
  vmr 'ls /Applications | sort > ~/before.txt'
  if ! vmr 'export PATH="$HOME/.nix-profile/bin:$PATH" INSTALL_APPS_LIST=$HOME/one.txt; install-apps && install-apps --check'; then
    echo "FAIL: $token did not install and verify"
    app_failures=$((app_failures + 1))
  fi
  vmr 'ls /Applications | sort | comm -13 ~/before.txt - | while read -r a; do sudo rm -rf "/Applications/$a"; done'
done <"$REPO/apps.txt"

say "Checking the result in a login shell"
vm 'cat > ~/check.sh' <<'EOF'
fail=0
bad() { echo "FAIL: $*"; fail=1; }
for t in home-manager starship atuin zoxide fzf direnv lsd bat delta micro jq fd devbox \
  gh node claude aws gcloud cloudflared git; do
  command -v "$t" >/dev/null 2>&1 || bad "$t is not on the PATH"
done
[ -n "$XDG_CONFIG_HOME" ] || bad "XDG_CONFIG_HOME is not set"
starship prompt 2>/dev/null | grep -q "$(printf '\033')" || bad "the prompt has no colour codes"
[ "$(npm config get @zitadel:registry 2>/dev/null)" = "https://registry.npmjs.org/" ] || bad "npm cannot read ~/.npmrc"
[ -L ~/.local/share/devbox/global/default/devbox.json ] || bad "the global devbox.json is not linked"
noise="$(zsh -l -i -c true 2>&1 </dev/null | grep -iE 'warning|error|not found' || true)"
[ -z "$noise" ] || bad "a new shell prints: $noise"
[ "$fail" -eq 0 ] && echo CHECKS_PASSED
EOF
result="$(vmtty 'zsh -l -i -c "source ~/check.sh" </dev/null' | tr -d '\r')"
echo "$result" | grep -E 'FAIL|CHECKS_PASSED' || true

if [ "$app_failures" -eq 0 ] && echo "$result" | grep -q CHECKS_PASSED && ! echo "$result" | grep -q FAIL; then
  say "PASS: a clean Mac was set up from this repository"
else
  say "FAIL"
  exit 1
fi
