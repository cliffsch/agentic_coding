#!/bin/bash
# Validate design documents before handoff
#
# Usage:
#   ./validate-design.sh /path/to/project
#   ./validate-design.sh  # uses current directory

set -e

PROJECT_DIR="${1:-$(pwd)}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
AGENTIC_HOME="${AGENTIC_HOME:-$(dirname "$SCRIPT_DIR")}"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info()    { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[✓]${NC} $1"; }
log_warn()    { echo -e "${YELLOW}[!]${NC} $1"; }
log_error()   { echo -e "${RED}[✗]${NC} $1"; }

ERRORS=0
WARNINGS=0

check_file() {
    local file="$1"
    local required="$2"

    if [ -f "$PROJECT_DIR/$file" ]; then
        log_success "$file exists"
        return 0
    else
        if [ "$required" = "required" ]; then
            log_error "$file missing (required)"
            ERRORS=$((ERRORS + 1))
        else
            log_warn "$file missing (optional)"
            WARNINGS=$((WARNINGS + 1))
        fi
        return 1
    fi
}

check_sections() {
    local file="$1"
    shift
    local sections=("$@")

    for section in "${sections[@]}"; do
        if grep -q "## $section" "$PROJECT_DIR/$file" 2>/dev/null; then
            log_success "$file has '$section' section"
        else
            log_warn "$file missing '$section' section"
            WARNINGS=$((WARNINGS + 1))
        fi
    done
}

echo "========================================"
echo "  Design Document Validation"
echo "========================================"
echo ""
echo "Project: $PROJECT_DIR"
echo ""

# Detect platform
if [ -f "$PROJECT_DIR/ProjectType.txt" ]; then
    PLATFORM=$(cat "$PROJECT_DIR/ProjectType.txt" | tr '[:upper:]' '[:lower:]')
else
    # Auto-detect
    if ls "$PROJECT_DIR"/*.cs 2>/dev/null | head -1 | grep -q ".cs"; then
        PLATFORM="ninjatrader"
    elif [ -f "$PROJECT_DIR/package.json" ]; then
        PLATFORM="react-supabase"
    else
        PLATFORM="python-ssh"
    fi
fi

log_info "Detected platform: $PLATFORM"
echo ""

# Check required documents
echo "Checking required documents..."
check_file "DESIGN.md" "required"
check_file "IMPLEMENTATION.md" "required"
echo ""

# Check optional documents
echo "Checking optional documents..."
check_file "PRD.md" "optional"
check_file "DESIGN_REVIEW_CHECKLIST.md" "optional"
echo ""

# Validate DESIGN.md structure
if [ -f "$PROJECT_DIR/DESIGN.md" ]; then
    echo "Validating DESIGN.md structure..."
    check_sections "DESIGN.md" "Overview" "Requirements" "Architecture"
    echo ""
fi

# Validate IMPLEMENTATION.md structure
if [ -f "$PROJECT_DIR/IMPLEMENTATION.md" ]; then
    echo "Validating IMPLEMENTATION.md structure..."

    # Check for phase structure
    PHASES=$(grep -c "## Phase" "$PROJECT_DIR/IMPLEMENTATION.md" 2>/dev/null || echo "0")
    if [ "$PHASES" -gt 0 ]; then
        log_success "IMPLEMENTATION.md has $PHASES phases"
    else
        log_warn "IMPLEMENTATION.md has no Phase sections"
        WARNINGS=$((WARNINGS + 1))
    fi

    # Check for verification steps
    if grep -qi "verification" "$PROJECT_DIR/IMPLEMENTATION.md" 2>/dev/null; then
        log_success "IMPLEMENTATION.md has verification steps"
    else
        log_warn "IMPLEMENTATION.md missing verification steps"
        WARNINGS=$((WARNINGS + 1))
    fi

    # Check for commit messages
    if grep -qi "commit" "$PROJECT_DIR/IMPLEMENTATION.md" 2>/dev/null; then
        log_success "IMPLEMENTATION.md has commit instructions"
    else
        log_warn "IMPLEMENTATION.md missing commit instructions"
        WARNINGS=$((WARNINGS + 1))
    fi
    echo ""
fi

# Platform-specific checks
echo "Platform-specific checks ($PLATFORM)..."
case "$PLATFORM" in
    ninjatrader)
        # Check for class name
        if grep -q "class.*:" "$PROJECT_DIR/DESIGN.md" 2>/dev/null; then
            log_success "Class structure defined"
        else
            log_warn "No class structure found in DESIGN.md"
            WARNINGS=$((WARNINGS + 1))
        fi

        # Check for OnBarUpdate
        if grep -qi "OnBarUpdate" "$PROJECT_DIR/DESIGN.md" 2>/dev/null || \
           grep -qi "OnBarUpdate" "$PROJECT_DIR/IMPLEMENTATION.md" 2>/dev/null; then
            log_success "OnBarUpdate method referenced"
        else
            log_warn "OnBarUpdate not mentioned"
            WARNINGS=$((WARNINGS + 1))
        fi
        ;;
    react-supabase)
        # Check for component structure
        if grep -qi "component" "$PROJECT_DIR/DESIGN.md" 2>/dev/null; then
            log_success "Component structure mentioned"
        else
            log_warn "No component structure in DESIGN.md"
            WARNINGS=$((WARNINGS + 1))
        fi
        ;;
esac
echo ""

# Git status check
echo "Checking git status..."
cd "$PROJECT_DIR"
if git rev-parse --git-dir > /dev/null 2>&1; then
    log_success "Git repository detected"

    # Check for uncommitted changes
    if [ -n "$(git status --porcelain)" ]; then
        log_warn "Uncommitted changes detected"
        WARNINGS=$((WARNINGS + 1))
    else
        log_success "Working directory clean"
    fi
else
    log_warn "Not a git repository"
    WARNINGS=$((WARNINGS + 1))
fi
echo ""

# Summary
echo "========================================"
echo "  Validation Summary"
echo "========================================"
echo ""

if [ $ERRORS -eq 0 ] && [ $WARNINGS -eq 0 ]; then
    log_success "All checks passed! Ready for handoff."
    echo ""
    echo "To start autonomous workflow:"
    echo "  run-agentic-workflow.sh -p $PROJECT_DIR"
    exit 0
elif [ $ERRORS -eq 0 ]; then
    log_warn "$WARNINGS warnings found (non-blocking)"
    echo ""
    echo "You can proceed with handoff, but consider addressing warnings."
    echo "  run-agentic-workflow.sh -p $PROJECT_DIR"
    exit 0
else
    log_error "$ERRORS errors found (must fix before handoff)"
    echo ""
    echo "Fix the errors above before proceeding."
    exit 1
fi
