#!/bin/bash
# React Dev Server Output Watcher
# Monitors Vite/dev server output and captures compilation errors

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
AGENTIC_HOME="${AGENTIC_HOME:-$(dirname "$SCRIPT_DIR")}"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info() { echo -e "${BLUE}[WATCHER]${NC} $1"; }
log_success() { echo -e "${GREEN}[WATCHER]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WATCHER]${NC} $1"; }
log_error() { echo -e "${RED}[WATCHER]${NC} $1"; }

PROJECT_DIR="${1:-$(pwd)}"
cd "$PROJECT_DIR"

LOG_FILE="${PROJECT_DIR}/.dev-server.log"
FEEDBACK_DIR="${PROJECT_DIR}/feedback"
COMPILE_ERRORS="${FEEDBACK_DIR}/COMPILE_ERRORS.md"
COMPILE_SUCCESS="${FEEDBACK_DIR}/COMPILE_SUCCESS.md"
WATCHER_PID_FILE="${PROJECT_DIR}/.watcher.pid"

mkdir -p "$FEEDBACK_DIR"

# Store this script's PID
echo $$ > "$WATCHER_PID_FILE"

cleanup() {
    log_info "Stopping watcher..."
    rm -f "$WATCHER_PID_FILE"
    exit 0
}

trap cleanup SIGINT SIGTERM

log_info "Watching dev server output: $LOG_FILE"
log_info "Feedback directory: $FEEDBACK_DIR"

# Track state
last_state=""
error_buffer=""
capturing_error=false

# Clear old feedback files
rm -f "$COMPILE_ERRORS" "$COMPILE_SUCCESS"

# Initial state - assume success until we see an error
echo "# Compilation Status

**Status**: ✅ Watching for errors...
**Timestamp**: $(date -u +"%Y-%m-%dT%H:%M:%SZ")

No compilation errors detected yet. Dev server is starting up.
" > "$COMPILE_SUCCESS"

watch_log() {
    tail -F "$LOG_FILE" 2>/dev/null | while IFS= read -r line; do
        # Check for Vite ready signal (successful start)
        if echo "$line" | grep -qE "Local:.*http://localhost|ready in"; then
            if [ "$last_state" != "success" ]; then
                log_success "Build successful"
                echo "# Compilation Success

**Status**: ✅ Success
**Timestamp**: $(date -u +"%Y-%m-%dT%H:%M:%SZ")

Build completed successfully. Dev server is ready.

## Last Build Output
\`\`\`
$(tail -20 "$LOG_FILE" | grep -v "^$")
\`\`\`
" > "$COMPILE_SUCCESS"
                rm -f "$COMPILE_ERRORS"
                last_state="success"
                error_buffer=""
                capturing_error=false
            fi
        fi

        # Check for various error patterns
        if echo "$line" | grep -qE "error|Error|ERROR|failed|Failed|FAILED|Cannot find|Module not found|SyntaxError|TypeError|ReferenceError"; then
            capturing_error=true
            error_buffer="${error_buffer}${line}"$'\n'
        fi

        # Check for TypeScript errors
        if echo "$line" | grep -qE "TS[0-9]{4}:|Type error:"; then
            capturing_error=true
            error_buffer="${error_buffer}${line}"$'\n'
        fi

        # If we've been capturing errors and hit a blank line or build restart, process the error
        if [ "$capturing_error" = true ]; then
            if echo "$line" | grep -qE "^$|building|transforming|hmr update"; then
                if [ -n "$error_buffer" ]; then
                    log_error "Compilation error detected"

                    echo "# Compilation Errors

**Status**: ❌ Build Failed
**Timestamp**: $(date -u +"%Y-%m-%dT%H:%M:%SZ")

## Error Output

\`\`\`
$error_buffer
\`\`\`

## Full Context (Last 50 Lines)

\`\`\`
$(tail -50 "$LOG_FILE" | grep -v "^$")
\`\`\`

## Instructions for Agent

1. Read the error messages above carefully
2. Identify the file(s) and line(s) with errors
3. Fix the errors in the source code
4. The dev server will automatically rebuild
5. Wait for COMPILE_SUCCESS.md to appear

## Common Error Types

- **Module not found**: Check import paths and installed dependencies
- **TypeScript errors**: Check type definitions and interfaces
- **Syntax errors**: Check for missing brackets, semicolons, etc.
- **Reference errors**: Check variable/function names and scopes
" > "$COMPILE_ERRORS"
                    rm -f "$COMPILE_SUCCESS"
                    last_state="error"
                    error_buffer=""
                    capturing_error=false
                fi
            else
                error_buffer="${error_buffer}${line}"$'\n'
            fi
        fi
    done
}

# Start watching
if [ ! -f "$LOG_FILE" ]; then
    log_warn "Log file not found, waiting for dev server to start..."
    touch "$LOG_FILE"
fi

log_info "Starting watch loop (PID: $$)"
log_info "Press Ctrl+C to stop"

watch_log
