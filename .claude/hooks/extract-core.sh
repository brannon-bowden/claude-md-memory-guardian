#!/bin/bash
# Extracts content between <!-- CORE --> tags from CLAUDE.md
# Used by UserPromptSubmit hook to inject essential rules every prompt

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
CLAUDE_MD="$PROJECT_ROOT/CLAUDE.md"

if [ -f "$CLAUDE_MD" ]; then
  sed -n '/<!-- CORE -->/,/<!-- \/CORE -->/p' "$CLAUDE_MD" | grep -v "<!-- \?/\?CORE -->"
fi
