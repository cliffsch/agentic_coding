# Design Document: {PROJECT_NAME}

> NinjaTrader 8 {Indicator|Strategy} Design Specification

## Overview

| Field | Value |
|-------|-------|
| **Project** | {PROJECT_NAME} |
| **Type** | {Indicator / Strategy} |
| **Platform** | NinjaTrader 8 |
| **Author** | {AUTHOR} |
| **Created** | {DATE} |

## Purpose

{One paragraph describing what this indicator/strategy does and why it's needed}

## Requirements

### Functional Requirements

1. **FR-1**: {Requirement description}
   - Acceptance: {How to verify}

2. **FR-2**: {Requirement description}
   - Acceptance: {How to verify}

### Non-Functional Requirements

> Baseline NFRs from `templates/nfr/COMMON.md` and `templates/nfr/ninjatrader.md` apply.
> Document any overrides in `NFR_OVERRIDES.md`.

| Category | Key Requirements | Status |
|----------|-----------------|--------|
| **Operability** | Multi-level logging, debug toggle, `Calculate.OnBarClose` default | [ ] |
| **Performance** | No per-bar allocations, indicator caching, `Dispose()` cleanup | [ ] |
| **Alerting** | Email alerts (`SendMail()`), optional Telegram, alert deduplication | [ ] |
| **Security** | No hardcoded API keys, use NinjaScriptProperty for secrets | [ ] |

**Project-Specific NFRs:**
1. {Additional NFR if needed}

**NFR Overrides:** {Reference NFR_OVERRIDES.md if deviations exist}

## Architecture

### Class Structure

```
{ClassName} : {Indicator|Strategy}
├── Properties
│   ├── {InputParam1} : {type} - {description}
│   └── {InputParam2} : {type} - {description}
├── State Management
│   ├── SetDefaults - Initialize properties, add plots
│   ├── Configure - Add data series, configure indicators
│   └── DataLoaded - Initialize runtime objects
├── Core Logic
│   └── OnBarUpdate() - Main calculation
└── Cleanup
    └── Dispose() - Release resources
```

### Input Parameters

| Parameter | Type | Default | Range | Description |
|-----------|------|---------|-------|-------------|
| {Param1} | int | 14 | 1-100 | {Description} |
| {Param2} | double | 1.5 | 0.1-10 | {Description} |

### Plots / Drawing

| Plot | Color | Style | Description |
|------|-------|-------|-------------|
| {Plot1} | DodgerBlue | Line | {Description} |
| {Plot2} | Red | Dot | {Description} |

### Dependencies

| Dependency | Type | Purpose |
|------------|------|---------|
| {Indicator1} | Built-in | {Why needed} |
| {CustomIndicator} | Custom | {Why needed} |

## Calculation Logic

### Algorithm Overview

{Describe the main algorithm in plain language}

### Pseudocode

```
OnBarUpdate:
  1. Check minimum bars requirement
  2. Calculate {main value}
  3. Apply {filter/condition}
  4. Set plot values
  5. Draw {visual elements} if applicable
```

### Edge Cases

| Scenario | Handling |
|----------|----------|
| First bar of session | {How to handle} |
| Insufficient history | {How to handle} |
| Gap/missing data | {How to handle} |

## State Management

### SetDefaults

```csharp
// Properties
Name = "{ClassName}";
Description = "{Description}";
Calculate = Calculate.OnBarClose;
IsOverlay = {true|false};
DisplayInDataBox = true;
PaintPriceMarkers = true;

// Plots
AddPlot(Brushes.DodgerBlue, "{PlotName}");

// Parameters
{Param1} = {default};
```

### Configure

```csharp
// Add data series if multi-timeframe
// AddDataSeries(BarsPeriodType.Minute, 5);

// Add indicators
// {indicator} = {IndicatorName}(params);
```

### DataLoaded

```csharp
// Initialize runtime objects
// Subscribe to events (remember to unsubscribe in Dispose!)
```

## Verification Strategy

### Desk Check (Phase 3)
- [ ] Code compiles without errors
- [ ] All State handlers implemented
- [ ] Dispose() releases all resources
- [ ] Input parameters have proper attributes

### Visual Verification (Phase 4)
- [ ] Plots display correctly
- [ ] Colors are distinguishable
- [ ] Values match expected calculations

### Manual Testing (Post-Implementation)
- [ ] Load on chart with default settings
- [ ] Test with different parameter values
- [ ] Verify real-time vs historical behavior
- [ ] Check memory usage over time

## Handoff Notes

### For Implementation Agent

1. **Reference Pattern**: Use `Strategies/IchiADRpivotOVN.cs` as primary reference
2. **No Compilation**: Mac development - desk check only
3. **Logging**: Use `Print($"{Time[0]:yyyy-MM-dd HH:mm:ss} [{ClassName}] {message}");`
4. **Commits**: One commit per implementation phase

### Deployment

1. Changes in `{Indicators|Strategies}/` folder trigger NT8 auto-compile
2. Compilation results appear in NT8 Log tab
3. AutoHotkey script harvests errors to `feedback/COMPILE_RESULT.md`

### Known Constraints

- {Any platform-specific constraints}
- {Any known NT8 quirks to be aware of}
