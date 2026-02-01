#!/bin/bash
# Agentic Workflow Runner v4.0
# Multi-Platform, Multi-Machine Orchestration
#
# Features:
# - Platform detection (ninjatrader, react-supabase, python-ssh, n8n)
# - Remote execution support (Windows NT8, VMs)
# - Compilation feedback loop
# - MCP integration
# - Git-based synchronization

set -e

# =============================================================================
# CONFIGURATION
# =============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
AGENTIC_HOME="${AGENTIC_HOME:-$(dirname "$SCRIPT_DIR")}"

# Load configuration
if [ -f "${AGENTIC_HOME}/config.sh" ]; then
    source "${AGENTIC_HOME}/config.sh"
else
    echo "Warning: config.sh not found, using defaults"
    source "${AGENTIC_HOME}/config.example.sh" 2>/dev/null || true
fi

# Default directories
PROJECT_DIR="${PROJECT_DIR:-$(pwd)}"
DESIGN_DIR="${DESIGN_DIR:-$PROJECT_DIR}"
PROFILES_DIR="${PROFILES_DIR:-${AGENTIC_HOME}/profiles/kilocode}"
FEEDBACK_DIR="${FEEDBACK_DIR:-${AGENTIC_HOME}/feedback}"
TEMPLATES_DIR="${TEMPLATES_DIR:-${AGENTIC_HOME}/templates}"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
NC='\033[0m'

# Flags
VERBOSE=0
WORKFLOW_TYPE="auto"
REMOTE_EXEC=""
PHASE=""

# =============================================================================
# LOGGING
# =============================================================================

