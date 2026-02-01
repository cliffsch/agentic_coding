; NinjaTrader 8 Compilation Error Harvester
; AutoHotkey v2 Script
;
; Purpose: Monitor NT8 for compilation results and write to feedback directory
;
; Setup:
; 1. Set FEEDBACK_DIR to your agentic_coding/feedback path
; 2. Set NT8_LOG_WINDOW to match your NT8 Log tab title
; 3. Run this script when starting agentic development session
;
; Usage:
; - Script monitors for NT8 compilation events
; - On compile success: Creates COMPILE_SUCCESS.md
; - On compile error: Creates COMPILE_ERRORS.md with details
; - Optionally triggers git push to sync results

#Requires AutoHotkey v2.0
#SingleInstance Force

; =============================================================================
; CONFIGURATION
; =============================================================================

; Path to feedback directory (use forward slashes or escaped backslashes)
FEEDBACK_DIR := "C:\Users\cliff\Documents\nt8_custom\feedback"

; NT8 window titles to monitor
NT8_MAIN_WINDOW := "NinjaTrader"
NT8_LOG_TAB := "Log"

; Git sync after writing feedback (true/false)
AUTO_GIT_SYNC := true

; Polling interval in milliseconds
POLL_INTERVAL := 2000

; =============================================================================
; MAIN SCRIPT
; =============================================================================

; Create feedback directory if it doesn't exist
if !DirExist(FEEDBACK_DIR)
    DirCreate(FEEDBACK_DIR)

; Start monitoring
SetTimer(CheckCompileStatus, POLL_INTERVAL)

; Tray icon and tooltip
A_IconTip := "NT8 Compile Monitor - Active"
TrayTip("NT8 Compile Monitor", "Monitoring for compilation results...", "Info")

; =============================================================================
; FUNCTIONS
; =============================================================================

CheckCompileStatus() {
    global FEEDBACK_DIR, NT8_MAIN_WINDOW

    ; Check if NT8 is running
    if !WinExist(NT8_MAIN_WINDOW)
        return

    ; Try to read the Log tab content
    ; This is a simplified version - real implementation needs to:
    ; 1. Activate the Log tab
    ; 2. Read the text content
    ; 3. Parse for compile messages

    ; For now, we'll use a file-based approach:
    ; NT8 can be configured to write logs to a file
    logContent := ReadNT8Log()

    if (logContent = "")
        return

    ; Check for compilation messages
    if InStr(logContent, "NinjaScript compilation completed") {
        if InStr(logContent, "error") {
            WriteCompileErrors(logContent)
        } else {
            WriteCompileSuccess()
        }

        ; Sync to git if enabled
        if (AUTO_GIT_SYNC)
            GitSync()
    }
}

ReadNT8Log() {
    ; Option 1: Read from NT8's log file
    ; NT8 writes logs to: Documents\NinjaTrader 8\log\
    logPath := A_MyDocuments . "\NinjaTrader 8\log\"

    ; Find the most recent log file
    latestLog := ""
    latestTime := 0

    Loop Files logPath . "*.log" {
        if (A_LoopFileTimeModified > latestTime) {
            latestTime := A_LoopFileTimeModified
            latestLog := A_LoopFilePath
        }
    }

    if (latestLog = "")
        return ""

    ; Read last N lines of log
    try {
        content := FileRead(latestLog)
        ; Get last 100 lines
        lines := StrSplit(content, "`n")
        if (lines.Length > 100)
            lines := lines.Slice(-100)
        return lines.Join("`n")
    } catch {
        return ""
    }
}

