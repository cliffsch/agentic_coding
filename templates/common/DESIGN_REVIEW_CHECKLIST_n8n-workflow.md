# Design Review Checklist - n8n Workflows

> Validates DESIGN.md and IMPLEMENTATION.md completeness for n8n workflow projects before implementation begins.

## Pre-Review Verification

- [ ] DESIGN.md exists and is readable
- [ ] IMPLEMENTATION.md exists and is readable
- [ ] WORKFLOW_SPEC.md exists (if applicable)
- [ ] WEBHOOK_SPEC.md exists (if applicable)
- [ ] All referenced files exist

---

## 1. Workflow Structure Requirements

### 1.1 Workflow JSON Structure
- [ ] Workflow JSON schema is valid
- [ ] Workflow has a unique name
- [ ] Workflow has proper version tagging
- [ ] Nodes have unique IDs

### 1.2 Node Configuration
- [ ] All required nodes are specified
- [ ] Node parameters are documented
- [ ] Node connections (flows) are defined
- [ ] Error handling nodes are present

---

## 2. Credential Management

### 2.1 Credential References
- [ ] **CRITICAL**: Credential references use proper naming (not hardcoded values)
- [ ] All required credentials are listed
- [ ] Credential types are specified
- [ ] Default credential names are documented

### 2.2 Security
- [ ] No sensitive data in workflow JSON
- [ ] API keys use credential references
- [ ] Webhook secrets use environment variables

---

## 3. Webhook Configuration

### 3.1 Webhook Setup
- [ ] Webhook URLs use environment variables
- [ ] Webhook paths are documented
- [ ] Webhook methods (GET, POST, etc.) are specified
- [ ] Webhook authentication is configured

### 3.2 Webhook Security
- [ ] Webhook endpoints are secured (if needed)
- [ ] IP allowlisting is documented (if applicable)
- [ ] Webhook payload validation is specified

---

## 4. Error Handling

### 4.1 Error Nodes
- [ ] Error handling nodes are present at critical points
- [ ] Error workflows are defined for unhandled errors
- [ ] Retry logic is configured where appropriate

### 4.2 Error Notifications
- [ ] Error notification channels are specified (email, Slack, etc.)
- [ ] Error logging is configured
- [ ] Alert thresholds are defined

---

## 5. Data Flow

### 5.1 Data Transformation
- [ ] Data transformation steps are documented
- [ ] JSON paths/expressions are specified
- [ ] Data validation is implemented

### 5.2 Data Storage
- [ ] Temporary data storage is managed
- [ ] File handling is specified (if applicable)
- [ ] Data retention is configured

---

## 6. Execution Configuration

### 6.1 Execution Settings
- [ ] Execution mode is specified (manual, webhook, schedule)
- [ ] Timeout settings are configured
- [ ] Concurrency limits are defined (if needed)

### 6.2 Scheduling
- [ ] Cron expressions are valid (if scheduled)
- [ ] Timezone is specified
- [ ] Schedule overlaps are handled

---

## 7. Implementation Plan Validation

### 7.1 Phase Completeness
- [ ] Phase 1: Workflow structure (triggers, nodes)
- [ ] Phase 2: Core logic (transformations, conditions)
- [ ] Phase 3: Integrations (API calls, webhooks)
- [ ] Phase 4: Error handling and logging
- [ ] Phase 5: Testing and validation

### 7.2 Deployment Considerations
- [ ] Workflows deployed via n8n API
- [ ] Credentials configured in n8n UI
- [ ] Webhook URLs match deployed environment

---

## 8. Common n8n Pitfalls

### 8.1 Infinite Loops
- [ ] No circular references in workflow logic
- [ ] Webhook triggers don't create self-referential loops
- [ ] Error handling doesn't trigger the same workflow

### 8.2 Data Issues
- [ ] Large data sets are handled (pagination)
- [ ] Binary data is properly managed
- [ ] Data type conversions are handled

### 8.3 API Limits
- [ ] Rate limiting is considered
- [ ] API quotas are documented
- [ ] Retry with backoff is configured

---

## Review Decision

**Status**: [ ] DESIGN_APPROVED / [ ] DESIGN_ISSUES_FOUND

### If APPROVED:
- Create `DESIGN_APPROVED.md`
- Implementation can proceed

### If ISSUES_FOUND:
- Create `DESIGN_ISSUES.md` with:
  - Issue description
  - Location (file, section)
  - Severity (Critical/Medium/Low)
  - Recommendation
  - Example fix

---

## Review Output Checklist

- [ ] DESIGN_REVIEW_RESULTS.md created with detailed findings
- [ ] All Critical issues documented (if any)
- [ ] All Medium issues documented (if any)
- [ ] DESIGN_APPROVED.md OR DESIGN_ISSUES.md created
- [ ] Human notified if Critical issues found
