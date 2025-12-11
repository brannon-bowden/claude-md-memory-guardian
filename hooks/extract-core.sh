#!/bin/bash
# Extracts content between <!-- CORE --> tags from CLAUDE.md
# Used by UserPromptSubmit hook to inject essential rules every prompt
#
# Works in plugin context: assumes current directory is user's project

CLAUDE_MD="CLAUDE.md"

if [ -f "$CLAUDE_MD" ]; then
  sed -n '/<!-- CORE -->/,/<!-- \/CORE -->/p' "$CLAUDE_MD" | grep -v "<!-- \?/\?CORE -->"
fi