WriteCompileSuccess() {
    global FEEDBACK_DIR

    timestamp := FormatTime(, "yyyy-MM-ddTHH:mm:ss")

    content := "# Compilation Success`n`n"
    content .= "**Timestamp**: " . timestamp . "`n"
    content .= "**Status**: SUCCESS`n"
    content .= "**Source**: NT8 Auto-Compile`n"

    ; Clear any previous error file
    if FileExist(FEEDBACK_DIR . "\COMPILE_ERRORS.md")
        FileDelete(FEEDBACK_DIR . "\COMPILE_ERRORS.md")

    ; Write success file
    FileDelete(FEEDBACK_DIR . "\COMPILE_SUCCESS.md")  ; Remove old if exists
    FileAppend(content, FEEDBACK_DIR . "\COMPILE_SUCCESS.md")

    TrayTip("Compilation Success", "NT8 compiled successfully", "Info")
}

WriteCompileErrors(logContent) {
    global FEEDBACK_DIR

    timestamp := FormatTime(, "yyyy-MM-ddTHH:mm:ss")

    ; Parse errors from log content
    errors := ParseCompileErrors(logContent)

    content := "# Compilation Errors`n`n"
    content .= "**Timestamp**: " . timestamp . "`n"
    content .= "**Status**: FAILED`n"
    content .= "**Error Count**: " . errors.Length . "`n`n"
    content .= "## Errors`n`n"

    for i, err in errors {
        content .= "### Error " . i . "`n"
        content .= "- **Code**: " . err.code . "`n"
        content .= "- **Line**: " . err.line . "`n"
        content .= "- **Message**: " . err.message . "`n"
        content .= "- **File**: " . err.file . "`n`n"
    }

    ; Clear any previous success file
    if FileExist(FEEDBACK_DIR . "\COMPILE_SUCCESS.md")
        FileDelete(FEEDBACK_DIR . "\COMPILE_SUCCESS.md")

    ; Write errors file
    FileDelete(FEEDBACK_DIR . "\COMPILE_ERRORS.md")  ; Remove old if exists
    FileAppend(content, FEEDBACK_DIR . "\COMPILE_ERRORS.md")

    TrayTip("Compilation Failed", errors.Length . " error(s) found", "Warning")
}

ParseCompileErrors(logContent) {
    errors := []

    ; NT8 error format:
    ; Error on Line X, Column Y: CSxxxx: message
    ; or
    ; filename.cs(line,col): error CSxxxx: message

    for line in StrSplit(logContent, "`n") {
        ; Pattern 1: error CSxxxx
        if RegExMatch(line, "error (CS\d+):\s*(.+)", &match) {
            err := {
                code: match[1],
                message: match[2],
                line: "unknown",
                file: "unknown"
            }

            ; Try to extract file and line
            if RegExMatch(line, "(\w+\.cs)\((\d+)", &fileMatch) {
                err.file := fileMatch[1]
                err.line := fileMatch[2]
            }

            errors.Push(err)
        }
    }

    return errors
}

GitSync() {
    global FEEDBACK_DIR

    ; Change to feedback directory and sync
    SetWorkingDir(FEEDBACK_DIR)

    ; Add, commit, and push
    RunWait('git add .', , "Hide")
    RunWait('git commit -m "Feedback: compile result"', , "Hide")
    RunWait('git push', , "Hide")

    TrayTip("Git Sync", "Feedback pushed to repository", "Info")
}

; =============================================================================
; HOTKEYS
; =============================================================================

; Manual trigger: Ctrl+Shift+C to check compile status now
^+c:: {
    CheckCompileStatus()
    TrayTip("Manual Check", "Checked compilation status", "Info")
}

; Exit: Ctrl+Shift+Q
^+q:: {
    ExitApp
}

; =============================================================================
; GUI (Optional - for status display)
; =============================================================================

; Uncomment below for a simple status GUI

/*
StatusGui := Gui()
StatusGui.Title := "NT8 Compile Monitor"
StatusGui.Add("Text", "w300", "Status: Monitoring...")
StatusGui.Add("Button", "w100", "Check Now").OnEvent("Click", (*) => CheckCompileStatus())
StatusGui.Add("Button", "w100 x+10", "Exit").OnEvent("Click", (*) => ExitApp())
StatusGui.Show()
*/
