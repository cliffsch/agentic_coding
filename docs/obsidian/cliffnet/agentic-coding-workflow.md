---
tags:
  - ai
  - automation
  - kilo-code
  - workflow
  - agentic
  - development
  - ninjatrader
  - react
  - supabase
---

# Agentic Coding Workflow v4.2

> A multi-tier AI-assisted software development system using specialized models for each phase of the development lifecycle.
> **Now supporting multiple platforms: Python/SSH, C#/NinjaTrader, React/Vite/Supabase, and n8n workflows.**
> **Includes Phase 5: Bug Fix & Revision mode for post-implementation fixes.**

## Overview

This guide enables you to build software using a **4-Phase Workflow** (plus optional Bug Fix mode):

| Phase | Model | Role | Task |
|-------|-------|------|------|
| **Phase 1** | Kimi K2.5 | Design Review | Validate DESIGN.md and IMPLEMENTATION.md completeness BEFORE implementation |
| **Phase 2** | Minimax M2.1 | Implementation | Execute all phases in IMPLEMENTATION.md |
| **Phase 3** | Kimi K2.5 | Code Review | Validate implementation against specifications |
| **Phase 5** | Minimax M2.1 | Bug Fix & Revision | Fix issues based on user-provided ISSUES.md |

## Design Principles

1. **Right model for the task**: Kimi K2.5 for design/code review, Minimax M2.1 for implementation and bug fixes
2. **Validate before building**: Design review catches gaps before implementation starts
3. **Autonomous implementation**: Self-sufficient execution with clear success criteria
4. **Tiered review**: Automated validation before human review
5. **Cost optimization**: Use cheaper models where quality permits
6. **User-driven revisions**: ISSUES.md takes priority over original design for bug fixes

## Phase Details

### Phase 1: Design Review (Kimi K2.5)

**Environment**: Kilo Code CLI in review mode
**Model**: Kimi K2.5 via OpenRouter
**Mode**: Analysis and validation

**Responsibilities**:
- Read DESIGN.md, IMPLEMENTATION.md, and DESIGN_REVIEW_CHECKLIST.md completely
- Check EVERY item in DESIGN_REVIEW_CHECKLIST.md - do not skip
- Create a traceability matrix mapping DESIGN.md sections to IMPLEMENTATION.md phases
- Identify implicit requirements (config settings without code, cleanup without logic, etc.)
- Do NOT modify files - only report findings
- Create detailed DESIGN_REVIEW_RESULTS.md

**Exit Criteria**:
- Create DESIGN_APPROVED.md if approved
- Create DESIGN_ISSUES.md with specific problems if issues found

### Phase 2: Implementation (Minimax M2.1)

**Environment**: Kilo Code CLI in agent mode
**Model**: Minimax M2.1 via OpenRouter
**Mode**: Autonomous

**Phase Execution**:
- Phase 1: Project Structure (pyproject.toml, requirements.txt, __init__.py)
- Phase 2: Configuration (config.py, tests/test_config.py)
- Phase 3: Session Manager (session.py, tests/test_session.py)
- Phase 4: AskUI Wrapper (askui_wrapper.py, tests/test_askui_wrapper.py)
- Phase 5: Controller (controller.py)
- Phase 6: CLI Entry Point (__main__.py)
- Phase 7: E2E Testing on VM (deploy, test, verify)
- Phase 8: Documentation (SKILL.md)

**Constraints**:
- No clarifying questions (all info in docs)
- Max 3 retries per phase
- Document blockers in BLOCKED.md and stop
- Auto-approve safe operations only

### Phase 3: Code Review (Kimi K2.5)

**Environment**: Kilo Code CLI in review mode
**Model**: Kimi K2.5 via OpenRouter
**Mode**: Validation

**Agent Rules**:
1. Read REVIEW_CHECKLIST.md completely
2. Check each item systematically - do not skip
3. Run all tests: pytest tests/ -v
4. Run E2E tests on VM
5. Verify all commits match IMPLEMENTATION.md specifications
6. Check for TODO/FIXME comments
7. Do NOT fix issues yourself - only report them
8. Create detailed REVIEW_RESULTS.md

**Decision**:
- **APPROVED**: Create REVIEW_APPROVED.md
- **ISSUES FOUND**: Create REVIEW_ISSUES.md with specific problems

**Maximum 2 review cycles** before human escalation.

### Phase 5: Bug Fix & Revision (Minimax M2.1)

**Environment**: Kilo Code CLI in code mode
**Model**: Minimax M2.1 via OpenRouter
**Mode**: Autonomous bug fixing

