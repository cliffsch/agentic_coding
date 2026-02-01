# n8n Workflow NFRs

> Platform-specific non-functional requirements for n8n workflow automation projects.
> These extend the common NFRs in `COMMON.md`.

## Platform Context

n8n is a workflow automation platform that connects various services via webhooks, APIs, and scheduled triggers. Workflows run as background jobs where errors may go unnoticed without proper alerting. Credential management is critical as workflows often have access to sensitive services.

---

## n8n Operability (N8-OPS)

| ID | Requirement | Implementation Pattern | Default |
|----|-------------|------------------------|---------|
| N8-OPS-1 | Workflow versioning | Version in workflow name or description | Required |
| N8-OPS-2 | Workflow documentation | Notes node at start explaining purpose | Required |
| N8-OPS-3 | Execution logging | Log key decisions and data transformations | Recommended |

### N8-OPS Implementation Patterns

**N8-OPS-1 Versioning Convention:**
```
Workflow Name: "Customer Sync v2.1"
Description: "v2.1 - Added retry logic for API failures (2025-01-15)"
```

**N8-OPS-2 Documentation Node:**
```json
{
  "type": "n8n-nodes-base.stickyNote",
  "position": [0, 0],
  "parameters": {
    "content": "## Customer Sync Workflow\n\n**Purpose:** Sync customer data from CRM to database\n\n**Trigger:** Webhook from CRM on customer update\n\n**Dependencies:**\n- CRM API credentials\n- Database credentials\n\n**Error handling:** Sends Slack alert on failure"
  }
}
```

**N8-OPS-3 Logging with Set Node:**
```json
{
  "type": "n8n-nodes-base.set",
  "parameters": {
    "values": {
      "string": [
        {
          "name": "log_entry",
          "value": "={{ JSON.stringify({ timestamp: $now.toISO(), step: 'transform', input_count: $input.all().length }) }}"
        }
      ]
    }
  }
}
```

---

## n8n Alerting (N8-ALT)

| ID | Requirement | Implementation Pattern | Default |
|----|-------------|------------------------|---------|
| N8-ALT-1 | Error notifications | Error Trigger node → notification channel | Required |
| N8-ALT-2 | Workflow failure alerts | Dedicated error workflow | Required |
| N8-ALT-3 | Success confirmation | Notify on critical workflow completion | Recommended |

### N8-ALT Implementation Patterns

**N8-ALT-1 Error Trigger Workflow:**
```json
{
  "name": "Error Handler",
  "nodes": [
    {
      "type": "n8n-nodes-base.errorTrigger",
      "name": "On Error",
      "position": [250, 300]
    },
    {
      "type": "n8n-nodes-base.slack",
      "name": "Send Slack Alert",
      "parameters": {
        "channel": "#alerts",
        "text": "🔴 Workflow Error\n*Workflow:* {{ $json.workflow.name }}\n*Error:* {{ $json.execution.error.message }}\n*Time:* {{ $now }}"
      }
    }
  ]
}
```

**N8-ALT-2 Error Branch in Main Workflow:**
```
[Trigger] → [Process] → [Success Path]
                ↓
           [Error Path] → [Send Alert]
```

Use "On Error" setting in node options:
- Continue: Send to error branch
- Stop Workflow: Triggers error workflow

**N8-ALT-3 Telegram Alert Node:**
```json
{
  "type": "n8n-nodes-base.telegram",
  "parameters": {
    "chatId": "={{ $env.TELEGRAM_CHAT_ID }}",
    "text": "✅ {{ $workflow.name }} completed\nProcessed {{ $input.all().length }} items"
  }
}
```

---

## n8n Security (N8-SEC)

| ID | Requirement | Implementation Pattern | Default |
|----|-------------|------------------------|---------|
| N8-SEC-1 | Credential references | Never inline credentials, use n8n credential store | Required |
| N8-SEC-2 | Webhook authentication | Use header auth or webhook path secrets | Required |
| N8-SEC-3 | Data sanitization | Filter sensitive fields before logging | Required |

### N8-SEC Implementation Patterns

**N8-SEC-1 Credential Reference:**
```json
{
  "type": "n8n-nodes-base.httpRequest",
  "parameters": {
    "authentication": "predefinedCredentialType",
    "nodeCredentialType": "httpHeaderAuth"
  },
  "credentials": {
    "httpHeaderAuth": {
      "id": "1",
      "name": "My API Key"
    }
  }
}
```

