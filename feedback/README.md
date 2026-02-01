# Feedback Directory

This directory receives compilation results and test outputs from remote machines.

## Signal Files

| File | Source | Purpose |
|------|--------|---------|
| `COMPILE_SUCCESS.md` | Windows AutoHotkey | NT8 compilation succeeded |
| `COMPILE_ERRORS.md` | Windows AutoHotkey | NT8 compilation failed |
| `TEST_RESULTS.md` | Remote VM | pytest/npm test results |
| `MANUAL_VERIFIED.md` | Human | Manual verification complete |

## Workflow

1. Agent makes code changes
2. Changes sync to target machine (git push/pull)
3. Target machine processes (compile, test)
4. Results written to this directory (git push/pull)
5. Orchestrator polls for signal files
6. Agent reads results and continues/fixes

## Git Sync

This directory is tracked in git for cross-machine synchronization:

```bash
# On development machine (Mac)
git pull  # Get latest feedback

# On target machine (Windows)
# After compilation:
git add feedback/
git commit -m "Feedback: compile result"
git push
```

## AutoHotkey Integration (Windows)

The `nt8_harvest_errors.ahk` script monitors NT8's Log tab and writes results here.

See: `scripts/windows/nt8_harvest_errors.ahk`
