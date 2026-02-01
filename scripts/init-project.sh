#!/bin/bash
# Initialize a new project from platform template
#
# Usage:
#   ./init-project.sh --platform ninjatrader --name MyIndicator --dir /path/to/project
#   ./init-project.sh -p react-supabase -n my-app

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
AGENTIC_HOME="${AGENTIC_HOME:-$(dirname "$SCRIPT_DIR")}"
TEMPLATES_DIR="${AGENTIC_HOME}/templates"

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

log_info()    { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
log_warn()    { echo -e "${YELLOW}[WARN]${NC} $1"; }

# Defaults
PLATFORM=""
PROJECT_NAME=""
PROJECT_DIR=""
PROJECT_TYPE=""  # indicator, strategy, webapp, script, workflow

show_help() {
    cat << EOF
Initialize Project from Template

Usage: $(basename "$0") [OPTIONS]

Required:
  -p, --platform PLATFORM   Platform type (ninjatrader, react-supabase, python-ssh, n8n)
  -n, --name NAME           Project name

Optional:
  -d, --dir DIR             Target directory (default: current dir / name)
  -t, --type TYPE           Project subtype (e.g., indicator, strategy, webapp)
  -h, --help                Show this help

Examples:
  $(basename "$0") -p ninjatrader -n DailyPivots -t indicator
  $(basename "$0") -p react-supabase -n my-dashboard -d ./projects
  $(basename "$0") --platform python-ssh --name automation-script

Platforms:
  ninjatrader     - NinjaTrader 8 indicators/strategies
  react-supabase  - React + Vite + Supabase web apps
  python-ssh      - Python projects with SSH deployment
  n8n             - n8n workflow automation
EOF
}

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -p|--platform)  PLATFORM="$2"; shift 2 ;;
        -n|--name)      PROJECT_NAME="$2"; shift 2 ;;
        -d|--dir)       PROJECT_DIR="$2"; shift 2 ;;
        -t|--type)      PROJECT_TYPE="$2"; shift 2 ;;
        -h|--help)      show_help; exit 0 ;;
        *)              shift ;;
    esac
done

# Validate required args
if [ -z "$PLATFORM" ] || [ -z "$PROJECT_NAME" ]; then
    echo "Error: --platform and --name are required"
    echo ""
    show_help
    exit 1
fi

# Set defaults
PROJECT_DIR="${PROJECT_DIR:-$(pwd)/$PROJECT_NAME}"

# Validate platform
case "$PLATFORM" in
    ninjatrader|react-supabase|python-ssh|n8n) ;;
    *)
        echo "Error: Unknown platform '$PLATFORM'"
        echo "Valid: ninjatrader, react-supabase, python-ssh, n8n"
        exit 1
        ;;
esac

# Create project directory
log_info "Creating project: $PROJECT_NAME"
log_info "Platform: $PLATFORM"
log_info "Directory: $PROJECT_DIR"

mkdir -p "$PROJECT_DIR"
mkdir -p "$PROJECT_DIR/feedback"

