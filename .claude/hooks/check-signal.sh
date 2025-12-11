#!/bin/bash
# Checks Claude's response for [✓ rules] signal marker
# If missing, outputs CLAUDE.md with self-audit instructions

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
CLAUDE_MD="$PROJECT_ROOT/CLAUDE.md"

# Read Claude's response from stdin
response=$(cat)

# Check for the signal marker
if ! echo "$response" | grep -q "\[✓ rules\]"; then
  # Only alert if CLAUDE.md exists (this is a project with rules)
  if [ -f "$CLAUDE_MD" ]; then
    echo "⚠️ MEMORY ALERT: Signal marker missing from your last response."
    echo ""
    echo "Required actions:"
    echo "1. Re-read the project rules below"
    echo "2. Review your previous response for any rule violations"
    echo "3. Report any issues you find and correct them"
    echo "4. Resume with [✓ rules] on all future responses"
    echo ""
    echo "=== CLAUDE.md ==="
    cat "$CLAUDE_MD"
    echo "=== END CLAUDE.md ==="
  fi
fi
