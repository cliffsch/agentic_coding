# Code Review Checklist: NinjaTrader

> Validates implementation against DESIGN.md and NinjaTrader best practices

## Pre-Review Verification

- [ ] `IMPLEMENTATION_COMPLETE.md` exists
- [ ] `COMPILE_SUCCESS.md` confirms successful build
- [ ] All commits match IMPLEMENTATION.md phase messages

---

## 1. Class Structure

### 1.1 Inheritance and Namespace
- [ ] Class inherits from correct base (`Indicator` or `Strategy`)
- [ ] Namespace follows NT8 convention (`NinjaTrader.NinjaScript.{Indicators|Strategies}`)
- [ ] Using statements are minimal and correct

### 1.2 Properties
- [ ] All input parameters have `[NinjaScriptProperty]`
- [ ] All parameters have `[Display]` with Name, Description, GroupName, Order
- [ ] Default values are sensible
- [ ] Property types match DESIGN.md specification

---

## 2. State Management

### 2.1 SetDefaults
- [ ] Name and Description set
- [ ] Calculate mode appropriate for use case
- [ ] IsOverlay set correctly
- [ ] All plots added with `AddPlot()`
- [ ] Default parameter values set

### 2.2 Configure
- [ ] Additional data series added if needed
- [ ] Indicator dependencies configured

### 2.3 DataLoaded
- [ ] Runtime objects initialized
- [ ] Indicator instances created
- [ ] Event subscriptions (if any) are documented

---

## 3. Core Logic (OnBarUpdate)

### 3.1 Guards and Bounds
- [ ] `CurrentBar < N` check for historical data access
- [ ] `BarsInProgress` check if multi-series
- [ ] Null checks where appropriate

### 3.2 Calculation
- [ ] Algorithm matches DESIGN.md specification
- [ ] Plot values set correctly: `PlotName[0] = value`
- [ ] Historical vs real-time behavior correct

### 3.3 Performance
- [ ] No unnecessary calculations
- [ ] No blocking operations
- [ ] Efficient data structure usage

---

## 4. Resource Management

### 4.1 Memory Safety
- [ ] All event handlers unsubscribed in OnTermination/Dispose
- [ ] No static references that prevent GC
- [ ] Drawing objects cleaned up when replaced

### 4.2 Thread Safety
- [ ] UI updates use Dispatcher if needed
- [ ] No shared mutable state issues

---

## 5. Drawing and Visualization

### 5.1 Plots
- [ ] Plot colors are appropriate and distinguishable
- [ ] Plot styles match DESIGN.md
- [ ] Plots update correctly in real-time

### 5.2 Draw Methods
- [ ] Draw objects have unique tags
- [ ] Old draw objects removed when no longer needed
- [ ] Template parameter used for styling (if applicable)

---

## 6. Code Quality

### 6.1 Documentation
- [ ] XML summary on class
- [ ] XML documentation on public properties
- [ ] Inline comments for complex logic only

### 6.2 Naming
- [ ] Class name matches filename
- [ ] Property names are descriptive
- [ ] Variable names follow conventions

### 6.3 Logging
- [ ] Debug Print statements removed or conditional
- [ ] Logging format follows standard: `{Time[0]:yyyy-MM-dd HH:mm:ss} [{ClassName}] {message}`

---

## 7. Design Compliance

### 7.1 Requirements Traceability
- [ ] FR-1: {Verified/Not Verified}
- [ ] FR-2: {Verified/Not Verified}
- [ ] (Add all functional requirements from DESIGN.md)

### 7.2 Edge Cases
- [ ] First bar of session handled
- [ ] Insufficient history handled
- [ ] Gap/missing data handled

---

## 8. Security and Safety

### 8.1 Input Validation
- [ ] Parameter ranges enforced (if applicable)
- [ ] No division by zero potential
- [ ] No array index out of bounds potential

### 8.2 Order Safety (Strategies only)
- [ ] Position management correct
- [ ] No duplicate order submissions
- [ ] Proper order cancellation handling

---

## Review Decision

**Overall Status**: [ ] APPROVED / [ ] ISSUES FOUND

### Summary

| Category | Status | Notes |
|----------|--------|-------|
| Class Structure | {Pass/Fail} | |
| State Management | {Pass/Fail} | |
| Core Logic | {Pass/Fail} | |
| Resource Management | {Pass/Fail} | |
| Visualization | {Pass/Fail} | |
| Code Quality | {Pass/Fail} | |
| Design Compliance | {Pass/Fail} | |

### Issues Found

(If any issues, document here with severity and recommendations)

---

## Output Files

- **REVIEW_APPROVED.md**: All checks passed, ready for production
- **REVIEW_ISSUES.md**: Issues found, needs fixes before approval
