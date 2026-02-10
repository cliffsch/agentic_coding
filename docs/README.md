# Autonomous Workflow Guide

> **Start here** for all agentic coding workflows - from design to deployment

This is your single reference for the complete autonomous development workflow. Follow the process below, which will guide you to other documents only when needed.

---

## The Process (3 Main Steps)

```
┌─────────────────────────────────────────────────────────────┐
│  1. DESIGN SESSION (Interactive - You + Claude Code)        │
│     • Collaborative design and planning                      │
│     • Creates: DESIGN.md, IMPLEMENTATION.md                  │
├─────────────────────────────────────────────────────────────┤
│  2. PRE-FLIGHT CHECK (5 minutes - You)                      │
│     • Verify configuration before handoff                    │
│     • Prevents 90% of early failures                         │
├─────────────────────────────────────────────────────────────┤
│  3. AUTONOMOUS EXECUTION (Hands-off - Kilocode)             │
│     • Design review → Implementation → Test → Code review    │
│     • Monitor progress, intervene if blocked                 │
└─────────────────────────────────────────────────────────────┘
```

---

## Step 1: Design Session

### When You Have a New Feature or Project

Start an interactive session with Claude Code:

```
You: "I want to [describe your feature/project]. Let's do a design session."

Claude: [Asks clarifying questions, explores codebase, creates design docs]
```

**What Gets Created:**
- `DESIGN.md` - Architecture and specifications
- `IMPLEMENTATION.md` - Phased execution plan
- `DESIGN_REVIEW_START.md` - Handoff signal file
- `NFR_OVERRIDES.md` - If needed

**Design Session Tips:**
- Be specific about constraints and requirements
- Reference existing code patterns
- Clarify testing requirements
- Ask to "prepare for handoff" when ready

📖 **Need help with design sessions?** See [DESIGN_SESSION_GUIDE.md](DESIGN_SESSION_GUIDE.md)

---

## Step 2: Pre-Flight Check (5 Minutes)

**⚠️ CRITICAL: Run this checklist before starting the autonomous workflow!**

### Quick Checks

```bash
# 1. Model names (must have kilo/ prefix)
grep MODEL_ ~/Documents/agentic_coding/config.sh
# Should show: kilo/provider/model ✅

# 2. Dev server port (React only)
grep -A 3 "server:" vite.config.ts
# Note the actual port (might not be 5173!)

# 3. Environment variables
cat .env.local
# Verify all required vars are set (check .env.example)

# 4. Test dev server (React only)
npm run dev  # In separate terminal, leave running
curl http://localhost:PORT  # Should return HTML

# 5. Git status
git status  # Should be clean or only design docs
```

### Common Fixes

| Issue | Fix |
|-------|-----|
| Models missing `kilo/` | Add prefix: `kilo/moonshotai/kimi-k2.5` |
| Wrong port in docs | Search/replace `5173` with actual port |
| Missing env vars | Copy from `.env.example`, add real values |
| Dev server not running | Run `npm run dev` in separate terminal |

📋 **Detailed checklist:** [PRE_FLIGHT_CHECKLIST.md](PRE_FLIGHT_CHECKLIST.md)

---

## Step 3: Start Autonomous Workflow

### Launch the Workflow

```bash
cd ~/Documents/agentic_coding

# Standard (artifacts in project root)
./scripts/run-agentic-workflow.sh \
  --project-dir /path/to/project \
  -t react-supabase \
  -v

# Or with subdirectory for artifacts
./scripts/run-agentic-workflow.sh \
  --project-dir "/path/to/project/_plans/_Code Merge" \
  -t react-supabase \
  -v
```

### What Happens Next (Automated)

1. **Design Review** (10-20 min) - Validates design docs
2. **Implementation** (1-10 hours) - Executes phases from IMPLEMENTATION.md
3. **Browser Testing** (30-90 min) - Tests in real browser (React only)
4. **Code Review** (30-60 min) - Reviews all changes
5. **Revision** (if needed) - Fixes issues, repeats review (up to 3x)

