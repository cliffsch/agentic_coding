# Implementation Plan: {PROJECT_NAME}

> Phased implementation for NinjaTrader 8 {Indicator|Strategy}

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
- [ ] Target file path confirmed: `{Indicators|Strategies}/{ClassName}.cs`

---

## Phase 1: Class Structure

### Objective
Create the basic class structure with properties and state management skeleton.

### Tasks

1. Create file `{Indicators|Strategies}/{ClassName}.cs`
2. Add namespace and using statements
3. Define class inheriting from `{Indicator|Strategy}`
4. Add all `[NinjaScriptProperty]` input parameters
5. Add `[Display]` attributes with proper grouping
6. Implement `OnStateChange()` skeleton with all states
7. Add empty `OnBarUpdate()` method

### Code Template

```csharp
#region Using declarations
using System;
using System.ComponentModel;
using System.ComponentModel.DataAnnotations;
using NinjaTrader.Cbi;
using NinjaTrader.Gui;
using NinjaTrader.NinjaScript;
using NinjaTrader.NinjaScript.{Indicators|Strategies};
#endregion

namespace NinjaTrader.NinjaScript.{Indicators|Strategies}
{
    public class {ClassName} : {Indicator|Strategy}
    {
        #region Variables
        // Private variables here
        #endregion

        protected override void OnStateChange()
        {
            if (State == State.SetDefaults)
            {
                // See Phase 2
            }
            else if (State == State.Configure)
            {
                // See Phase 2
            }
            else if (State == State.DataLoaded)
            {
                // See Phase 3
            }
        }

        protected override void OnBarUpdate()
        {
            // See Phase 3
        }

        #region Properties
        // See Phase 1 tasks
        #endregion
    }
}
```

### Verification
- **Local**: Syntax check (Read tool pattern matching)
- **Remote**: Compile check → `feedback/COMPILE_RESULT.md`

### Commit
```
Phase 1: Class structure for {ClassName}
```

### Wait For
- `COMPILE_SUCCESS.md` OR fix errors from `COMPILE_ERRORS.md`

---

## Phase 2: State Configuration

### Objective
Implement SetDefaults and Configure states with all initialization.

### Tasks

1. In `State.SetDefaults`:
   - Set Name, Description
   - Set Calculate mode
   - Set IsOverlay, DisplayInDataBox, etc.
   - Add all plots with `AddPlot()`
   - Set default parameter values

2. In `State.Configure`:
   - Add any additional data series
   - Configure indicator dependencies

### Verification
- **Remote**: Compile check
- Plots should appear in indicator list

### Commit
```
Phase 2: State configuration for {ClassName}
```

### Wait For
- `COMPILE_SUCCESS.md`

---

## Phase 3: Core Logic

### Objective
Implement the main calculation logic in OnBarUpdate().

### Tasks

1. In `State.DataLoaded`:
   - Initialize runtime objects
   - Create indicator instances

2. In `OnBarUpdate()`:
   - Add minimum bars check: `if (CurrentBar < {MinBars}) return;`
   - Implement main calculation algorithm
   - Set plot values: `{PlotName}[0] = {value};`
   - Add debug logging: `Print($"{Time[0]:yyyy-MM-dd HH:mm:ss} [{ClassName}] {message}");`

### Verification
- **Remote**: Compile check
- **Manual**: Load on chart, verify output values

### Commit
```
Phase 3: Core logic implementation for {ClassName}
```

### Wait For
- `COMPILE_SUCCESS.md`
- (Optional) `MANUAL_VERIFIED.md` for complex logic

---

## Phase 4: Drawing and Visualization

### Objective
Add any Draw methods and visual enhancements.

### Tasks

1. Add `Draw.Text()`, `Draw.Line()`, `Draw.Region()` as needed
2. Implement color conditions (bullish/bearish coloring)
3. Add price markers if applicable
4. Manage drawing object cleanup

### Verification
- **Remote**: Compile check
- **Manual**: Visual inspection on chart

### Commit
```
Phase 4: Visualization for {ClassName}
```

### Wait For
- `COMPILE_SUCCESS.md`

---

## Phase 5: Cleanup and Documentation

### Objective
Add proper resource cleanup and XML documentation.

### Tasks

1. Implement `Dispose()` method:
   ```csharp
   protected override void OnTermination()
   {
       // Unsubscribe from events
       // Dispose custom objects
   }
   ```

2. Add XML documentation comments:
   - Class summary
   - Property descriptions
   - Method descriptions

3. Remove debug logging (or make conditional)

4. Final code review for:
   - Memory leaks (event handlers)
   - Null reference potential
   - Edge cases

### Verification
- **Remote**: Final compile check
- **Manual**: Memory usage test (run for extended period)

### Commit
```
Phase 5: Cleanup and documentation for {ClassName}

Co-Authored-By: Claude <noreply@anthropic.com>
```

---

## Feedback Loop Protocol

### Auto-Compile Feedback

When files change in `{Indicators|Strategies}/`:

1. NT8 detects change and compiles
2. AutoHotkey script monitors NT8 Log tab
3. Results written to `feedback/`:
   - `COMPILE_SUCCESS.md` - Compilation succeeded
   - `COMPILE_ERRORS.md` - Compilation failed with errors

### Signal File Format

**COMPILE_SUCCESS.md:**
```markdown
# Compilation Success

**Timestamp**: {ISO timestamp}
**File**: {ClassName}.cs
**Status**: SUCCESS
**Duration**: {seconds}s
```

**COMPILE_ERRORS.md:**
```markdown
# Compilation Errors

**Timestamp**: {ISO timestamp}
**File**: {ClassName}.cs
**Status**: FAILED
**Error Count**: {N}

## Errors

### Error 1
- **Code**: CS{XXXX}
- **Line**: {line number}
- **Message**: {error message}
- **Context**: {code snippet}

### Error 2
...
```

### Agent Response to Errors

1. Read `COMPILE_ERRORS.md`
2. Identify root cause
3. Fix code
4. Commit with message: `Fix: {error description}`
5. Wait for new compile result
6. Max 3 retries before `BLOCKED.md`

---

## Completion Signals

| Signal | Meaning | Created By |
|--------|---------|------------|
| `IMPLEMENTATION_COMPLETE.md` | All phases done | Implementation Agent |
| `COMPILE_SUCCESS.md` | Latest compile passed | AutoHotkey/Feedback |
| `COMPILE_ERRORS.md` | Latest compile failed | AutoHotkey/Feedback |
| `MANUAL_VERIFIED.md` | Human verified on NT8 | Human |
| `BLOCKED.md` | Agent stuck, needs help | Implementation Agent |
