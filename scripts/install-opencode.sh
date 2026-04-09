#!/bin/zsh
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
TARGET="$HOME/.shared-skills"
mkdir -p "$TARGET"

for skill in recaf-cli recaf-script-authoring recaf-patching; do
  ln -sfn "$ROOT/skills/$skill" "$TARGET/$skill"
done

echo "Installed Recaf skills into $TARGET"
echo
echo "For OpenCode, add this path under skills.paths in ~/.config/opencode/opencode.jsonc:"
echo "\"$TARGET\""
echo
echo "Example:"
echo '{'
echo '  "skills": {'
echo "    \"paths\": [\"$TARGET\"]"
echo '  }'
echo '}'
