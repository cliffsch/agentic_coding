# Common Non-Functional Requirements (NFRs)

> Cross-platform baseline requirements for all projects in the agentic coding system.
> Platform-specific NFRs extend these; project-level overrides can modify or disable.

## Operability (OPS)

| ID | Requirement | Rationale | Default |
|----|-------------|-----------|---------|
| OPS-1 | Project-level documentation | Self-contained projects that can be understood without external context | Required |
| OPS-2 | Multi-level logging (DEBUG/INFO/WARN/ERROR/CRITICAL) | Graduated visibility for different operational contexts with first level being | Required |
| OPS-3 | Debug logging as runtime toggle | Troubleshooting without redeploy; avoid performance impact in production | Required |
| OPS-4 | Health/status endpoints or indicators | Quick operational checks; know if system is alive | Recommended |
| OPS-5 | Structured log format (JSON preferred) | Log aggregation friendly; machine-parseable | Recommended |

### OPS Implementation Guidance

**OPS-2 Log Levels:**
- `INFO`: Normal operations, startup/shutdown, key milestones
- `WARN`: Recoverable issues, degraded performance, approaching limits
- `ERROR`: Operation failed but system continues
- `CRITICAL`: System-wide failure requiring immediate attention

**OPS-3 Debug Toggle:**
- Environment variable (e.g., `LOG_LEVEL=DEBUG`) or runtime flag
- Default to INFO in production
- Debug logging should include: input/output values, timing, decision paths

---

## Maintainability (MNT)

| ID | Requirement | Rationale | Default |
|----|-------------|-----------|---------|
| MNT-1 | Clear code organization | Human + AI agent readability; faster onboarding | Required |
| MNT-2 | Consistent naming conventions | Reduces cognitive load; predictable patterns | Required |
| MNT-3 | No magic numbers/strings | Self-documenting code; single point of change | Required |
| MNT-4 | Minimal dependencies | Easier updates; smaller attack surface | Recommended |

### MNT Implementation Guidance

**MNT-1 Code Organization:**
- Group related functionality
- Separate concerns (data, logic, presentation)
- Use descriptive file/folder names

**MNT-3 Magic Numbers:**
- Define constants with meaningful names
- Place configuration values in config files/environment
- Document non-obvious values with comments

---

## Performance (PRF)

| ID | Requirement | Rationale | Default |
|----|-------------|-----------|---------|
| PRF-1 | Log rotation/retention limits | Prevent disk exhaustion; manage storage costs | Required |
| PRF-2 | Lazy initialization where appropriate | Faster startup; defer heavy operations | Recommended |
| PRF-3 | Resource cleanup on shutdown | No orphaned resources; clean restarts | Required |

### PRF Implementation Guidance

**PRF-1 Log Retention:**
- Default: 7 days or 100MB, whichever is reached first
- Archive or delete based on compliance needs
- Consider log shipping for long-term analysis

**PRF-3 Resource Cleanup:**
- Implement shutdown hooks/handlers
- Close connections, file handles, subscriptions
- Persist state if needed for recovery

---

## Security (SEC)

| ID | Requirement | Rationale | Default |
|----|-------------|-----------|---------|
| SEC-1 | No hardcoded secrets | Environment/vault only; prevents accidental exposure | Required |
| SEC-2 | Input validation at boundaries | Defense in depth; prevent injection attacks | Required |
| SEC-3 | Audit logging for sensitive ops | Traceability; compliance; forensics | Recommended |
| SEC-4 | Principle of least privilege | Minimize blast radius; defense in depth | Required |

### SEC Implementation Guidance

**SEC-1 Secrets Management:**
- Use environment variables for local development
- Use secrets manager (Vault, AWS Secrets Manager) for production
- Never commit `.env` files with real secrets

**SEC-2 Input Validation:**
- Validate at system boundaries (user input, API calls, file reads)
- Whitelist allowed values when possible
- Sanitize before use in queries, commands, output

---

## User Experience (UX)

| ID | Requirement | Rationale | Default |
|----|-------------|-----------|---------|
| UX-1 | Graceful error handling | User sees helpful messages, not stack traces | Required |
| UX-2 | Loading states | User knows something is happening | Recommended |
| UX-3 | Confirmation feedback | User knows action succeeded | Recommended |

### UX Implementation Guidance

**UX-1 Error Messages:**
- User-facing: Clear, actionable, non-technical
- Developer-facing: Full context in logs
- Never expose internal paths, stack traces, or sensitive data

---

## Operator Alerting (ALT)

| ID | Requirement | Rationale | Default |
|----|-------------|-----------|---------|
| ALT-1 | Critical error notifications | Immediate awareness of system failures | Required |
| ALT-2 | Platform-appropriate channels | Email/Telegram for trading, webhook for web apps | Required |
| ALT-3 | Alert deduplication/throttling | Prevent alert fatigue; aggregate similar issues | Recommended |
| ALT-4 | Actionable alert content | Include context needed to diagnose | Required |

### ALT Implementation Guidance

**ALT-1 When to Alert:**
- System startup failures
- Unhandled exceptions in critical paths
- Resource exhaustion (disk, memory, connections)
- External service failures (API, database)

**ALT-4 Alert Content:**
- What happened (error type, message)
- Where (component, function, line if available)
- When (timestamp in UTC)
- Context (relevant IDs, state, recent actions)
- Suggested action (if known)

---

## NFR Compliance in Design Review

Design reviews should verify:

1. **Baseline compliance**: All "Required" NFRs are addressed
2. **Justified deviations**: Any disabled/modified NFRs documented in `NFR_OVERRIDES.md`
3. **Platform-specific**: Platform NFRs are also addressed
4. **Implementation patterns**: Chosen approaches align with guidance above

---

## Version History

| Version | Date | Changes |
|---------|------|---------|
| 1.0 | 2025-02-01 | Initial NFR framework |
