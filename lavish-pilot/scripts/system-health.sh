#!/bin/bash

# System Health Check Script for Lavish Pilot
# Version: 1.0
# Runs every 30 minutes via cron

PILOT_DIR="$HOME/.lavish-pilot"
LOGFILE="$PILOT_DIR/logs/health-$(date +%Y-%m-%d).log"

# Create log directory if it doesn't exist
mkdir -p "$PILOT_DIR/logs"

# Function to log with timestamp
log() {
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOGFILE"
}

# Function to send alert (placeholder - can integrate with Telegram/Slack later)
send_alert() {
  local severity=$1
  local message=$2
  log "[$severity] $message"

  # TODO: Integrate with Telegram/Slack notifications
  # Example: curl -X POST https://api.telegram.org/bot$TOKEN/sendMessage -d "chat_id=$CHAT_ID&text=$message"
}

log "=== Starting Health Check ==="

# Initialize status flags
CRITICAL_ISSUES=0
WARNINGS=0

# Check 1: Gateway Health
log "Checking gateway health..."
if curl -f http://localhost:18789/health >/dev/null 2>&1; then
  log "✓ Gateway: OK"
else
  log "✗ Gateway: DOWN"
  send_alert "CRITICAL" "Clawdbot gateway is not responding!"
  ((CRITICAL_ISSUES++))

  # Attempt automatic restart
  log "Attempting to restart gateway..."
  if command -v systemctl >/dev/null 2>&1; then
    sudo systemctl restart lavish-gateway
    sleep 5

    if curl -f http://localhost:18789/health >/dev/null 2>&1; then
      log "✓ Gateway restarted successfully"
      send_alert "INFO" "Gateway was down but has been restarted successfully"
    else
      log "✗ Gateway restart failed"
      send_alert "CRITICAL" "Gateway restart failed - manual intervention required"
    fi
  fi
fi

# Check 2: Disk Space
log "Checking disk space..."
DISK_USAGE=$(df -h / | awk 'NR==2 {print $5}' | sed 's/%//')
log "Disk usage: ${DISK_USAGE}%"

if [ "$DISK_USAGE" -gt 90 ]; then
  log "✗ Disk: ${DISK_USAGE}% (CRITICAL)"
  send_alert "CRITICAL" "Disk usage is at ${DISK_USAGE}%! Immediate cleanup required."
  ((CRITICAL_ISSUES++))
elif [ "$DISK_USAGE" -gt 80 ]; then
  log "⚠ Disk: ${DISK_USAGE}% (WARNING)"
  send_alert "WARNING" "Disk usage is at ${DISK_USAGE}%. Consider cleanup soon."
  ((WARNINGS++))
else
  log "✓ Disk: ${DISK_USAGE}%"
fi

# Check 3: Memory Usage
log "Checking memory usage..."
MEM_TOTAL=$(free -m | awk 'NR==2 {print $2}')
MEM_USED=$(free -m | awk 'NR==2 {print $3}')
MEM_USAGE=$(awk "BEGIN {printf \"%.0f\", ($MEM_USED/$MEM_TOTAL) * 100}")
log "Memory usage: ${MEM_USAGE}% (${MEM_USED}MB / ${MEM_TOTAL}MB)"

if [ "$MEM_USAGE" -gt 95 ]; then
  log "✗ Memory: ${MEM_USAGE}% (CRITICAL)"
  send_alert "CRITICAL" "Memory usage is at ${MEM_USAGE}%! System may become unstable."
  ((CRITICAL_ISSUES++))
elif [ "$MEM_USAGE" -gt 85 ]; then
  log "⚠ Memory: ${MEM_USAGE}% (WARNING)"
  send_alert "WARNING" "Memory usage is at ${MEM_USAGE}%. Monitor closely."
  ((WARNINGS++))
else
  log "✓ Memory: ${MEM_USAGE}%"
fi

# Check 4: CPU Load
log "Checking CPU load..."
CPU_CORES=$(nproc)
LOAD_AVG=$(uptime | awk -F'load average:' '{print $2}' | awk '{print $1}' | sed 's/,//')
LOAD_PERCENT=$(awk "BEGIN {printf \"%.0f\", ($LOAD_AVG/$CPU_CORES) * 100}")
log "CPU load: ${LOAD_AVG} (${LOAD_PERCENT}% of ${CPU_CORES} cores)"

if [ "$LOAD_PERCENT" -gt 90 ]; then
  log "⚠ CPU: High load (${LOAD_PERCENT}%)"
  send_alert "WARNING" "CPU load is high: ${LOAD_AVG} on ${CPU_CORES} cores"
  ((WARNINGS++))
