# Lavish Pilot VPS - Quick Reference Card

**Keep this handy for daily operations!**

---

## SSH Connection

```bash
# From your local machine
ssh lavish-pilot

# Or with explicit settings
ssh -i ~/.ssh/lavish-hetzner lavish@YOUR_SERVER_IP
```

---

## Gateway Operations

### Check Status
```bash
# Via systemd
sudo systemctl status lavish-gateway

# Via health endpoint
curl http://localhost:18789/health

# View logs (real-time)
sudo journalctl -u lavish-gateway -f

# View logs (last 50 lines)
sudo journalctl -u lavish-gateway -n 50
```

### Control Gateway
```bash
# Start
sudo systemctl start lavish-gateway

# Stop
sudo systemctl stop lavish-gateway

# Restart
sudo systemctl restart lavish-gateway

# Check if enabled (auto-start on boot)
sudo systemctl is-enabled lavish-gateway
```

---

## Agent Communication

### Test Single Agent
```bash
clawdbot agent --agent ceo --message "Health check - status report?"
clawdbot agent --agent social --message "What's trending on TikTok today?"
clawdbot agent --agent analyst --message "Show me yesterday's performance metrics"
```

### Available Agents
- `ceo` - Strategy, orchestration, client comms
- `strategist` - Content planning, trends, keywords
- `copywriter` - Long-form content, blogs
- `social` - Instagram/TikTok/Facebook posting
- `seo` - Technical SEO, optimization
- `video` - Scripts, concepts, YouTube
- `email` - Newsletters, campaigns
- `analyst` - Performance tracking, dashboards
- `designer` - Visuals, brand consistency
- `pm` - Deadlines, task tracking

---

## Daily Operations

### Run Daily Automation
```bash
bash ~/.lavish-pilot/scripts/daily-content-production.sh
```

### View Today's Logs
```bash
tail -f ~/.lavish-pilot/logs/daily-$(date +%Y-%m-%d).log
```

### Check System Health
```bash
bash ~/.lavish-pilot/scripts/system-health.sh
```

---

## Monitoring

### Disk Space
```bash
# Overall
df -h

# Lavish directories
du -sh ~/.lavish-pilot ~/.clawdbot

# Find large files
find ~/.lavish-pilot -type f -size +100M -exec ls -lh {} \;
```

### Memory Usage
```bash
free -h

# Detailed
htop  # (press q to quit)
```

### CPU & Load
```bash
uptime

# Real-time
top  # (press q to quit)
```

### Network
```bash
# Check open ports
sudo ss -ltnp

# Check gateway port specifically
sudo ss -ltnp | grep 18789

# Test internet connectivity
ping -c 3 8.8.8.8

# Test API providers
curl -I https://api.z.ai
curl -I https://api.minimax.chat
```

---

## Configuration

### Edit Environment Variables
```bash
nano ~/.lavish-pilot/.env

# After editing, restart gateway
sudo systemctl restart lavish-gateway
```

### Edit Clawdbot Config
```bash
nano ~/.clawdbot/clawdbot.json

# After editing, restart gateway
sudo systemctl restart lavish-gateway
```

### View Current Config
```bash
cat ~/.clawdbot/clawdbot.json | jq .
# (if jq not installed: cat ~/.clawdbot/clawdbot.json)
```

---

## Cron Jobs

### View Scheduled Jobs
```bash
crontab -l
```

### Edit Cron Schedule
```bash
crontab -e
```

### Current Schedule
```
0 6 * * *     Daily content production (6 AM)
0 9 * * 1     Weekly strategy review (Monday 9 AM)
*/30 * * *    System health checks (every 30 min)
0 0 * * 0     Cleanup old logs (Sunday midnight)
```

---

## Logs

### Gateway Logs
```bash
# Main log
tail -f ~/.lavish-pilot/logs/gateway.log

# Error log
tail -f ~/.lavish-pilot/logs/gateway-error.log

# Via journalctl
sudo journalctl -u lavish-gateway --since today
```

