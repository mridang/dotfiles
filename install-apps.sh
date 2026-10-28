# Installs the macOS apps in apps.txt by Homebrew cask name, without Homebrew.
# It prefers the vendor's PKG, falls back to the cask's DMG or ZIP, verifies signatures and
# leaves apps that are already installed alone, since they update themselves.
#
#   install-apps            Install what is missing; exits non-zero if any app fails.
#   install-apps --check    Verify every app is installed and validly signed.

list="${INSTALL_APPS_LIST:-${DOTFILES}/apps.txt}"
check_only=0
[ "${1:-}" = "--check" ] && check_only=1

work="$(mktemp -d)"
mnt="$work/mnt"
results="$work/results"
: >"$results"
cleanup() {
  hdiutil detach "$mnt" -quiet 2>/dev/null || true
  rm -rf "$work"
}
trap cleanup EXIT

say() { printf '\n==> %s\n' "$*"; }
record() { printf '%s\t%s\n' "$1" "$2" >>"$results"; }

is_pkg() { [ "$(curl -fsSL -m 30 -r 0-3 "$1" 2>/dev/null | head -c 4)" = "xar!" ]; }

download() { curl -fL --retry 3 --retry-delay 5 -o "$2" "$1"; }

verify_sha() {
  [ "$2" = "no_check" ] || [ "$(shasum -a 256 "$1" | cut -d' ' -f1)" = "$2" ]
}

install_pkg() {
  pkgutil --check-signature "$1" | grep -q 'Status: signed'
  sudo installer -pkg "$1" -target /
}

install_app() {
  local file="$1" kind="$2" app="$3" src
  case "$kind" in
  dmg)
    mkdir -p "$mnt"
    hdiutil attach -nobrowse -readonly -quiet -mountpoint "$mnt" "$file"
    src="$mnt/$app"
    ;;
  zip)
    mkdir -p "$work/unzip"
    ditto -x -k "$file" "$work/unzip"
    src="$work/unzip/$app"
    ;;
  *)
    echo "Unknown format: $kind" >&2
    return 1
    ;;
  esac
  [ -d "$src" ] || {
    echo "$app is not in the download" >&2
    return 1
  }
  ditto "$src" "/Applications/$app"
  hdiutil detach "$mnt" -quiet 2>/dev/null || true
}

signed() { spctl --assess --type execute "/Applications/$1" 2>/dev/null; }

# Runs in its own subshell with errexit on, so any failed step stops that app only.
install_one() {
  local token="$1" override="$2" json app cask_url sha has_pkg pkg_url="" candidate ext file
  json="$(curl -fsS "https://formulae.brew.sh/api/cask/$token.json")"
  app="$(jq -r '[.artifacts[]? | select(type == "object" and has("app")) | .app[]? | strings][0] // empty' <<<"$json")"
  [ -n "$app" ] || app="$(jq -r '.name[0]' <<<"$json").app"
  cask_url="$(jq -r '.url' <<<"$json")"
  sha="$(jq -r '.sha256' <<<"$json")"
  has_pkg="$(jq -r '[.artifacts[]? | select(type == "object" and has("pkg"))] | length' <<<"$json")"

  if [ "$check_only" -eq 1 ]; then
    if signed "$app"; then record ok "$token"; else record failed "$token: $app is missing or not validly signed"; fi
    return 0
  fi

  if [ -d "/Applications/$app" ]; then
    echo "$app is already installed"
    record present "$token"
    return 0
  fi

  if [ -n "$override" ]; then
    pkg_url="$override"
  elif [ "$has_pkg" -gt 0 ]; then
    pkg_url="$cask_url"
  else
    candidate="${cask_url%.dmg}.pkg"
    if [ "$candidate" != "$cask_url" ] && is_pkg "$candidate"; then pkg_url="$candidate"; fi
  fi

  if [ -n "$pkg_url" ]; then
    is_pkg "$pkg_url" || {
      echo "$pkg_url is not a PKG" >&2
      return 1
    }
    file="$work/$token.pkg"
    echo "Installing $app from its PKG"
    download "$pkg_url" "$file"
    if [ "$pkg_url" = "$cask_url" ]; then verify_sha "$file" "$sha"; fi
    install_pkg "$file"
  else
    ext="${cask_url%%\?*}"
    ext="${ext##*.}"
    file="$work/$token.$ext"
    echo "Installing $app from its $ext"
    download "$cask_url" "$file"
    verify_sha "$file" "$sha"
    install_app "$file" "$ext" "$app"
  fi

  rm -f "$file"
  if [ -d "/Applications/$app" ] && signed "$app"; then
    record installed "$token"
  else
    echo "$app did not install or is not validly signed" >&2
    return 1
  fi
}

if [ "$check_only" -eq 0 ]; then
  sudo -n true 2>/dev/null || sudo -v
  # Keep the sudo ticket alive while large downloads run.
  while kill -0 "$$" 2>/dev/null; do
    sudo -n true
    sleep 50
  done 2>/dev/null &
fi

while read -r token extra || [ -n "$token" ]; do
  case "$token" in "" | \#*) continue ;; esac
  say "$token"
  override="${extra#pkg=}"
  [ "$override" != "$extra" ] || override=""
  set +e
  (
    set -e
    install_one "$token" "$override"
  )
  rc=$?
  set -e
  [ "$rc" -eq 0 ] || record failed "$token: the install failed (exit $rc)"
done <"$list"

count() { { grep -c "^$1	" "$results" || true; } | head -1; }

say "Summary"
echo "Installed now: $(count installed)"
echo "Already installed: $(count present)"
echo "Verified: $(count ok)"
echo "Failed: $(count failed)"
if [ "$(count failed)" != "0" ]; then
  grep "^failed	" "$results" | cut -f2- | sed 's/^/  /'
  exit 1
fi
