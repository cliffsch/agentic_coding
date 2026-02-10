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

## Pre-Flight Configuration Check

**CRITICAL**: Verify these configuration items before starting the workflow to avoid early failures.

### 1. Model Configuration (Kilocode)

Kilocode requires the `kilo/` prefix for all model names in `config.sh`:

```bash
# ❌ WRONG - Missing kilo/ prefix
export MODEL_DESIGN_REVIEW="moonshotai/kimi-k2.5"
export MODEL_IMPLEMENTATION="minimax/minimax-m2.1"

# ✅ CORRECT - With kilo/ prefix
export MODEL_DESIGN_REVIEW="kilo/moonshotai/kimi-k2.5"
export MODEL_IMPLEMENTATION="kilo/minimax/minimax-m2.1"
export MODEL_CODE_REVIEW="kilo/moonshotai/kimi-k2.5"
```

**Verify models exist:**
```bash
kilocode models | grep -i "your-model-name"
```

**Common models:**
- Design/Review: `kilo/moonshotai/kimi-k2.5` or `kilo/z-ai/glm-4.7`
- Implementation: `kilo/minimax/minimax-m2.1` or `kilo/anthropic/claude-sonnet-4.5`
- Code Review: `kilo/moonshotai/kimi-k2.5` or `kilo/z-ai/glm-4.7`

### 2. React/Vite Port Configuration

**Do NOT assume port 5173!** Check the actual port configuration:

```bash
# Check vite.config.ts/js for port
cat vite.config.ts | grep -A 3 "server:"

# Example output:
# server: {
#   host: "::",
#   port: 8080,  // <-- Actual port
# }
```

**Update all documentation** with the correct port:
- `DESIGN.md` - Browser testing sections
- `IMPLEMENTATION.md` - All localhost URLs
- `BROWSER_TEST_CHECKLIST.md` - Test URLs

**Verify dev server is accessible:**
```bash
# Start dev server
npm run dev

# Test in another terminal
curl -s -o /dev/null -w "%{http_code}" http://localhost:PORT
# Should return: 200
```

### 3. Environment Variables

**For React/Supabase projects**, verify ALL required env vars are in `.env.local`:

```bash
# Check what's required
cat .env.example

# Verify what's set
cat .env.local

# Required for dual-database setups:
VITE_SUPABASE_URL=...                    # Main database
VITE_SUPABASE_ANON_KEY=...              # Main database
VITE_LEADERSHIP_SUPABASE_URL=...         # Second database (if applicable)
VITE_LEADERSHIP_SUPABASE_ANON_KEY=...   # Second database (if applicable)

# Also check for:
VITE_WEBHOOK_URL=...                     # Backend integrations
VITE_APP_BUGSNAG_KEY=...                # Error tracking
VITE_PUBLIC_POSTHOG_KEY=...             # Analytics
```

**Missing env vars will cause immediate failure** in Phase 2 (database configuration).

### 4. Unit of Work Sizing

**Phase sizing guidelines** for autonomous agents:

| Phase Scope | Lines of Code | Files Changed | Risk Level | Recommendation |
|-------------|---------------|---------------|------------|----------------|
| **Small** | < 200 LOC | 1-3 files | LOW | ✅ Ideal |
| **Medium** | 200-500 LOC | 3-10 files | MEDIUM | ✅ Good |
| **Large** | 500-2000 LOC | 10-30 files | HIGH | ⚠️ Consider breaking down |
| **Very Large** | > 2000 LOC | 30+ files | VERY HIGH | 🔴 Break into sub-phases |

**When to break down large phases:**

1. **File merges > 50 files**: Consider sub-phases
   - Phase 1a: Directory structure + core files
   - Phase 1b: Component files (batch 1)
   - Phase 1c: Component files (batch 2)
   - Phase 1d: Verification

2. **Route additions > 30 routes**: Consider grouping
   - Phase 4a: Add route group 1 (leadership)
   - Phase 4b: Add route group 2 (school-leader)
   - Phase 4c: Add route group 3 (admin)

3. **Complex refactoring**: Break by concern
   - Phase 3a: Update interfaces
   - Phase 3b: Implement logic
   - Phase 3c: Update consumers