### Automation Logs
```bash
# Daily automation
tail -f ~/.lavish-pilot/logs/cron-daily.log

# Weekly review
tail -f ~/.lavish-pilot/logs/cron-weekly.log

# Health checks
tail -f ~/.lavish-pilot/logs/cron-health.log
```

### Cleanup Old Logs
```bash
# Delete logs older than 30 days
find ~/.lavish-pilot/logs -name "*.log" -mtime +30 -delete

# Check log size before cleanup
du -sh ~/.lavish-pilot/logs
```

---

## Security

### Check Firewall
```bash
sudo ufw status verbose
```

### Check fail2ban
```bash
# Status
sudo systemctl status fail2ban

# Check SSH bans
sudo fail2ban-client status sshd

# Unban an IP (if needed)
sudo fail2ban-client set sshd unbanip YOUR_IP_HERE
```

### Check Who's Logged In
```bash
who
w
last  # Recent logins
```

---

## Backups

### Manual Snapshot
1. Go to Hetzner Console: https://console.hetzner.cloud/
2. Select your server: `lavish-pilot-production`
3. Go to **Snapshots** tab
4. Click **Create Snapshot**
5. Name: `manual-backup-YYYY-MM-DD`

### Backup Critical Files (to local machine)
```bash
# On your local machine
rsync -avz lavish-pilot:~/.lavish-pilot/.env ./backups/
rsync -avz lavish-pilot:~/.lavish-pilot/content/ ./backups/content/
rsync -avz lavish-pilot:~/.clawdbot/clawdbot.json ./backups/
```

---

## Updates

### Update System Packages
```bash
sudo apt update
sudo apt list --upgradable
sudo apt upgrade

# If kernel was updated, reboot
sudo reboot
```

### Update Clawdbot
```bash
# Load nvm
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

# Update globally
npm update -g clawdbot

# Restart gateway
sudo systemctl restart lavish-gateway

# Verify version
clawdbot --version
```

### Update Node.js
```bash
# Load nvm
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

# Check current version
node -v

# Install latest LTS
nvm install --lts
nvm use --lts
nvm alias default lts/*

# Reinstall global packages (including clawdbot)
npm install -g clawdbot

# Restart gateway
sudo systemctl restart lavish-gateway
```

---

## Troubleshooting

### Gateway Won't Start
```bash
# Check logs
sudo journalctl -u lavish-gateway -n 50 --no-pager

# Check if port is in use
sudo ss -ltnp | grep 18789

# Kill process using port (if stuck)
sudo kill $(sudo lsof -t -i:18789)

# Try manual start (for debugging)
clawdbot gateway run --bind 127.0.0.1 --port 18789 --verbose
```

### Out of Disk Space
```bash
# Find what's using space
du -sh ~/.lavish-pilot/* ~/.clawdbot/* | sort -h

# Clean up logs
find ~/.lavish-pilot/logs -name "*.log" -mtime +7 -delete

# Clean up old content drafts
find ~/.lavish-pilot/content/drafts -mtime +30 -delete

# Check again
df -h
```

### High Memory Usage
```bash
# Check top processes
ps aux --sort=-%mem | head -n 10

# If clawdbot is using too much:
sudo systemctl restart lavish-gateway

# If problem persists, check for memory leaks in logs
tail -n 100 ~/.lavish-pilot/logs/gateway-error.log
```

### Agent Not Responding
```bash
# Check gateway is running
curl http://localhost:18789/health

# Test specific agent
clawdbot agent --agent ceo --message "Test"

# Check agent workspace exists
ls -la ~/.clawdbot/agents/ceo

# Check clawdbot config
cat ~/.clawdbot/clawdbot.json

# Restart gateway
sudo systemctl restart lavish-gateway
```

---

## Emergency Procedures