**Trigger**: Create `ISSUES.md` in project folder

**Priority Rules**:
1. **ISSUES.md takes HIGHEST priority** - User's explicit changes override original design
2. Use original design documents only for context and understanding
3. If ISSUES.md contradicts DESIGN.md, follow ISSUES.md
4. Maintain consistency with existing codebase patterns
5. Do NOT revert changes that were intentionally made per ISSUES.md

**Agent Behavior**:
- Read ISSUES.md completely - this is the primary directive
- Read original design documents for context only
- Fix each issue systematically
- After each fix, verify it doesn't break other functionality
- Commit each fix with message: "Fix: [issue description]"
- Update BUGFIX_PROGRESS.md after each fix
- When all issues resolved, create BUGFIX_COMPLETE.md

**Critical Rules**:
- User's ISSUES.md overrides any conflicting requirements in original design
- If an issue requires design clarification, create BUGFIX_BLOCKED.md
- Do NOT ask clarifying questions - all requirements are in ISSUES.md
- If blocked after 3 attempts: Create BUGFIX_BLOCKED.md and stop

**Exit Criteria**:
- Create BUGFIX_COMPLETE.md when all issues resolved
- Create BUGFIX_BLOCKED.md if unable to proceed after 3 attempts

## Coordination Signals

### Phase 1: Design Review Signals

| Signal File | Created By | Meaning |
|-------------|------------|---------|
| `DESIGN_REVIEW_START.md` | Orchestrator | Design review initiated |
| `DESIGN_REVIEW_RESULTS.md` | Design Review Agent | Review findings documented |
| `DESIGN_APPROVED.md` | Design Review Agent | Design is complete and ready |
| `DESIGN_ISSUES.md` | Design Review Agent | Design has problems |

### Phase 2: Implementation Signals

| Signal File | Created By | Meaning |
|-------------|------------|---------|
| `IMPLEMENTATION_START.md` | Orchestrator | Ready to implement |
| `IMPLEMENTATION_COMPLETE.md` | Implementation | All phases done |
| `BLOCKED.md` | Implementation | Stuck after 3 retries |
| `PROGRESS.md` | Implementation | Current status (updated continuously) |

### Phase 3: Code Review Signals

| Signal File | Created By | Meaning |
|-------------|------------|---------|
| `REVIEW_START.md` | Orchestrator | Ready to review |
| `REVIEW_APPROVED.md` | Code Review | All checks passed |
| `REVIEW_ISSUES.md` | Code Review | Problems found, needs fixes |

### Phase 5: Bug Fix & Revision Signals

| Signal File | Created By | Meaning |
|-------------|------------|---------|
| `BUGFIX_START.md` | Orchestrator | Bug fix mode initiated |
| `BUGFIX_PROGRESS.md` | Bug Fix Agent | Current progress (updated continuously) |
| `BUGFIX_COMPLETE.md` | Bug Fix Agent | All issues resolved |
| `BUGFIX_BLOCKED.md` | Bug Fix Agent | Unable to proceed after 3 attempts |

## Supported Platforms

| Platform | Language/Stack | Deployment | Use Case |
|----------|---------------|------------|----------|
| **Python/SSH** | Python 3.x | SSH to remote VM | Automation, backend services |
| **C#/NinjaTrader** | C# (.NET) | Git → Windows NT | Trading indicators/strategies |
| **React/Supabase** | React + Vite + TS | Git → Vercel | Web applications |
| **n8n Workflows** | JSON workflows | n8n API | Automation workflows |

### Platform Detection

The workflow runner auto-detects your platform:
- **C#/NinjaTrader**: `*.cs` files with Indicator/Strategy, `NinjaTrader.csproj`, or `ProjectType.txt` containing "ninjatrader"
- **React/Supabase**: `package.json` with vite + `supabase/config.toml` or `src/lib/supabase`
- **React/Vite**: `package.json` with vite (without Supabase)
- **n8n**: `package.json` with n8n
- **Python/SSH**: `pyproject.toml`, `requirements.txt`, or `*.py` files (default)

Force a specific platform with:
```bash
./scripts/run-agentic-workflow.sh --type csharp-ninjatrader
./scripts/run-agentic-workflow.sh --type react-supabase
./scripts/run-agentic-workflow.sh --type python-ssh
```

## Running the Workflow

### Full Workflow

```bash
# Full 4-phase workflow (auto-detect platform)
./scripts/run-agentic-workflow.sh

# Force specific workflow type
./scripts/run-agentic-workflow.sh --type csharp-ninjatrader
./scripts/run-agentic-workflow.sh --type react-supabase
./scripts/run-agentic-workflow.sh --type python-ssh
```

