# Issues & Revisions List

**Project**: [Project Name]
**Created**: [Date]
**Priority**: HIGH - Overrides original design where conflicts exist

## Issue Classification

### Critical Bugs
- [ ] Issue 1: [Description]
  - **File**: [path/to/file.cs]
  - **Expected**: [What should happen]
  - **Actual**: [What's happening]
  - **Root Cause**: [If known]

### Design Misinterpretations
- [ ] Issue 2: [Description]
  - **Original Requirement**: [Quote from DESIGN.md]
  - **Misinterpretation**: [What was implemented incorrectly]
  - **Correction**: [What needs to change]

### Improvements/Enhancements
- [ ] Issue 3: [Description]
  - **Rationale**: [Why this change is needed]
  - **Impact**: [What this affects]

### Refactoring
- [ ] Issue 4: [Description]
  - **Current State**: [Description]
  - **Desired State**: [Description]

## Notes for Agent

- These issues take priority over original design documents
- Use original design only for context, not as authority
- If an issue is unclear, mark it in BUGFIX_BLOCKED.md
- Fix issues in order listed unless dependencies require otherwise
- Each fix should be committed with a descriptive message
- Update BUGFIX_PROGRESS.md after each fix is completed

## Example Issues

### Critical Bug Example
- [ ] Pivot line calculation incorrect on M1 timeframe
  - **File**: Indicators/PivotMC.cs
  - **Expected**: Pivot lines should use HLC/3 formula
  - **Actual**: Using HL/2 formula
  - **Root Cause**: Line 245 uses wrong calculation

### Design Misinterpretation Example
- [ ] Multi-timeframe aggregation not implemented
  - **Original Requirement**: "Aggregate pivot levels from M1, M5, M15 timeframes"
  - **Misinterpretation**: Only M1 timeframe used
  - **Correction**: Add M5 and M15 timeframe aggregation

### Improvement Example
- [ ] Add pivot line strength indicator
  - **Rationale**: Helps identify strongest support/resistance levels
  - **Impact**: Visual enhancement only, no logic changes
