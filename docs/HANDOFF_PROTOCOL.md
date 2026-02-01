# Handoff Protocol

> Standardized process for transitioning from interactive design (Claude Code) to autonomous implementation (Kilocode)

## Overview

The handoff is the critical transition point between:
- **Design Phase**: Interactive, exploratory, collaborative (Claude Code)
- **Implementation Phase**: Autonomous, deterministic, cost-optimized (Kilocode)

## Handoff Checklist

Before initiating handoff, verify:

### Documents Ready
- [ ] `DESIGN.md` - Complete architecture and specifications
- [ ] `IMPLEMENTATION.md` - Phased plan with verification steps
- [ ] `DESIGN_REVIEW_CHECKLIST.md` - Platform-specific validation criteria
- [ ] (Optional) `PRD.md` - Original requirements

### Design Completeness
- [ ] All requirements have corresponding implementation phases
- [ ] Each phase has clear verification steps
- [ ] Edge cases are documented
- [ ] Platform-specific concerns addressed

### Repository State
- [ ] All design documents committed
- [ ] No uncommitted changes
- [ ] On correct branch for agentic work
- [ ] Remote is accessible (for multi-machine sync)

## Handoff Artifacts

### DESIGN_REVIEW_START.md

This file signals the start of autonomous work and provides instructions to the first agent:

```markdown
# Design Review Start Signal

**Project**: {ProjectName}
**Platform**: {ninjatrader|react-supabase|python-ssh|n8n}
**Timestamp**: {ISO timestamp}

## Documents to Review

- /path/to/DESIGN.md
- /path/to/IMPLEMENTATION.md
- /path/to/DESIGN_REVIEW_CHECKLIST.md

## Review Instructions

1. Read all documents completely
2. Check each item in DESIGN_REVIEW_CHECKLIST.md
3. Verify requirements traceability
4. Create DESIGN_REVIEW_RESULTS.md with findings

## Decision Criteria

- **APPROVED**: All checklist items pass → Create DESIGN_APPROVED.md
- **ISSUES**: Any critical failures → Create DESIGN_ISSUES.md

## Platform-Specific Notes

{Any notes specific to this platform or project}
```

## Handoff Commands

### Interactive Handoff (Claude Code)

During a design session, when ready to hand off:

```
You: The design is complete. Prepare for handoff to Kilocode.

Claude: I'll create the handoff artifacts.

[Creates DESIGN_REVIEW_START.md]
[Validates against checklist]
[Commits all documents]

Ready for handoff. Run:
  cd /path/to/project
  run-agentic-workflow.sh
```

### Automated Handoff

```bash
# Validate design and create handoff signal
./scripts/validate-design.sh /path/to/project

# Start autonomous workflow
./scripts/run-agentic-workflow.sh --project-dir /path/to/project
```

## Platform-Specific Handoff

### NinjaTrader

Additional considerations:
- Ensure git remote is configured for Windows pull
- Verify AutoHotkey harvester is running on Windows
- Check that NT8 has the project folder in its workspace

```bash
# NinjaTrader handoff with remote execution
./scripts/run-agentic-workflow.sh \
  --project-dir /path/to/nt8_custom \
  --type ninjatrader \
  --remote windows-nt8
```

### React/Supabase

Additional considerations:
- Verify Supabase project is accessible
- Check Vercel project is linked
- Ensure MCP is configured if using database tools

```bash
# React/Supabase handoff
./scripts/run-agentic-workflow.sh \
  --project-dir /path/to/react-app \
  --type react-supabase
```

### Python/SSH

Additional considerations:
- Verify SSH keys are configured
- Check target VM is accessible
- Ensure dependencies are documented

```bash
# Python with remote VM execution
./scripts/run-agentic-workflow.sh \
  --project-dir /path/to/python-app \
  --type python-ssh \
  --remote python-vm
```

## Handoff Failure Modes

### Design Issues Found

If the autonomous design review finds issues:

1. `DESIGN_ISSUES.md` is created
2. Workflow pauses
3. Return to interactive mode (Claude Code) to fix issues
4. Re-run handoff

```bash
# After fixing issues
./scripts/run-agentic-workflow.sh --design-review
```

### Implementation Blocked

If implementation gets stuck:

1. `BLOCKED.md` is created with details
2. Workflow pauses
3. Review the blockage
4. Either fix manually or return to design session
5. Continue from current phase

```bash
# Resume after unblocking
./scripts/run-agentic-workflow.sh --implementation
```

### Code Review Issues

If code review finds issues:

1. `REVIEW_ISSUES.md` is created
2. Implementation agent should fix (up to 2 cycles)
3. If persistent, return to manual intervention

## Post-Handoff Monitoring

### Progress Tracking

Check `PROGRESS.md` for current status:

```markdown
## Phase 2: Core Logic
- Status: IN_PROGRESS
- Started: 2026-02-01 10:00:00
- Current Task: Implementing OnBarUpdate()
```

### Signal File Monitoring

```bash
# Check status
./scripts/run-agentic-workflow.sh --status

# Watch for changes
watch -n 5 "ls -la *.md | grep -E '(APPROVED|ISSUES|COMPLETE|BLOCKED)'"
```

### Feedback Directory

For platforms with async feedback (NinjaTrader):

```bash
# Watch for compilation results
watch -n 2 "ls -la feedback/"
```

## Returning from Autonomous to Interactive

When to return to Claude Code:
- Complex design issues found
- Persistent implementation blocks
- Need to change requirements
- Code review reveals architectural problems

Process:
1. Note current state (PROGRESS.md, signal files)
2. Start Claude Code session
3. Reference existing documents
4. Make changes interactively
5. Re-initiate handoff when ready

```
You: The implementation hit a block. I need to redesign the session handling.

Claude: I'll read the current state and help you revise the design.

[Reads BLOCKED.md, PROGRESS.md, current code]
[Discusses changes]
[Updates DESIGN.md and IMPLEMENTATION.md]
[Prepares new handoff]
```

## Best Practices

1. **Clean Handoffs**: Ensure all documents are complete before handoff
2. **Single Source of Truth**: DESIGN.md is the authoritative specification
3. **Incremental Phases**: Keep phases small and verifiable
4. **Clear Signals**: Use signal files consistently
5. **Git Everything**: All state should be in git for multi-machine sync
6. **Monitor Early**: Check first phase completion before walking away
7. **Document Blocks**: When intervening, update documents before re-handoff
