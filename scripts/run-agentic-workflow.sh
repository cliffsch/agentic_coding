#!/bin/bash
# Agentic Workflow Runner v4.2
# Multi-Platform, Multi-Machine Orchestration
#
# Features:
# - Platform detection (ninjatrader, react-supabase, python-ssh, n8n)
# - Project-level rules integration (.kilorules, .cursorrules, .claude/)
# - Remote execution support (Windows NT8, VMs)
# - Compilation feedback loop
# - MCP integration
# - Git-based synchronization
# - Bug fix & revision mode (Phase 5)

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
# PROJECT RULES LOADING
# =============================================================================

# Global variables for loaded rules
PROJECT_RULES=""
PROJECT_RULES_SOURCE=""

load_project_rules() {
    local dir="${1:-$PROJECT_DIR}"
    local phase="${2:-general}"
    PROJECT_RULES=""
    PROJECT_RULES_SOURCE=""

    # Priority 1: .kilorules (Kilocode-specific rules)
    if [ -f "$dir/.kilorules" ]; then
        PROJECT_RULES_SOURCE=".kilorules"
        log_info "Loading rules from .kilorules"
        PROJECT_RULES=$(cat "$dir/.kilorules")
        return 0
    fi

    # Priority 2: .cursorrules (Claude/general rules - user mentioned they use this for Claude)
    if [ -f "$dir/.cursorrules" ]; then
        PROJECT_RULES_SOURCE=".cursorrules"
        log_info "Loading rules from .cursorrules"
        PROJECT_RULES=$(cat "$dir/.cursorrules")
        return 0
    fi

    # Priority 3: .claude/ directory with modular rules
    if [ -d "$dir/.claude" ]; then
        PROJECT_RULES_SOURCE=".claude/"
        log_info "Loading rules from .claude/ directory"

        # Load main rules file if exists
        local rules_content=""
        for rules_file in "$dir/.claude/CLAUDE.md" "$dir/.claude/CLAUDE_OPTIMIZED.md" "$dir/.claude/rules.md"; do
            if [ -f "$rules_file" ]; then
                rules_content=$(cat "$rules_file")
                break
            fi
        done

        # Load phase-specific or domain-specific rules
        case "$phase" in
            design-review)
                [ -f "$dir/.claude/workflows/design_review.md" ] && \
                    rules_content="$rules_content"$'\n\n'"$(cat "$dir/.claude/workflows/design_review.md")"
                ;;
            implementation)
                [ -f "$dir/.claude/workflows/code_generation.md" ] && \
                    rules_content="$rules_content"$'\n\n'"$(cat "$dir/.claude/workflows/code_generation.md")"
                ;;
            code-review)
                [ -f "$dir/.claude/workflows/code_review.md" ] && \
                    rules_content="$rules_content"$'\n\n'"$(cat "$dir/.claude/workflows/code_review.md")"
                ;;
        esac

        # Load platform-specific rules based on workflow type
        case "$WORKFLOW_TYPE" in
            ninjatrader)
                [ -f "$dir/.claude/nt8/core.md" ] && \
                    rules_content="$rules_content"$'\n\n'"$(cat "$dir/.claude/nt8/core.md")"
                ;;
            react-supabase|react-vite)
                [ -f "$dir/.claude/react/core.md" ] && \
                    rules_content="$rules_content"$'\n\n'"$(cat "$dir/.claude/react/core.md")"
                ;;
            python-ssh)
                [ -f "$dir/.claude/python/core.md" ] && \
                    rules_content="$rules_content"$'\n\n'"$(cat "$dir/.claude/python/core.md")"
                ;;
        esac

        PROJECT_RULES="$rules_content"
        return 0
    fi

    # Priority 4: .kilo/ directory (parallel structure for Kilocode)
    if [ -d "$dir/.kilo" ]; then
        PROJECT_RULES_SOURCE=".kilo/"
        log_info "Loading rules from .kilo/ directory"

        local rules_content=""
        [ -f "$dir/.kilo/README.md" ] && rules_content=$(cat "$dir/.kilo/README.md")

        # Load phase-specific workflows
        case "$phase" in
            design-review)
                [ -f "$dir/.kilo/workflows/design_review.md" ] && \
                    rules_content="$rules_content"$'\n\n'"$(cat "$dir/.kilo/workflows/design_review.md")"
                ;;
            implementation)
                [ -f "$dir/.kilo/workflows/code_generation.md" ] && \
                    rules_content="$rules_content"$'\n\n'"$(cat "$dir/.kilo/workflows/code_generation.md")"
                ;;
            code-review)
                [ -f "$dir/.kilo/workflows/code_review.md" ] && \
                    rules_content="$rules_content"$'\n\n'"$(cat "$dir/.kilo/workflows/code_review.md")"
                ;;
        esac

        # Load platform-specific rules
        case "$WORKFLOW_TYPE" in
            ninjatrader)
                [ -f "$dir/.kilo/nt8/core.md" ] && \
                    rules_content="$rules_content"$'\n\n'"$(cat "$dir/.kilo/nt8/core.md")"
                ;;
        esac

        PROJECT_RULES="$rules_content"
        return 0
    fi

    # Priority 5: Fall back to profile JSON from agentic_coding system
    load_profile_rules "$phase"
}