**Trust the iterative review loop** (v4.3) to catch issues even with larger phases, but err on the side of smaller units when uncertain.

### 5. Project Directory Structure

**Option A: Artifacts in root** (simple)
```
/project-root/
├── src/
├── DESIGN.md               # Signal files in root
├── IMPLEMENTATION.md
└── DESIGN_REVIEW_START.md
```

**Option B: Artifacts in subdirectory** (organized)
```
/project-root/
├── src/
└── _plans/_Code Merge/     # Signal files here
    ├── DESIGN.md
    ├── IMPLEMENTATION.md
    └── DESIGN_REVIEW_START.md
```

**If using Option B:**
1. Create subdirectory: `mkdir -p /path/to/project/_plans/_Code\ Merge`
2. Move all `.md` files to subdirectory
3. **Update DESIGN_REVIEW_START.md** to clarify directory structure:
   ```markdown
   ## Working Directory Structure

   **CODE ROOT**: /path/to/project (parent directory)
   **PLANS/ARTIFACTS**: /path/to/project/_plans/_Code Merge (this directory)

   ⚠️ **CRITICAL**: All code changes must be performed in the CODE ROOT.
   ```
4. Run workflow with subdirectory path:
   ```bash
   ./scripts/run-agentic-workflow.sh \
     --project-dir "/path/to/project/_plans/_Code Merge"
   ```

### 6. Dev Server Requirements (React Projects)

**Browser testing requires the dev server to be running** throughout the workflow.

**Setup:**
```bash
# Terminal 1: Start dev server (leave running)
cd /path/to/project
npm run dev

# Terminal 2: Run workflow
cd /path/to/agentic_coding
./scripts/run-agentic-workflow.sh --project-dir /path/to/project
```

**Kilocode browser testing:**
- Uses Playwright/Puppeteer via MCP
- Connects to `http://localhost:PORT` directly
- **No remote browser relay needed** for local development
- Spawns its own browser instance (headless or headed)

**If dev server stops:**
- Browser testing will fail
- Restart dev server and re-run `--browser-test` phase

### 7. Platform-Specific Configuration

#### React/Supabase
- [ ] `package.json` has `dev` script
- [ ] Vite port documented in DESIGN.md
- [ ] Supabase credentials in `.env.local`
- [ ] MCP Supabase server configured (if using)
- [ ] Build succeeds: `npm run build`

#### NinjaTrader
- [ ] NT8 custom folder accessible
- [ ] Windows remote accessible (if cross-machine)
- [ ] AutoHotkey harvester running (Windows)
- [ ] Git remote configured for sync

#### Python/SSH
- [ ] SSH keys configured
- [ ] Remote VM accessible
- [ ] Python environment documented
- [ ] Dependencies in `requirements.txt` or `pyproject.toml`

## Pre-Flight Checklist Summary

Run through this checklist **before** starting the workflow:

```bash
# 1. Verify models
kilocode models | grep "$(grep MODEL_DESIGN_REVIEW config.sh | cut -d'"' -f2)"

# 2. Check port (React)
grep -A 3 "server:" vite.config.ts

# 3. Verify env vars
diff <(grep -v "^#" .env.example | grep "=") <(grep -v "^#" .env.local | grep "=")

# 4. Test dev server (React)
curl -s -o /dev/null -w "%{http_code}" http://localhost:PORT

# 5. Verify git state
git status

# 6. Check phase sizing
wc -l IMPLEMENTATION.md  # Should have reasonable phase breakdown
```

**If any check fails, fix before starting the workflow!**

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
8. **Verify Configuration**: Run pre-flight checklist before starting workflow
9. **Size Appropriately**: Break large phases (>50 files, >30 routes) into sub-phases
10. **Test Infrastructure**: Verify dev server, databases, and tools before handoff

## Common Pitfalls & Solutions

### Pitfall 1: Wrong Model Names
**Symptom**: `ProviderModelNotFoundError` immediately on workflow start

**Cause**: Missing `kilo/` prefix in model names

