# Design Review Checklist - C#/NinjaTrader

> Validates DESIGN.md and IMPLEMENTATION.md completeness for NinjaTrader indicators/strategies before implementation begins.

## Pre-Review Verification

- [ ] DESIGN.md exists and is readable
- [ ] IMPLEMENTATION.md exists and is readable
- [ ] INDICATOR_SPEC.md or STRATEGY_SPEC.md exists (if applicable)
- [ ] NFR_OVERRIDES.md exists (may be empty)
- [ ] All referenced files exist

---

## 0. NFR Compliance

> Reference: `templates/nfr/COMMON.md` and `templates/nfr/ninjatrader.md`

### 0.1 Common NFRs
- [ ] **OPS-2**: Multi-level logging implemented (INFO/WARN/ERROR/CRITICAL via Print())
- [ ] **OPS-3**: Debug logging toggle specified
- [ ] **PRF-3**: Resource cleanup in Dispose() or State.Terminated
- [ ] **SEC-1**: No hardcoded secrets (use NinjaScriptProperty for API keys)
- [ ] **ALT-1**: Critical error notification mechanism (SendMail minimum)

### 0.2 NinjaTrader-Specific NFRs
- [ ] **NT-OPS-1**: Calculate mode appropriate (OnBarClose default)
- [ ] **NT-OPS-2**: Dispose() pattern with event handler cleanup
- [ ] **NT-PRF-1**: No per-bar allocations, reuse objects
- [ ] **NT-PRF-2**: Indicators cached in DataLoaded state
- [ ] **NT-ALT-1**: Email alerts configured for critical errors
- [ ] **NT-ALT-3**: Alert deduplication to prevent spam

### 0.3 NFR Overrides
- [ ] All disabled NFRs justified in NFR_OVERRIDES.md
- [ ] All modified NFRs documented with rationale
- [ ] Any additional project-specific NFRs defined

---

## 1. NinjaTrader Architecture Requirements

### 1.1 Class Structure
- [ ] Indicator inherits from `Indicator` base class OR Strategy inherits from `Strategy` base class
- [ ] Class has proper `[NinjaScriptProperty]` attributes for all input parameters
- [ ] Class has XML documentation comments
- [ ] Namespace follows NinjaTrader conventions (`NinjaTrader.NinjaScript.Indicators` or `NinjaTrader.NinjaScript.Strategies`)

### 1.2 Required Methods
- [ ] `OnStateChange()` method is implemented
- [ ] `OnBarUpdate()` method is implemented
- [ ] `Dispose()` method is implemented (if resources need cleanup)

---

## 2. State Management Requirements

### 2.1 State Configuration
- [ ] `State.SetDefaults` - Default values set, plots added with `AddPlot()`
- [ ] `State.Configure` - Indicators and data series configured
- [ ] `State.DataLoaded` - Data loaded, series initialized
- [ ] `State.Historical` / `State.Realtime` - Proper handling for each state

### 2.2 Resource Management
- [ ] **CRITICAL**: All event handlers are removed in `Dispose()`
- [ ] **CRITICAL**: All disposable resources are disposed
- [ ] No memory leaks from unreleased event subscriptions

---

## 3. Input Parameters

### 3.1 Parameter Definition
- [ ] All inputs use `[NinjaScriptProperty]` attribute
- [ ] All inputs have `[Display()]` attribute with Name, Description, Order
- [ ] Default values are specified
- [ ] Parameter types are appropriate (int, double, bool, etc.)

### 3.2 Parameter Validation
- [ ] Range validation is implemented (if applicable)
- [ ] Invalid parameter handling is specified

---

## 4. Plot and Drawing

### 4.1 Plot Configuration
- [ ] Plots are added in `OnStateChange()` when `State == State.SetDefaults`
- [ ] `AddPlot()` calls include proper parameters (Brush, Name, PlotStyle)
- [ ] Plot colors are appropriate for the indicator type

### 4.2 Drawing Methods
- [ ] `Draw.Text()`, `Draw.Line()`, etc. are used correctly
- [ ] Drawing objects are managed (removed when no longer needed)

---

## 5. Calculation Logic

### 5.1 Bar Processing
- [ ] `OnBarUpdate()` handles `IsFirstTickOfBar` correctly (if needed)
- [ ] Historical vs Real-time behavior is correct
- [ ] `Calculate` property is set appropriately (`Calculate.OnBarClose` or `Calculate.OnEachTick`)

### 5.2 Data Access
- [ ] `Close[0]`, `High[0]`, `Low[0]`, `Open[0]` used correctly
- [ ] Index bounds checking is implemented
- [ ] `BarsInProgress` is checked for multi-series indicators

---

## 6. Implementation Plan Validation

### 6.1 Phase Completeness
- [ ] Phase 1: Class structure (class definition, properties, State management)
- [ ] Phase 2: Core calculation logic (OnBarUpdate, indicators)
- [ ] Phase 3: Plotting and visualization (AddPlot, Draw methods)
- [ ] Phase 4: Input validation and edge cases
- [ ] Phase 5: Documentation and comments

### 6.2 Deployment Considerations
- [ ] Git repository is configured for NinjaTrader AddOns folder
- [ ] Commit/push will trigger deployment to Windows machine
- [ ] No automated testing - manual verification on NT platform

---

## 7. Common NinjaTrader Pitfalls

### 7.1 Memory Leaks
- [ ] Event handlers (like `Bars.Instrument...`) are unsubscribed in `Dispose()`
- [ ] No static references that prevent garbage collection

### 7.2 Threading Issues
- [ ] UI updates use `Dispatcher.Invoke()` if needed
- [ ] No blocking calls in `OnBarUpdate()`

### 7.3 Data Issues
- [ ] `Bars.IsFirstBarOfSession` checks if needed
- [ ] `CurrentBar` index checking before accessing historical data

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

## Example DESIGN_ISSUES.md Format

```markdown
# Design Review Issues

## Issue 1: Missing Dispose() Implementation
**Location**: DESIGN.md Class Structure section
**Severity**: Critical
**Description**: Event handlers are subscribed but never unsubscribed, causing memory leaks.
**Recommendation**: Add Dispose() method that unsubscribes all event handlers.
**Example Fix**:
```csharp
protected override void Dispose(bool disposing)
{
    if (disposing)
    {
        // Unsubscribe from events
        Bars.Instrument... -= OnSomeEvent;
    }
    base.Dispose(disposing);
}
```

## Issue 2: Plot Not Added in SetDefaults
**Location**: DESIGN.md Plot Configuration
**Severity**: Medium
**Description**: AddPlot() is called in OnBarUpdate instead of OnStateChange.
**Recommendation**: Move AddPlot() calls to OnStateChange() when State == State.SetDefaults.
```

---

## Review Output Checklist

- [ ] DESIGN_REVIEW_RESULTS.md created with detailed findings
- [ ] All Critical issues documented (if any)
- [ ] All Medium issues documented (if any)
- [ ] DESIGN_APPROVED.md OR DESIGN_ISSUES.md created
- [ ] Human notified if Critical issues found
