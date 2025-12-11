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

### Option 1: Install as Plugin (Recommended)

```bash
# Add the marketplace
/plugin marketplace add brannon-bowden/claude-md-memory-guardian

# Install the plugin
/plugin install memory-guardian@brannon-bowden
```

Then create a `CLAUDE.md` in your project with `<!-- CORE -->` tags (see format below).

### Option 2: Manual Installation

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

## How It Works

```
┌─────────────────────────────────────────────────────┐
│                   CLAUDE.md                         │
│  (your rules file with <!-- CORE --> tags)         │
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
   injection     extraction      [✓ rules]
                                      │
                              Missing? → Re-inject
                                        + Self-audit
```

## Plugin Files

```
.claude-plugin/
├── plugin.json        # Plugin manifest
└── marketplace.json   # Marketplace configuration
hooks/
├── hooks.json         # Hook definitions
├── extract-core.sh    # Extracts <!-- CORE --> tagged content
└── check-signal.sh    # Checks for [✓ rules] signal
```

## Customization

- **Change the signal**: Edit the marker in both your `CLAUDE.md` and fork `check-signal.sh`
- **Adjust core content**: Add/remove `<!-- CORE -->` tags in your `CLAUDE.md`
- **Disable per-prompt injection**: Remove the plugin and use manual installation without UserPromptSubmit hook

## License

MIT
