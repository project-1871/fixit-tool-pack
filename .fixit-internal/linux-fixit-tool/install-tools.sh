#!/usr/bin/env bash
# Installs the free diagnostic/repair tools listed in tools.json.
# Part of the linux-fixit-tool kit.
#
# Detects the distro's package manager, installs every "pkg" entry using the
# field that matches it, and prints the "manual" entries (mostly bootable-ISO
# tools that can't be installed onto the OS they're meant to rescue) with
# their download URLs at the end.

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MANIFEST="$SCRIPT_DIR/tools.json"

if [ ! -f "$MANIFEST" ]; then
    echo "ERROR: tools.json not found next to this script." >&2
    exit 1
fi

# --- detect package manager ---
if command -v apt-get >/dev/null 2>&1; then
    PM="apt"; PKG_FIELD="pkgApt"
    INSTALL_CMD="sudo apt-get install -y"
    UPDATE_CMD="sudo apt-get update"
elif command -v dnf >/dev/null 2>&1; then
    PM="dnf"; PKG_FIELD="pkgDnf"
    INSTALL_CMD="sudo dnf install -y"
    UPDATE_CMD=""
elif command -v pacman >/dev/null 2>&1; then
    PM="pacman"; PKG_FIELD="pkgPacman"
    INSTALL_CMD="sudo pacman -S --noconfirm --needed"
    UPDATE_CMD=""
elif command -v zypper >/dev/null 2>&1; then
    PM="zypper"; PKG_FIELD="pkgZypper"
    INSTALL_CMD="sudo zypper install -y"
    UPDATE_CMD=""
else
    echo "ERROR: no supported package manager found (looked for apt-get, dnf, pacman, zypper)." >&2
    exit 1
fi
echo "Detected package manager: $PM"

# --- bootstrap jq (needed to read tools.json), via the same package manager ---
if ! command -v jq >/dev/null 2>&1; then
    echo "==> Installing jq (needed to read tools.json)"
    [ -n "$UPDATE_CMD" ] && $UPDATE_CMD
    $INSTALL_CMD jq
fi

[ -n "$UPDATE_CMD" ] && { echo "==> Updating package index"; $UPDATE_CMD; }

installed=()
failed=()
manual=()

count=$(jq '.tools | length' "$MANIFEST")
for i in $(seq 0 $((count - 1))); do
    tool=$(jq -c ".tools[$i]" "$MANIFEST")
    name=$(echo "$tool" | jq -r '.name')
    install_type=$(echo "$tool" | jq -r '.install')

    if [ "$install_type" = "pkg" ]; then
        pkg=$(echo "$tool" | jq -r ".$PKG_FIELD // empty")
        if [ -z "$pkg" ]; then
            echo -e "\n==> Skipping $name — no package name known for $PM"
            failed+=("$name (no $PKG_FIELD entry)")
            continue
        fi
        echo -e "\n==> Installing $name ($pkg)"
        if $INSTALL_CMD "$pkg"; then
            installed+=("$name")
        else
            echo "    FAILED — package name may have drifted, try: $PM search-equivalent for '$name' manually"
            failed+=("$name")
        fi
    elif [ "$install_type" = "manual" ]; then
        url=$(echo "$tool" | jq -r '.manualUrl')
        manual+=("$name: $url")
    fi
done

echo -e "\n============================================================"
echo "SUMMARY"
echo "============================================================"

echo -e "\nInstalled (${#installed[@]}):"
printf '  - %s\n' "${installed[@]}"

if [ ${#failed[@]} -gt 0 ]; then
    echo -e "\nFailed (${#failed[@]}) — package name may have drifted for your distro/release:"
    printf '  - %s\n' "${failed[@]}"
fi

if [ ${#manual[@]} -gt 0 ]; then
    echo -e "\nNo package available — download these by hand once (${#manual[@]}):"
    printf '  - %s\n' "${manual[@]}"
fi

echo -e "\nSee tools.json for what each tool is for."