### Individual Phases

```bash
# Run only design review
./scripts/run-agentic-workflow.sh --design-review

# Run only implementation (requires DESIGN_APPROVED.md)
./scripts/run-agentic-workflow.sh --implementation

# Run only code review (requires IMPLEMENTATION_COMPLETE.md)
./scripts/run-agentic-workflow.sh --code-review

# Run bug fix mode (requires ISSUES.md)
./scripts/run-agentic-workflow.sh --bug-fix
```

### Status and Maintenance

```bash
# Check status
./scripts/run-agentic-workflow.sh --status

# Reset/clean signal files
./scripts/run-agentic-workflow.sh --clean

# Verbose output
./scripts/run-agentic-workflow.sh --verbose

# Specify project directory
./scripts/run-agentic-workflow.sh --project-dir /path/to/project
```

## Bug Fix Mode

When implementation reveals issues or you want to make changes:

### 1. Create ISSUES.md

```bash
# Copy template
cp templates/common/ISSUES_TEMPLATE.md /path/to/project/ISSUES.md

# Edit with your issues
vim /path/to/project/ISSUES.md
```

### 2. Run bug fix mode

```bash
./scripts/run-agentic-workflow.sh --project-dir /path/to/project --bug-fix
```

### 3. ISSUES.md Format

- **Critical Bugs**: Actual vs Expected behavior
- **Design Misinterpretations**: Original requirement vs what was implemented
- **Improvements**: Rationale and impact
- **Refactoring**: Current vs desired state

### 4. Priority Hierarchy

1. ISSUES.md (User's explicit changes)
2. Original Design Documents (Context only)
3. Project Rules (.kilorules, .cursorrules)
4. Platform Templates

## Model Cost Optimization

| Provider/Model | Input | Output | Best For |
|----------------|-------|--------|----------|
| Kimi K2.5 | Free | Free | Design Review, Code Review |
| Minimax M2.1 | $0.18 | $0.18 | Implementation, Bug Fix |

### Typical Task Costs (4-Phase Workflow)

| Task Type | Design Review | Implementation | Code Review | Bug Fix | Total |
|-----------|---------------|----------------|-------------|---------|-------|
| Small feature | $0.00 | $0.30 | $0.00 | $0.10 | ~$0.40 |
| Medium feature | $0.00 | $1.50 | $0.00 | $0.50 | ~$2.00 |
| Large feature | $0.00 | $5.00 | $0.00 | $1.00 | ~$6.00 |

## Platform-Specific Notes

### C#/NinjaTrader
- Develop on macOS, deploy via git to Windows NinjaTrader
- No compilation during implementation (desk check only)
- Manual verification required on NT platform
- Key files: `*.cs`, `NinjaTrader.csproj`, `ProjectType.txt`

### React/Vite/Supabase
- TypeScript strict mode recommended
- Git push triggers Vercel deployment
- Supabase migrations applied separately
- n8n workflows deployed via API or manual import
- Key files: `package.json`, `supabase/config.toml`, `vercel.json`

### Python/SSH
- Test on target VM, not just locally
- Environment parity critical
- SSH keys must be configured
- Key files: `pyproject.toml`, `requirements.txt`

## Current Status

- [x] 3-Phase workflow defined
- [x] Multi-platform support (Python, C#/NT, React/Supabase, n8n)
- [x] Design review phase documented
- [x] Implementation phase documented
- [x] Code review phase documented
- [x] Bug fix & revision phase documented
- [x] Handoff protocol documented
- [x] Profile configurations defined
- [x] Platform auto-detection
- [x] ISSUES.md template created
- [ ] KiloCode agent mode testing
- [ ] OpenClaw orchestration (future)

## Related Documents

- [[computer-use-v3-handoff]] - First project using this workflow
- [[skills/computer-use-v3/DESIGN.md]] - Example design doc
- [[skills/computer-use-v3/IMPLEMENTATION.md]] - Example implementation doc
- [[skills/computer-use-v3/DESIGN_REVIEW_CHECKLIST.md]] - Example design review checklist
- [[skills/computer-use-v3/REVIEW_CHECKLIST.md]] - Example code review checklist
- [[skills/computer-use-v3/KILOCODE.md]] - Example agent config
- [[docs/kilocode/AGENTIC_WORKFLOW_GUIDE.md]] - Detailed workflow guide
- [[Agentic Coding/Bug Fix Mode]] - Bug fix mode detailed guide
- [[Agentic Coding/Workflow Phases]] - Phase-by-phase breakdown
