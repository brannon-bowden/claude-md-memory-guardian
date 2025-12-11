# CLAUDE.md Memory Guardian - Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Implement a hook system that prevents Claude from forgetting CLAUDE.md rules after context compaction.

**Architecture:** Three hooks work together - SessionStart injects full CLAUDE.md, UserPromptSubmit injects extracted core rules, and Stop monitors for a behavioral signal (`[✓ rules]`) that indicates memory retention. Missing signal triggers automatic re-injection and self-audit.

**Tech Stack:** Bash scripts, Claude Code hooks (JSON configuration)

---

## Task 1: Create Hooks Directory

**Files:**
- Create: `.claude/hooks/` directory

**Step 1: Create the hooks directory**

```bash
mkdir -p .claude/hooks
```

**Step 2: Verify directory exists**

Run: `ls -la .claude/`
Expected: Shows `hooks/` directory

**Step 3: Commit**

```bash
git add .claude/hooks/.gitkeep 2>/dev/null || touch .claude/hooks/.gitkeep && git add .claude/hooks/.gitkeep
git commit -m "chore: add hooks directory structure"
```

---

## Task 2: Create Core Rules Extraction Script

**Files:**
- Create: `.claude/hooks/extract-core.sh`

**Step 1: Write the extraction script**

Create `.claude/hooks/extract-core.sh`:

```bash
#!/bin/bash
# Extracts content between <!-- CORE --> tags from CLAUDE.md
# Used by UserPromptSubmit hook to inject essential rules every prompt

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
CLAUDE_MD="$PROJECT_ROOT/CLAUDE.md"

if [ -f "$CLAUDE_MD" ]; then
  sed -n '/<!-- CORE -->/,/<!-- \/CORE -->/p' "$CLAUDE_MD" | grep -v "<!-- \?/\?CORE -->"
fi
```

**Step 2: Make script executable**

Run: `chmod +x .claude/hooks/extract-core.sh`

**Step 3: Verify script is executable**

Run: `ls -la .claude/hooks/extract-core.sh`
Expected: Shows `-rwxr-xr-x` permissions

**Step 4: Commit**

```bash
git add .claude/hooks/extract-core.sh
git commit -m "feat: add core rules extraction script"
```

---

## Task 3: Create Signal Checker Script

**Files:**
- Create: `.claude/hooks/check-signal.sh`

**Step 1: Write the signal checker script**

Create `.claude/hooks/check-signal.sh`:

```bash
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
```

**Step 2: Make script executable**

Run: `chmod +x .claude/hooks/check-signal.sh`

**Step 3: Verify script is executable**

Run: `ls -la .claude/hooks/check-signal.sh`
Expected: Shows `-rwxr-xr-x` permissions

**Step 4: Commit**

```bash
git add .claude/hooks/check-signal.sh
git commit -m "feat: add signal checker script for memory detection"
```

---

## Task 4: Update Hook Configuration

**Files:**
- Modify: `.claude/settings.local.json`

**Step 1: Read current settings**

The current `.claude/settings.local.json` contains permissions only. We need to add the hooks section.

**Step 2: Update settings with hooks configuration**

Replace `.claude/settings.local.json` with:

```json
{
  "permissions": {
    "allow": [
      "Skill(superpowers:brainstorming)",
      "Bash(mkdir:*)",
      "Bash(git init:*)",
      "Bash(git add:*)",
      "Bash(git commit:*)",
      "mcp__github---personal__create_repository",
      "Bash(git remote add:*)",
      "Bash(git push:*)",
      "Skill(superpowers:writing-plans)"
    ],
    "deny": [],
    "ask": []
  },
  "hooks": {
    "SessionStart": [
      {
        "type": "command",
        "command": "cat CLAUDE.md 2>/dev/null || true"
      }
    ],
    "UserPromptSubmit": [
      {
        "type": "command",
        "command": "sh .claude/hooks/extract-core.sh"
      }
    ],
    "Stop": [
      {
        "type": "command",
        "command": "sh .claude/hooks/check-signal.sh"
      }
    ]
  }
}
```

**Step 3: Verify JSON is valid**

Run: `cat .claude/settings.local.json | python3 -m json.tool > /dev/null && echo "Valid JSON"`
Expected: "Valid JSON"

**Step 4: Commit**

```bash
git add .claude/settings.local.json
git commit -m "feat: configure hooks for CLAUDE.md memory guardian"
```

---

## Task 5: Create Example CLAUDE.md Template

**Files:**
- Create: `CLAUDE.md`

**Step 1: Write the template CLAUDE.md**

Create `CLAUDE.md`:

```markdown
# Project Rules

## About This File

This file contains project rules and preferences for Claude Code. Rules marked with
`<!-- CORE -->` tags are reinforced with every prompt to prevent memory loss.

---

## Critical Constraints
<!-- CORE -->
- [Add your non-negotiable rules here]
- [Example: Never delete files without confirmation]
- [Example: Always run tests before committing]
<!-- /CORE -->

Extended explanation of constraints...

---

## Code Style
<!-- CORE -->
- [Add key style rules here]
- [Example: Use descriptive variable names]
<!-- /CORE -->

Detailed style guidelines...

---

## Communication Preferences
<!-- CORE -->
- [Add communication preferences here]
- [Example: Be concise, avoid fluff]
<!-- /CORE -->

---

## Memory Signal
<!-- CORE -->
End every response with: [✓ rules]

This confirms you're operating with full project context.
If you cannot remember these rules, say so immediately.
<!-- /CORE -->
```

