---
tags:
  - ai
  - automation
  - kilo-code
  - workflow
  - bug-fix
  - revision
---

# Bug Fix Mode

> Post-implementation bug fixes and revisions based on user-provided ISSUES.md.

## Overview

Bug Fix Mode (Phase 5) allows you to fix issues, correct misinterpretations, and implement improvements after the initial implementation is complete. This mode is triggered by creating an `ISSUES.md` file in your project folder.

## When to Use Bug Fix Mode

Use Bug Fix Mode when:
- **Critical bugs** are discovered during testing
- **Design misinterpretations** are found (implementation doesn't match requirements)
- **Improvements** are needed after seeing the code in action
- **Refactoring** is required for better code organization

## How It Works

### Priority Hierarchy

The agent follows this priority order when resolving issues:

1. **ISSUES.md** - User's explicit changes (HIGHEST priority)
2. Original Design Documents - Context only
3. Project Rules (.kilorules, .cursorrules)
4. Platform Templates

**Key Rule**: If ISSUES.md contradicts DESIGN.md, the agent follows ISSUES.md.

### Agent Behavior

When Bug Fix Mode runs, the agent will:

1. Read ISSUES.md completely - this is the primary directive
2. Read original design documents for context only
3. Fix each issue systematically
4. After each fix, verify it doesn't break other functionality
5. Commit each fix with message: "Fix: [issue description]"
6. Update BUGFIX_PROGRESS.md after each fix
7. When all issues resolved, create BUGFIX_COMPLETE.md

### Critical Rules

- User's ISSUES.md overrides any conflicting requirements in original design
- If an issue requires design clarification, create BUGFIX_BLOCKED.md
- Do NOT ask clarifying questions - all requirements are in ISSUES.md
- If blocked after 3 attempts: Create BUGFIX_BLOCKED.md and stop

## Running Bug Fix Mode

### Step 1: Create ISSUES.md

```bash
# Copy template
cp templates/common/ISSUES_TEMPLATE.md /path/to/project/ISSUES.md

# Edit with your issues
vim /path/to/project/ISSUES.md
```

### Step 2: Run bug fix mode

```bash
# Auto-detect ISSUES.md and run bug fix mode
./scripts/run-agentic-workflow.sh --project-dir /path/to/project

# Or explicitly specify bug fix mode
./scripts/run-agentic-workflow.sh --project-dir /path/to/project --bug-fix
```

### Step 3: Monitor progress

```bash
# Check status
./scripts/run-agentic-workflow.sh --status

# View progress
cat /path/to/project/BUGFIX_PROGRESS.md
```

## ISSUES.md Format

### Issue Categories

#### Critical Bugs
- **File**: path/to/file.cs
- **Expected**: What should happen
- **Actual**: What's happening
- **Root Cause**: If known

#### Design Misinterpretations
- **Original Requirement**: Quote from DESIGN.md
- **Misinterpretation**: What was implemented incorrectly
- **Correction**: What needs to change

#### Improvements/Enhancements
- **Rationale**: Why this change is needed
- **Impact**: What this affects

#### Refactoring
- **Current State**: Description
- **Desired State**: Description

### Example ISSUES.md

```markdown
# Issues & Revisions List

**Project**: PivotMC Indicator
**Created**: 2026-02-02
**Priority**: HIGH - Overrides original design where conflicts exist

## Issue Classification

### Critical Bugs
- [ ] Pivot line calculation incorrect on M1 timeframe
  - **File**: Indicators/PivotMC.cs
  - **Expected**: Pivot lines should use HLC/3 formula
  - **Actual**: Using HL/2 formula
  - **Root Cause**: Line 245 uses wrong calculation

### Design Misinterpretations
- [ ] Multi-timeframe aggregation not implemented
  - **Original Requirement**: "Aggregate pivot levels from M1, M5, M15 timeframes"
  - **Misinterpretation**: Only M1 timeframe used
  - **Correction**: Add M5 and M15 timeframe aggregation

### Improvements/Enhancements
- [ ] Add pivot line strength indicator
  - **Rationale**: Helps identify strongest support/resistance levels
  - **Impact**: Visual enhancement only, no logic changes
```

## Signal Files

Bug Fix Mode uses these signal files to track progress:

| Signal File | Created By | Meaning |
|-------------|------------|---------|
| `BUGFIX_START.md` | Orchestrator | Bug fix mode initiated |
| `BUGFIX_PROGRESS.md` | Bug Fix Agent | Current progress (updated continuously) |
| `BUGFIX_COMPLETE.md` | Bug Fix Agent | All issues resolved |
| `BUGFIX_BLOCKED.md` | Bug Fix Agent | Unable to proceed after 3 attempts |

## Model Configuration

Bug Fix Mode uses the same model as Implementation:

```bash
# In config.sh
MODEL_IMPLEMENTATION="minimax/minimax-m2.1"
```

## Cost Considerations

Bug Fix Mode typically costs less than initial implementation:

| Issue Count | Estimated Cost |
|-------------|----------------|
| 1-2 issues | ~$0.10 - $0.30 |
| 3-5 issues | ~$0.30 - $0.80 |
| 6-10 issues | ~$0.80 - $1.50 |

## Troubleshooting

### Agent Gets Stuck

If the agent creates `BUGFIX_BLOCKED.md`:

1. Review the blocking issue
2. Update ISSUES.md with clarification
3. Delete BUGFIX_BLOCKED.md
4. Run bug fix mode again

### Issues Not Fixed

If issues remain after BUGFIX_COMPLETE.md:

1. Review BUGFIX_PROGRESS.md
2. Add remaining issues to ISSUES.md
3. Run bug fix mode again

### Conflicts with Original Design

If you're unsure whether to follow ISSUES.md or DESIGN.md:

- **ISSUES.md always wins** - it represents your current intent
- Original design is only for context
- Update DESIGN.md after bug fixes if needed

## Best Practices

1. **Be Specific**: Include file paths, line numbers, and expected behavior
2. **Prioritize**: List critical bugs first
3. **One Issue Per Item**: Don't combine multiple issues
4. **Provide Context**: Include quotes from original design when relevant
5. **Test After**: Verify fixes work as expected

## Related Documents

- [[Agentic Coding/Workflow Phases]] - Phase-by-phase breakdown
- [[cliffnet/agentic-coding-workflow]] - Main workflow documentation
- [[templates/common/ISSUES_TEMPLATE.md]] - ISSUES.md template
