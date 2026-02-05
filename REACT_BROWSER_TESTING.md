# React Browser Testing Integration

**Version**: 4.3
**Date**: 2026-02-05
**Status**: Ready for Testing

## Overview

The agentic workflow system now supports **local development with automated browser testing** for React/Supabase projects. This enables fast iteration with Kilocode CLI using its native browser-action tool.

## What's New

### 1. Local Dev Server Management
- **Auto-start**: Dev server starts automatically for React projects
- **Port detection**: Defaults to 5173, adapts to available ports
- **Package manager detection**: Supports npm, pnpm, and yarn
- **Background mode**: Runs in background during workflow

### 2. Compilation Monitoring
- **Real-time feedback**: Watches Vite output for errors
- **Feedback files**: Writes to `feedback/COMPILE_ERRORS.md` and `feedback/COMPILE_SUCCESS.md`
- **Agent integration**: Both Kilocode and Claude Code can read feedback
- **Error context**: Captures full error details with file/line numbers

### 3. Browser Testing Phase
- **Kilocode browser-action**: Uses native Puppeteer/Chromium integration
- **Automated testing**: Agent navigates, clicks, inspects, captures
- **Screenshot capture**: Visual evidence of issues and states
- **Console monitoring**: Captures browser console errors
- **Iterative fixes**: Test → Fix → Retest loop

### 4. Cross-Agent Compatibility
- **File-based feedback**: Works with Kilocode CLI and Claude Code
- **Standardized signals**: Consistent signal file pattern
- **Universal access**: Both agents read same feedback files

## New Scripts

### `scripts/start-dev-server.sh`
Manages dev server lifecycle:
```bash
./start-dev-server.sh /path/to/project start   # Start server
./start-dev-server.sh /path/to/project stop    # Stop server
./start-dev-server.sh /path/to/project status  # Check status
```

Features:
- Package manager detection
- PID tracking
- Health checks
- Automatic cleanup

### `scripts/watch-dev-server.sh`
Monitors compilation output:
```bash
./watch-dev-server.sh /path/to/project
```

Features:
- Parses Vite/dev server output
- Detects errors, TypeScript issues, syntax problems
- Writes structured feedback files
- Runs in background with signal handling

## New Templates

### `templates/platform/react-supabase/BROWSER_TEST_CHECKLIST.md`
Comprehensive testing checklist for Kilocode:
- Initial load tests
- Authentication flows
- Functionality verification
- Console error checks
- Network/API validation
- Success criteria

### `templates/platform/react-supabase/SETUP_LOCAL_DEV.md`
Complete setup guide:
- Supabase environment configuration
- Local development setup
- Environment variable management
- Troubleshooting tips

### `templates/platform/react-supabase/.env.local.template`
Environment configuration template for local dev

## Modified Workflow

The orchestration script now runs:

```
Phase 1: Design Review
Phase 2: Implementation
  ├── Start dev server (React projects)
  ├── Monitor compilation
  └── Write code
Phase 2.5: Browser Testing (NEW - React projects only)
  ├── Ensure dev server running
  ├── Run browser-action tests
  ├── Capture errors/screenshots
  └── Iterate until passing
Phase 3: Code Review
```

## Usage Examples

### Full Workflow (New React Project)
```bash
cd ~/Documents/agentic_coding/scripts
./run-agentic-workflow.sh -p /path/to/react/project -t react-supabase
```

This will:
1. Detect React/Supabase platform
2. Run design review
3. Start implementation
4. Launch dev server automatically
5. Monitor compilation errors
6. Run browser testing with Kilocode browser-action
7. Run code review

### Browser Testing Only
```bash
./run-agentic-workflow.sh -p /path/to/react/project --browser-test
```

### Bug Fix Mode with Browser Testing
```bash
# Create ISSUES.md with your bug list
./run-agentic-workflow.sh -p /path/to/react/project -b
```

Dev server and browser testing work automatically in bug fix mode.

### Check Status
```bash
./run-agentic-workflow.sh -p /path/to/react/project -s
```

Shows:
- Platform detection
- Dev server status (running/stopped)
- All signal files
- Browser test results

### Manual Dev Server Control
```bash
# Start manually
./scripts/start-dev-server.sh /path/to/project start

# Watch compilation
./scripts/watch-dev-server.sh /path/to/project

# Stop when done
./scripts/start-dev-server.sh /path/to/project stop
```

## Signal Files

New browser testing signals:

