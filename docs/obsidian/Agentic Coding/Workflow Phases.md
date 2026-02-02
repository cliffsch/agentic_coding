---
tags:
  - ai
  - automation
  - kilo-code
  - workflow
  - phases
---

# Workflow Phases

> Detailed breakdown of each phase in the Agentic Coding Workflow.

## Phase Overview

| Phase | Model | Mode | Purpose | Entry Signal | Exit Signal |
|-------|-------|------|---------|--------------|-------------|
| **Phase 1** | Kimi K2.5 | Review | Validate design before implementation | DESIGN_REVIEW_START.md | DESIGN_APPROVED.md or DESIGN_ISSUES.md |
| **Phase 2** | Minimax M2.1 | Agent | Implement all features | IMPLEMENTATION_START.md | IMPLEMENTATION_COMPLETE.md or BLOCKED.md |
| **Phase 3** | Kimi K2.5 | Review | Validate implementation | REVIEW_START.md | REVIEW_APPROVED.md or REVIEW_ISSUES.md |
| **Phase 5** | Minimax M2.1 | Code | Fix issues from ISSUES.md | BUGFIX_START.md | BUGFIX_COMPLETE.md or BUGFIX_BLOCKED.md |

---

## Phase 1: Design Review

### Purpose
Validate DESIGN.md and IMPLEMENTATION.md completeness BEFORE implementation starts. Catch gaps and ambiguities early.

### Model
- **Model**: Kimi K2.5 (Moonshot AI)
- **Mode**: Review/Analysis
- **Cost**: Free

### Responsibilities
1. Read DESIGN.md, IMPLEMENTATION.md, and DESIGN_REVIEW_CHECKLIST.md completely
2. Check EVERY item in DESIGN_REVIEW_CHECKLIST.md - do not skip
3. Create a traceability matrix mapping DESIGN.md sections to IMPLEMENTATION.md phases
4. Identify implicit requirements (config settings without code, cleanup without logic, etc.)
5. Do NOT modify files - only report findings
6. Create detailed DESIGN_REVIEW_RESULTS.md

### Exit Criteria
- **Approved**: Create `DESIGN_APPROVED.md` - proceed to implementation
- **Issues Found**: Create `DESIGN_ISSUES.md` - fix issues before proceeding

### Signal Files
| Signal | Created By | Meaning |
|--------|------------|---------|
| `DESIGN_REVIEW_START.md` | Orchestrator | Design review initiated |
| `DESIGN_REVIEW_RESULTS.md` | Design Review Agent | Review findings documented |
| `DESIGN_APPROVED.md` | Design Review Agent | Design is complete and ready |
| `DESIGN_ISSUES.md` | Design Review Agent | Design has problems |

### Typical Duration
- Small project: 5-10 minutes
- Medium project: 10-20 minutes
- Large project: 20-40 minutes

---

## Phase 2: Implementation

### Purpose
Execute all phases in IMPLEMENTATION.md to build the software.

### Model
- **Model**: Minimax M2.1
- **Mode**: Agent/Autonomous
- **Cost**: $0.18 per 1M tokens (input + output)

### Phase Execution
The implementation is broken into sub-phases:

1. **Phase 1**: Project Structure (pyproject.toml, requirements.txt, __init__.py)
2. **Phase 2**: Configuration (config.py, tests/test_config.py)
3. **Phase 3**: Session Manager (session.py, tests/test_session.py)
4. **Phase 4**: AskUI Wrapper (askui_wrapper.py, tests/test_askui_wrapper.py)
5. **Phase 5**: Controller (controller.py)
6. **Phase 6**: CLI Entry Point (__main__.py)
7. **Phase 7**: E2E Testing on VM (deploy, test, verify)
8. **Phase 8**: Documentation (SKILL.md)

### Constraints
- No clarifying questions (all info in docs)
- Max 3 retries per phase
- Document blockers in BLOCKED.md and stop
- Auto-approve safe operations only

### Exit Criteria
- **Complete**: Create `IMPLEMENTATION_COMPLETE.md` - proceed to code review
- **Blocked**: Create `BLOCKED.md` - manual intervention required

### Signal Files
| Signal | Created By | Meaning |
|--------|------------|---------|
| `IMPLEMENTATION_START.md` | Orchestrator | Ready to implement |
| `IMPLEMENTATION_COMPLETE.md` | Implementation Agent | All phases done |
| `BLOCKED.md` | Implementation Agent | Stuck after 3 retries |
| `PROGRESS.md` | Implementation Agent | Current status (updated continuously) |

### Typical Duration
- Small project: 10-30 minutes
- Medium project: 30-90 minutes
- Large project: 90-180 minutes