**N8-SEC-2 Webhook Authentication:**
```json
{
  "type": "n8n-nodes-base.webhook",
  "parameters": {
    "path": "my-webhook-{{ $env.WEBHOOK_SECRET }}",
    "authentication": "headerAuth",
    "options": {
      "rawBody": true
    }
  }
}
```

**N8-SEC-3 Data Sanitization:**
```json
{
  "type": "n8n-nodes-base.set",
  "parameters": {
    "keepOnlySet": true,
    "values": {
      "string": [
        {"name": "user_id", "value": "={{ $json.user_id }}"},
        {"name": "action", "value": "={{ $json.action }}"}
      ]
    }
  }
}
```
(Excludes sensitive fields like passwords, tokens)

---

## n8n Performance (N8-PRF)

| ID | Requirement | Implementation Pattern | Default |
|----|-------------|------------------------|---------|
| N8-PRF-1 | Rate limiting | Wait nodes, retry with backoff | Required |
| N8-PRF-2 | Batch processing | Split In Batches node for large datasets | Required |
| N8-PRF-3 | Timeout configuration | Set appropriate timeouts for HTTP requests | Required |

### N8-PRF Implementation Patterns

**N8-PRF-1 Rate Limiting with Wait:**
```json
{
  "type": "n8n-nodes-base.wait",
  "parameters": {
    "amount": 1,
    "unit": "seconds"
  }
}
```

**N8-PRF-1 Retry with Backoff:**
```json
{
  "type": "n8n-nodes-base.httpRequest",
  "parameters": {
    "options": {
      "retry": {
        "maxRetries": 3,
        "retryIntervalMs": 1000,
        "exponentialBackoff": true
      }
    }
  }
}
```

**N8-PRF-2 Batch Processing:**
```
[Trigger] → [Split In Batches (size: 10)] → [Process Batch] → [Merge]
```

```json
{
  "type": "n8n-nodes-base.splitInBatches",
  "parameters": {
    "batchSize": 10,
    "options": {}
  }
}
```

**N8-PRF-3 HTTP Timeout:**
```json
{
  "type": "n8n-nodes-base.httpRequest",
  "parameters": {
    "options": {
      "timeout": 30000
    }
  }
}
```

---

## n8n Maintainability (N8-MNT)

| ID | Requirement | Implementation Pattern | Default |
|----|-------------|------------------------|---------|
| N8-MNT-1 | Node naming | Descriptive names reflecting function | Required |
| N8-MNT-2 | Color coding | Use colors to group related nodes | Recommended |
| N8-MNT-3 | Modular sub-workflows | Extract reusable logic to sub-workflows | Recommended |

### N8-MNT Implementation Patterns

**N8-MNT-1 Node Naming Convention:**
```
❌ Bad:  "HTTP Request", "Set", "IF"
✅ Good: "Fetch Customer Data", "Format Response", "Check API Success"
```

**N8-MNT-2 Color Coding:**
```
- Green: Success paths
- Red: Error handling
- Blue: Data transformation
- Yellow: External API calls
- Gray: Utility/logging
```

**N8-MNT-3 Sub-workflow Pattern:**
```json
{
  "type": "n8n-nodes-base.executeWorkflow",
  "parameters": {
    "source": "database",
    "workflowId": "{{ $env.ALERT_WORKFLOW_ID }}"
  }
}
```

---

## n8n Testing (N8-TST)

| ID | Requirement | Implementation Pattern | Default |
|----|-------------|------------------------|---------|
| N8-TST-1 | Test with sample data | Document test cases with expected outputs | Required |
| N8-TST-2 | Dry run capability | Environment toggle for test mode | Recommended |

### N8-TST Implementation Patterns

**N8-TST-2 Test Mode Toggle:**
```json
{
  "type": "n8n-nodes-base.if",
  "parameters": {
    "conditions": {
      "boolean": [
        {
          "value1": "={{ $env.TEST_MODE }}",
          "value2": "true"
        }
      ]
    }
  }
}
```

Then route to mock nodes or skip actual API calls in test mode.

---

## Compliance Checklist for Design Review

- [ ] Workflow has version in name/description
- [ ] Documentation node explains purpose and dependencies
- [ ] Error Trigger workflow configured
- [ ] All credentials use n8n credential store (no inline secrets)
- [ ] Webhooks have authentication configured
- [ ] Rate limiting implemented for external API calls
- [ ] Batch processing used for large datasets
- [ ] HTTP requests have timeout configured
- [ ] Nodes have descriptive names
- [ ] Sensitive data filtered from logs
- [ ] Test cases documented