# Copy platform templates
PLATFORM_TEMPLATES="${TEMPLATES_DIR}/platform/${PLATFORM}"
if [ -d "$PLATFORM_TEMPLATES" ]; then
    log_info "Copying platform templates..."
    cp "$PLATFORM_TEMPLATES"/*.md "$PROJECT_DIR/" 2>/dev/null || true
fi

# Copy common templates
log_info "Copying common templates..."
cp "${TEMPLATES_DIR}/common"/*.md "$PROJECT_DIR/" 2>/dev/null || true

# Copy NFR baseline and create override file
log_info "Setting up NFR framework..."
mkdir -p "$PROJECT_DIR/nfr"
cp "${TEMPLATES_DIR}/nfr/COMMON.md" "$PROJECT_DIR/nfr/" 2>/dev/null || true

# Copy platform-specific NFR
case "$PLATFORM" in
    ninjatrader)
        cp "${TEMPLATES_DIR}/nfr/ninjatrader.md" "$PROJECT_DIR/nfr/" 2>/dev/null || true
        ;;
    react-supabase)
        cp "${TEMPLATES_DIR}/nfr/react-supabase.md" "$PROJECT_DIR/nfr/" 2>/dev/null || true
        ;;
    python-ssh)
        cp "${TEMPLATES_DIR}/nfr/python-ssh.md" "$PROJECT_DIR/nfr/" 2>/dev/null || true
        ;;
    n8n)
        cp "${TEMPLATES_DIR}/nfr/n8n-workflow.md" "$PROJECT_DIR/nfr/" 2>/dev/null || true
        ;;
esac

# Create NFR_OVERRIDES.md from template
if [ -f "${TEMPLATES_DIR}/project/NFR_OVERRIDES.template.md" ]; then
    cp "${TEMPLATES_DIR}/project/NFR_OVERRIDES.template.md" "$PROJECT_DIR/NFR_OVERRIDES.md"
fi

# Replace placeholders in templates
log_info "Customizing templates..."
DATE=$(date +"%Y-%m-%d")
AUTHOR="${USER:-$(whoami)}"

# Process all .md files including NFR_OVERRIDES.md
for file in "$PROJECT_DIR"/*.md "$PROJECT_DIR/nfr"/*.md; do
    [ -f "$file" ] || continue

    # macOS sed requires different syntax
    if [[ "$OSTYPE" == "darwin"* ]]; then
        sed -i '' "s/{PROJECT_NAME}/${PROJECT_NAME}/g" "$file"
        sed -i '' "s/{AUTHOR}/${AUTHOR}/g" "$file"
        sed -i '' "s/{DATE}/${DATE}/g" "$file"
        sed -i '' "s/{Indicator|Strategy}/${PROJECT_TYPE:-Indicator}/g" "$file"
        sed -i '' "s/{Indicators|Strategies}/${PROJECT_TYPE:-Indicators}/g" "$file"
    else
        sed -i "s/{PROJECT_NAME}/${PROJECT_NAME}/g" "$file"
        sed -i "s/{AUTHOR}/${AUTHOR}/g" "$file"
        sed -i "s/{DATE}/${DATE}/g" "$file"
        sed -i "s/{Indicator|Strategy}/${PROJECT_TYPE:-Indicator}/g" "$file"
        sed -i "s/{Indicators|Strategies}/${PROJECT_TYPE:-Indicators}/g" "$file"
    fi
done

# Create ProjectType.txt for detection
echo "$PLATFORM" > "$PROJECT_DIR/ProjectType.txt"

# Platform-specific setup
case "$PLATFORM" in
    ninjatrader)
        log_info "NinjaTrader project initialized"
        log_info "Next steps:"
        echo "  1. Edit DESIGN.md with your indicator/strategy requirements"
        echo "  2. Review NFR baseline in nfr/ folder"
        echo "  3. Run a design session with Claude Code (includes NFR discussion)"
        echo "  4. Hand off to Kilocode: run-agentic-workflow.sh -p $PROJECT_DIR"
        ;;
    react-supabase)
        log_info "React/Supabase project initialized"
        log_info "Next steps:"
        echo "  1. Run: npm create vite@latest . -- --template react-ts"
        echo "  2. Edit DESIGN.md with your app requirements"
        echo "  3. Review NFR baseline in nfr/ folder"
        echo "  4. Run a design session with Claude Code (includes NFR discussion)"
        ;;
    python-ssh)
        log_info "Python project initialized"
        log_info "Next steps:"
        echo "  1. Create pyproject.toml or requirements.txt"
        echo "  2. Edit DESIGN.md with your script requirements"
        echo "  3. Review NFR baseline in nfr/ folder"
        echo "  4. Run a design session with Claude Code (includes NFR discussion)"
        ;;
    n8n)
        log_info "n8n workflow project initialized"
        mkdir -p "$PROJECT_DIR/workflows"
        log_info "Next steps:"
        echo "  1. Edit DESIGN.md with your workflow requirements"
        echo "  2. Review NFR baseline in nfr/ folder"
        echo "  3. Run a design session with Claude Code (includes NFR discussion)"
        ;;
esac

log_success "Project initialized at $PROJECT_DIR"
echo ""
echo "Files created:"
ls -la "$PROJECT_DIR"/*.md 2>/dev/null || echo "  (templates pending)"
