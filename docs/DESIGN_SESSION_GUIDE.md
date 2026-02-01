# Design Session Guide

> How to conduct effective design sessions with Claude Code before autonomous implementation

## Overview

A **Design Session** is an interactive collaboration between you and Claude Code to transform requirements into implementation-ready documents. The output of a design session is a complete set of documents that can be handed off to Kilocode for autonomous implementation.

## When to Use Design Sessions

- **New features**: Starting from requirements or ideas
- **Complex refactoring**: Need to plan the approach
- **Platform-specific work**: Leverage Claude's knowledge of NT8, React, etc.
- **Uncertain scope**: Need to explore and define boundaries

## Design Session Flow

```
┌─────────────────────────────────────────────────────────────────────┐
│                        DESIGN SESSION                                │
│                      (Claude Code - Interactive)                     │
├─────────────────────────────────────────────────────────────────────┤
│                                                                      │
│  1. REQUIREMENTS GATHERING                                          │
│     └─ User describes goal → Claude asks clarifying questions       │
│                                                                      │
│  2. ARCHITECTURE EXPLORATION                                        │
│     └─ Claude reads existing code → proposes approach               │
│                                                                      │
│  3. NFR DISCUSSION                                                  │
│     └─ Claude loads platform NFRs → discusses overrides with user   │
│     └─ Creates NFR_OVERRIDES.md if deviations needed                │
│                                                                      │
│  4. DESIGN DOCUMENT GENERATION                                      │
│     └─ Claude creates DESIGN.md from template (includes NFR section)│
│                                                                      │
│  5. IMPLEMENTATION PLANNING                                         │
│     └─ Claude creates IMPLEMENTATION.md with phases                 │
│                                                                      │
│  6. VALIDATION                                                       │
│     └─ Claude checks against REVIEW_CHECKLIST.md (includes NFRs)    │
│                                                                      │
│  7. HANDOFF PREPARATION                                             │
│     └─ Claude creates DESIGN_REVIEW_START.md                        │
│                                                                      │
└─────────────────────────────────────────────────────────────────────┘
                                │
                                ▼
┌─────────────────────────────────────────────────────────────────────┐
│                     AUTONOMOUS IMPLEMENTATION                        │
│                      (Kilocode CLI - Headless)                       │
├─────────────────────────────────────────────────────────────────────┤
│  Design Review → Implementation → Code Review                       │
└─────────────────────────────────────────────────────────────────────┘
```

## Starting a Design Session

### Option 1: From a PRD

If you have a Product Requirements Document:

```
You: I want to implement the feature described in PRD.md. Let's do a design session.

Claude: I'll read the PRD and we can work through the design together.
[Reads PRD.md]
[Asks clarifying questions]
[Generates DESIGN.md and IMPLEMENTATION.md]
```

### Option 2: From a Verbal Description

```
You: I want to create a NinjaTrader indicator that shows pivot points
     based on the previous day's high/low/close. Let's design it.

Claude: I'll help you design this indicator. Let me ask some questions:
- Should it show all standard pivots (S1, S2, S3, R1, R2, R3)?
- Do you want Fibonacci pivots as well?
- Should it extend the lines through the current session?
...
```

### Option 3: From Existing Code

```
You: I want to refactor the PivotMC strategy to add a new entry signal.
     Let's design the changes.

Claude: I'll read the existing code first.
[Reads Strategies/PivotMC.cs]
I see the current structure. The new signal would fit in OnBarUpdate().
Let me understand what you want to add...
```

## Design Session Commands

These phrases help Claude understand your intent:

| Phrase | Meaning |
|--------|---------|
| "Let's do a design session" | Start formal design process |
| "Help me design..." | Interactive design exploration |
| "Generate the design docs" | Create DESIGN.md and IMPLEMENTATION.md |
| "Validate the design" | Check against platform checklist |
| "Prepare for handoff" | Create DESIGN_REVIEW_START.md |
| "I want to hand this to Kilocode" | Signal autonomous phase coming |

## NFR Discussion Phase

The NFR (Non-Functional Requirements) discussion ensures operability, performance, security, and alerting are addressed before implementation.

### NFR Framework Structure

```
templates/nfr/
├── COMMON.md              # Cross-platform NFRs (all projects)
├── ninjatrader.md         # NinjaTrader-specific NFRs
├── react-supabase.md      # React/Supabase-specific NFRs
├── python-ssh.md          # Python/SSH-specific NFRs
└── n8n-workflow.md        # n8n-specific NFRs
```

### NFR Categories

| Category | Focus | Examples |
|----------|-------|----------|
| **Operability (OPS)** | Running the system | Logging, debug toggle, health checks |
| **Maintainability (MNT)** | Code quality | Naming conventions, no magic numbers |
| **Performance (PRF)** | Efficiency | Log rotation, lazy init, cleanup |
| **Security (SEC)** | Protection | No hardcoded secrets, input validation |
| **User Experience (UX)** | End users | Graceful errors, loading states |
| **Alerting (ALT)** | Operator awareness | Critical notifications, throttling |

### During Design Session

1. **Load baseline**: Claude reads `COMMON.md` + platform-specific NFR file
2. **Review with user**: Discuss which NFRs apply, any needed overrides
3. **Document overrides**: Create `NFR_OVERRIDES.md` if deviations needed
4. **Include in DESIGN.md**: NFR section summarizes applicable requirements