### Monitoring Progress

**First 30 minutes** - Watch for these signals:
```bash
# Check for success indicators
ls -la /path/to/project/*.md | grep -E "APPROVED|COMPLETE"

# Check for problems
ls -la /path/to/project/*.md | grep -E "BLOCKED|ISSUES"
```

**Throughout execution:**
- ✅ Design review completes → `DESIGN_APPROVED.md`
- ✅ Each phase completes → Commits appear
- ✅ Tests pass → `BROWSER_TEST_COMPLETE.md`
- ✅ Review passes → `CODE_REVIEW_COMPLETE.md`

**🔴 Red flags:**
- `BLOCKED.md` appears in first 2 phases → [Troubleshoot](#troubleshooting)
- No activity for > 1 hour → [Intervene](#when-to-intervene)
- Dev server crashes → Restart it

### Timeline Estimates

| Scope | Duration | Description |
|-------|----------|-------------|
| **Small** | 2-4 hours | Single feature, < 10 files |
| **Medium** | 4-8 hours | Multi-file feature, 10-30 files |
| **Large** | 15-25 hours | Major integration, 50+ files |

---

## When to Intervene

### Intervene Immediately If:

1. **`BLOCKED.md` appears in Phase 1-2**
   - Usually configuration issue
   - Check error, fix, restart

2. **Same phase retries > 3 times**
   - Phase probably too large
   - Break into smaller sub-phases

3. **Dev server crashes** (React)
   - Restart: `npm run dev`
   - Resume: `./scripts/run-agentic-workflow.sh --browser-test`

4. **No activity for > 1 hour**
   - Check if workflow hung
   - Review logs, consider restarting

### Let It Run If:

- Iterative review loop is cycling (normal)
- Commits appearing regularly (progress)
- Phase completion signals being created (working)

---

## Troubleshooting

### Quick Error Fixes

| Error | Quick Fix |
|-------|-----------|
| `ProviderModelNotFoundError` | Add `kilo/` prefix to models in config.sh |
| `Connection refused` (port) | Start dev server, check port in vite.config |
| `Cannot connect to database` | Add env vars to `.env.local` |
| `File not found` | Check PROJECT_DIR in DESIGN_REVIEW_START.md |
| Workflow hangs | Check dev server, restart workflow |

🔧 **Full troubleshooting guide:** [TROUBLESHOOTING.md](TROUBLESHOOTING.md)

---

## Success Criteria

Your workflow completed successfully when:

- [x] All phases completed (`IMPLEMENTATION_COMPLETE.md`)
- [x] Browser testing passed (`BROWSER_TEST_COMPLETE.md`)
- [x] Code review approved (`CODE_REVIEW_COMPLETE.md`)
- [x] Build succeeds (`npm run build`)
- [x] No `BLOCKED.md` or persistent `ISSUES.md`
- [x] Manual verification passes

**Next:** Commit results, deploy, celebrate! 🎉

---

## Common Scenarios

### Scenario 1: Small Feature (React Component)

```bash
# 1. Design session (10 min)
You: "Add a UserProfile component with avatar and bio"
Claude: [Creates design docs]

# 2. Pre-flight (2 min)
grep MODEL_ config.sh  # Check models
npm run dev            # Start server

# 3. Run workflow (2-4 hours)
./scripts/run-agentic-workflow.sh -p /path/to/project -t react-supabase

# 4. Monitor
# Phases complete quickly, all tests pass
```

### Scenario 2: Large Integration (Multi-Site Merge)

```bash
# 1. Design session (30 min)
You: "Merge leadership prototype with main app"
Claude: [Explores code, creates detailed design]

# 2. Pre-flight (5 min)
# Check models, port, env vars, break large phases

# 3. Run workflow (15-25 hours)
./scripts/run-agentic-workflow.sh -p /path/to/project -t react-supabase -v

# 4. Monitor actively first 2 hours
# Let run overnight, check morning
```

### Scenario 3: Bug Fix Mode

```bash
# 1. Create ISSUES.md
cat > ISSUES.md << 'EOF'
# Issues to Fix

## Issue 1: Login button not working
- Button click doesn't trigger auth
- Console shows "undefined handler"
- Fix: Add onClick handler

## Issue 2: Styling broken on mobile
- Layout wraps incorrectly
- Fix: Update responsive breakpoints
EOF

# 2. Run bug fix mode
./scripts/run-agentic-workflow.sh -p /path/to/project -b

# 3. Agent fixes issues, tests, commits
```

---

## Configuration Files

### config.sh (Models and Settings)

Located at: `~/Documents/agentic_coding/config.sh`

**Key settings:**
```bash
# Models (must have kilo/ prefix!)
export MODEL_DESIGN_REVIEW="kilo/moonshotai/kimi-k2.5"
export MODEL_IMPLEMENTATION="kilo/minimax/minimax-m2.1"
export MODEL_CODE_REVIEW="kilo/moonshotai/kimi-k2.5"

# Workflow options
export MAX_RETRIES=3        # Review iterations
export AUTO_APPROVE="true"  # For pipeline mode
export VERBOSE="false"      # Show agent output
```

### Platform Types

| Platform | Use For | Example |
|----------|---------|---------|
| `react-supabase` | Web apps with Supabase | SPA, dashboard, app |
| `ninjatrader` | NT8 indicators/strategies | Trading indicators |
| `python-ssh` | Python projects, VMs | Backend services |
| `n8n` | n8n workflows | Automation |

---

## Quick Commands Reference

```bash
# Start full workflow
./scripts/run-agentic-workflow.sh -p /path/to/project -t react-supabase

# Run specific phase
./scripts/run-agentic-workflow.sh -p /path/to/project --design-review
./scripts/run-agentic-workflow.sh -p /path/to/project --implementation
./scripts/run-agentic-workflow.sh -p /path/to/project --browser-test
./scripts/run-agentic-workflow.sh -p /path/to/project --code-review

# Bug fix mode
./scripts/run-agentic-workflow.sh -p /path/to/project -b

# Check status
./scripts/run-agentic-workflow.sh -p /path/to/project --status

# Clean signals (restart)
./scripts/run-agentic-workflow.sh -p /path/to/project --clean

# Verbose mode (see agent output)
./scripts/run-agentic-workflow.sh -p /path/to/project -v
```

---

## Getting Help

### Documentation Index

- **This file (README.md)** - Start here, covers everything
- [DESIGN_SESSION_GUIDE.md](DESIGN_SESSION_GUIDE.md) - Deep dive on design sessions
- [PRE_FLIGHT_CHECKLIST.md](PRE_FLIGHT_CHECKLIST.md) - Detailed pre-flight checks
- [HANDOFF_PROTOCOL.md](HANDOFF_PROTOCOL.md) - Complete handoff reference
- [TROUBLESHOOTING.md](TROUBLESHOOTING.md) - Error solutions

### Support

1. Check [TROUBLESHOOTING.md](TROUBLESHOOTING.md) for your error
2. Review `BLOCKED.md` or `ISSUES.md` in project
3. Check logs in terminal output
4. Create issue at [github.com/anthropics/claude-code/issues](https://github.com/anthropics/claude-code/issues)

---

## Tips for Success

✅ **Do:**
- Run pre-flight check every time
- Keep phases small (<50 files)
- Monitor first 2 hours
- Commit design docs before starting
- Keep dev server running (React)

❌ **Don't:**
- Skip pre-flight check
- Assume port 5173
- Create phases > 100 files
- Forget environment variables
- Leave workflow unmonitored for days

---

**Ready to start?** Follow the 3 steps at the top! 🚀
