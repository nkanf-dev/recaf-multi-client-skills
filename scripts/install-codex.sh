#!/bin/zsh
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
TARGET="$HOME/.codex/skills"
mkdir -p "$TARGET"

for skill in recaf-cli recaf-script-authoring recaf-patching; do
  ln -sfn "$ROOT/skills/$skill" "$TARGET/$skill"
done

echo "Installed Recaf skills into $TARGET"