log_info()     { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success()  { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
log_warn()     { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error()    { echo -e "${RED}[ERROR]${NC} $1"; }
log_phase()    { echo -e "${CYAN}[PHASE]${NC} $1"; }
log_workflow() { echo -e "${MAGENTA}[WORKFLOW]${NC} $1"; }
log_remote()   { echo -e "${MAGENTA}[REMOTE]${NC} $1"; }

# =============================================================================
# PLATFORM DETECTION
# =============================================================================

detect_workflow_type() {
    local dir="${1:-$PROJECT_DIR}"

    # Check for explicit ProjectType.txt
    if [ -f "$dir/ProjectType.txt" ]; then
        cat "$dir/ProjectType.txt" | tr '[:upper:]' '[:lower:]' | head -1
        return 0
    fi

    # Check for C#/NinjaTrader
    if ls "$dir"/*.cs 2>/dev/null | head -1 | grep -q ".cs" || \
       [ -d "$dir/Strategies" ] || [ -d "$dir/Indicators" ]; then
        echo "ninjatrader"
        return 0
    fi

    # Check for React/Vite/Supabase
    if [ -f "$dir/package.json" ]; then
        if grep -q "vite" "$dir/package.json" 2>/dev/null; then
            if grep -q "supabase" "$dir/package.json" 2>/dev/null || \
               [ -f "$dir/supabase/config.toml" ]; then
                echo "react-supabase"
            else
                echo "react-vite"
            fi
            return 0
        fi
        if grep -q "n8n" "$dir/package.json" 2>/dev/null; then
            echo "n8n"
            return 0
        fi
    fi

    # Check for Python
    if [ -f "$dir/pyproject.toml" ] || [ -f "$dir/requirements.txt" ]; then
        echo "python-ssh"
        return 0
    fi

    # Default
    log_warn "Could not detect platform, defaulting to python-ssh"
    echo "python-ssh"
}

# =============================================================================
# SIGNAL FILES
# =============================================================================

check_signal() {
    [ -f "$PROJECT_DIR/$1" ]
}

wait_for_signal() {
    local file="$1"
    local timeout="${2:-300}"
    local elapsed=0

    log_info "Waiting for $file..."
    while [ $elapsed -lt $timeout ]; do
        if check_signal "$file"; then
            echo ""
            log_success "Detected $file"
            return 0
        fi
        sleep 5
        elapsed=$((elapsed + 5))
        echo -n "."
    done
    echo ""
    log_error "Timeout waiting for $file after ${timeout}s"
    return 1
}

wait_for_feedback() {
    local timeout="${1:-120}"
    local elapsed=0

    log_info "Waiting for compilation feedback..."
    while [ $elapsed -lt $timeout ]; do
        # Check project feedback dir first, then global
        if [ -f "$PROJECT_DIR/feedback/COMPILE_SUCCESS.md" ] || \
           [ -f "$FEEDBACK_DIR/COMPILE_SUCCESS.md" ]; then
            echo ""
            log_success "Compilation succeeded!"
            return 0
        fi
        if [ -f "$PROJECT_DIR/feedback/COMPILE_ERRORS.md" ] || \
           [ -f "$FEEDBACK_DIR/COMPILE_ERRORS.md" ]; then
            echo ""
            log_warn "Compilation failed - errors found"
            # Show errors
            cat "$PROJECT_DIR/feedback/COMPILE_ERRORS.md" 2>/dev/null || \
            cat "$FEEDBACK_DIR/COMPILE_ERRORS.md" 2>/dev/null
            return 2
        fi
        sleep "$NT8_FEEDBACK_POLL_INTERVAL"
        elapsed=$((elapsed + NT8_FEEDBACK_POLL_INTERVAL))
        echo -n "."
    done
    echo ""
    log_warn "No feedback received within ${timeout}s"
    return 1
}

# =============================================================================
# GIT SYNC
# =============================================================================

git_sync_push() {
    if [ "$AUTO_PUSH" = "true" ]; then
        log_info "Syncing changes to remote..."
        cd "$PROJECT_DIR"
        git add -A
        git commit -m "Agentic: sync for remote execution" --allow-empty 2>/dev/null || true
        git push 2>/dev/null || log_warn "Git push failed"
    fi
}

git_sync_pull() {
    log_info "Pulling latest from remote..."
    cd "$PROJECT_DIR"
    git pull --rebase 2>/dev/null || log_warn "Git pull failed"
}

# =============================================================================
# REMOTE EXECUTION
# =============================================================================

run_remote_windows() {
    local command="$1"

    if [ -z "$WINDOWS_NT8_HOST" ]; then
        log_error "WINDOWS_NT8_HOST not configured"
        return 1
    fi

    log_remote "Executing on $WINDOWS_NT8_HOST..."
    ssh "${WINDOWS_NT8_USER}@${WINDOWS_NT8_HOST}" "$command"
}

trigger_nt8_compile() {
    log_remote "Triggering NT8 compilation..."

    # Push changes first
    git_sync_push

    # Signal remote to pull (could be a webhook, SSH command, or file signal)
    if [ -n "$WINDOWS_NT8_HOST" ]; then
        run_remote_windows "cd '$WINDOWS_NT8_PATH' && git pull" || true
    fi

    # Wait for compilation feedback
    wait_for_feedback "$NT8_COMPILE_TIMEOUT"
    return $?
}

# =============================================================================
# DOCUMENT DISCOVERY
# =============================================================================

discover_documents() {
    local docs=""

    # Check DESIGN_REVIEW_START.md for explicit list
    if [ -f "$DESIGN_DIR/DESIGN_REVIEW_START.md" ]; then
        log_info "Using document list from DESIGN_REVIEW_START.md"
        # Parse document list from file (simplified)
        grep -E "^\s*-\s+" "$DESIGN_DIR/DESIGN_REVIEW_START.md" | \
            sed 's/^[[:space:]]*-[[:space:]]*//' | \
            while read -r doc; do
                [ -f "$doc" ] && echo "$doc"
            done
        return 0
    fi

    # Auto-discover
    for doc in DESIGN.md PRD.md IMPLEMENTATION.md ARCHITECTURE.md; do
        [ -f "$DESIGN_DIR/$doc" ] && docs="$docs $DESIGN_DIR/$doc"
        [ -f "$PROJECT_DIR/$doc" ] && [ "$PROJECT_DIR" != "$DESIGN_DIR" ] && docs="$docs $PROJECT_DIR/$doc"
    done

    echo "$docs" | sed 's/^ *//'
}

# =============================================================================
# WORKFLOW PHASES
# =============================================================================

run_design_review() {
    log_phase "=== Phase 1: Design Review ==="
    log_info "Model: ${MODEL_DESIGN_REVIEW:-moonshotai/kimi-k2.5}"
    log_info "Platform: $WORKFLOW_TYPE"

    local documents=$(discover_documents)
    [ -z "$documents" ] && { log_error "No design documents found"; return 1; }

    log_info "Documents: $documents"

    # Check for existing DESIGN_REVIEW_START.md or create one
    if [ ! -f "$PROJECT_DIR/DESIGN_REVIEW_START.md" ]; then
        # Use template if available
        local template="${TEMPLATES_DIR}/platform/${WORKFLOW_TYPE}/DESIGN_REVIEW_START.md"
        if [ -f "$template" ]; then
            cp "$template" "$PROJECT_DIR/DESIGN_REVIEW_START.md"
        else
            cat > "$PROJECT_DIR/DESIGN_REVIEW_START.md" << EOF
# Design Review Start Signal

**Project**: $(basename "$PROJECT_DIR")
**Platform**: $WORKFLOW_TYPE
**Timestamp**: $(date -u +"%Y-%m-%dT%H:%M:%SZ")

## Documents to Review

$(for doc in $documents; do echo "- $doc"; done)

## Instructions

Read all documents and validate against DESIGN_REVIEW_CHECKLIST.md.

- If APPROVED: Create DESIGN_APPROVED.md
- If ISSUES: Create DESIGN_ISSUES.md
EOF
        fi
        log_success "Created DESIGN_REVIEW_START.md"
    fi

    # Ensure checklist exists
    if [ ! -f "$PROJECT_DIR/DESIGN_REVIEW_CHECKLIST.md" ]; then
        local checklist="${TEMPLATES_DIR}/platform/${WORKFLOW_TYPE}/REVIEW_CHECKLIST.md"
        if [ -f "$checklist" ]; then
            cp "$checklist" "$PROJECT_DIR/DESIGN_REVIEW_CHECKLIST.md"
            log_info "Copied platform checklist"
        fi
    fi

    # Run Kilocode
    log_info "Starting Kilocode design review..."

    local kilocode_args="--mode review"
    [ "$AUTO_APPROVE" = "true" ] && kilocode_args="$kilocode_args --auto --yolo"

    cd "$PROJECT_DIR"
    if [ "$VERBOSE" -eq 1 ]; then
        kilocode $kilocode_args \
            --append-system-prompt "You are a design review agent. Read DESIGN_REVIEW_START.md and follow instructions." \
            "Begin design review"
    else
        kilocode $kilocode_args \
            --append-system-prompt "You are a design review agent. Read DESIGN_REVIEW_START.md and follow instructions." \
            "Begin design review" &

        local pid=$!
        log_info "Kilocode PID: $pid"

        # Wait for result
        while kill -0 $pid 2>/dev/null; do
            if check_signal "DESIGN_APPROVED.md"; then
                log_success "Design approved!"
                return 0
            fi
            if check_signal "DESIGN_ISSUES.md"; then
                log_warn "Design has issues"
                cat "$PROJECT_DIR/DESIGN_ISSUES.md"
                return 2
            fi
            sleep 5
        done
    fi

    # Check final status
    if check_signal "DESIGN_APPROVED.md"; then
        log_success "Design approved!"
        return 0
    elif check_signal "DESIGN_ISSUES.md"; then
        log_warn "Design has issues"
        return 2
    else
        log_error "No result signal found"
        return 1
    fi
}

run_implementation() {
    log_phase "=== Phase 2: Implementation ==="
    log_info "Model: ${MODEL_IMPLEMENTATION:-minimax/minimax-m2.1}"
    log_info "Platform: $WORKFLOW_TYPE"

    if ! check_signal "DESIGN_APPROVED.md"; then
        log_error "DESIGN_APPROVED.md not found"
        return 1
    fi

    # Create implementation start signal
    cat > "$PROJECT_DIR/IMPLEMENTATION_START.md" << EOF
# Implementation Start Signal

**Project**: $(basename "$PROJECT_DIR")
**Platform**: $WORKFLOW_TYPE
**Timestamp**: $(date -u +"%Y-%m-%dT%H:%M:%SZ")

## Instructions

Read IMPLEMENTATION.md and execute phases in order.

- Run verification after each phase
- Commit after each phase
- Update PROGRESS.md
- If blocked after 3 attempts: Create BLOCKED.md
- When complete: Create IMPLEMENTATION_COMPLETE.md
EOF

    log_success "Created IMPLEMENTATION_START.md"

    # Run Kilocode
    local kilocode_args="--mode code"
    [ "$AUTO_APPROVE" = "true" ] && kilocode_args="$kilocode_args --auto --yolo"

    cd "$PROJECT_DIR"

    if [ "$VERBOSE" -eq 1 ]; then
        kilocode $kilocode_args \
            --append-system-prompt "You are an implementation agent. Read IMPLEMENTATION_START.md and follow instructions." \
            "Begin implementation"
    else
        kilocode $kilocode_args \
            --append-system-prompt "You are an implementation agent. Read IMPLEMENTATION_START.md and follow instructions." \
            "Begin implementation" &

        local pid=$!
        log_info "Kilocode PID: $pid"

        while kill -0 $pid 2>/dev/null; do
            # For NinjaTrader, check for compilation feedback
            if [ "$WORKFLOW_TYPE" = "ninjatrader" ]; then
                if [ -f "$PROJECT_DIR/feedback/COMPILE_ERRORS.md" ]; then
                    log_warn "Compile errors detected - agent should fix"
                fi
            fi

            if check_signal "IMPLEMENTATION_COMPLETE.md"; then
                log_success "Implementation complete!"
                return 0
            fi
            if check_signal "BLOCKED.md"; then
                log_error "Implementation blocked"
                cat "$PROJECT_DIR/BLOCKED.md"
                return 1
            fi
            sleep 10
        done
    fi

    if check_signal "IMPLEMENTATION_COMPLETE.md"; then
        log_success "Implementation complete!"
        return 0
    elif check_signal "BLOCKED.md"; then
        log_error "Implementation blocked"
        return 1
    else
        log_error "No result signal found"
        return 1
    fi
}

run_code_review() {
    log_phase "=== Phase 3: Code Review ==="
    log_info "Model: ${MODEL_CODE_REVIEW:-moonshotai/kimi-k2.5}"
    log_info "Platform: $WORKFLOW_TYPE"

    if ! check_signal "IMPLEMENTATION_COMPLETE.md"; then
        log_error "IMPLEMENTATION_COMPLETE.md not found"
        return 1
    fi

    # Create code review start signal
    cat > "$PROJECT_DIR/REVIEW_START.md" << EOF
# Code Review Start Signal

**Project**: $(basename "$PROJECT_DIR")
**Platform**: $WORKFLOW_TYPE
**Timestamp**: $(date -u +"%Y-%m-%dT%H:%M:%SZ")

## Instructions

Review implementation against DESIGN.md and REVIEW_CHECKLIST.md.

- Check each item systematically
- Do NOT fix issues - only report
- Create REVIEW_RESULTS.md with findings
- If APPROVED: Create REVIEW_APPROVED.md
- If ISSUES: Create REVIEW_ISSUES.md
EOF

    log_success "Created REVIEW_START.md"

    local kilocode_args="--mode review"
    [ "$AUTO_APPROVE" = "true" ] && kilocode_args="$kilocode_args --auto --yolo"

    cd "$PROJECT_DIR"

    if [ "$VERBOSE" -eq 1 ]; then
        kilocode $kilocode_args \
            --append-system-prompt "You are a code review agent. Read REVIEW_START.md and follow instructions." \
            "Begin code review"
    else
        kilocode $kilocode_args \
            --append-system-prompt "You are a code review agent. Read REVIEW_START.md and follow instructions." \
            "Begin code review" &

        local pid=$!

        while kill -0 $pid 2>/dev/null; do
            if check_signal "REVIEW_APPROVED.md"; then
                log_success "Code review approved!"
                return 0
            fi
            if check_signal "REVIEW_ISSUES.md"; then
                log_warn "Code review found issues"
                cat "$PROJECT_DIR/REVIEW_ISSUES.md"
                return 2
            fi
            sleep 10
        done
    fi

    if check_signal "REVIEW_APPROVED.md"; then
        log_success "Code review approved!"
        return 0
    elif check_signal "REVIEW_ISSUES.md"; then
        log_warn "Code review found issues"
        return 2
    else
        log_error "No result signal found"
        return 1
    fi
}

show_status() {
    echo "========================================"
    echo "  Agentic Workflow Status"
    echo "========================================"
    echo ""
    echo "Project: $PROJECT_DIR"
    echo "Platform: $(detect_workflow_type)"
    echo "Remote: ${REMOTE_EXEC:-none}"
    echo ""

    echo "Phase 1: Design Review"
    for f in DESIGN_REVIEW_START.md DESIGN_REVIEW_RESULTS.md DESIGN_APPROVED.md DESIGN_ISSUES.md; do
        check_signal "$f" && echo "  [✓] $f" || echo "  [ ] $f"
    done

    echo ""
    echo "Phase 2: Implementation"
    for f in IMPLEMENTATION_START.md PROGRESS.md IMPLEMENTATION_COMPLETE.md BLOCKED.md; do
        check_signal "$f" && echo "  [✓] $f" || echo "  [ ] $f"
    done

    echo ""
    echo "Phase 3: Code Review"
    for f in REVIEW_START.md REVIEW_RESULTS.md REVIEW_APPROVED.md REVIEW_ISSUES.md; do
        check_signal "$f" && echo "  [✓] $f" || echo "  [ ] $f"
    done

    echo ""
    echo "Feedback:"
    for f in COMPILE_SUCCESS.md COMPILE_ERRORS.md MANUAL_VERIFIED.md; do
        if [ -f "$PROJECT_DIR/feedback/$f" ] || [ -f "$FEEDBACK_DIR/$f" ]; then
            echo "  [✓] $f"
        else
            echo "  [ ] $f"
        fi
    done
}

clean_signals() {
    log_warn "Cleaning all signal files..."

    local signals=(
        DESIGN_REVIEW_START.md DESIGN_REVIEW_RESULTS.md DESIGN_APPROVED.md DESIGN_ISSUES.md
        IMPLEMENTATION_START.md PROGRESS.md IMPLEMENTATION_COMPLETE.md BLOCKED.md
        REVIEW_START.md REVIEW_RESULTS.md REVIEW_APPROVED.md REVIEW_ISSUES.md
    )

    for f in "${signals[@]}"; do
        rm -f "$PROJECT_DIR/$f"
    done

    # Clean feedback
    rm -f "$PROJECT_DIR/feedback/COMPILE_SUCCESS.md"
    rm -f "$PROJECT_DIR/feedback/COMPILE_ERRORS.md"
    rm -f "$FEEDBACK_DIR/COMPILE_SUCCESS.md"
    rm -f "$FEEDBACK_DIR/COMPILE_ERRORS.md"

    log_success "Signal files cleaned"
}

# =============================================================================
# MAIN
# =============================================================================

main() {
    echo "========================================"
    echo "  Agentic Workflow Runner v4.0"
    echo "  Multi-Platform | Multi-Machine"
    echo "========================================"
    echo ""

    # Detect platform
    if [ "$WORKFLOW_TYPE" = "auto" ]; then
        WORKFLOW_TYPE=$(detect_workflow_type)
    fi
    log_workflow "Platform: $WORKFLOW_TYPE"

    # Check current state and resume appropriately
    if check_signal "REVIEW_APPROVED.md"; then
        log_success "Project already approved!"
        exit 0
    fi

    if check_signal "IMPLEMENTATION_COMPLETE.md"; then
        log_info "Implementation complete, running code review..."
        run_code_review
        exit $?
    fi

    if check_signal "DESIGN_APPROVED.md"; then
        log_info "Design approved, running implementation..."
        run_implementation || exit $?
        run_code_review
        exit $?
    fi

    # Full workflow
    log_workflow "Starting full 3-phase workflow..."

    run_design_review
    case $? in
        0) ;;
        2) log_warn "Fix design issues and re-run"; exit 2 ;;
        *) log_error "Design review failed"; exit 1 ;;
    esac

    run_implementation || { log_error "Implementation failed"; exit 1; }

    run_code_review
    case $? in
        0) log_success "=== WORKFLOW COMPLETE ===" ;;
        2) log_warn "Fix code review issues and re-run"; exit 2 ;;
        *) log_error "Code review failed"; exit 1 ;;
    esac
}

