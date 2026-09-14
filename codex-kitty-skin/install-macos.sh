#!/bin/bash
set -euo pipefail
umask 077
KITTY_ROOT="$(cd "$(dirname "$0")" && pwd -P)"
MODE="${1:---check}"
case "$MODE" in --check|--install) ;; *) echo 'Usage: bash install-macos.sh [--check|--install] [--accept-local-debugging] [--with-pet]'; exit 2;; esac
shift "$(( $# > 0 ? 1 : 0 ))"
ACCEPT=false; PET=false
for arg in "$@"; do
 case "$arg" in --accept-local-debugging) ACCEPT=true;; --with-pet) PET=true;; *) echo "Unknown argument: $arg"; exit 2;; esac
done
[ "$(uname -s)" = Darwin ] || { echo 'macOS only.'; exit 1; }
ACTUAL="$(/usr/bin/shasum -a 256 "$KITTY_ROOT/payload.zip" | /usr/bin/awk '{print $1}')"
[ "$ACTUAL" = 1f11307b939a9317f0fec2129b56720104ba360d61b2fcfa6e5df10702caa976 ] || { echo 'Payload checksum mismatch; download the complete repository again.'; exit 1; }
KITTY_TMP="$(mktemp -d "${TMPDIR:-/tmp}/kitty-install.XXXXXX")"
trap '/bin/rm -rf "$KITTY_TMP"' EXIT
/usr/bin/ditto -x -k "$KITTY_ROOT/payload.zip" "$KITTY_TMP"
chmod 700 "$KITTY_TMP/engine/scripts/"*.sh
. "$KITTY_TMP/engine/scripts/common-macos.sh"
discover_codex_app
require_macos_runtime
printf 'Verified official Codex %s. Reference version: 26.908.40834.\n' "$CODEX_VERSION"
if [ "$MODE" = --check ]; then
 echo 'Package and signed runtime checks passed. No skin was installed.'
 [ ! -e "$INSTALL_ROOT" ] || echo 'Existing skin engine found: automatic install will stop; ask your AI to review migration.'
 exit 0
fi
[ "$ACCEPT" = true ] || { echo 'This uses localhost debugging port 9341. Local processes can access the debugging session. Review AI_INSTALL.md, then pass --accept-local-debugging if you agree.'; exit 1; }
codex_is_running && { echo 'Save work and fully quit Codex. Run this installer from a separate Terminal.'; exit 1; }
# First-release installer deliberately does not overwrite existing engines or theme libraries.
for item in "$INSTALL_ROOT" "$STATE_ROOT"; do
 [ ! -e "$item" ] && [ ! -L "$item" ] || { echo "Existing installation found: $item. Stop for reviewed migration; do not delete it."; exit 1; }
done
[ -f "$CONFIG_PATH" ] && [ ! -L "$CONFIG_PATH" ] || { echo 'Launch official Codex once, quit it, then retry. Config must be a regular file.'; exit 1; }
if [ "$PET" = true ]; then
 [ ! -e "$HOME/.codex/pets/hello-kitty-cream" ] && [ ! -L "$HOME/.codex/pets/hello-kitty-cream" ] || { echo 'Kitty pet already exists; rerun without --with-pet.'; exit 1; }
fi
KITTY_BACKUP="$(mktemp -d "$HOME/.codex/kitty-config-backup.XXXXXX")"
cp -p "$CONFIG_PATH" "$KITTY_BACKUP/config.toml"
echo "Original config backup: $KITTY_BACKUP/config.toml"
"$KITTY_TMP/engine/scripts/import-theme-zip-macos.sh" --file "$KITTY_TMP/kitty-theme.zip" --expected-sha256 dafb69b0b49c1d6f98fcf2e380a3f2e7df54cb26554764ad024f17d3fba1727f --expected-bytes 2162396
"$KITTY_TMP/engine/scripts/switch-theme-macos.sh" --id strawberry-cream-kitty --no-apply
"$KITTY_TMP/engine/scripts/install-dream-skin-macos.sh" --no-launch --no-launchers
if [ "$PET" = true ]; then
 mkdir -p "$HOME/.codex/pets"
 cp -R "$KITTY_TMP/pet" "$HOME/.codex/pets/hello-kitty-cream"
 echo 'Pet copied. Select 奶油粉 Kitty in Codex pet settings.'
fi
"$INSTALL_ROOT/scripts/start-dream-skin-macos.sh" --prompt-restart
"$INSTALL_ROOT/scripts/doctor-macos.sh" --require-live
echo 'Live check passed. Confirm the pink theme visually. Use Open Kitty.command for future launches.'
