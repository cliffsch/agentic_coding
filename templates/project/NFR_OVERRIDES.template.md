# NFR Overrides for {PROJECT_NAME}

> Project-specific modifications to baseline NFRs.
> Reference: `templates/nfr/COMMON.md` and `templates/nfr/{platform}.md`

## Overview

This file documents deviations from the baseline NFRs. Design review validates that all overrides are justified.

---

## Disabled NFRs

<!-- List NFR IDs that don't apply to this project with justification -->

| NFR ID | Reason for Disabling |
|--------|---------------------|
| _none_ | _All baseline NFRs apply_ |

<!-- Example:
| OPS-4 | No health endpoint needed (single-use CLI script) |
| RS-UX-2 | Headless service - no UI notifications needed |
-->

---

## Modified NFRs

<!-- NFRs with different thresholds, approaches, or implementations -->

| NFR ID | Modification | Justification |
|--------|--------------|---------------|
| _none_ | _No modifications_ | _Using baseline values_ |

<!-- Example:
| PRF-1 | Log retention extended to 90 days | Audit compliance requirement |
| ALT-3 | Alert cooldown reduced to 60 seconds | Critical trading system |
-->

---

## Additional NFRs

<!-- Project-specific requirements not covered by baseline -->

| ID | Requirement | Rationale | Implementation Notes |
|----|-------------|-----------|---------------------|
| _none_ | _No additional NFRs_ | | |

<!-- Example:
| PROJ-1 | Must support offline mode | Mobile field usage | Queue operations, sync on reconnect |
| PROJ-2 | Maximum 2-second response time | User experience target | Consider caching, lazy loading |
-->

---

## NFR Compliance Summary

**Baseline NFRs:**
- [ ] COMMON.md: All Required items addressed
- [ ] {platform}.md: All Required items addressed

**Review Status:**
- [ ] Overrides reviewed and approved in design review
- [ ] Implementation plan includes NFR verification steps

---

## Version History

| Date | Author | Changes |
|------|--------|---------|
| {DATE} | {AUTHOR} | Initial creation |
