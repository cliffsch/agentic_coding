# Troubleshooting Guide

> Common errors and solutions for the agentic workflow system

---

## Quick Error Lookup

| Error Message | Section | Quick Fix |
|---------------|---------|-----------|
| `ProviderModelNotFoundError` | [Models](#model-errors) | Add `kilo/` prefix |
| `Connection refused` | [Browser Testing](#browser-testing-errors) | Start dev server |
| `Cannot connect to Supabase` | [Database](#database-errors) | Check env vars |
| `File not found` | [File System](#file-system-errors) | Check PROJECT_DIR |
| `Context limit exceeded` | [Phase Sizing](#phase-too-large) | Break into sub-phases |
| Workflow hangs | [Workflow Hangs](#workflow-hangs) | Check logs, intervene |

---

## Model Errors

### ProviderModelNotFoundError

**Error:**
```
ProviderModelNotFoundError: ProviderModelNotFoundError
 data: {
  providerID: "moonshotai",
  modelID: "kimi-k2.5",
  suggestions: [],
}
```

**Cause:** Missing `kilo/` prefix in model configuration

**Solution:**
```bash
# Edit config.sh
vim ~/Documents/agentic_coding/config.sh

# Change FROM:
export MODEL_DESIGN_REVIEW="moonshotai/kimi-k2.5"

# Change TO:
export MODEL_DESIGN_REVIEW="kilo/moonshotai/kimi-k2.5"

# Verify model exists:
kilocode models | grep "kimi-k2.5"
```

**Alternative models:**
- Design/Review: `kilo/z-ai/glm-4.7`, `kilo/anthropic/claude-sonnet-4.5`
- Implementation: `kilo/minimax/minimax-m2.1`, `kilo/anthropic/claude-sonnet-4.5`

---

### Model Rate Limit Exceeded

**Error:**
```
RateLimitError: Rate limit exceeded for provider
```

**Cause:** Too many requests to model provider

**Solution:**
```bash
# Option 1: Wait and retry
sleep 60
./scripts/run-agentic-workflow.sh --implementation  # Resume

# Option 2: Switch to alternate model
# Edit config.sh
export MODEL_IMPLEMENTATION="kilo/anthropic/claude-sonnet-4.5"

# Option 3: Use free tier alternatives
export MODEL_IMPLEMENTATION="kilo/minimax/minimax-m2.1:free"
export MODEL_DESIGN_REVIEW="kilo/z-ai/glm-4.7:free"
```

---

## Browser Testing Errors

### Connection Refused (Port)

**Error:**
```
Error: connect ECONNREFUSED 127.0.0.1:5173
```

**Cause 1:** Dev server not running

**Solution:**
```bash
# Start dev server
cd /path/to/project
npm run dev

# Verify
curl http://localhost:PORT
```

**Cause 2:** Wrong port in documentation

**Solution:**
```bash
# Check actual port
grep -A 3 "server:" vite.config.ts
# Example output: port: 8080

# Update all docs
cd /path/to/project/_plans/_Code\ Merge
sed -i '' 's/localhost:5173/localhost:8080/g' DESIGN.md
sed -i '' 's/localhost:5173/localhost:8080/g' IMPLEMENTATION.md

# Restart workflow
./scripts/run-agentic-workflow.sh --browser-test
```

---

### Browser Testing Timeout

**Error:**
```
Browser test failed: Navigation timeout exceeded
```

**Cause:** Page takes too long to load or crashes

**Solution:**
```bash
# Check dev server console for errors
# Common causes:
# - Missing environment variables
# - JavaScript syntax errors
# - Infinite loops in React components

# Fix errors, then restart
npm run dev  # Check console output
./scripts/run-agentic-workflow.sh --browser-test
```

---

## Database Errors

### Cannot Connect to Supabase

**Error:**
```
Error: Invalid Supabase URL or anonymous key
```

**Cause:** Missing or incorrect environment variables

**Solution:**
```bash
# Check what's set
cat .env.local

# Check what's required
cat .env.example

# Add missing vars
echo 'VITE_SUPABASE_URL=https://your-project.supabase.co' >> .env.local
echo 'VITE_SUPABASE_ANON_KEY=your-anon-key' >> .env.local

# For dual-database setups:
echo 'VITE_LEADERSHIP_SUPABASE_URL=...' >> .env.local
echo 'VITE_LEADERSHIP_SUPABASE_ANON_KEY=...' >> .env.local

# Restart dev server
npm run dev
```

---

### RLS Policy Error

**Error:**
```
Error: new row violates row-level security policy
```

**Cause:** Database RLS policies blocking operations

**Solution:**
```bash
# Check if policies are configured for your user
# In Supabase dashboard:
# 1. Go to Database → Policies
# 2. Verify policies exist for tables
# 3. Check policy conditions match your user

# Quick fix for development:
# Temporarily disable RLS (NOT for production)
# In Supabase SQL editor:
ALTER TABLE your_table DISABLE ROW LEVEL SECURITY;

# Better: Add proper policy
CREATE POLICY "Allow authenticated users"
ON your_table
FOR ALL
TO authenticated
USING (true)
WITH CHECK (true);
```

---

## File System Errors

### File Not Found

**Error:**
```
Error: ENOENT: no such file or directory, open '/path/to/file'
```

**Cause 1:** PROJECT_DIR points to wrong directory

**Solution:**
```bash
# Check PROJECT_DIR
./scripts/run-agentic-workflow.sh --status

# If using subdirectory, verify DESIGN_REVIEW_START.md has:
## Working Directory Structure
**CODE ROOT**: /full/path/to/project
**PLANS**: /full/path/to/project/_plans/_Code Merge

# Update if needed
vim "_plans/_Code Merge/DESIGN_REVIEW_START.md"
```

**Cause 2:** File genuinely doesn't exist

**Solution:**
```bash
# Check if file was supposed to be created in previous phase
ls -la /path/to/expected/file

# If missing, check PROGRESS.md for errors
cat PROGRESS.md

# May need to re-run previous phase
./scripts/run-agentic-workflow.sh --implementation
```

---

### Permission Denied

**Error:**
```
Error: EACCES: permission denied, open '/path/to/file'
```

**Cause:** Insufficient file permissions

**Solution:**
```bash
# Check permissions
ls -la /path/to/file

# Fix if needed
chmod 644 /path/to/file  # For files
chmod 755 /path/to/dir   # For directories

# Or change ownership
sudo chown $USER:$USER /path/to/file
```

---

## Phase Execution Errors

### Phase Too Large

**Symptom:**
- Phase takes > 3 hours
- BLOCKED.md created with "context limit" message
- Agent appears stuck

**Cause:** Phase includes too many files (>50) or operations

**Solution:**
```bash
# 1. Stop workflow (Ctrl+C if running in foreground)

# 2. Return to design session
# Edit IMPLEMENTATION.md, break phase into sub-phases:

# Example: Phase 1 was too large (141 files)
# Break into:
## Phase 1a: Core Structure (10 files)
## Phase 1b: Leadership Pages (30 files)
## Phase 1c: School Leader Pages (20 files)
## Phase 1d: Admin and Shared (30 files)
## Phase 1e: Remaining Files

# 3. Update phase numbering in rest of document

# 4. Restart workflow
./scripts/run-agentic-workflow.sh --implementation
```

---

### Compilation Errors

**Error:**
```
TypeScript error in src/components/Page.tsx
Property 'foo' does not exist on type 'Props'
```

**Cause:** TypeScript type errors introduced during implementation

**Solution:**
```bash
# Check full error log
npm run build 2>&1 | tee build-errors.log

# Common fixes:
# 1. Missing imports
# 2. Incorrect prop types
# 3. Undefined variables

# Let iterative review loop handle it
# Code review will catch and fix these

# Or manually fix if urgent
vim src/components/Page.tsx

# Then re-run
./scripts/run-agentic-workflow.sh --code-review
```

---

## Workflow Hangs

### No Activity for > 1 Hour

**Symptom:** No signal file updates, no commits, workflow appears stuck

**Diagnosis:**
```bash
# Check if workflow is actually running
ps aux | grep "run-agentic-workflow"

# Check last signal file
ls -lt /path/to/project/*.md | head -5

# Check if dev server crashed (React)
curl http://localhost:PORT

# Check Kilocode process
ps aux | grep kilocode
```

**Solutions:**

1. **If dev server crashed:**
   ```bash
   cd /path/to/project
   npm run dev
   # Restart workflow at browser-test phase
   ./scripts/run-agentic-workflow.sh --browser-test
   ```

2. **If workflow hung:**
   ```bash
   # Kill workflow
   pkill -f "run-agentic-workflow"

   # Check BLOCKED.md
   cat /path/to/project/BLOCKED.md

   # Fix issue, restart at last phase
   ./scripts/run-agentic-workflow.sh --implementation
   ```

3. **If Kilocode stuck:**
   ```bash
   # Kill Kilocode
   pkill -f kilocode

   # Restart workflow
   ./scripts/run-agentic-workflow.sh --resume
   ```

---

### Infinite Loop in Review Cycle

**Symptom:** Same issues in REVIEW_ISSUES.md across multiple iterations

**Cause:** Agent unable to fix issues, hitting MAX_RETRIES

**Solution:**
```bash
# Check iteration count
ls -la REVIEW_ISSUES_ITER_*.md | wc -l

# If at MAX_RETRIES (default 3), workflow will stop
# Manual intervention required

# 1. Read latest issues
cat REVIEW_ISSUES.md

# 2. Fix issues manually
vim src/problematic-file.ts

# 3. Commit fixes
git add .
git commit -m "Manual fix: address review issues"

# 4. Clean iteration signals
rm REVIEW_ISSUES*.md
rm CODE_REVIEW_START.md

# 5. Re-run code review
./scripts/run-agentic-workflow.sh --code-review
```

---

## Git Errors

### Merge Conflicts

**Error:**
```
error: Your local changes to the following files would be overwritten by merge
```

**Cause:** Uncommitted changes conflict with workflow commits

**Solution:**
```bash
# Option 1: Stash changes
git stash
./scripts/run-agentic-workflow.sh --implementation
git stash pop

# Option 2: Commit changes
git add .
git commit -m "WIP: local changes"
./scripts/run-agentic-workflow.sh --implementation

# Option 3: Reset to clean state (CAUTION)
git reset --hard HEAD
./scripts/run-agentic-workflow.sh --implementation
```

---

### Remote Push Failed

**Error:**
```
error: failed to push some refs to 'origin'
```

**Cause:** Remote has commits that local doesn't

**Solution:**
```bash
# Pull latest
git pull --rebase

# Resolve any conflicts
git rebase --continue

# Resume workflow
./scripts/run-agentic-workflow.sh --resume
```

---

## Emergency Recovery

### Complete Workflow Failure

**Symptom:** Multiple errors, workflow completely broken

**Recovery steps:**

1. **Save current state:**
   ```bash
   cd /path/to/project
   git branch backup-$(date +%Y%m%d-%H%M%S)
   git add .
   git commit -m "Backup before recovery"
   ```

2. **Check last known good commit:**
   ```bash
   git log --oneline | head -10
   # Find last commit before workflow started
   ```

3. **Reset to last good state:**
   ```bash
   git reset --hard COMMIT_HASH
   ```

4. **Review design documents:**
   ```bash
   # Check if design needs updating
   cat DESIGN.md
   cat IMPLEMENTATION.md
   ```

5. **Restart from design review:**
   ```bash
   # Clean signals
   ./scripts/run-agentic-workflow.sh --clean

   # Start fresh
   ./scripts/run-agentic-workflow.sh --design-review
   ```

---

## Getting Help

### Collect Diagnostic Information

Before asking for help, collect this information:

```bash
# 1. Workflow configuration
cat config.sh | grep MODEL

# 2. Project info
ls -la /path/to/project

# 3. Signal files
ls -la /path/to/project/*.md

# 4. Recent commits
git log --oneline -10

# 5. Error messages
cat /path/to/project/BLOCKED.md
cat /path/to/project/REVIEW_ISSUES.md

# 6. Dev server status (React)
curl -I http://localhost:PORT

# 7. Environment vars (REDACT secrets!)
cat .env.local | sed 's/=.*/=<REDACTED>/'
```

### Create Issue Report

```markdown
## Issue Description
[Describe what went wrong]

## Steps to Reproduce
1. [Step 1]
2. [Step 2]
3. [Error occurred]

## Configuration
- Platform: [ninjatrader/react-supabase/python-ssh/n8n]
- Models: [design/implementation/review models]
- Phase: [Which phase failed]

## Error Messages
[Paste relevant errors from BLOCKED.md or console]

## Diagnostic Info
[Paste output from diagnostic commands above]
```

---

## Prevention

To avoid common issues:

1. ✅ **Always run pre-flight checklist** before starting workflow
2. ✅ **Keep phases small** (<50 files, <30 routes)
3. ✅ **Verify environment variables** before Phase 2
4. ✅ **Start dev server** before starting workflow (React)
5. ✅ **Use correct model names** with `kilo/` prefix
6. ✅ **Document actual port numbers** (not defaults)
7. ✅ **Commit frequently** to enable easy rollback
8. ✅ **Monitor first 2 hours** to catch issues early

See also: [PRE_FLIGHT_CHECKLIST.md](PRE_FLIGHT_CHECKLIST.md)
