# Design Document: DailyPivots

> NinjaTrader 8 Indicator Design Specification

## Overview

| Field | Value |
|-------|-------|
| **Project** | DailyPivots |
| **Type** | Indicator |
| **Platform** | NinjaTrader 8 |
| **Author** | cliff |
| **Created** | 2026-02-01 |

## Purpose

Display standard pivot point levels (P, S1, S2, S3, R1, R2, R3) calculated from the previous trading session's high, low, and close. Lines extend horizontally through the current session for visual reference.

## Requirements

### Functional Requirements

1. **FR-1**: Calculate pivot levels from prior session
   - Acceptance: Levels match standard formula: P = (H + L + C) / 3

2. **FR-2**: Display 7 horizontal lines for each level
   - Acceptance: Lines visible on chart with distinct colors

3. **FR-3**: Support RTH (Regular Trading Hours) session
   - Acceptance: Uses correct session times for prior day calculation

4. **FR-4**: Extend lines through current session
   - Acceptance: Lines span from session start to current bar

### Non-Functional Requirements

1. **NFR-1**: Performance - Must not cause lag during real-time trading
2. **NFR-2**: Memory - Must properly dispose resources

## Architecture

### Class Structure

```
DailyPivots : Indicator
├── Properties
│   ├── PivotColor : Brush - Color for main pivot
│   ├── ResistanceColor : Brush - Color for R1, R2, R3
│   ├── SupportColor : Brush - Color for S1, S2, S3
│   └── ShowLabels : bool - Whether to show level labels
├── State Management
│   ├── SetDefaults - Initialize properties, add 7 plots
│   ├── Configure - Set up SessionIterator
│   └── DataLoaded - Initialize session tracking
├── Core Logic
│   └── OnBarUpdate() - Calculate and plot levels
└── Cleanup
    └── OnTermination() - Release resources
```

### Input Parameters

| Parameter | Type | Default | Range | Description |
|-----------|------|---------|-------|-------------|
| PivotColor | Brush | DodgerBlue | - | Main pivot line color |
| ResistanceColor | Brush | Red | - | Resistance levels color |
| SupportColor | Brush | Green | - | Support levels color |
| ShowLabels | bool | true | - | Show/hide level labels |

### Plots

| Plot | Color | Style | Description |
|------|-------|-------|-------------|
| Pivot | DodgerBlue | Line | Central pivot (P) |
| R1 | Red | Dash | First resistance |
| R2 | Red | Dash | Second resistance |
| R3 | Red | Dash | Third resistance |
| S1 | Green | Dash | First support |
| S2 | Green | Dash | Second support |
| S3 | Green | Dash | Third support |

### Dependencies

| Dependency | Type | Purpose |
|------------|------|---------|
| SessionIterator | Built-in | Determine session boundaries |

## Calculation Logic

### Algorithm Overview

Standard pivot point calculation from prior session's OHLC:
- P = (High + Low + Close) / 3
- R1 = 2*P - Low
- R2 = P + (High - Low)
- R3 = High + 2*(P - Low)
- S1 = 2*P - High
- S2 = P - (High - Low)
- S3 = Low - 2*(High - P)

### Pseudocode

```
OnBarUpdate:
  1. Check if new session started
  2. If new session:
     - Get prior session High, Low, Close
     - Calculate all pivot levels
  3. Plot current level values
  4. Draw text labels (if enabled)
```

### Edge Cases

| Scenario | Handling |
|----------|----------|
| First bar of session | Wait for complete prior session |
| Insufficient history | Return early, don't plot |
| Gap/missing data | Use last valid session |

## State Management

### SetDefaults

```csharp
Name = "DailyPivots";
Description = "Standard pivot points from prior session";
Calculate = Calculate.OnBarClose;
IsOverlay = true;
DisplayInDataBox = true;
PaintPriceMarkers = true;

AddPlot(Brushes.DodgerBlue, "Pivot");
AddPlot(new Stroke(Brushes.Red, DashStyleHelper.Dash, 1), PlotStyle.Line, "R1");
AddPlot(new Stroke(Brushes.Red, DashStyleHelper.Dash, 1), PlotStyle.Line, "R2");
AddPlot(new Stroke(Brushes.Red, DashStyleHelper.Dash, 1), PlotStyle.Line, "R3");
AddPlot(new Stroke(Brushes.Green, DashStyleHelper.Dash, 1), PlotStyle.Line, "S1");
AddPlot(new Stroke(Brushes.Green, DashStyleHelper.Dash, 1), PlotStyle.Line, "S2");
AddPlot(new Stroke(Brushes.Green, DashStyleHelper.Dash, 1), PlotStyle.Line, "S3");

PivotColor = Brushes.DodgerBlue;
ResistanceColor = Brushes.Red;
SupportColor = Brushes.Green;
ShowLabels = true;
```

### Configure

```csharp
// Session iterator will be used for session detection
```

### DataLoaded

```csharp
sessionIterator = new SessionIterator(Bars);
priorHigh = 0;
priorLow = 0;
priorClose = 0;
pivotCalculated = false;
```

## Verification Strategy

### Desk Check (Phase 3)
- [ ] Code compiles without errors
- [ ] All State handlers implemented
- [ ] Plot values assigned correctly
- [ ] Session detection logic correct

### Visual Verification (Phase 4)
- [ ] Plots display correctly
- [ ] Colors are distinguishable
- [ ] Labels positioned correctly
- [ ] Lines extend through session

### Manual Testing (Post-Implementation)
- [ ] Load on ES chart with RTH session
- [ ] Verify pivot matches manual calculation
- [ ] Check real-time updates work
- [ ] Memory usage stable over time

## Handoff Notes

### For Implementation Agent

1. **Reference Pattern**: Use `Strategies/IchiADRpivotOVN.cs` for session handling
2. **No Compilation**: Mac development - desk check only
3. **Logging**: Use `Print($"{Time[0]:yyyy-MM-dd HH:mm:ss} [DailyPivots] {message}");`
4. **Commits**: One commit per implementation phase

### Deployment

1. Changes in `Indicators/` folder trigger NT8 auto-compile
2. Compilation results appear in NT8 Log tab
3. AutoHotkey script harvests errors to `feedback/COMPILE_RESULT.md`

### Known Constraints

- SessionIterator must be used in DataLoaded or later
- Plots must be added in SetDefaults
- IsOverlay = true for price-level indicators
