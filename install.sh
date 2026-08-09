#!/usr/bin/env bash
#
# Install the loop and utility slash commands into ~/.codex/skills.
#
set -euo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DEST="${CODEX_HOME:-$HOME/.codex}/skills"

mkdir -p "$DEST"
for skill in loop flash deepseek luna sol build utility; do
  rm -rf "$DEST/$skill"
  cp -R "$HERE/skills/$skill" "$DEST/$skill"
  echo "installed $skill -> $DEST/$skill"
done

echo
echo "Restart Codex so the new skills appear in the slash command list."