### Complete Gateway Reset
```bash
# Stop gateway
sudo systemctl stop lavish-gateway

# Kill any stuck processes
pkill -9 -f clawdbot

# Clear cache (if needed)
rm -rf ~/.clawdbot/cache/* 2>/dev/null || true

# Restart
sudo systemctl start lavish-gateway

# Wait and verify
sleep 5
curl http://localhost:18789/health
```

### Server Reboot
```bash
# Graceful reboot
sudo reboot

# After reboot, verify:
# 1. SSH back in
ssh lavish-pilot

# 2. Check gateway started
sudo systemctl status lavish-gateway

# 3. Test health
curl http://localhost:18789/health

# 4. Test an agent
clawdbot agent --agent ceo --message "Post-reboot health check"
```

### Restore from Snapshot
1. Go to Hetzner Console
2. Server → Snapshots
3. Select snapshot to restore
4. Click **Restore**
5. Confirm (this will overwrite current server!)
6. Wait for restore to complete
7. SSH back in and verify everything works

---

## Performance Metrics

### Check Agent Activity
```bash
# See recent agent interactions
tail -n 100 ~/.lavish-pilot/logs/daily-$(date +%Y-%m-%d).log

# Count today's agent messages
grep -c "agent --agent" ~/.lavish-pilot/logs/daily-$(date +%Y-%m-%d).log 2>/dev/null || echo "0"
```

### Monitor API Usage
```bash
# Check gateway logs for API calls
sudo journalctl -u lavish-gateway --since today | grep -i "api\|request" | wc -l

# Check for rate limit errors
sudo journalctl -u lavish-gateway --since today | grep -i "rate limit"
```

---

## Useful Aliases (add to ~/.bashrc)

```bash
# Add these to ~/.bashrc for quick access
alias lavish-status='sudo systemctl status lavish-gateway'
alias lavish-logs='sudo journalctl -u lavish-gateway -f'
alias lavish-health='curl http://localhost:18789/health'
alias lavish-restart='sudo systemctl restart lavish-gateway'
alias lavish-ceo='clawdbot agent --agent ceo --message'
alias lavish-disk='df -h && du -sh ~/.lavish-pilot ~/.clawdbot'

# After adding, reload:
source ~/.bashrc
```

---

## Important File Locations

```
~/.lavish-pilot/
├── .env                              # API keys & secrets
├── content/                          # All generated content
│   ├── drafts/                       # Work in progress
│   ├── published/                    # Final content
│   ├── calendar/                     # Content calendar
│   └── analytics/                    # Weekly reports
├── scripts/                          # Automation scripts
└── logs/                             # All log files

~/.clawdbot/
├── clawdbot.json                     # Main config
├── agents/                           # Agent workspaces
│   └── [agent-name]/
│       ├── workspace/                # Agent's working directory
│       ├── skills/                   # Agent-specific skills
│       └── sessions/                 # Conversation history
└── skills/                           # Shared skills library

/etc/systemd/system/
└── lavish-gateway.service            # Gateway service config

/var/log/
└── fail2ban.log                      # Security log
```

---

## Support Contacts

**Hetzner Issues:**
- Status: https://status.hetzner.com/
- Console: https://console.hetzner.cloud/
- Support tickets via console

**Clawdbot Issues:**
- Discord: https://discord.gg/clawd
- Docs: https://docs.clawd.bot
- GitHub: https://github.com/clawdbot/clawdbot

**Emergency Escalation:**
- Check `HETZNER-VPS-SETUP.md` troubleshooting section
- Review gateway error logs
- Take snapshot before major changes
- Document issue for support ticket

---

**Version:** 1.0
**Last Updated:** January 25, 2026
**Server:** Hetzner CPX41 (Ubuntu 22.04 LTS)

**Quick Health Check:**
```bash
curl http://localhost:18789/health && \
sudo systemctl status lavish-gateway --no-pager && \
df -h / && \
free -h && \
echo "✅ All systems operational!"
```

---

🍸 Ready to manage your Lavish AI content agency!