else
  log "✓ CPU: ${LOAD_PERCENT}%"
fi

# Check 5: Clawdbot Process
log "Checking Clawdbot processes..."
CLAWDBOT_PROCS=$(ps aux | grep -c '[c]lawdbot' || true)
if [ "$CLAWDBOT_PROCS" -gt 0 ]; then
  log "✓ Clawdbot: $CLAWDBOT_PROCS process(es) running"
else
  log "⚠ Clawdbot: No processes found"
  ((WARNINGS++))
fi

# Check 6: Systemd Service (if available)
if command -v systemctl >/dev/null 2>&1; then
  log "Checking systemd service..."
  if systemctl is-active --quiet lavish-gateway 2>/dev/null; then
    log "✓ Systemd: lavish-gateway service is active"
  else
    log "⚠ Systemd: lavish-gateway service is not active"
    ((WARNINGS++))
  fi
fi

# Check 7: Network Connectivity
log "Checking network connectivity..."
if ping -c 1 8.8.8.8 >/dev/null 2>&1; then
  log "✓ Network: Internet connectivity OK"
else
  log "✗ Network: Internet connectivity failed"
  send_alert "CRITICAL" "Server has lost internet connectivity!"
  ((CRITICAL_ISSUES++))
fi

# Check 8: API Provider Connectivity
log "Checking API provider connectivity..."
API_CHECKS=0
API_FAILURES=0

# Check z.ai
if timeout 5 curl -s -o /dev/null -w "%{http_code}" https://api.z.ai >/dev/null 2>&1; then
  log "✓ API: z.ai reachable"
  ((API_CHECKS++))
else
  log "⚠ API: z.ai unreachable"
  ((API_FAILURES++))
fi

# Check MiniMax
if timeout 5 curl -s -o /dev/null https://api.minimax.chat >/dev/null 2>&1; then
  log "✓ API: MiniMax reachable"
  ((API_CHECKS++))
else
  log "⚠ API: MiniMax unreachable"
  ((API_FAILURES++))
fi

if [ "$API_FAILURES" -gt 0 ]; then
  log "⚠ API Connectivity: $API_FAILURES/$((API_CHECKS + API_FAILURES)) providers unreachable"
  ((WARNINGS++))
fi

# Check 9: Log File Sizes
log "Checking log file sizes..."
if [ -d "$PILOT_DIR/logs" ]; then
  TOTAL_LOG_SIZE=$(du -sm "$PILOT_DIR/logs" 2>/dev/null | awk '{print $1}' || echo "0")
  log "Total log size: ${TOTAL_LOG_SIZE}MB"

  if [ "$TOTAL_LOG_SIZE" -gt 1000 ]; then
    log "⚠ Logs: ${TOTAL_LOG_SIZE}MB (cleanup recommended)"
    ((WARNINGS++))
  else
    log "✓ Logs: ${TOTAL_LOG_SIZE}MB"
  fi
fi

# Check 10: Recent Errors in Gateway Logs
log "Checking for recent gateway errors..."
if [ -f "$PILOT_DIR/logs/gateway-error.log" ]; then
  # Count errors in last 30 minutes
  RECENT_ERRORS=$(tail -n 1000 "$PILOT_DIR/logs/gateway-error.log" 2>/dev/null | grep -c "error\|Error\|ERROR" || echo "0")
  if [ "$RECENT_ERRORS" -gt 50 ]; then
    log "⚠ Gateway Errors: $RECENT_ERRORS errors in recent logs"
    send_alert "WARNING" "High number of gateway errors detected: $RECENT_ERRORS"
    ((WARNINGS++))
  else
    log "✓ Gateway Errors: $RECENT_ERRORS recent errors (normal)"
  fi
fi

# Summary
log "=== Health Check Summary ==="
log "Critical Issues: $CRITICAL_ISSUES"
log "Warnings: $WARNINGS"

if [ "$CRITICAL_ISSUES" -eq 0 ] && [ "$WARNINGS" -eq 0 ]; then
  log "✅ All systems healthy!"
  exit 0
elif [ "$CRITICAL_ISSUES" -eq 0 ]; then
  log "⚠️  System operational with $WARNINGS warning(s)"
  exit 0
else
  log "🚨 System has $CRITICAL_ISSUES critical issue(s)!"
  send_alert "CRITICAL" "Health check failed with $CRITICAL_ISSUES critical issues and $WARNINGS warnings"
  exit 1
fi
