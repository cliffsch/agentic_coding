# Design Document: {PROJECT_NAME}

> n8n Workflow Automation Design Specification

## Overview

| Field | Value |
|-------|-------|
| **Project** | {PROJECT_NAME} |
| **Type** | n8n Workflow |
| **Platform** | n8n |
| **Author** | {AUTHOR} |
| **Created** | {DATE} |

## Purpose

{One paragraph describing what this workflow does and why it's needed}

## Requirements

### Functional Requirements

1. **FR-1**: {Requirement description}
   - Acceptance: {How to verify}

2. **FR-2**: {Requirement description}
   - Acceptance: {How to verify}

### Non-Functional Requirements

> Baseline NFRs from `templates/nfr/COMMON.md` and `templates/nfr/n8n-workflow.md` apply.
> Document any overrides in `NFR_OVERRIDES.md`.

| Category | Key Requirements | Status |
|----------|-----------------|--------|
| **Operability** | Workflow versioning, documentation nodes, logging | [ ] |
| **Alerting** | Error trigger workflow, Slack/Telegram alerts | [ ] |
| **Performance** | Rate limiting, batch processing, timeouts | [ ] |
| **Security** | Credential store, webhook auth, data sanitization | [ ] |
| **Maintainability** | Descriptive node names, color coding | [ ] |

**Project-Specific NFRs:**
1. {Additional NFR if needed}

**NFR Overrides:** {Reference NFR_OVERRIDES.md if deviations exist}

## Workflow Architecture

### Workflow Overview

```
[Trigger] → [Validation] → [Processing] → [Output]
                              ↓
                        [Error Handler] → [Alert]
```

### Trigger Configuration

| Trigger Type | Configuration |
|--------------|---------------|
| {Webhook / Schedule / Manual} | {Details} |

**Webhook Details (if applicable):**
- Path: `{/webhook-path}`
- Method: `{POST/GET}`
- Authentication: `{Header auth / None}`

**Schedule Details (if applicable):**
- Cron: `{expression}`
- Timezone: `{timezone}`

### Node Flow

| # | Node Name | Type | Purpose |
|---|-----------|------|---------|
| 1 | {Trigger Name} | {type} | {description} |
| 2 | {Validation} | IF | Validate input data |
| 3 | {Process} | {type} | {description} |
| 4 | {Output} | {type} | {description} |

### Error Handling Flow

| Error Type | Handling |
|------------|----------|
| Validation failure | Log and skip |
| API error | Retry with backoff, then alert |
| Critical failure | Alert immediately, stop workflow |

## Data Flow

### Input Data

| Field | Type | Validation | Required |
|-------|------|------------|----------|
| {field1} | {type} | {rules} | {Yes/No} |
| {field2} | {type} | {rules} | {Yes/No} |

### Data Transformations

| Step | Input | Output | Notes |
|------|-------|--------|-------|
| 1 | {input} | {output} | {transformation logic} |
| 2 | {input} | {output} | {transformation logic} |

### Output Data

| Destination | Format | Fields |
|-------------|--------|--------|
| {destination} | {JSON/etc} | {key fields} |

## External Integrations

### API Calls

| API | Endpoint | Method | Rate Limit |
|-----|----------|--------|------------|
| {API name} | {/endpoint} | {GET/POST} | {limits} |

### Credentials Required

| Credential Name | Type | Used By |
|-----------------|------|---------|
| {name} | {HTTP Header / OAuth2} | {Node names} |

## Error & Alert Configuration

### Error Trigger Workflow

| On Error | Action |
|----------|--------|
| Any workflow error | Send to error handler workflow |

### Alert Channels

| Channel | Trigger | Content |
|---------|---------|---------|
| {Slack / Telegram / Email} | {When to send} | {What to include} |

### Alert Throttling

| Alert Type | Cooldown |
|------------|----------|
| {type} | {duration} |

## Testing Strategy

### Test Cases

| Test Case | Input | Expected Output |
|-----------|-------|-----------------|
| Happy path | {sample input} | {expected result} |
| Validation failure | {invalid input} | {error handling} |
| API failure | {trigger failure} | {retry/alert} |

### Test Mode

| Setting | Production | Test |
|---------|------------|------|
| {Setting} | {value} | {value} |

## Deployment

### Workflow Export

```bash
# Export workflow JSON
n8n export:workflow --id={workflow_id} --output=workflow.json

# Import to target environment
n8n import:workflow --input=workflow.json
```

### Credentials Setup

| Credential | Setup Steps |
|------------|-------------|
| {name} | 1. {step} 2. {step} |

### Environment Variables

| Variable | Purpose |
|----------|---------|
| `{VAR_NAME}` | {description} |

## Verification Strategy

### Pre-Implementation
- [ ] Workflow diagram approved
- [ ] API access verified
- [ ] Credentials created in n8n

### Post-Implementation
- [ ] Workflow executes successfully
- [ ] Error handling works
- [ ] Alerts fire correctly
- [ ] Rate limiting respected
- [ ] Test cases pass

## Handoff Notes

### For Implementation Agent

1. **Node Naming**: Use descriptive names, not defaults
2. **Colors**: Follow standard color coding
3. **Documentation**: Add sticky note at start
4. **Testing**: Run manual tests before activating

### Known Constraints

- {API rate limits}
- {Data size limitations}
- {Timing constraints}
