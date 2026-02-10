# Pre-Flight Checklist

> Quick reference for verifying configuration before starting autonomous workflow

**Run this checklist BEFORE executing `run-agentic-workflow.sh` to avoid early failures.**

---

## ✅ Quick Checks (5 minutes)

### 1. Model Configuration

```bash
# Check models have kilo/ prefix
grep MODEL_ ~/Documents/agentic_coding/config.sh

# Expected output:
# export MODEL_DESIGN_REVIEW="kilo/moonshotai/kimi-k2.5"
# export MODEL_IMPLEMENTATION="kilo/minimax/minimax-m2.1"
# export MODEL_CODE_REVIEW="kilo/moonshotai/kimi-k2.5"
```

**✅ PASS**: All models have `kilo/` prefix
**❌ FAIL**: Add `kilo/` prefix to all model names in config.sh

---

### 2. Dev Server Port (React/Vite Projects Only)

```bash
# Check actual port configuration
cd /path/to/project
grep -A 3 "server:" vite.config.ts

# Example output:
# server: {
#   host: "::",
#   port: 8080,  // <-- This is your actual port
# }
```

**✅ PASS**: Port is documented in DESIGN.md and IMPLEMENTATION.md
**❌ FAIL**: Search/replace `localhost:5173` with `localhost:ACTUAL_PORT` in all docs

**Verify dev server works:**
```bash
# Terminal 1: Start dev server
npm run dev

# Terminal 2: Test
curl -s -o /dev/null -w "%{http_code}" http://localhost:PORT
# Expected: 200
```

---

### 3. Environment Variables

```bash
# Compare .env.example vs .env.local
cd /path/to/project
diff <(grep -v "^#" .env.example | grep "=" | sort) \
     <(grep -v "^#" .env.local | grep "=" | sort)

# Check for missing vars
```

**Required for React/Supabase:**
- `VITE_SUPABASE_URL`
- `VITE_SUPABASE_ANON_KEY`
- `VITE_LEADERSHIP_SUPABASE_URL` (if dual-database)
- `VITE_LEADERSHIP_SUPABASE_ANON_KEY` (if dual-database)

**✅ PASS**: All required vars present in `.env.local`
**❌ FAIL**: Add missing vars before starting workflow

---

### 4. Phase Sizing

```bash
# Check if any phase is too large
cat IMPLEMENTATION.md | grep "Phase [0-9]:"
```

**Guidelines:**
- ✅ **Small**: < 10 files, < 200 LOC
- ✅ **Medium**: 10-30 files, 200-500 LOC
- ⚠️ **Large**: 30-50 files, 500-2000 LOC
- 🔴 **Too Large**: > 50 files, > 2000 LOC

**If phase is too large:**
1. Break into sub-phases (Phase 1a, 1b, 1c)
2. Update IMPLEMENTATION.md
3. Re-validate

---

### 5. Git Repository State

```bash
cd /path/to/project
git status

# Expected: Clean working tree or only committed design docs
```

**✅ PASS**: Clean or only design docs
**❌ FAIL**: Commit or stash changes before starting

---

### 6. Project Directory Structure (If Using Subdirectory)

```bash
# If using _plans subdirectory for artifacts:
ls "/path/to/project/_plans/_Code Merge/"
# Should show: DESIGN.md, IMPLEMENTATION.md, DESIGN_REVIEW_START.md
```

**If using subdirectory, verify DESIGN_REVIEW_START.md has:**
```markdown
## Working Directory Structure

**CODE ROOT**: /path/to/project (parent directory)
**PLANS/ARTIFACTS**: /path/to/project/_plans/_Code Merge (this directory)

⚠️ **CRITICAL**: All code changes must be performed in the CODE ROOT.
```

---

## 🚀 Ready to Launch

If all checks pass, start the workflow:

```bash
cd ~/Documents/agentic_coding

# Standard (artifacts in project root)
./scripts/run-agentic-workflow.sh \
  --project-dir /path/to/project \
  -t react-supabase \
  -v

# With subdirectory (artifacts in _plans)
./scripts/run-agentic-workflow.sh \
  --project-dir "/path/to/project/_plans/_Code Merge" \
  -t react-supabase \
  -v
```

---

## 🔧 Troubleshooting

| Problem | Solution |
|---------|----------|
| `ProviderModelNotFoundError` | Add `kilo/` prefix to model names |
| `Connection refused` (browser test) | Check port, start dev server |
| `Cannot connect to database` | Add env vars to `.env.local` |
| `File not found` errors | Check PROJECT_DIR, verify directory structure |
| Workflow hangs on Phase 1 | Phase too large, break into sub-phases |

---

## 📊 Expected Timeline

**For large integrations (100+ files, 30+ routes):**
- Design Review: 10-20 minutes
- Phase 1 (Merge files): 1-3 hours
- Phase 2 (Config): 30-60 minutes
- Phase 3 (Layout): 30-60 minutes
- Phase 4 (Routes): 2-4 hours
- Phase 5 (Testing): 3-5 hours
- Browser Testing: 30-90 minutes
- Code Review: 30-60 minutes
- Revisions (if needed): 1-3 hours per iteration

**Total: 15-25 hours** for complex integrations

---

## 📝 Post-Launch Monitoring

### First 30 Minutes
- [ ] Design review completes
- [ ] DESIGN_APPROVED.md created
- [ ] Phase 1 starts
- [ ] No BLOCKED.md appears

### First 2 Hours
- [ ] Phase 1 completes
- [ ] First commit appears
- [ ] Phase 2 starts
- [ ] No persistent errors

### Throughout Workflow
- [ ] Signal files updating regularly
- [ ] Commits appearing for each phase
- [ ] Dev server still running (React)
- [ ] No BLOCKED.md

**Intervene if:**
- BLOCKED.md appears in first 2 phases
- No activity for > 1 hour
- Same phase retries > 3 times
- Browser testing fails consistently

---

## ✅ Success Criteria

Workflow complete when:
- [ ] IMPLEMENTATION_COMPLETE.md exists
- [ ] BROWSER_TEST_COMPLETE.md exists (React)
- [ ] CODE_REVIEW_COMPLETE.md exists
- [ ] Build succeeds: `npm run build`
- [ ] Manual verification passes
- [ ] No BLOCKED.md or persistent ISSUES.md

---

**For detailed information, see:**
- [HANDOFF_PROTOCOL.md](HANDOFF_PROTOCOL.md) - Complete handoff process
- [DESIGN_SESSION_GUIDE.md](DESIGN_SESSION_GUIDE.md) - Design session workflow