**Solution**:
```bash
# Check config.sh
grep MODEL_ config.sh

# Should see:
export MODEL_DESIGN_REVIEW="kilo/moonshotai/kimi-k2.5"  # ✅
# NOT:
export MODEL_DESIGN_REVIEW="moonshotai/kimi-k2.5"      # ❌
```

### Pitfall 2: Wrong Port in Documentation
**Symptom**: Browser testing fails, "Connection refused" errors

**Cause**: Documentation assumes default port 5173, but project uses different port

**Solution**:
1. Check `vite.config.ts` for actual port
2. Search/replace all `localhost:5173` with correct port in DESIGN.md and IMPLEMENTATION.md
3. Verify with `curl http://localhost:ACTUAL_PORT`

### Pitfall 3: Missing Environment Variables
**Symptom**: Phase 2 fails with "Cannot read properties of undefined" or database connection errors

**Cause**: Required env vars not in `.env.local`

**Solution**:
1. Compare `.env.example` vs `.env.local`
2. Add all required vars before starting workflow
3. For dual-database setups, ensure BOTH sets of credentials are present

### Pitfall 4: Phase Too Large
**Symptom**: Agent hits context limits, BLOCKED.md created, or takes excessive time (>3 hours)

**Cause**: Phase includes too many files (>50) or routes (>30)

**Solution**:
1. Pause workflow
2. Return to design session
3. Break phase into 2-3 sub-phases
4. Update IMPLEMENTATION.md
5. Restart workflow

### Pitfall 5: Dev Server Not Running
**Symptom**: Browser testing phase fails immediately

**Cause**: Dev server wasn't started before workflow

**Solution**:
1. Start dev server: `npm run dev`
2. Verify with `curl http://localhost:PORT`
3. Re-run workflow with `--browser-test` flag to retry

### Pitfall 6: Artifacts in Wrong Directory
**Symptom**: Agent can't find code files, only sees signal files

**Cause**: PROJECT_DIR points to subdirectory with artifacts, not code root

**Solution**:
1. Update DESIGN_REVIEW_START.md to clarify directory structure
2. Add "Working Directory Structure" section specifying CODE ROOT vs PLANS directory
3. Agent will navigate to correct directory based on instructions

## Troubleshooting Quick Reference

| Error | Quick Check | Fix |
|-------|-------------|-----|
| `ProviderModelNotFoundError` | `grep MODEL_ config.sh` | Add `kilo/` prefix |
| `Connection refused` (port) | `cat vite.config.ts \| grep port` | Update docs with correct port |
| `Cannot connect to database` | `cat .env.local` | Add missing env vars |
| `Context limit exceeded` | Check phase file count | Break into sub-phases |
| `Browser test failed` | `curl http://localhost:PORT` | Start dev server |
| `File not found` errors | Check PROJECT_DIR | Verify directory structure in signal files |

## Post-Handoff Best Practices

### First Hour Monitoring

Watch for these indicators of success/failure:

**✅ Good Signs:**
- Design review completes in 10-20 minutes
- Phase 1 starts within 5 minutes of design approval
- First commit appears within 1 hour
- No BLOCKED.md created
- Progress signals updating regularly

**🔴 Warning Signs:**
- No activity for > 30 minutes
- BLOCKED.md appears
- Multiple retry attempts on same phase
- Dev server crashes
- Excessive error messages in terminal

### When to Intervene

**Intervene immediately if:**
1. BLOCKED.md appears in first 2 phases (likely config issue)
2. Same phase retries > 3 times (phase too large)
3. Browser testing fails consistently (dev server issue)
4. Agent appears stuck (no signal file updates for > 1 hour)

**Let it run if:**
1. Iterative review loop is cycling normally
2. Commits are appearing regularly
3. Phase completion signals are being created
4. Expected to take 15-20 hours for large integrations

### Success Criteria

Workflow completed successfully when:
- [ ] All phases completed (check IMPLEMENTATION_COMPLETE.md)
- [ ] Browser testing passed
- [ ] Code review approved (or revisions completed)
- [ ] Build succeeds
- [ ] Main functionality verified manually
- [ ] No BLOCKED.md or persistent ISSUES.md