---

## Phase 3: Code Review

### Purpose
Validate implementation against specifications and ensure quality.

### Model
- **Model**: Kimi K2.5 (Moonshot AI)
- **Mode**: Review/Validation
- **Cost**: Free

### Agent Rules
1. Read REVIEW_CHECKLIST.md completely
2. Check each item systematically - do not skip
3. Run all tests: `pytest tests/ -v`
4. Run E2E tests on VM
5. Verify all commits match IMPLEMENTATION.md specifications
6. Check for TODO/FIXME comments
7. Do NOT fix issues yourself - only report them
8. Create detailed REVIEW_RESULTS.md

### Decision
- **APPROVED**: Create `REVIEW_APPROVED.md` - project complete
- **ISSUES FOUND**: Create `REVIEW_ISSUES.md` - needs fixes

### Maximum 2 review cycles** before human escalation.

### Signal Files
| Signal | Created By | Meaning |
|--------|------------|---------|
| `REVIEW_START.md` | Orchestrator | Ready to review |
| `REVIEW_APPROVED.md` | Code Review Agent | All checks passed |
| `REVIEW_ISSUES.md` | Code Review Agent | Problems found, needs fixes |

### Typical Duration
- Small project: 5-15 minutes
- Medium project: 15-30 minutes
- Large project: 30-60 minutes

---

## Phase 5: Bug Fix & Revision

### Purpose
Fix issues, correct misinterpretations, and implement improvements after initial implementation.

### Model
- **Model**: Minimax M2.1
- **Mode**: Code/Autonomous
- **Cost**: $0.18 per 1M tokens (input + output)

### Trigger
Create `ISSUES.md` in project folder with list of issues.

### Priority Rules
1. **ISSUES.md takes HIGHEST priority** - User's explicit changes override original design
2. Use original design documents only for context and understanding
3. If ISSUES.md contradicts DESIGN.md, follow ISSUES.md
4. Maintain consistency with existing codebase patterns
5. Do NOT revert changes that were intentionally made per ISSUES.md

### Agent Behavior
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

### Exit Criteria
- **Complete**: Create `BUGFIX_COMPLETE.md` - all issues resolved
- **Blocked**: Create `BUGFIX_BLOCKED.md` - unable to proceed

### Signal Files
| Signal | Created By | Meaning |
|--------|------------|---------|
| `BUGFIX_START.md` | Orchestrator | Bug fix mode initiated |
| `BUGFIX_PROGRESS.md` | Bug Fix Agent | Current progress (updated continuously) |
| `BUGFIX_COMPLETE.md` | Bug Fix Agent | All issues resolved |
| `BUGFIX_BLOCKED.md` | Bug Fix Agent | Unable to proceed after 3 attempts |

### Typical Duration
- 1-2 issues: 5-15 minutes
- 3-5 issues: 15-30 minutes
- 6-10 issues: 30-60 minutes

---

## Phase Transitions

### Normal Flow
```
Phase 1 (Design Review)
    ↓ (DESIGN_APPROVED.md)
Phase 2 (Implementation)
    ↓ (IMPLEMENTATION_COMPLETE.md)
Phase 3 (Code Review)
    ↓ (REVIEW_APPROVED.md)
✅ COMPLETE
```

### With Bug Fixes
```
Phase 1 (Design Review)
    ↓ (DESIGN_APPROVED.md)
Phase 2 (Implementation)
    ↓ (IMPLEMENTATION_COMPLETE.md)
Phase 3 (Code Review)
    ↓ (REVIEW_APPROVED.md)
[User creates ISSUES.md]
Phase 5 (Bug Fix)
    ↓ (BUGFIX_COMPLETE.md)
✅ COMPLETE
```

### Error Handling
```
Phase 1 (Design Review)
    ↓ (DESIGN_ISSUES.md)
❌ Fix issues, restart Phase 1

Phase 2 (Implementation)
    ↓ (BLOCKED.md)
❌ Manual intervention, restart Phase 2

Phase 3 (Code Review)
    ↓ (REVIEW_ISSUES.md)
❌ Fix issues, restart Phase 3 (max 2 cycles)

Phase 5 (Bug Fix)
    ↓ (BUGFIX_BLOCKED.md)
❌ Update ISSUES.md, restart Phase 5
```

---

## Running Individual Phases

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

---

## Related Documents

- [[Agentic Coding/Bug Fix Mode]] - Detailed bug fix mode guide
- [[cliffnet/agentic-coding-workflow]] - Main workflow documentation
- [[templates/common/ISSUES_TEMPLATE.md]] - ISSUES.md template
