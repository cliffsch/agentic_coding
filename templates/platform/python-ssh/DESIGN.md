# Design Document: {PROJECT_NAME}

> Python Application with SSH Deployment Design Specification

## Overview

| Field | Value |
|-------|-------|
| **Project** | {PROJECT_NAME} |
| **Type** | {Script / Service / CLI Tool} |
| **Platform** | Python with SSH deployment |
| **Author** | {AUTHOR} |
| **Created** | {DATE} |

## Purpose

{One paragraph describing what this application does and why it's needed}

## Requirements

### Functional Requirements

1. **FR-1**: {Requirement description}
   - Acceptance: {How to verify}

2. **FR-2**: {Requirement description}
   - Acceptance: {How to verify}

### Non-Functional Requirements

> Baseline NFRs from `templates/nfr/COMMON.md` and `templates/nfr/python-ssh.md` apply.
> Document any overrides in `NFR_OVERRIDES.md`.

| Category | Key Requirements | Status |
|----------|-----------------|--------|
| **Operability** | Multi-level logging, signal handling, debug toggle | [ ] |
| **Performance** | Graceful shutdown, context managers, resource cleanup | [ ] |
| **Alerting** | Telegram/email notifications, alert throttling | [ ] |
| **Security** | Secrets from environment, input validation | [ ] |
| **Deployment** | SSH deployment docs, systemd service file | [ ] |

**Project-Specific NFRs:**
1. {Additional NFR if needed}

**NFR Overrides:** {Reference NFR_OVERRIDES.md if deviations exist}

## Architecture

### Module Structure

```
{project_name}/
├── __init__.py
├── __main__.py      # Entry point
├── config.py        # Configuration loading
├── {module1}.py     # Core functionality
├── {module2}.py     # Additional modules
└── utils/
    ├── logging.py   # Logging setup
    └── alerts.py    # Alert functions
```

### Class/Module Overview

| Module | Responsibility |
|--------|---------------|
| `config` | Load and validate configuration |
| `{module1}` | {Description} |
| `{module2}` | {Description} |

### Configuration

| Setting | Type | Default | Description |
|---------|------|---------|-------------|
| `LOG_LEVEL` | string | `INFO` | Logging level |
| `{SETTING}` | {type} | {default} | {Description} |

## Data Flow

### Input Sources

| Input | Format | Validation |
|-------|--------|------------|
| {input1} | {format} | {validation rules} |

### Output

| Output | Format | Destination |
|--------|--------|-------------|
| {output1} | {format} | {destination} |

### State Management

| State | Persistence | Recovery |
|-------|-------------|----------|
| {state1} | {How stored} | {How recovered} |

## Error Handling

### Error Scenarios

| Scenario | Handling | Alert Level |
|----------|----------|-------------|
| {scenario1} | {approach} | {INFO/WARN/ERROR/CRITICAL} |
| {scenario2} | {approach} | {level} |

### Retry Logic

| Operation | Max Retries | Backoff |
|-----------|-------------|---------|
| {operation} | {count} | {strategy} |

## Lifecycle Management

### Startup

```
1. Load configuration from environment
2. Initialize logging
3. Validate required settings
4. {Additional startup steps}
5. Signal ready state
```

### Shutdown

```
1. Receive SIGTERM/SIGINT
2. Stop accepting new work
3. Complete in-progress operations
4. {Additional cleanup}
5. Close connections
6. Exit cleanly
```

### Health Check

| Method | Implementation |
|--------|---------------|
| {File / HTTP / Socket} | {Details} |

## SSH Deployment

### Target Environment

| Setting | Value |
|---------|-------|
| Host | {hostname or IP} |
| User | {deployment user} |
| Directory | {/path/to/app} |
| Python | {version} |

### Deployment Steps

```bash
# 1. Sync files
rsync -avz --exclude '.git' --exclude '__pycache__' \
  ./ user@host:/path/to/app/

# 2. Update dependencies
ssh user@host "cd /path/to/app && pip install -r requirements.txt"

# 3. Restart service
ssh user@host "sudo systemctl restart {service_name}"

# 4. Verify
ssh user@host "sudo systemctl status {service_name}"
```

### Rollback

```bash
# Restore previous version
ssh user@host "cd /path/to/app && git checkout HEAD~1"
ssh user@host "sudo systemctl restart {service_name}"
```

## Dependencies

| Package | Version | Purpose |
|---------|---------|---------|
| {package1} | {version} | {why needed} |
| {package2} | {version} | {why needed} |

## Verification Strategy

### Pre-Implementation
- [ ] All configuration settings documented
- [ ] Error handling strategy defined
- [ ] SSH deployment commands verified

### Post-Implementation
- [ ] Script runs locally without errors
- [ ] All log levels work correctly
- [ ] Signal handling tested (Ctrl+C)
- [ ] Deploys successfully to target
- [ ] Health check working
- [ ] Alerts fire on critical errors

## Handoff Notes

### For Implementation Agent

1. **Python version**: {3.9+ / specific version}
2. **Style**: Follow PEP 8, use type hints
3. **Logging**: Use standard `logging` module
4. **Commits**: One commit per implementation phase

### Known Constraints

- {Any platform-specific constraints}
- {VM/server limitations}
- {Network considerations}
