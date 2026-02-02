# Agentic Coding System

A multi-platform, multi-machine orchestration system for autonomous software development.

## Philosophy

**Two-Agent Model:**
- **Claude Code (Architect)**: Interactive design sessions, deep reasoning, requirements refinement
- **Kilocode CLI (Builder)**: Autonomous implementation, cost-effective execution

**Multi-Machine Orchestration:**
- Design on any machine (MacBook, etc.)
- Execute on the best machine for the task (Windows for NinjaTrader, etc.)
- Feedback loops for platforms without CLI testing (compilation results, etc.)

## Quick Start

```bash
# Initialize a new project from template
./scripts/init-project.sh --platform ninjatrader --name MyIndicator

# Run design validation before handoff
./scripts/validate-design.sh /path/to/project

# Run agentic workflow (local)
./scripts/run-agentic-workflow.sh --project-dir /path/to/project

# Run with remote execution (Windows machine for NT8)
./scripts/run-agentic-workflow.sh --project-dir /path/to/project --remote windows-nt8

# Run bug fix mode (after implementation, when issues are found)
./scripts/run-agentic-workflow.sh --project-dir /path/to/project --bug-fix
```

## Supported Platforms

| Platform | Execution | Testing | MCP Support |
|----------|-----------|---------|-------------|
| **NinjaTrader** | Windows (remote) | Auto-compile feedback | Planned |
| **React/Supabase** | Local/Vercel | CLI (`npm test`, `vercel`) | supabase-mcp |
| **Python/SSH** | Remote VM | SSH (`pytest`) | - |
| **n8n** | Local/Remote | n8n API | n8n-mcp |

## Directory Structure

```
agentic_coding/
├── config.sh                    # Global configuration
├── docs/
│   ├── DESIGN_SESSION_GUIDE.md  # Claude Code design workflow
│   ├── HANDOFF_PROTOCOL.md      # Kilocode handoff process
│   └── platform/                # Platform-specific guides
├── templates/
│   ├── common/                  # Cross-platform templates
│   └── platform/                # Platform-specific templates
├── profiles/
│   └── kilocode/                # Kilocode agent profiles
├── mcp/
│   └── config/                  # MCP server configurations
├── scripts/
│   ├── run-agentic-workflow.sh  # Main orchestrator
│   ├── init-project.sh          # Project initializer
│   └── validate-design.sh       # Design validator
└── feedback/
    └── (compilation results, test outputs)
```

## Workflow Phases

### Phase 0: Design Session (Claude Code)
Interactive refinement of requirements into implementation-ready documents.

### Phase 1: Design Review (Kilocode - Kimi K2.5)
Automated validation of design completeness.

### Phase 2: Implementation (Kilocode - Minimax M2.1)
Autonomous code generation following implementation plan.

### Phase 3: Verification (Platform-specific)
- **NinjaTrader**: Auto-compile on Windows, harvest errors
- **React**: `npm run build && npm test`
- **Python**: `pytest` on target VM

### Phase 4: Code Review (Kilocode - Kimi K2.5)
Validation of implementation against specifications.

### Phase 5: Bug Fix & Revision (Kilocode - Minimax M2.1)
Post-implementation bug fixes and revisions based on user-provided ISSUES.md.
- **Trigger**: Create `ISSUES.md` in project folder
- **Priority**: ISSUES.md takes highest priority over original design
- **Context**: Agent has access to original design for reference
- **Use Case**: Fix bugs, correct misinterpretations, implement improvements

## Bug Fix Mode

When implementation reveals issues or you want to make changes:

1. **Create ISSUES.md** in your project folder
   ```bash
   # Copy template
   cp templates/common/ISSUES_TEMPLATE.md /path/to/project/ISSUES.md
   
   # Edit with your issues
   vim /path/to/project/ISSUES.md
   ```

2. **Run bug fix mode**
   ```bash
   ./scripts/run-agentic-workflow.sh --project-dir /path/to/project --bug-fix
   ```

3. **Agent will**:
   - Read ISSUES.md as primary directive
   - Reference original design for context
   - Fix issues systematically
   - Commit each fix with descriptive messages
   - Create BUGFIX_COMPLETE.md when done

**ISSUES.md Format**:
- Critical Bugs: Actual vs Expected behavior
- Design Misinterpretations: Original requirement vs what was implemented
- Improvements: Rationale and impact
- Refactoring: Current vs desired state

**Priority Hierarchy**:
1. ISSUES.md (User's explicit changes)
2. Original Design Documents (Context only)
3. Project Rules (.kilorules, .cursorrules)
4. Platform Templates

## Remote Execution

For platforms requiring specific machines (NinjaTrader on Windows):

1. **Git Sync**: Changes pushed to repo, pulled on target machine
2. **Auto-Compile**: NT8 detects file changes, compiles automatically
3. **Feedback Harvest**: AutoHotkey/AskUI captures compile results
4. **Signal Files**: Results written to `feedback/COMPILE_RESULT.md`
5. **Git Sync Back**: Results pushed, orchestrator continues

## MCP Integration

Platform-specific tools via MCP:

```bash
# Configure MCP for a platform
./scripts/configure-mcp.sh --platform react-supabase

# MCP servers used per platform:
# - react-supabase: @anthropic/supabase-mcp
# - n8n: n8n-mcp-server
# - ninjatrader: (future) nt8-compile-mcp
```

## Configuration

Copy `config.example.sh` to `config.sh` and customize:

```bash
# Machine configurations
WINDOWS_NT8_HOST="cliff-windows"
WINDOWS_NT8_PATH="/c/Users/cliff/Documents/NinjaTrader 8"

# Git repo for sync
SYNC_REPO="git@github.com:cliff/nt8_custom.git"

# MCP server paths
MCP_SUPABASE_PATH="~/.config/mcp/supabase"
```

## Obsidian Documentation

This system is documented in Obsidian for easy reference and updates:

- **Main Documentation**: `Agentic Coding System` note in Obsidian vault
- **Bug Fix Mode**: `Agentic Coding/Bug Fix Mode` note
- **Workflow Phases**: `Agentic Coding/Workflow Phases` note
- **Platform Guides**: `Agentic Coding/Platforms/` folder

When updating this README, also update the corresponding Obsidian notes to maintain consistency.

To find and update Obsidian notes:
```bash
# List notes in Agentic Coding folder
npx obsidian-mcp-server obsidian_list_notes --dirPath "Agentic Coding"

# Read a specific note
npx obsidian-mcp-server obsidian_read_note --filePath "Agentic Coding/Bug Fix Mode.md"

# Update a note
npx obsidian-mcp-server obsidian_update_note --filePath "Agentic Coding/Bug Fix Mode.md" --content "..."
```