load_profile_rules() {
    local phase="${1:-general}"
    local profile_name=""

    # Map workflow type and phase to profile name
    case "$WORKFLOW_TYPE" in
        ninjatrader) profile_name="csharp-ninjatrader" ;;
        react-supabase) profile_name="react-supabase" ;;
        python-ssh) profile_name="python-ssh" ;;
        n8n) profile_name="n8n-workflow" ;;
        *) profile_name="python-ssh" ;;
    esac

    case "$phase" in
        design-review) profile_name="${profile_name}-design-review" ;;
        implementation) profile_name="${profile_name}-impl" ;;
        code-review) profile_name="${profile_name}-review" ;;
    esac

    local profile_file="${PROFILES_DIR}/${profile_name}.json"

    if [ -f "$profile_file" ]; then
        PROJECT_RULES_SOURCE="profile:${profile_name}"
        log_info "Loading rules from profile: $profile_name"

        # Extract rules array from JSON and format as markdown
        if command -v jq &> /dev/null; then
            PROJECT_RULES=$(jq -r '.rules[]? // empty' "$profile_file" 2>/dev/null | while read -r rule; do
                echo "- $rule"
            done)
        else
            # Fallback: simple grep extraction if jq not available
            PROJECT_RULES=$(grep -oP '"[^"]+(?=",?)' "$profile_file" 2>/dev/null | \
                grep -v "name\|description\|provider\|model_id" | \
                sed 's/^"//;s/"$//' | \
                while read -r rule; do echo "- $rule"; done)
        fi
        return 0
    fi

    log_warn "No project rules or profile found for $phase"
    PROJECT_RULES=""
}