# =============================================================================
# CLI PARSING
# =============================================================================

show_help() {
    cat << EOF
Agentic Workflow Runner v4.0

Usage: $(basename "$0") [OPTIONS] [PHASE]

Options:
  -p, --project-dir DIR   Project directory (default: current)
  --design-dir DIR        Design documents directory (default: project dir)
  -t, --type TYPE         Force platform type (ninjatrader, react-supabase, python-ssh, n8n)
  -r, --remote HOST       Enable remote execution
  -v, --verbose           Show agent output
  -h, --help              Show this help

Phases:
  -d, --design-review     Run only design review
  -i, --implementation    Run only implementation
  -c, --code-review       Run only code review
  -s, --status            Show current status
  --clean                 Clean all signal files

Examples:
  $(basename "$0")                           # Full workflow, auto-detect
  $(basename "$0") -t ninjatrader            # Force NinjaTrader platform
  $(basename "$0") -p /path/to/project -v    # Verbose mode
  $(basename "$0") --remote windows-nt8      # With remote execution
EOF
}

while [[ $# -gt 0 ]]; do
    case $1 in
        -p|--project-dir)  PROJECT_DIR="$2"; shift 2 ;;
        --design-dir)      DESIGN_DIR="$2"; shift 2 ;;
        -t|--type)         WORKFLOW_TYPE="$2"; shift 2 ;;
        -r|--remote)       REMOTE_EXEC="$2"; shift 2 ;;
        -v|--verbose)      VERBOSE=1; shift ;;
        -d|--design-review) PHASE="design-review"; shift ;;
        -i|--implementation) PHASE="implementation"; shift ;;
        -c|--code-review)  PHASE="code-review"; shift ;;
        -s|--status)       PHASE="status"; shift ;;
        --clean)           PHASE="clean"; shift ;;
        -h|--help)         show_help; exit 0 ;;
        *)                 shift ;;
    esac
done

# Execute
cd "$PROJECT_DIR"
[ "$WORKFLOW_TYPE" = "auto" ] && WORKFLOW_TYPE=$(detect_workflow_type)

case "${PHASE:-main}" in
    design-review)   run_design_review ;;
    implementation)  run_implementation ;;
    code-review)     run_code_review ;;
    status)          show_status ;;
    clean)           clean_signals ;;
    main)            main ;;
esac
