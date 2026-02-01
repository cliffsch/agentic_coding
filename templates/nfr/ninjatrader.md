# NinjaTrader NFRs

> Platform-specific non-functional requirements for NinjaTrader 8 indicators and strategies.
> These extend the common NFRs in `COMMON.md`.

## Platform Context

NinjaTrader 8 is a trading platform where indicators and strategies run in real-time with direct financial impact. Performance issues cause trading lag; memory leaks accumulate over long sessions; unhandled errors can disrupt trading operations.

---

## NinjaTrader Operability (NT-OPS)

| ID | Requirement | Implementation Pattern | Default |
|----|-------------|------------------------|---------|
| NT-OPS-1 | No real-time lag | `Calculate.OnBarClose` default; `OnEachTick` only when explicitly needed | Required |
| NT-OPS-2 | Resource disposal | Implement `Dispose()` pattern; unsubscribe all event handlers | Required |
| NT-OPS-3 | State-aware logging | Use `Print()` with timestamps; respect State for appropriate logging | Required |

### NT-OPS Implementation Patterns

**NT-OPS-1 Calculate Mode:**
```csharp
// In SetDefaults
Calculate = Calculate.OnBarClose;  // Default for most indicators

// Only use OnEachTick when you need intra-bar updates
// Calculate = Calculate.OnEachTick;  // Higher CPU, use sparingly
```

**NT-OPS-2 Dispose Pattern:**
```csharp
protected override void OnStateChange()
{
    if (State == State.Terminated)
    {
        // Unsubscribe from events
        if (myTimer != null)
        {
            myTimer.Elapsed -= OnTimerElapsed;
            myTimer.Dispose();
        }
        // Clean up any other subscriptions
    }
}
```

**NT-OPS-3 Logging Pattern:**
```csharp
private void Log(string level, string message)
{
    if (State == State.Realtime || State == State.Historical)
        Print($"{Time[0]:yyyy-MM-dd HH:mm:ss} [{level}] {Name}: {message}");
}
```

---

## NinjaTrader Performance (NT-PRF)

| ID | Requirement | Implementation Pattern | Default |
|----|-------------|------------------------|---------|
| NT-PRF-1 | Memory efficiency | Reuse objects (SessionIterator); avoid per-bar allocations | Required |
| NT-PRF-2 | Indicator caching | Cache hosted indicators; don't recreate in OnBarUpdate | Required |
| NT-PRF-3 | Minimal drawing | Batch drawing operations; limit historical draws | Recommended |

### NT-PRF Implementation Patterns

**NT-PRF-1 SessionIterator Reuse:**
```csharp
private SessionIterator sessionIterator;

protected override void OnStateChange()
{
    if (State == State.DataLoaded)
    {
        sessionIterator = new SessionIterator(Bars);
    }
}

protected override void OnBarUpdate()
{
    // Reuse the same iterator
    sessionIterator.GetNextSession(Time[0], true);
}
```

**NT-PRF-2 Indicator Caching:**
```csharp
private SMA sma;

protected override void OnStateChange()
{
    if (State == State.DataLoaded)
    {
        sma = SMA(14);  // Create once
    }
}

protected override void OnBarUpdate()
{
    double value = sma[0];  // Use cached indicator
}
```

---

## NinjaTrader Alerting (NT-ALT)

| ID | Requirement | Implementation Pattern | Default |
|----|-------------|------------------------|---------|
| NT-ALT-1 | Email alerts for critical errors | `SendMail()` built-in method | Required |
| NT-ALT-2 | Telegram alerts (optional) | HTTP webhook via background thread | Recommended |
| NT-ALT-3 | Alert state tracking | Prevent duplicate alerts for same condition | Required |

### NT-ALT Implementation Patterns

**NT-ALT-1 Email Alert:**
```csharp
private void SendCriticalAlert(string subject, string body)
{
    try
    {
        SendMail("alerts@yourdomain.com", "NinjaTrader Alert: " + subject, body);
        Log("INFO", $"Alert sent: {subject}");
    }
    catch (Exception ex)
    {
        Log("ERROR", $"Failed to send alert: {ex.Message}");
    }
}
```

**NT-ALT-2 Telegram Alert (via webhook):**
```csharp
private void SendTelegramAlert(string message)
{
    // Run in background to avoid blocking OnBarUpdate
    Task.Run(() =>
    {
        try
        {
            using (var client = new WebClient())
            {
                string url = $"https://api.telegram.org/bot{TelegramBotToken}/sendMessage";
                var data = $"chat_id={TelegramChatId}&text={Uri.EscapeDataString(message)}";
                client.Headers[HttpRequestHeader.ContentType] = "application/x-www-form-urlencoded";
                client.UploadString(url, data);
            }
        }
        catch (Exception ex)
        {
            Print($"Telegram alert failed: {ex.Message}");
        }
    });
}
```

**NT-ALT-3 Alert Deduplication:**
```csharp
private DateTime lastAlertTime = DateTime.MinValue;
private string lastAlertKey = "";

private bool ShouldSendAlert(string alertKey, TimeSpan cooldown)
{
    if (alertKey == lastAlertKey && DateTime.Now - lastAlertTime < cooldown)
        return false;

    lastAlertKey = alertKey;
    lastAlertTime = DateTime.Now;
    return true;
}
```

---

## NinjaTrader Security (NT-SEC)

| ID | Requirement | Implementation Pattern | Default |
|----|-------------|------------------------|---------|
| NT-SEC-1 | No hardcoded API keys | Use NinjaTrader user-defined parameters | Required |
| NT-SEC-2 | Validate external data | Check for null/invalid before using | Required |

### NT-SEC Implementation Patterns

**NT-SEC-1 User-Defined Parameters:**
```csharp
[NinjaScriptProperty]
[Display(Name = "Telegram Bot Token", GroupName = "Alerts", Order = 1)]
public string TelegramBotToken { get; set; }

// User enters in indicator properties dialog
// Never hardcode tokens in source code
```

---

## NinjaTrader Maintainability (NT-MNT)

| ID | Requirement | Implementation Pattern | Default |
|----|-------------|------------------------|---------|
| NT-MNT-1 | State machine clarity | Document all State transitions; handle each explicitly | Required |
| NT-MNT-2 | Separate calculation from presentation | Logic in OnBarUpdate; drawing in separate methods | Recommended |

### NT-MNT Implementation Patterns

**NT-MNT-1 State Machine Pattern:**
```csharp
protected override void OnStateChange()
{
    switch (State)
    {
        case State.SetDefaults:
            // Initialize properties, add plots
            break;
        case State.Configure:
            // Add data series, configure indicators
            break;
        case State.DataLoaded:
            // Initialize runtime objects
            break;
        case State.Historical:
            // Historical data processing begins
            break;
        case State.Realtime:
            // Live data processing begins
            break;
        case State.Terminated:
            // Cleanup resources
            break;
    }
}
```

---

## Compliance Checklist for Design Review

- [ ] Calculate mode is appropriate (OnBarClose unless OnEachTick needed)
- [ ] Dispose() or State.Terminated handles all cleanup
- [ ] No per-bar object allocations
- [ ] Indicators are cached in DataLoaded state
- [ ] Alert mechanism is implemented (email minimum)
- [ ] Alert deduplication prevents spam
- [ ] No hardcoded credentials
- [ ] Logging uses Print() with timestamps