# Build the system prompt with project rules
build_agent_prompt() {
    local role="$1"
    local phase="$2"
    local signal_file="$3"

    # Load rules for this phase
    load_project_rules "$PROJECT_DIR" "$phase"

    local prompt="You are a ${role} agent."
    prompt="$prompt Read ${signal_file} and follow instructions."

    if [ -n "$PROJECT_RULES" ]; then
        # Truncate rules if too long (keep under ~4000 chars for system prompt)
        local rules_preview="${PROJECT_RULES:0:4000}"
        if [ ${#PROJECT_RULES} -gt 4000 ]; then
            rules_preview="${rules_preview}..."
            log_warn "Rules truncated (${#PROJECT_RULES} chars) - full rules in project files"
        fi
        prompt="$prompt"$'\n\n'"## Project Rules (from $PROJECT_RULES_SOURCE)"$'\n'"$rules_preview"
    fi

    echo "$prompt"
}

# Get NFR (Non-Functional Requirements) content for the platform
get_nfr_content() {
    local nfr_content=""

    # Load common NFRs
    if [ -f "${TEMPLATES_DIR}/nfr/COMMON.md" ]; then
        nfr_content=$(cat "${TEMPLATES_DIR}/nfr/COMMON.md")
    fi

    # Load platform-specific NFRs
    local platform_nfr="${TEMPLATES_DIR}/nfr/${WORKFLOW_TYPE}.md"
    if [ -f "$platform_nfr" ]; then
        nfr_content="$nfr_content"$'\n\n'"$(cat "$platform_nfr")"
    fi

    # Check for project-level NFR overrides
    if [ -f "$PROJECT_DIR/NFR_OVERRIDES.md" ]; then
        nfr_content="$nfr_content"$'\n\n'"## Project NFR Overrides"$'\n'"$(cat "$PROJECT_DIR/NFR_OVERRIDES.md")"
    fi

    echo "$nfr_content"
}

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
    log_info "Model: ${MODEL_DESIGN_REVIEW:-z-ai/glm-4.7}"
    log_info "Platform: $WORKFLOW_TYPE"

    local documents=$(discover_documents)
    [ -z "$documents" ] && { log_error "No design documents found"; return 1; }

    log_info "Documents: $documents"

    # Load project rules for this phase
    load_project_rules "$PROJECT_DIR" "design-review"
    [ -n "$PROJECT_RULES_SOURCE" ] && log_info "Rules: $PROJECT_RULES_SOURCE"

    # Get NFR content
    local nfr_content=$(get_nfr_content)

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
**Rules Source**: ${PROJECT_RULES_SOURCE:-defaults}

## Documents to Review

$(for doc in $documents; do echo "- $doc"; done)

## Instructions

Read all documents and validate against DESIGN_REVIEW_CHECKLIST.md.

### Critical Checks
- Every config setting has implementing code that USES it
- Every "cleanup" or "retention" mention has cleanup logic
- All cross-document references are valid
- No implicit requirements left unspecified

### Decision
- If APPROVED: Create DESIGN_APPROVED.md
- If ISSUES: Create DESIGN_ISSUES.md with specific problems
EOF
        fi
        log_success "Created DESIGN_REVIEW_START.md"
    fi

    # Ensure checklist exists
    if [ ! -f "$PROJECT_DIR/DESIGN_REVIEW_CHECKLIST.md" ]; then
        # Try platform-specific first
        local checklist="${TEMPLATES_DIR}/platform/${WORKFLOW_TYPE}/REVIEW_CHECKLIST.md"
        [ ! -f "$checklist" ] && checklist="${TEMPLATES_DIR}/common/DESIGN_REVIEW_CHECKLIST_${WORKFLOW_TYPE}.md"
        if [ -f "$checklist" ]; then
            cp "$checklist" "$PROJECT_DIR/DESIGN_REVIEW_CHECKLIST.md"
            log_info "Copied platform checklist"
        fi
    fi

    # Build the agent prompt with project rules
    local agent_prompt=$(build_agent_prompt "design review" "design-review" "DESIGN_REVIEW_START.md")

    # Run Kilocode
    log_info "Starting Kilocode design review..."

    local kilocode_args="--mode review"
    [ "$AUTO_APPROVE" = "true" ] && kilocode_args="$kilocode_args --auto --yolo"

    cd "$PROJECT_DIR"
    if [ "$VERBOSE" -eq 1 ]; then
        kilocode $kilocode_args \
            --append-system-prompt "$agent_prompt" \
            "Begin design review"
    else
        kilocode $kilocode_args \
            --append-system-prompt "$agent_prompt" \
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

    # Load project rules for this phase
    load_project_rules "$PROJECT_DIR" "implementation"
    [ -n "$PROJECT_RULES_SOURCE" ] && log_info "Rules: $PROJECT_RULES_SOURCE"

    # Get platform-specific implementation instructions
    local platform_instructions=""
    case "$WORKFLOW_TYPE" in
        ninjatrader)
            platform_instructions="
### NinjaTrader Implementation Rules
- Write code for desk check only - NO compilation on macOS
- Focus on logic correctness and NT API usage
- Follow NinjaTrader naming conventions strictly
- Include XML documentation comments
- Handle all State transitions properly (SetDefaults, Configure, DataLoaded)
- Implement proper Dispose() patterns"
            ;;
        react-supabase)
            platform_instructions="
### React/Supabase Implementation Rules
- Use TypeScript for all new code
- Follow component composition patterns
- Implement proper error boundaries
- Use React Query for server state management
- Implement proper loading and error states"
            ;;
        python-ssh)
            platform_instructions="
### Python Implementation Rules
- Follow PEP 8 style guidelines
- Use type hints for function signatures
- Include docstrings for public functions
- Write unit tests alongside implementation"
            ;;
    esac

    # Create implementation start signal
    cat > "$PROJECT_DIR/IMPLEMENTATION_START.md" << EOF
# Implementation Start Signal

**Project**: $(basename "$PROJECT_DIR")
**Platform**: $WORKFLOW_TYPE
**Timestamp**: $(date -u +"%Y-%m-%dT%H:%M:%SZ")
**Rules Source**: ${PROJECT_RULES_SOURCE:-defaults}

## Instructions

Read IMPLEMENTATION.md and execute phases in order.

