# CLAUDE.md Memory Guardian - Design Document

## Problem

Claude Code forgets CLAUDE.md content over time, especially after context compaction. Users must manually remind Claude to re-read the file.

## Solution

A hook-based system that:
1. Injects CLAUDE.md at session start
2. Reinforces core rules with every user prompt
3. Detects memory loss via a behavioral signal and self-corrects

## Architecture

```
┌─────────────────────────────────────────────────────┐
│                   CLAUDE.md                         │
│  (full rules file with <!-- CORE --> tags)         │
└─────────────────────┬───────────────────────────────┘
                      │
        ┌─────────────┼─────────────┐
        ▼             ▼             ▼
   ┌─────────┐  ┌───────────┐  ┌──────────────┐
   │ Session │  │  Prompt   │  │   Response   │
   │  Start  │  │  Submit   │  │   Monitor    │
   └────┬────┘  └─────┬─────┘  └──────┬───────┘
        │             │               │
   Full file     Core rules      Check for
   injection     extraction      signal marker
                                      │
                              Missing? → Re-inject
                                        + Self-audit
```

## Behavioral Signal

Claude ends every response with `[✓ rules]` to confirm it remembers the project rules. Missing signal triggers re-injection and self-correction.

## File Structure

```
project/
├── CLAUDE.md                      # Rules with <!-- CORE --> tags
└── .claude/
    ├── settings.local.json        # Hook configuration
    └── hooks/
        ├── extract-core.sh        # Extracts tagged sections
        └── check-signal.sh        # Detects missing signal
```

## Hook Configuration

`.claude/settings.local.json`:

```json
{
  "hooks": {
    "SessionStart": [
      {
        "type": "command",
        "command": "cat CLAUDE.md"
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

## Hook Scripts

### extract-core.sh

Extracts lines between `<!-- CORE -->` tags from CLAUDE.md:

```bash
#!/bin/bash
sed -n '/<!-- CORE -->/,/<!-- \/CORE -->/p' CLAUDE.md | grep -v "<!-- \?/\?CORE -->"
```

### check-signal.sh

Checks Claude's response for the signal marker, triggers recovery if missing:

```bash
#!/bin/bash

# Read Claude's response from stdin
response=$(cat)

# Check for the signal marker
if ! echo "$response" | grep -q "\[✓ rules\]"; then
  echo "⚠️ MEMORY ALERT: Signal marker missing from your last response."
  echo ""
  echo "Required actions:"
  echo "1. Re-read the project rules below"
  echo "2. Review your previous response for any rule violations"
  echo "3. Report any issues you find and correct them"
  echo "4. Resume with [✓ rules] on all future responses"
  echo ""
  echo "=== CLAUDE.md ==="
  cat CLAUDE.md
  echo "=== END CLAUDE.md ==="
fi
```

## CLAUDE.md Template

```markdown
# Project Rules

## Critical Constraints
<!-- CORE -->
- [Non-negotiable rule #1]
- [Non-negotiable rule #2]
<!-- /CORE -->

Extended context...

## Code Style
<!-- CORE -->
- [Key style rule #1]
<!-- /CORE -->

Detailed style guide...

## Memory Signal
<!-- CORE -->
End every response with: [✓ rules]

This confirms you're operating with full project context.
If you cannot remember these rules, say so immediately.
<!-- /CORE -->
```

## Tagging Guidelines

- Tag rules Claude must actively follow, not background info
- Keep total CORE content under ~20 lines
- The signal instruction must always be tagged

## How Recovery Works

1. Claude responds without `[✓ rules]`
2. Stop hook detects missing signal
3. Hook outputs full CLAUDE.md with self-correction instructions
4. Claude re-reads rules and audits its previous response
5. Claude corrects any violations and resumes with signal

## Design Decisions

- **Single file with tags** over separate files to avoid sync drift
- **Behavioral signal** over periodic injection for reliable detection
- **Self-audit on recovery** to catch violations, not just prevent future ones
- **Implicit compaction detection** via signal loss rather than explicit counter
