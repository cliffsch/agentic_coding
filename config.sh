#!/bin/bash
# Agentic Coding System Configuration
# Copy to config.sh and customize for your environment

# =============================================================================
# PATHS
# =============================================================================

# Base directory for agentic coding system
export AGENTIC_HOME="${HOME}/Documents/agentic_coding"

# Kilocode profiles directory
export PROFILES_DIR="${AGENTIC_HOME}/profiles/kilocode"

# Templates directory
export TEMPLATES_DIR="${AGENTIC_HOME}/templates"

# Feedback directory (compilation results, test outputs)
export FEEDBACK_DIR="${AGENTIC_HOME}/feedback"

# =============================================================================
# REMOTE MACHINES
# =============================================================================

# Windows machine with NinjaTrader (SSH or network path)
# Options: SSH hostname, UNC path, or "local" for same machine
export WINDOWS_NT8_HOST="cliff-windows.local"
export WINDOWS_NT8_USER="cliff"
export WINDOWS_NT8_PATH="/c/Users/cliff/Documents/NinjaTrader 8"

# Remote VM for Python projects
export PYTHON_VM_HOST=""
export PYTHON_VM_USER=""
export PYTHON_VM_PATH=""

# =============================================================================
# GIT SYNC
# =============================================================================

# Repository for cross-machine sync (optional, uses project's remote if not set)
export SYNC_REPO=""

# Branch for agentic work (default: current branch)
export SYNC_BRANCH=""

# Auto-push after each phase (true/false)
export AUTO_PUSH="true"

# =============================================================================
# NINJATRADER SPECIFIC
# =============================================================================

# NT8 data folder (where Strategies/ and Indicators/ live)
# This should match the actual NT8 custom folder location
export NT8_CUSTOM_FOLDER="${HOME}/Documents/nt8_custom"

# Feedback polling interval (seconds)
export NT8_FEEDBACK_POLL_INTERVAL=5

# Maximum wait time for compilation (seconds)
export NT8_COMPILE_TIMEOUT=120

# AutoHotkey script for harvesting compile results (Windows path)
export NT8_AHK_HARVEST_SCRIPT="C:\\Scripts\\nt8_harvest_errors.ahk"

# =============================================================================
# MCP CONFIGURATION
# =============================================================================

# Enable MCP integration (true/false)
export MCP_ENABLED="true"

# MCP configuration directory
export MCP_CONFIG_DIR="${AGENTIC_HOME}/mcp/config"

# Platform-specific MCP servers
export MCP_SUPABASE_ENABLED="true"
export MCP_N8N_ENABLED="true"
export MCP_NT8_ENABLED="false"  # Future: computer-use MCP

# =============================================================================
# MODEL CONFIGURATION
# =============================================================================

# Default models for each phase (can be overridden per-platform)
export MODEL_DESIGN_REVIEW="moonshotai/kimi-k2.5"
export MODEL_IMPLEMENTATION="minimax/minimax-m2.1"
export MODEL_CODE_REVIEW="moonshotai/kimi-k2.5"

# =============================================================================
# WORKFLOW OPTIONS
# =============================================================================

# Maximum retry attempts per phase
export MAX_RETRIES=3

# Verbose logging (true/false)
export VERBOSE="false"

# Auto-approve all permissions in Kilocode (--auto flag for pipeline usage)
export AUTO_APPROVE="true"

# Create git commits after each phase (true/false)
export AUTO_COMMIT="true"