### Critical Rules
- Execute phases IN ORDER - do not skip
- Run verification after each phase before committing
- Commit after each phase with EXACT message from IMPLEMENTATION.md
- Update PROGRESS.md after each phase
- Use explicit file paths - no relative paths
- Do NOT ask clarifying questions - all requirements are documented
- If blocked after 3 attempts: Create BLOCKED.md and stop
$platform_instructions

### Completion Signal
When all phases complete successfully, create IMPLEMENTATION_COMPLETE.md with summary.

BEGIN NOW: Read IMPLEMENTATION.md and start Phase 1.
EOF

    log_success "Created IMPLEMENTATION_START.md"

    # Build the agent prompt with project rules
    local agent_prompt=$(build_agent_prompt "implementation" "implementation" "IMPLEMENTATION_START.md")

    # Run Kilocode
    local kilocode_args="--mode code"
    [ "$AUTO_APPROVE" = "true" ] && kilocode_args="$kilocode_args --auto --yolo"

    cd "$PROJECT_DIR"

    if [ "$VERBOSE" -eq 1 ]; then
        kilocode $kilocode_args \
            --append-system-prompt "$agent_prompt" \
            "Begin implementation"
    else
        kilocode $kilocode_args \
            --append-system-prompt "$agent_prompt" \
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
    log_info "Model: ${MODEL_CODE_REVIEW:-z-ai/glm-4.7}"
    log_info "Platform: $WORKFLOW_TYPE"

    if ! check_signal "IMPLEMENTATION_COMPLETE.md"; then
        log_error "IMPLEMENTATION_COMPLETE.md not found"
        return 1
    fi

    # Load project rules for this phase
    load_project_rules "$PROJECT_DIR" "code-review"
    [ -n "$PROJECT_RULES_SOURCE" ] && log_info "Rules: $PROJECT_RULES_SOURCE"

    # Get platform-specific review instructions
    local platform_review=""
    case "$WORKFLOW_TYPE" in
        ninjatrader)
            platform_review="
### NinjaTrader Code Review
- Desk check code logic (no compilation on Mac)
- Verify NT API usage is correct
- Check State management transitions
- Validate input parameter handling
- Review Dispose() implementation
- Check for memory leaks (event handlers)
- Verify plot updates are efficient"
            ;;
        react-supabase)
            platform_review="
### React/Supabase Code Review
- Run TypeScript checks: npm run type-check
- Run linter: npm run lint
- Build verification: npm run build
- Check Supabase type safety
- Verify API error handling
- Review component prop types
- Check for security issues (XSS, injection)"
            ;;
        python-ssh)
            platform_review="
### Python Code Review
- Run all tests: pytest tests/ -v
- Check type hints with mypy
- Verify PEP 8 compliance
- Review error handling"
            ;;
    esac

    # Create code review start signal
    cat > "$PROJECT_DIR/REVIEW_START.md" << EOF
# Code Review Start Signal

**Project**: $(basename "$PROJECT_DIR")
**Platform**: $WORKFLOW_TYPE
**Timestamp**: $(date -u +"%Y-%m-%dT%H:%M:%SZ")
**Rules Source**: ${PROJECT_RULES_SOURCE:-defaults}

## Instructions

Review implementation against DESIGN.md and REVIEW_CHECKLIST.md.

### Critical Rules
- Read REVIEW_CHECKLIST.md completely
- Check each item systematically - do not skip
- Verify all commits match IMPLEMENTATION.md specifications
- Check for TODO/FIXME comments that should be resolved
- Do NOT fix issues yourself - only report them
- Create detailed REVIEW_RESULTS.md
$platform_review

### Decision
- If APPROVED: Create REVIEW_APPROVED.md
- If ISSUES FOUND: Create REVIEW_ISSUES.md with specific problems

Maximum 2 review cycles before human escalation.

BEGIN NOW: Start review using REVIEW_CHECKLIST.md.
EOF

    log_success "Created REVIEW_START.md"

    # Build the agent prompt with project rules
    local agent_prompt=$(build_agent_prompt "code review" "code-review" "REVIEW_START.md")

    local kilocode_args="--mode review"
    [ "$AUTO_APPROVE" = "true" ] && kilocode_args="$kilocode_args --auto --yolo"

    cd "$PROJECT_DIR"

    if [ "$VERBOSE" -eq 1 ]; then
        kilocode $kilocode_args \
            --append-system-prompt "$agent_prompt" \
            "Begin code review"
    else
        kilocode $kilocode_args \
            --append-system-prompt "$agent_prompt" \
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

