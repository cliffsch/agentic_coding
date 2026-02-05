#!/bin/bash
# React Dev Server Manager
# Starts, stops, and monitors local development server

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
AGENTIC_HOME="${AGENTIC_HOME:-$(dirname "$SCRIPT_DIR")}"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info() { echo -e "${BLUE}[DEV-SERVER]${NC} $1"; }
log_success() { echo -e "${GREEN}[DEV-SERVER]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[DEV-SERVER]${NC} $1"; }
log_error() { echo -e "${RED}[DEV-SERVER]${NC} $1"; }

PROJECT_DIR="${1:-$(pwd)}"
ACTION="${2:-start}"
DEV_PORT="${DEV_PORT:-5173}"
PID_FILE="${PROJECT_DIR}/.dev-server.pid"
LOG_FILE="${PROJECT_DIR}/.dev-server.log"

cd "$PROJECT_DIR"

start_dev_server() {
    if [ -f "$PID_FILE" ]; then
        local pid=$(cat "$PID_FILE")
        if ps -p "$pid" > /dev/null 2>&1; then
            log_warn "Dev server already running (PID: $pid)"
            return 0
        else
            log_warn "Stale PID file found, cleaning up..."
            rm -f "$PID_FILE"
        fi
    fi

    log_info "Starting dev server on port $DEV_PORT..."

    # Detect package manager
    if [ -f "pnpm-lock.yaml" ]; then
        PKG_MANAGER="pnpm"
    elif [ -f "yarn.lock" ]; then
        PKG_MANAGER="yarn"
    else
        PKG_MANAGER="npm"
    fi

    # Start dev server in background, redirect output to log
    $PKG_MANAGER run dev > "$LOG_FILE" 2>&1 &
    local pid=$!

    echo "$pid" > "$PID_FILE"
    log_success "Dev server started (PID: $pid)"
    log_info "Log: $LOG_FILE"

    # Wait a few seconds to check if it started successfully
    sleep 3
    if ! ps -p "$pid" > /dev/null 2>&1; then
        log_error "Dev server failed to start"
        cat "$LOG_FILE"
        rm -f "$PID_FILE"
        return 1
    fi

    # Wait for server to be ready
    log_info "Waiting for server to be ready..."
    local attempts=0
    while [ $attempts -lt 30 ]; do
        if curl -s "http://localhost:$DEV_PORT" > /dev/null 2>&1; then
            log_success "Dev server ready at http://localhost:$DEV_PORT"
            return 0
        fi
        sleep 1
        attempts=$((attempts + 1))
    done

    log_warn "Server started but may not be responding yet"
    return 0
}

stop_dev_server() {
    if [ ! -f "$PID_FILE" ]; then
        log_warn "No PID file found, server may not be running"
        return 0
    fi

    local pid=$(cat "$PID_FILE")
    if ps -p "$pid" > /dev/null 2>&1; then
        log_info "Stopping dev server (PID: $pid)..."
        kill "$pid" 2>/dev/null || kill -9 "$pid" 2>/dev/null
        sleep 1

        if ps -p "$pid" > /dev/null 2>&1; then
            log_warn "Server still running, force killing..."
            kill -9 "$pid" 2>/dev/null
        fi

        log_success "Dev server stopped"
    else
        log_warn "Server not running (stale PID)"
    fi

    rm -f "$PID_FILE"
    return 0
}

status_dev_server() {
    if [ ! -f "$PID_FILE" ]; then
        echo "stopped"
        return 1
    fi

    local pid=$(cat "$PID_FILE")
    if ps -p "$pid" > /dev/null 2>&1; then
        echo "running (PID: $pid, http://localhost:$DEV_PORT)"
        return 0
    else
        echo "stopped (stale PID)"
        rm -f "$PID_FILE"
        return 1
    fi
}

case "$ACTION" in
    start)
        start_dev_server
        ;;
    stop)
        stop_dev_server
        ;;
    restart)
        stop_dev_server
        start_dev_server
        ;;
    status)
        status_dev_server
        ;;
    *)
        echo "Usage: $0 [PROJECT_DIR] {start|stop|restart|status}"
        exit 1
        ;;
esac