### Example NFR Discussion

```
Claude: I've loaded the NFR baseline for NinjaTrader. Key requirements:
- Multi-level logging via Print()
- Email alerts for critical errors (SendMail)
- Calculate.OnBarClose default (performance)
- Dispose() cleanup for resources

Do any of these need modification for your project?

User: This is a simple indicator, I don't think we need the email alerts.

Claude: I'll note that in NFR_OVERRIDES.md:
- NT-ALT-1 disabled: Simple indicator, no critical errors expected

Do you want Telegram alerts as an alternative, or skip alerting entirely?
```

---

## Platform Templates

During design sessions, Claude uses platform-specific templates:

### NinjaTrader

```bash
# Template location
agentic_coding/templates/platform/ninjatrader/

# Files generated
DESIGN.md           # NT8-specific architecture
IMPLEMENTATION.md   # Phased plan with compile feedback
REVIEW_CHECKLIST.md # NT8 best practices
```

### React/Supabase

```bash
# Template location
agentic_coding/templates/platform/react-supabase/

# Files generated
DESIGN.md           # Component architecture, DB schema
IMPLEMENTATION.md   # Build/test/deploy phases
REVIEW_CHECKLIST.md # TypeScript, security, performance
```

## Example Design Session (NinjaTrader)

```markdown
## Session: Daily Pivot Indicator

**User**: I want a NinjaTrader indicator that plots daily pivot levels.

**Claude**: I'll help you design this. Let me check the template and ask
some questions.

[Reads templates/platform/ninjatrader/DESIGN.md]

Questions:
1. Which pivot calculation method? (Standard, Fibonacci, Woodie, Camarilla)
2. Should it show all levels or just main (P, S1, R1)?
3. Do you want the levels to extend into the future?
4. Should there be alerts when price touches a level?
5. What session should it use for the "previous day"? (Regular, ETH, Custom)

**User**: Standard pivots, all levels, extend lines, no alerts for now,
use the regular session (RTH).

**Claude**: I'll generate the design documents.

[Creates DESIGN.md with specifications]
[Creates IMPLEMENTATION.md with 5 phases]
[Validates against REVIEW_CHECKLIST.md]

The design is ready. Here's a summary:
- Indicator: DailyPivots
- Plots: P, S1, S2, S3, R1, R2, R3 (7 plots)
- Session: Uses SessionIterator for RTH
- Implementation: 5 phases, estimated desk-check only

Would you like me to prepare the handoff for Kilocode?

**User**: Yes, prepare the handoff.

**Claude**:
[Creates DESIGN_REVIEW_START.md]

Ready for handoff. To start autonomous implementation:

```bash
cd /path/to/project
run-agentic-workflow.sh --design-review
```
```

## Design Validation

Before handoff, Claude checks:

### Completeness
- [ ] All requirements from PRD are addressed
- [ ] All input parameters defined with types and defaults
- [ ] All outputs/plots specified
- [ ] Edge cases documented

### Platform Compliance
- [ ] Follows platform conventions (NT8 State management, React hooks, etc.)
- [ ] Uses appropriate patterns from reference code
- [ ] Addresses platform-specific concerns (memory, threading, etc.)

### Implementation Readiness
- [ ] Each phase has clear tasks
- [ ] Verification steps defined
- [ ] Commit messages specified
- [ ] Feedback loop documented (compile results, tests, etc.)

## Handoff Artifacts

A complete design session produces:

| File | Purpose |
|------|---------|
| `DESIGN.md` | Architecture and specifications (includes NFR section) |
| `IMPLEMENTATION.md` | Phased implementation plan |
| `NFR_OVERRIDES.md` | Project-specific NFR deviations (if any) |
| `DESIGN_REVIEW_START.md` | Instructions for review agent |
| `DESIGN_REVIEW_CHECKLIST.md` | Platform-specific checklist (includes NFR compliance) |

## Tips for Effective Design Sessions

### Be Specific About Constraints
```
"This indicator will be used in real-time trading, so performance is critical."
"The strategy must handle partial fills and order rejections."
```

### Reference Existing Code
```
"Use the same pattern as IchiADRpivotOVN.cs for session handling."
"Follow the state management from the existing MyIndicator.cs."
```

### Clarify Testing Requirements
```
"I'll need to test this with historical data first."
"We should add debug logging that I can disable later."
```

### Define Handoff Criteria
```
"The design is ready when all five phases are defined."
"I want to review the IMPLEMENTATION.md before handoff."
```

## Multi-Machine Considerations

When designing for cross-machine execution:

### NinjaTrader (Mac → Windows)
- Design and docs created on Mac
- Implementation runs on Mac (desk check) OR Windows (with compile feedback)
- Manual verification on Windows NT8 platform

### Remote VMs
- Design on local machine
- Implementation can target remote via SSH
- Test results sync back via git or signal files

## Next Steps After Design Session

1. **Review Generated Docs**: Read DESIGN.md and IMPLEMENTATION.md
2. **Commit to Git**: Ensure all docs are committed
3. **Start Autonomous Phase**:
   ```bash
   ./scripts/run-agentic-workflow.sh --project-dir /path/to/project
   ```
4. **Monitor Progress**: Check PROGRESS.md and feedback directory
5. **Handle Blocks**: If BLOCKED.md appears, review and intervene