run_bug_fix_mode() {
    log_phase "=== Phase 5: Bug Fix & Revision ==="
    log_info "Model: ${MODEL_IMPLEMENTATION:-minimax/minimax-m2.1}"
    log_info "Platform: $WORKFLOW_TYPE"

    # Check for ISSUES.md
    if [ ! -f "$PROJECT_DIR/ISSUES.md" ]; then
        log_error "ISSUES.md not found. Create this file with your list of issues."
        return 1
    fi

    # Load project rules for implementation phase
    load_project_rules "$PROJECT_DIR" "implementation"
    [ -n "$PROJECT_RULES_SOURCE" ] && log_info "Rules: $PROJECT_RULES_SOURCE"

    # Discover original design documents for context
    local design_docs=$(discover_documents)

    # Create bug fix start signal
    cat > "$PROJECT_DIR/BUGFIX_START.md" << EOF
# Bug Fix & Revision Start Signal

**Project**: $(basename "$PROJECT_DIR")
**Platform**: $WORKFLOW_TYPE
**Timestamp**: $(date -u +"%Y-%m-%dT%H:%M:%SZ")
**Rules Source**: ${PROJECT_RULES_SOURCE:-defaults}

## Context Documents (Reference Only)
$(for doc in $design_docs; do echo "- $doc"; done)

## Priority Rules
1. **ISSUES.md takes HIGHEST priority** - User's explicit changes override original design
2. Use original design documents only for context and understanding
3. If ISSUES.md contradicts DESIGN.md, follow ISSUES.md
4. Maintain consistency with existing codebase patterns
5. Do NOT revert changes that were intentionally made per ISSUES.md

## Instructions
1. Read ISSUES.md completely - this is your primary directive
2. Read original design documents for context only
3. Fix each issue systematically
4. After each fix, verify it doesn't break other functionality
5. Commit each fix with message: "Fix: [issue description]"
6. Update BUGFIX_PROGRESS.md after each fix
7. When all issues resolved, create BUGFIX_COMPLETE.md

## Critical Rules
- User's ISSUES.md overrides any conflicting requirements in original design
- If an issue requires design clarification, create BUGFIX_BLOCKED.md
- Do NOT ask clarifying questions - all requirements are in ISSUES.md
- If blocked after 3 attempts: Create BUGFIX_BLOCKED.md and stop

BEGIN NOW: Read ISSUES.md and start fixing issues.
EOF

    log_success "Created BUGFIX_START.md"

    # Build the agent prompt with project rules
    local agent_prompt=$(build_agent_prompt "bug fix" "implementation" "BUGFIX_START.md")

    # Run Kilocode in code mode
    local kilocode_args="--mode code"
    [ "$AUTO_APPROVE" = "true" ] && kilocode_args="$kilocode_args --auto --yolo"

    cd "$PROJECT_DIR"

    if [ "$VERBOSE" -eq 1 ]; then
        kilocode $kilocode_args \
            --append-system-prompt "$agent_prompt" \
            "Begin bug fixes"
    else
        kilocode $kilocode_args \
            --append-system-prompt "$agent_prompt" \
            "Begin bug fixes" &

        local pid=$!
        log_info "Kilocode PID: $pid"

        while kill -0 $pid 2>/dev/null; do
            # Check for compilation feedback
            if [ "$WORKFLOW_TYPE" = "ninjatrader" ]; then
                if [ -f "$PROJECT_DIR/feedback/COMPILE_ERRORS.md" ]; then
                    log_warn "Compile errors detected - agent should fix"
                fi
            fi

            if check_signal "BUGFIX_COMPLETE.md"; then
                log_success "Bug fixes complete!"
                return 0
            fi
            if check_signal "BUGFIX_BLOCKED.md"; then
                log_error "Bug fix blocked"
                cat "$PROJECT_DIR/BUGFIX_BLOCKED.md"
                return 1
            fi
            sleep 10
        done
    fi

    if check_signal "BUGFIX_COMPLETE.md"; then
        log_success "Bug fixes complete!"
        return 0
    elif check_signal "BUGFIX_BLOCKED.md"; then
        log_error "Bug fix blocked"
        return 1
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

    # Show rules detection
    echo "Rules Detection:"
    if [ -f "$PROJECT_DIR/.kilorules" ]; then
        echo "  [✓] .kilorules (Kilocode rules)"
    else
        echo "  [ ] .kilorules"
    fi
    if [ -f "$PROJECT_DIR/.cursorrules" ]; then
        echo "  [✓] .cursorrules (Claude rules)"
    else
        echo "  [ ] .cursorrules"
    fi
    if [ -d "$PROJECT_DIR/.claude" ]; then
        echo "  [✓] .claude/ directory"
    else
        echo "  [ ] .claude/"
    fi
    if [ -d "$PROJECT_DIR/.kilo" ]; then
        echo "  [✓] .kilo/ directory"
    else
        echo "  [ ] .kilo/"
    fi
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
    echo "Phase 5: Bug Fix & Revision"
    if [ -f "$PROJECT_DIR/ISSUES.md" ]; then
        echo "  [✓] ISSUES.md"
        for f in BUGFIX_START.md BUGFIX_PROGRESS.md BUGFIX_COMPLETE.md BUGFIX_BLOCKED.md; do
            check_signal "$f" && echo "  [✓] $f" || echo "  [ ] $f"
        done
    else
        echo "  [ ] ISSUES.md (not present)"
    fi

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
        BUGFIX_START.md BUGFIX_PROGRESS.md BUGFIX_COMPLETE.md BUGFIX_BLOCKED.md
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
    echo "  Agentic Workflow Runner v4.2"
    echo "  Multi-Platform | Project Rules | Bug Fix Mode"
    echo "========================================"
    echo ""

    # Detect platform
    if [ "$WORKFLOW_TYPE" = "auto" ]; then
        WORKFLOW_TYPE=$(detect_workflow_type)
    fi
    log_workflow "Platform: $WORKFLOW_TYPE"

    # Check for bug fix mode trigger
    if [ -f "$PROJECT_DIR/ISSUES.md" ]; then
        log_warn "ISSUES.md detected - entering bug fix mode"
        run_bug_fix_mode
        exit $?
    fi

    # Check current state and resume appropriately
    if check_signal "REVIEW_APPROVED.md"; then
        log_success "Project already approved!"
        exit 0
    fi

    if check_signal "BUGFIX_COMPLETE.md"; then
        log_success "Bug fixes complete!"
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
Agentic Workflow Runner v4.2

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
  -b, --bug-fix          Run bug fix & revision mode (requires ISSUES.md)
  -s, --status            Show current status
  --clean                 Clean all signal files

Project Rules Integration:
  The script automatically detects and loads rules from your project directory.
  Rules are injected into agent prompts for consistent behavior.

  Priority order:
    1. .kilorules          - Kilocode-specific rules (recommended)
    2. .cursorrules        - Claude/general rules
    3. .claude/            - Modular Claude rules directory
    4. .kilo/              - Modular Kilocode rules directory
    5. profiles/           - Fallback to agentic_coding profile JSONs

  For NinjaTrader projects, place .kilorules in nt8_custom/ or project folder.
  For React projects, create .kilorules or .cursorrules with project rules.

Bug Fix Mode:
  Create ISSUES.md in your project folder with a list of bugs, misinterpretations,
  or improvements. The agent will fix these issues while maintaining context from
  the original design documents. ISSUES.md takes priority over original design.

  See templates/common/ISSUES_TEMPLATE.md for the ISSUES.md format.

Examples:
  $(basename "$0")                           # Full workflow, auto-detect
  $(basename "$0") -t ninjatrader            # Force NinjaTrader platform
  $(basename "$0") -p /path/to/project -v    # Verbose mode
  $(basename "$0") --remote windows-nt8      # With remote execution
  $(basename "$0") -s                        # Show status including rules detection
  $(basename "$0") -b                        # Run bug fix mode (requires ISSUES.md)

Models (configurable in config.sh):
  Design Review:  \${MODEL_DESIGN_REVIEW:-z-ai/glm-4.7}
  Implementation: \${MODEL_IMPLEMENTATION:-minimax/minimax-m2.1}
  Code Review:    \${MODEL_CODE_REVIEW:-z-ai/glm-4.7}
  Bug Fix:        \${MODEL_IMPLEMENTATION:-minimax/minimax-m2.1}
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
        -b|--bug-fix)      PHASE="bug-fix"; shift ;;
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
    bug-fix)         run_bug_fix_mode ;;
    status)          show_status ;;
    clean)           clean_signals ;;
    main)            main ;;
esac
