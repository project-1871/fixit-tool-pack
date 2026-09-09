#!/usr/bin/env bash
# Installs the free diagnostic/repair tools listed in tools.json via Homebrew.
# Part of the mac-fixit-tool kit.

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MANIFEST="$SCRIPT_DIR/tools.json"

if [ ! -f "$MANIFEST" ]; then
    echo "ERROR: tools.json not found next to this script." >&2
    exit 1
fi

if ! command -v brew >/dev/null 2>&1; then
    echo "ERROR: Homebrew not found. Run install-claude-code.sh first (it installs Homebrew), or install it from https://brew.sh" >&2
    exit 1
fi

if ! command -v jq >/dev/null 2>&1; then
    echo "==> Installing jq (needed to read tools.json)"
    brew install jq
fi

installed=()
failed=()
manual=()

count=$(jq '.tools | length' "$MANIFEST")
for i in $(seq 0 $((count - 1))); do
    tool=$(jq -c ".tools[$i]" "$MANIFEST")
    name=$(echo "$tool" | jq -r '.name')
    install_type=$(echo "$tool" | jq -r '.install')
    brew_id=$(echo "$tool" | jq -r '.brewId // empty')

    case "$install_type" in
        brew)
            echo -e "\n==> Installing $name ($brew_id)"
            if brew install "$brew_id"; then installed+=("$name"); else failed+=("$name"); fi
            ;;
        brew-cask)
            echo -e "\n==> Installing $name ($brew_id, cask)"
            if brew install --cask "$brew_id"; then installed+=("$name"); else failed+=("$name"); fi
            ;;
        manual)
            url=$(echo "$tool" | jq -r '.manualUrl')
            note=$(echo "$tool" | jq -r '.platformNote // empty')
            manual+=("$name: $url${note:+ (NOTE: $note)}")
            ;;
    esac
done

echo -e "\n============================================================"
echo "SUMMARY"
echo "============================================================"

echo -e "\nInstalled (${#installed[@]}):"
printf '  - %s\n' "${installed[@]}"

if [ ${#failed[@]} -gt 0 ]; then
    echo -e "\nFailed (${#failed[@]}) — try: brew search \"<name>\" to find the current formula/cask name:"
    printf '  - %s\n' "${failed[@]}"
fi

if [ ${#manual[@]} -gt 0 ]; then
    echo -e "\nNo Homebrew package — download these by hand once (${#manual[@]}):"
    printf '  - %s\n' "${manual[@]}"
fi

echo -e "\nSee tools.json for what each tool is for, and CLAUDE.md's Boot & Recovery"
echo "section before proposing any bootable-USB fix — Apple Silicon Macs can't"
echo "boot the kind of rescue media Ventoy/Rescuezilla/balenaEtcher create."