```
BROWSER_TEST_START.md         # Script creates with test instructions
BROWSER_TEST_CHECKLIST.md     # Template copied to project
BROWSER_TEST_RESULTS.md       # Agent writes findings
BROWSER_TEST_PASS.md          # Agent signals all tests pass
BROWSER_TEST_BLOCKED.md       # Agent signals blocked after 3 attempts
```

Compilation feedback:

```
feedback/COMPILE_SUCCESS.md   # Dev server compiled successfully
feedback/COMPILE_ERRORS.md    # Compilation errors detected
```

## Environment Setup for Your React Project

### Step 1: Create Supabase Dev Environment
- Create "dev" branch in Supabase dashboard
- Note the URL and anon key

### Step 2: Configure Local Environment
```bash
cd /path/to/your/react/project
cp ~/Documents/agentic_coding/templates/platform/react-supabase/.env.local.template .env.local

# Edit .env.local with your dev credentials
nano .env.local
```

### Step 3: Test Local Dev
```bash
npm run dev
# Verify it works at http://localhost:5173
```

### Step 4: Run Agentic Workflow
```bash
~/Documents/agentic_coding/scripts/run-agentic-workflow.sh \
    -p /path/to/your/react/project \
    -t react-supabase
```

## How Browser Testing Works

1. **Script creates `BROWSER_TEST_START.md`** with instructions
2. **Kilocode receives system prompt** pointing to signal file
3. **Agent uses browser-action tool** to:
   - Open http://localhost:5173
   - Navigate and interact with UI
   - Capture console errors
   - Take screenshots
   - Test functionality per checklist
4. **Agent documents findings** in `BROWSER_TEST_RESULTS.md`
5. **Agent fixes issues** found during testing
6. **Dev server auto-recompiles** (watcher detects changes)
7. **Agent re-tests** until all pass
8. **Agent signals completion** via `BROWSER_TEST_PASS.md`

## For Claude Code Interactive Sessions

When using Claude Code (not via script):

1. Start dev server manually:
   ```bash
   npm run dev
   ```

2. Ask Claude Code to test:
   ```
   "Use your browser tool to test the app at http://localhost:5173"
   ```

3. Claude Code uses its built-in browser MCP tool (different from Kilocode's browser-action, but similar results)

## Configuration

All settings are in `config.sh`:

```bash
# Dev server port (auto-detected, but can override)
export DEV_PORT=5173

# Compilation feedback polling
export NT8_FEEDBACK_POLL_INTERVAL=5  # Also used for React

# Models (browser testing uses implementation model)
export MODEL_IMPLEMENTATION="minimax/minimax-m2.1"
```

## Troubleshooting

### Dev Server Won't Start
- Check port not in use: `lsof -i :5173`
- Check `.dev-server.log` for errors
- Try manual start to see errors

### Compilation Errors Not Detected
- Verify watcher is running: `ps aux | grep watch-dev-server`
- Check `.watcher.pid` exists
- Look at `.dev-server.log` for output

### Browser Testing Doesn't Run
- Ensure `IMPLEMENTATION_COMPLETE.md` exists first
- Verify dev server is running
- Check Kilocode has browser-action tool

### Screenshots Not Captured
- Create `screenshots/` directory in project
- Check agent has write permissions
- Verify browser-action is working

## Next Steps

1. **Set up your React project** following `SETUP_LOCAL_DEV.md`
2. **Test with your Lovable merge branch**:
   ```bash
   cd /path/to/your/branch
   ~/Documents/agentic_coding/scripts/run-agentic-workflow.sh \
       -p . \
       --browser-test
   ```
3. **Review screenshots** in `screenshots/` directory
4. **Iterate on issues** found by Kilocode

## Notes

- **Token efficiency**: Local testing is much faster than push-to-Vercel cycle
- **Kilocode budget**: Browser testing uses Kilocode's implementation model
- **Claude Code**: Can still use interactively for browser features
- **First run**: May take a few minutes for Kilocode to understand browser-action
- **Screenshots**: Excellent for debugging visual issues

## Files Modified

- `scripts/run-agentic-workflow.sh` - Added browser testing phase
- New: `scripts/start-dev-server.sh`
- New: `scripts/watch-dev-server.sh`
- New: `templates/platform/react-supabase/BROWSER_TEST_CHECKLIST.md`
- New: `templates/platform/react-supabase/SETUP_LOCAL_DEV.md`
- New: `templates/platform/react-supabase/.env.local.template`

## Compatibility

- ✅ Works with Kilocode CLI (browser-action)
- ✅ Works with Claude Code (browser MCP)
- ✅ Works with npm, pnpm, yarn
- ✅ Works with Vite, Create React App, Next.js
- ✅ Works with Supabase, other backends
- ✅ Compatible with existing workflow phases
