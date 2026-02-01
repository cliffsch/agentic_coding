# Implementation Plan: DailyPivots

> Phased implementation for NinjaTrader 8 Indicator

## Overview

| Field | Value |
|-------|-------|
| **Design Doc** | DESIGN.md |
| **Total Phases** | 5 |
| **Execution** | Remote (Windows NT8) |
| **Feedback** | Auto-compile results |

## Pre-Implementation Checklist

- [ ] DESIGN.md is complete and approved (DESIGN_APPROVED.md exists)
- [ ] Reference code reviewed: `Strategies/IchiADRpivotOVN.cs`
- [ ] Target file path confirmed: `Indicators/DailyPivots.cs`

---

## Phase 1: Class Structure

### Objective
Create the basic class structure with properties and state management skeleton.

### Tasks

1. Create file `Indicators/DailyPivots.cs`
2. Add namespace and using statements
3. Define class inheriting from `Indicator`
4. Add input properties with attributes:
   - `PivotColor` (Brush)
   - `ResistanceColor` (Brush)
   - `SupportColor` (Brush)
   - `ShowLabels` (bool)
5. Add `[Display]` attributes with GroupName "Parameters"
6. Implement `OnStateChange()` skeleton with all states
7. Add empty `OnBarUpdate()` method

### Files Changed
- `Indicators/DailyPivots.cs` (create)

### Verification
- **Remote**: Compile check → `feedback/COMPILE_SUCCESS.md`

### Commit
```
Phase 1: Class structure for DailyPivots
```

### Wait For
- `COMPILE_SUCCESS.md`

---

## Phase 2: State Configuration

### Objective
Implement SetDefaults with all 7 plots and Configure state.

### Tasks

1. In `State.SetDefaults`:
   - Set Name = "DailyPivots"
   - Set Description
   - Set Calculate = Calculate.OnBarClose
   - Set IsOverlay = true
   - Set DisplayInDataBox = true
   - Add 7 plots:
     - Pivot (DodgerBlue, solid)
     - R1, R2, R3 (Red, dashed)
     - S1, S2, S3 (Green, dashed)
   - Set default parameter values

2. In `State.Configure`:
   - Add any additional setup (minimal for this indicator)

### Files Changed
- `Indicators/DailyPivots.cs` (modify)

### Verification
- **Remote**: Compile check
- Indicator should appear in NinjaTrader indicator list

### Commit
```
Phase 2: State configuration for DailyPivots
```

### Wait For
- `COMPILE_SUCCESS.md`

---

## Phase 3: Core Logic

### Objective
Implement session detection and pivot calculation.

### Tasks

1. Add private variables:
   ```csharp
   private SessionIterator sessionIterator;
   private double priorHigh;
   private double priorLow;
   private double priorClose;
   private bool newSession;
   private double pivotLevel;
   private double r1, r2, r3;
   private double s1, s2, s3;
   ```

2. In `State.DataLoaded`:
   - Initialize SessionIterator
   - Set initial values

3. In `OnBarUpdate()`:
   - Check minimum bars: `if (CurrentBar < 1) return;`
   - Detect session change using SessionIterator
   - On session change:
     - Store prior session High/Low/Close
     - Calculate pivot levels
   - Set plot values:
     ```csharp
     Pivot[0] = pivotLevel;
     R1[0] = r1;
     R2[0] = r2;
     R3[0] = r3;
     S1[0] = s1;
     S2[0] = s2;
     S3[0] = s3;
     ```

4. Add debug logging:
   ```csharp
   Print($"{Time[0]:yyyy-MM-dd HH:mm:ss} [DailyPivots] P={pivotLevel:F2}");
   ```

### Files Changed
- `Indicators/DailyPivots.cs` (modify)

### Verification
- **Remote**: Compile check
- **Manual**: Load on chart, verify pivot values

### Commit
```
Phase 3: Core logic implementation for DailyPivots
```

### Wait For
- `COMPILE_SUCCESS.md`
- (Optional) `MANUAL_VERIFIED.md` for logic verification

---

## Phase 4: Labels and Visualization

### Objective
Add text labels for each pivot level.

### Tasks

1. Add label drawing in `OnBarUpdate()`:
   ```csharp
   if (ShowLabels && IsFirstTickOfBar)
   {
       Draw.Text(this, "PivotLabel" + CurrentBar, "P", 0, pivotLevel, PivotColor);
       Draw.Text(this, "R1Label" + CurrentBar, "R1", 0, r1, ResistanceColor);
       // ... etc for all levels
   }
   ```

2. Implement cleanup for old labels (manage tag naming)

3. Handle color updates from parameters

### Files Changed
- `Indicators/DailyPivots.cs` (modify)

### Verification
- **Remote**: Compile check
- **Manual**: Visual inspection of labels

### Commit
```
Phase 4: Visualization for DailyPivots
```

### Wait For
- `COMPILE_SUCCESS.md`

---

## Phase 5: Cleanup and Documentation

### Objective
Add proper resource cleanup and XML documentation.

### Tasks

1. Implement `OnTermination()`:
   ```csharp
   protected override void OnTermination()
   {
       // Clean up any resources
       // SessionIterator doesn't need disposal
   }
   ```

2. Add XML documentation:
   ```csharp
   /// <summary>
   /// Displays standard pivot points calculated from prior session.
   /// </summary>
   ```

3. Remove or conditionalize debug Print statements

4. Final review for:
   - Memory leaks
   - Null reference potential
   - Edge cases

### Files Changed
- `Indicators/DailyPivots.cs` (modify)

### Verification
- **Remote**: Final compile check
- **Manual**: Extended run test

### Commit
```
Phase 5: Cleanup and documentation for DailyPivots

Co-Authored-By: Claude <noreply@anthropic.com>
```

---

## Completion Signal

When all phases complete:

```markdown
# IMPLEMENTATION_COMPLETE.md

**Project**: DailyPivots
**Status**: COMPLETE
**Timestamp**: {ISO timestamp}

## Summary

- 5 phases completed
- All compilations successful
- Ready for code review

## Files Created/Modified

- Indicators/DailyPivots.cs (new)

## Notes

{Any notes about the implementation}
```