**Step 2: Verify CLAUDE.md exists and has content**

Run: `head -20 CLAUDE.md`
Expected: Shows first 20 lines of template

**Step 3: Commit**

```bash
git add CLAUDE.md
git commit -m "feat: add CLAUDE.md template with CORE tags"
```

---

## Task 6: Create README with Usage Instructions

**Files:**
- Create: `README.md`

**Step 1: Write README**

Create `README.md`:

```markdown
# CLAUDE.md Memory Guardian

Prevent Claude Code from forgetting your project rules after context compaction.

## The Problem

Claude Code reads `CLAUDE.md` at session start, but after long conversations or context compaction, it often forgets the rules. You end up repeatedly saying "please re-read CLAUDE.md."

## The Solution

A hook-based system that:
1. **Injects full rules at session start** - SessionStart hook
2. **Reinforces core rules every prompt** - UserPromptSubmit hook extracts `<!-- CORE -->` tagged content
3. **Detects memory loss automatically** - Stop hook checks for `[✓ rules]` signal; missing = re-inject

## Installation

1. Copy the `.claude/` directory to your project
2. Create or update your `CLAUDE.md` with `<!-- CORE -->` tags
3. Add the Memory Signal section to your `CLAUDE.md`

## CLAUDE.md Format

Tag your critical rules with `<!-- CORE -->` markers:

```markdown
## My Rules
<!-- CORE -->
- Critical rule that must be repeated every prompt
- Another critical rule
<!-- /CORE -->

Extended details that only need to be read once per session...
```

## The Memory Signal

Add this to your `CLAUDE.md`:

```markdown
## Memory Signal
<!-- CORE -->
End every response with: [✓ rules]

This confirms you're operating with full project context.
If you cannot remember these rules, say so immediately.
<!-- /CORE -->
```

When Claude forgets and stops adding `[✓ rules]`, the system automatically re-injects your full CLAUDE.md and instructs Claude to audit its previous response.

## Files

```
.claude/
├── settings.local.json    # Hook configuration
└── hooks/
    ├── extract-core.sh    # Extracts <!-- CORE --> tagged content
    └── check-signal.sh    # Checks for [✓ rules] signal
```

## Customization

- **Change the signal**: Edit the marker in both `CLAUDE.md` and `check-signal.sh`
- **Adjust core content**: Add/remove `<!-- CORE -->` tags in your `CLAUDE.md`
- **Disable per-prompt injection**: Remove the UserPromptSubmit hook if too noisy

## License

MIT
```

**Step 2: Verify README exists**

Run: `head -30 README.md`
Expected: Shows README content

**Step 3: Commit**

```bash
git add README.md
git commit -m "docs: add README with usage instructions"
```

---

## Task 7: Test the Extraction Script

**Files:**
- Test: `.claude/hooks/extract-core.sh`

**Step 1: Run extraction script and verify output**

Run: `sh .claude/hooks/extract-core.sh`

Expected output (approximately):
```
- [Add your non-negotiable rules here]
- [Example: Never delete files without confirmation]
- [Example: Always run tests before committing]
- [Add key style rules here]
- [Example: Use descriptive variable names]
- [Add communication preferences here]
- [Example: Be concise, avoid fluff]
End every response with: [✓ rules]

This confirms you're operating with full project context.
If you cannot remember these rules, say so immediately.
```

**Step 2: Verify no CORE tags in output**

Run: `sh .claude/hooks/extract-core.sh | grep -c "CORE"`
Expected: `0`

---

## Task 8: Test the Signal Checker Script

**Files:**
- Test: `.claude/hooks/check-signal.sh`

**Step 1: Test with signal present (should be silent)**

Run: `echo "Here is my response [✓ rules]" | sh .claude/hooks/check-signal.sh`
Expected: No output (empty)

**Step 2: Test with signal missing (should output alert)**

Run: `echo "Here is my response without signal" | sh .claude/hooks/check-signal.sh | head -5`
Expected: Shows "⚠️ MEMORY ALERT" and first lines of instructions

---

## Task 9: Push All Changes to GitHub

**Step 1: Verify all commits are in place**

Run: `git log --oneline -10`
Expected: Shows all commits from this implementation

**Step 2: Push to GitHub**

Run: `git push origin main`
Expected: Successful push

---

## Summary

After completing all tasks, you will have:

```
project/
├── CLAUDE.md                      # Template with CORE tags
├── README.md                      # Usage documentation
└── .claude/
    ├── settings.local.json        # Hook configuration (updated)
    └── hooks/
        ├── extract-core.sh        # Core rules extractor
        └── check-signal.sh        # Signal monitor
```

The system will:
1. Inject full CLAUDE.md at session start
2. Extract and inject CORE-tagged rules with every user prompt
3. Monitor responses for `[✓ rules]` signal
4. Auto-recover when signal is missing by re-injecting rules and requesting self-audit
