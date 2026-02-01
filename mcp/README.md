# MCP Integration

Model Context Protocol (MCP) servers provide platform-specific tools to agents.

## Supported MCP Servers

| Platform | MCP Server | Status | Purpose |
|----------|------------|--------|---------|
| Supabase | `@supabase/mcp-server-supabase` | Ready | DB queries, auth, storage |
| n8n | `n8n-mcp-server` | Ready | Workflow management |
| NinjaTrader | `nt8-mcp` | Planned | Compile feedback, workspace |
| Obsidian | `obsidian-mcp` | Ready | Note management |

## Configuration

### For Claude Code

Add to `~/.claude.json` or project `.claude/mcp.json`:

```json
{
  "mcpServers": {
    "supabase": {
      "command": "npx",
      "args": ["-y", "@supabase/mcp-server-supabase"],
      "env": {
        "SUPABASE_URL": "https://xxx.supabase.co",
        "SUPABASE_SERVICE_KEY": "..."
      }
    },
    "n8n": {
      "command": "npx",
      "args": ["-y", "n8n-mcp-server"],
      "env": {
        "N8N_API_URL": "http://localhost:5678",
        "N8N_API_KEY": "..."
      }
    }
  }
}
```

### For Kilocode

Kilocode uses its own MCP configuration in `.kilocode/mcp.json`:

```json
{
  "servers": {
    "supabase": {
      "command": "npx",
      "args": ["-y", "@supabase/mcp-server-supabase"]
    }
  }
}
```

## Platform-Specific Tools

### Supabase MCP

Tools available:
- `supabase_query`: Run SQL queries
- `supabase_insert`: Insert data
- `supabase_auth_user`: Manage users
- `supabase_storage`: Manage files

### n8n MCP

Tools available:
- `n8n_list_workflows`: List all workflows
- `n8n_get_workflow`: Get workflow details
- `n8n_execute_workflow`: Run a workflow
- `n8n_create_workflow`: Create new workflow

### Future: NinjaTrader MCP

Planned tools:
- `nt8_compile_status`: Get compilation status
- `nt8_get_errors`: Get compilation errors
- `nt8_workspace_open`: Open a saved workspace
- `nt8_chart_screenshot`: Capture chart image

## Usage in Workflows

The orchestration script detects platform and configures MCP:

```bash
# Auto-detect platform and enable relevant MCP
./scripts/run-agentic-workflow.sh --project-dir /path/to/react-app

# Platform detected: react-supabase
# MCP enabled: supabase
```

## Developing Custom MCP Servers

For NinjaTrader and other platforms without existing MCP:

1. Create server following MCP specification
2. Implement platform-specific tools
3. Add configuration to `mcp/config/`
4. Update platform profile to use MCP tools

See: https://modelcontextprotocol.io/docs
