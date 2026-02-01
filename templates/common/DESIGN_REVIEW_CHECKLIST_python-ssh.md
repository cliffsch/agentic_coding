# Design Review Checklist - Python/SSH

> Validates DESIGN.md and IMPLEMENTATION.md completeness for Python projects with SSH deployment before implementation begins.

## Pre-Review Verification

- [ ] DESIGN.md exists and is readable
- [ ] IMPLEMENTATION.md exists and is readable
- [ ] requirements.txt or pyproject.toml exists
- [ ] NFR_OVERRIDES.md exists (may be empty)
- [ ] All referenced files exist

---

## 0. NFR Compliance

> Reference: `templates/nfr/COMMON.md` and `templates/nfr/python-ssh.md`

### 0.1 Common NFRs
- [ ] **OPS-2**: Multi-level logging implemented (INFO/WARN/ERROR/CRITICAL)
- [ ] **OPS-3**: Debug logging toggle via LOG_LEVEL env var
- [ ] **PRF-1**: Log rotation/retention configured
- [ ] **PRF-3**: Resource cleanup on shutdown
- [ ] **SEC-1**: No hardcoded secrets (environment variables only)
- [ ] **SEC-2**: Input validation at boundaries (CLI args, config)
- [ ] **ALT-1**: Critical error notification mechanism

### 0.2 Python/SSH-Specific NFRs
- [ ] **PY-OPS-1**: Standard logging module with configurable level
- [ ] **PY-OPS-2**: SIGTERM/SIGINT signal handling
- [ ] **PY-OPS-3**: LOG_LEVEL environment variable support
- [ ] **PY-ALT-1**: Operator notification (Telegram/email/webhook)
- [ ] **PY-ALT-2**: Alert throttling implemented
- [ ] **PY-PRF-1**: Graceful shutdown with context managers
- [ ] **PY-SEC-1**: Secrets from environment or secrets manager
- [ ] **PY-SSH-1**: Deployment documentation complete

### 0.3 NFR Overrides
- [ ] All disabled NFRs justified in NFR_OVERRIDES.md
- [ ] All modified NFRs documented with rationale
- [ ] Any additional project-specific NFRs defined

---

## 1. Configuration Requirements Traceability

### 1.1 Config Schema Validation
- [ ] Every config setting in DESIGN.md has a default value
- [ ] Every config setting has a documented purpose
- [ ] Config types are specified (int, string, bool, etc.)

### 1.2 Config Implementation Requirements
- [ ] **CRITICAL**: Every config setting has implementing code that USES it
- [ ] Config loading code is specified
- [ ] Environment variable overrides are handled
- [ ] Config validation is implemented

---

## 2. Lifecycle Management Requirements

### 2.1 Resource Creation
- [ ] Every resource created has explicit creation code
- [ ] Resource initialization order is clear
- [ ] Required directories are created

### 2.2 Resource Cleanup
- [ ] **CRITICAL**: Every "cleanup" or "retention" mention has implementing code
- [ ] Temporary files are cleaned up
- [ ] Old sessions/logs are purged according to retention policy
- [ ] Progress files are archived or deleted

### 2.3 Signal/Interrupt Handling
- [ ] SIGINT/SIGTERM handling is specified
- [ ] Cleanup on interrupt is documented
- [ ] Partial state saving is handled

---

## 3. Data Flow Completeness

### 3.1 Input Handling
- [ ] All inputs are validated
- [ ] Input sources are documented (CLI, config, env vars)
- [ ] Default values are specified

### 3.2 Output Handling
- [ ] All outputs are documented
- [ ] Output locations are specified
- [ ] Output formats are defined

### 3.3 State Management
- [ ] State transitions are documented
- [ ] State persistence is specified
- [ ] State recovery is handled

---

## 4. Test Infrastructure Requirements

### 4.1 Test Fixtures
- [ ] **CRITICAL**: Every "fixture" or "test data" mention has creation steps
- [ ] Test environment setup is documented
- [ ] VM configuration is specified
- [ ] Required test files are listed with creation instructions

### 4.2 Test Coverage Requirements
- [ ] Unit tests are specified for each component
- [ ] Integration tests are specified
- [ ] E2E tests are specified
- [ ] Test verification commands are provided

---

## 5. SSH Deployment Requirements

### 5.1 Deployment Configuration
- [ ] SSH target host is documented
- [ ] SSH key or credential management is specified
- [ ] Remote directory structure is defined

### 5.2 Deployment Process
- [ ] Deployment commands are documented
- [ ] Pre-deployment checks are specified
- [ ] Post-deployment verification is defined
- [ ] Rollback procedure is documented

---

## 6. Component Interface Completeness

### 6.1 Class/Module Interfaces
- [ ] Every class has documented methods
- [ ] Method signatures are complete (params, return types)
- [ ] Abstract methods are fully specified
- [ ] Dependencies between components are clear

### 6.2 External Dependencies
- [ ] All external libraries are listed in requirements
- [ ] Version constraints are specified
- [ ] Optional dependencies are marked

---

## 7. Error Handling Completeness

### 7.1 Error Scenarios
- [ ] Common error scenarios are documented
- [ ] Error handling strategy is specified
- [ ] Error messages are defined
- [ ] Recovery procedures are documented

### 7.2 Failure Modes
- [ ] Graceful degradation is specified
- [ ] Retry logic is documented
- [ ] Circuit breaker patterns are defined (if needed)

---

## 8. Implementation Plan Validation

### 8.1 Phase Completeness
- [ ] Each phase has clear goals
- [ ] Each phase has specific files to create
- [ ] Each phase has verification steps
- [ ] Each phase has a commit message
- [ ] Phases are ordered correctly (dependencies first)

### 8.2 Traceability Matrix
- [ ] **CRITICAL**: Create a matrix mapping DESIGN.md sections to IMPLEMENTATION.md phases

---

## 9. Implicit Requirements Check

### 9.1 Keywords to Investigate
Search DESIGN.md for these and verify they have implementation:

- [ ] "manage" - Is management logic implemented?
- [ ] "track" - Is tracking logic implemented?
- [ ] "monitor" - Is monitoring logic implemented?
- [ ] "handle" - Is handling logic implemented?
- [ ] "support" - Is support logic implemented?
- [ ] "enable" - Is enabling logic implemented?
- [ ] "provide" - Is providing logic implemented?

### 9.2 Configuration-Only Features
Check for features that appear only in config but lack implementation:

- [ ] List all config settings
- [ ] Verify each has implementing code
- [ ] Flag any "config-only" features

---

## 10. Common Pitfalls Check

### 10.1 Partial Implementations
- [ ] Abstract classes have all methods specified
- [ ] Interface implementations are complete
- [ ] Placeholder code is marked with TODO/FIXME

### 10.2 Missing Infrastructure
- [ ] Logging is configured
- [ ] Error reporting is set up
- [ ] Metrics/monitoring is specified (if needed)

### 10.3 Environment Assumptions
- [ ] All environment variables are documented
- [ ] File paths work on target platforms
- [ ] Permissions requirements are specified

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
- [ ] Traceability matrix completed
- [ ] All Critical issues documented (if any)
- [ ] All Medium issues documented (if any)
- [ ] DESIGN_APPROVED.md OR DESIGN_ISSUES.md created
- [ ] Human notified if Critical issues found
