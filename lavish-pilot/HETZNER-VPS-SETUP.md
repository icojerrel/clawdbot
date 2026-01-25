# Hetzner VPS Setup Guide - Lavish Pilot Deployment

**Complete production-ready deployment: from zero to running Lavish AI content agency in 50 minutes**

Budget: €50/month | Setup time: ~50 minutes | Difficulty: Intermediate

---

## Table of Contents

1. [Account Setup (5 min)](#1-account-setup-5-min)
2. [VPS Selection & Configuration (10 min)](#2-vps-selection--configuration-10-min)
3. [Initial Server Hardening (15 min)](#3-initial-server-hardening-15-min)
4. [Lavish Pilot Deployment Automation (20 min)](#4-lavish-pilot-deployment-automation-20-min)
5. [Monitoring & Maintenance](#5-monitoring--maintenance)
6. [Troubleshooting](#6-troubleshooting)

---

## 1. Account Setup (5 min)

### 1.1 Sign Up for Hetzner Cloud

**Navigate to:** https://console.hetzner.cloud/

1. Click **Sign Up** (top right)
2. Fill in your details:
   - Email address
   - Password (strong, 16+ chars)
   - Accept Terms of Service
3. Verify your email address (check inbox)
4. Log in to Hetzner Cloud Console

### 1.2 Add Payment Method

**Why?** Hetzner requires payment info before you can create servers.

1. Go to **Billing** → **Payment Methods**
2. Add credit card or PayPal
3. **Optional:** Add €20 credit for the pilot (covers ~3 months of CPX41)

**Cost estimate:**
- CPX41: €49.90/month (billed hourly: €0.071/hour)
- First month: ~€50
- 8-week pilot: ~€100

### 1.3 Generate SSH Key Pair

**On your local machine:**

```bash
# Generate a new SSH key (if you don't have one)
ssh-keygen -t ed25519 -C "lavish-pilot-hetzner" -f ~/.ssh/lavish-hetzner

# Display your public key (copy this)
cat ~/.ssh/lavish-hetzner.pub
```

**Security best practices:**
- Use a strong passphrase for your SSH key
- Never share your private key (`~/.ssh/lavish-hetzner`)
- Only share the public key (`~/.ssh/lavish-hetzner.pub`)

### 1.4 Add SSH Key to Hetzner

1. In Hetzner Console, go to **Security** → **SSH Keys**
2. Click **Add SSH Key**
3. Paste your public key (from `cat ~/.ssh/lavish-hetzner.pub`)
4. Name it: `lavish-pilot-key`
5. Click **Add SSH Key**

---

## 2. VPS Selection & Configuration (10 min)

### 2.1 Create New Project

1. In Hetzner Console, click **New Project**
2. Name: `lavish-pilot`
3. Click **Add Project**

### 2.2 Create Server

Click **Add Server** and configure:

#### **Location**
- **Datacenter:** Falkenstein, Germany (`fsn1`)
- **Why?** EU privacy laws (GDPR compliant), low latency to Netherlands, excellent uptime

#### **Image**
- **OS:** Ubuntu 22.04 LTS (x64)
- **Why?** Long-term support (until 2027), stable, well-documented

#### **Type: CPX41** (Recommended for Lavish pilot)

| Spec | Value | Why? |
|------|-------|------|
| **vCPUs** | 8 cores | Parallel agent execution |
| **RAM** | 32 GB | Multiple agents + models in memory |
| **SSD** | 240 GB | Content storage, logs, media |
| **Traffic** | 20 TB | More than enough for API calls |
| **Network** | Up to 1 Gbit/s | Fast downloads/uploads |
| **Price** | €49.90/month | Best value for 10-agent swarm |

**Alternative options:**
- **CPX31** (4 vCPU, 16 GB RAM, €26.90/mo) - Budget option, slower
- **CPX51** (16 vCPU, 64 GB RAM, €96.90/mo) - If scaling beyond 10 agents

#### **Networking**
- **IPv4:** ✅ Enabled (required)
- **IPv6:** ✅ Enabled (optional, but recommended)
- **Private Network:** ⬜ Not needed for single-server pilot

#### **SSH Keys**
- ✅ Select `lavish-pilot-key` (the key you added earlier)

#### **Volumes**
- ⬜ Not needed (240 GB SSD is enough for pilot)

#### **Firewalls**
- Click **Create Firewall**
- Name: `lavish-firewall`
- **Inbound Rules:**
  - ✅ SSH (port 22) - Your IP only (more secure)
  - ⬜ HTTP (port 80) - Not needed unless hosting public web UI
  - ⬜ HTTPS (port 443) - Not needed for pilot
  - ✅ Custom TCP 18789 (gateway) - Only from your IP (optional, for remote debugging)
- **Outbound Rules:**
  - ✅ Allow all (default) - Needed for API calls to z.ai, MiniMax, etc.

**Important:** If you want SSH from anywhere, use `0.0.0.0/0` (all IPs). If you have a static IP, use `YOUR_IP/32` for better security.

#### **Backups**
- ⬜ Disabled (saves €9.98/mo)
- **Why?** For the pilot, snapshots are cheaper. Take manual snapshots weekly.

#### **Name**
- Server name: `lavish-pilot-production`
- Labels: `project=lavish`, `env=production`

#### **Cloud Config** (optional)
Leave blank for now (we'll use our custom hardening script).

### 2.3 Launch Server

1. Review configuration
2. Click **Create & Buy Now**
3. Wait 30-60 seconds for server to provision

**You'll see:**
- Server status: Running ✅
- Public IPv4: `XXX.XXX.XXX.XXX` (copy this)
- Public IPv6: `xxxx:xxxx:xxxx::1` (optional)

### 2.4 First Connection Test

```bash
# Add server to your SSH config for easy access
cat >> ~/.ssh/config <<EOF

# Lavish Pilot Production Server
Host lavish-pilot
    HostName XXX.XXX.XXX.XXX
    User root
    IdentityFile ~/.ssh/lavish-hetzner
    StrictHostKeyChecking accept-new
EOF

# Test connection
ssh lavish-pilot

# You should see:
# Welcome to Ubuntu 22.04.X LTS (GNU/Linux ...)
```

**If connection fails:**
- Check firewall rules (SSH port 22 must be open)
- Verify SSH key was added correctly
- Try direct: `ssh -i ~/.ssh/lavish-hetzner root@XXX.XXX.XXX.XXX`

---

## 3. Initial Server Hardening (15 min)

**Why harden?** Default Ubuntu is not secure enough for production. We'll:
- Create non-root user
- Disable root SSH login
- Setup fail2ban (auto-ban brute-force attempts)
- Configure UFW firewall
- Enable automatic security updates

### 3.1 Run Hardening Script (Automated)

**On your local machine**, download and run the automated hardening script:

```bash
# Download the script
curl -O https://raw.githubusercontent.com/clawdbot/clawdbot/main/lavish-pilot/scripts/harden-server.sh

# Review it (always review scripts before running!)
less harden-server.sh

# Make it executable
chmod +x harden-server.sh

# Run it (you'll be prompted for a new user password)
./harden-server.sh lavish-pilot
```

**What it does:**
1. Creates a new user `lavish` with sudo privileges
2. Copies your SSH key to the new user
3. Disables root SSH login
4. Installs and configures fail2ban
5. Sets up UFW firewall (SSH only)
6. Enables automatic security updates
7. Configures log rotation
8. Sets timezone to Europe/Amsterdam

**Or manually:** See [Manual Hardening Steps](#manual-hardening-steps) below.

### 3.2 Reconnect as New User

After hardening, root SSH is disabled. Reconnect as `lavish`:

```bash
# Update SSH config
sed -i '' 's/User root/User lavish/' ~/.ssh/config

# Reconnect (now as lavish user)
ssh lavish-pilot

# Test sudo access
sudo whoami
# Should output: root
```

### 3.3 Verify Security

```bash
# Check fail2ban is running
sudo systemctl status fail2ban

# Check UFW firewall
sudo ufw status

# Check automatic updates
sudo systemctl status unattended-upgrades

# Check for unauthorized users
cat /etc/passwd | grep -E '/(bash|sh)$'
# Should only show: root, lavish
```

---

## 4. Lavish Pilot Deployment Automation (20 min)

**This is the main event!** We'll transfer the Lavish pilot package and run the deployment script.

### 4.1 Transfer Deployment Package

**On your local machine:**

```bash
# Navigate to the lavish-pilot directory
cd /path/to/clawdbot/lavish-pilot

# Create a deployment tarball
tar czf lavish-pilot.tar.gz \
  deploy.sh \
  scripts/ \
  skills/ \
  config/ \
  templates/ \
  agents/ \
  README.md \
  QUICK-START.md \
  GET-MINIMAX-KEY.md

# Transfer to server
scp lavish-pilot.tar.gz lavish-pilot:~/

# SSH to server
ssh lavish-pilot

# Extract package
tar xzf lavish-pilot.tar.gz
cd lavish-pilot
```

### 4.2 Install Node.js 22+ (via nvm)

**On the server:**

```bash
# Install nvm (Node Version Manager)
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash

# Load nvm immediately
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

# Install Node.js 22 LTS
nvm install 22
nvm use 22
nvm alias default 22

# Verify installation
node -v  # Should show v22.x.x
npm -v   # Should show 10.x.x
```

### 4.3 Run Automated Deployment

**On the server:**

```bash
# Make deploy script executable
chmod +x deploy.sh

# Dry run first (see what it will do)
./deploy.sh --dry-run

# If dry run looks good, deploy for real
./deploy.sh
```

**You'll be prompted to:**
1. Fill in API keys in `~/.lavish-pilot/.env`
2. Wait for Clawdbot installation
3. Watch agent configurations being created
4. See the gateway start

**Deployment creates:**
```
~/.lavish-pilot/
├── .env                    # Your API keys
├── content/                # Content output
│   ├── drafts/
│   ├── published/
│   └── calendar/
├── scripts/                # Automation scripts
└── logs/                   # Daily logs

~/.clawdbot/
├── clawdbot.json           # Main configuration
├── agents/                 # 10 agent workspaces
│   ├── ceo/
│   ├── strategist/
│   ├── copywriter/
│   ├── social/
│   ├── seo/
│   ├── video/
│   ├── email/
│   ├── analyst/
│   ├── designer/
│   └── pm/
└── skills/                 # Shared skills library
    ├── meta-post.mjs
    ├── tiktok-analytics.mjs
    └── hashtag-generator.mjs
```

### 4.4 Configure API Keys

**Critical step!** The deployment script created `~/.lavish-pilot/.env` with placeholders.

```bash
# Edit the .env file
nano ~/.lavish-pilot/.env
```

**Fill in at minimum:**
```bash
# Gateway Auth (generate secure token)
CLAWDBOT_GATEWAY_TOKEN=$(openssl rand -hex 32)

# AI Model Providers (REQUIRED)
ZAI_API_KEY=your_zai_key_here
MINIMAX_API_KEY=your_minimax_key_here
MINIMAX_GROUP_ID=your_minimax_group_id_here

# Messaging Channels (recommended for pilot)
SLACK_BOT_TOKEN=xoxb-your-slack-bot-token
TELEGRAM_BOT_TOKEN=123456789:ABCdefGHIjklMNOpqrsTUVwxyz

# Optional (add as you integrate services)
META_ACCESS_TOKEN=
META_PAGE_ID=
TIKTOK_ACCESS_TOKEN=
GA4_PROPERTY_ID=
AHREFS_API_KEY=
```

**Where to get API keys?** See:
- `GET-MINIMAX-KEY.md` for MiniMax setup
- `QUICK-START.md` for z.ai key

**Save and exit:** `Ctrl+X`, `Y`, `Enter`

### 4.5 Setup Systemd Service (Production Gateway)

**Why?** So the gateway auto-starts on server reboot and stays running 24/7.

**On the server:**

```bash
# Create systemd service file
sudo tee /etc/systemd/system/lavish-gateway.service > /dev/null <<'EOF'
[Unit]
Description=Lavish Pilot - Clawdbot Gateway
After=network-online.target
Wants=network-online.target

[Service]
Type=simple
User=lavish
WorkingDirectory=/home/lavish
EnvironmentFile=/home/lavish/.lavish-pilot/.env
ExecStart=/home/lavish/.nvm/versions/node/v22.12.0/bin/clawdbot gateway run --bind 127.0.0.1 --port 18789 --force
Restart=always
RestartSec=10
StandardOutput=append:/home/lavish/.lavish-pilot/logs/gateway.log
StandardError=append:/home/lavish/.lavish-pilot/logs/gateway-error.log

# Security hardening
NoNewPrivileges=true
PrivateTmp=true
ProtectSystem=strict
ProtectHome=read-only
ReadWritePaths=/home/lavish/.lavish-pilot /home/lavish/.clawdbot

[Install]
WantedBy=multi-user.target
EOF

# Reload systemd to pick up new service
sudo systemctl daemon-reload

# Enable service (start on boot)
sudo systemctl enable lavish-gateway

# Start service now
sudo systemctl start lavish-gateway

# Check status
sudo systemctl status lavish-gateway

# View logs
sudo journalctl -u lavish-gateway -f
```

**If Node.js path is different:**
```bash
# Find your clawdbot binary path
which clawdbot

# Update ExecStart in service file to use full path
sudo nano /etc/systemd/system/lavish-gateway.service
```

### 4.6 Setup Cron Jobs (Daily Automation)

**On the server:**

```bash
# Edit crontab
crontab -e

# Add these lines:
# Daily content production (06:00 AM CET)
0 6 * * * /home/lavish/.lavish-pilot/scripts/daily-content-production.sh >> /home/lavish/.lavish-pilot/logs/cron-daily.log 2>&1

# Weekly strategy review (Monday 09:00 AM)
0 9 * * 1 /home/lavish/.lavish-pilot/scripts/weekly-strategy-review.sh >> /home/lavish/.lavish-pilot/logs/cron-weekly.log 2>&1

# System health checks (every 30 minutes)
*/30 * * * * /home/lavish/.lavish-pilot/scripts/system-health.sh >> /home/lavish/.lavish-pilot/logs/cron-health.log 2>&1

# Cleanup old logs (weekly, Sunday midnight)
0 0 * * 0 find /home/lavish/.lavish-pilot/logs -name "*.log" -mtime +30 -delete
```

**Save and exit.** Cron will automatically pick up the changes.

### 4.7 Verify Deployment

**Run health checks:**

```bash
# Test gateway health
curl http://localhost:18789/health

# Expected output:
# {"status":"ok","version":"X.X.X","uptime":123}

# Test agent communication
clawdbot agent --agent ceo --message "Health check - are we ready for Lavish pilot?"

# Check all agent workspaces exist
ls -la ~/.clawdbot/agents/
# Should show: ceo, strategist, copywriter, social, seo, video, email, analyst, designer, pm

# Verify skills loaded
clawdbot skills list
# Should show: meta-post, tiktok-analytics, hashtag-generator

# Check systemd service
sudo systemctl status lavish-gateway
# Should show: active (running)
```

**If everything passes:** 🎉 Deployment complete!

---

## 5. Monitoring & Maintenance

### 5.1 Log Rotation

**Already configured by deployment script.** Logs are stored in:
- `~/.lavish-pilot/logs/gateway.log` (gateway output)
- `~/.lavish-pilot/logs/gateway-error.log` (errors)
- `~/.lavish-pilot/logs/daily-YYYY-MM-DD.log` (daily automation)
- `~/.lavish-pilot/logs/cron-*.log` (cron job outputs)

**Log rotation config:**
```bash
# View log rotation settings
cat /etc/logrotate.d/lavish-pilot

# Manually rotate logs (if needed)
sudo logrotate -f /etc/logrotate.d/lavish-pilot
```

### 5.2 Disk Space Monitoring

**Check disk usage:**
```bash
# Overall disk usage
df -h

# Lavish pilot directories
du -sh ~/.lavish-pilot ~/.clawdbot

# Find large files
find ~/.lavish-pilot -type f -size +100M -exec ls -lh {} \;

# Clean up old content (drafts older than 30 days)
find ~/.lavish-pilot/content/drafts -mtime +30 -delete
```

**Automated disk monitoring:**
```bash
# Add to cron (daily at midnight)
crontab -e

# Add this line:
0 0 * * * df -h / | awk 'NR==2 {if (substr($5,1,length($5)-1) > 80) print "WARNING: Disk usage is "$5}' | mail -s "Lavish Pilot Disk Alert" your-email@example.com
```

### 5.3 Gateway Health Checks

**Monitor gateway uptime:**
```bash
# Check if gateway is responding
curl -f http://localhost:18789/health || echo "Gateway is down!"

# View real-time logs
sudo journalctl -u lavish-gateway -f

# Check gateway process
ps aux | grep clawdbot-gateway

# Restart gateway if needed
sudo systemctl restart lavish-gateway
```

**Add to monitoring script:**
```bash
# Create health check script
cat > ~/.lavish-pilot/scripts/system-health.sh <<'EOF'
#!/bin/bash

LOGFILE="$HOME/.lavish-pilot/logs/health-$(date +%Y-%m-%d).log"

echo "=== Health Check $(date) ===" >> "$LOGFILE"

# Gateway health
if curl -f http://localhost:18789/health > /dev/null 2>&1; then
  echo "✓ Gateway: OK" >> "$LOGFILE"
else
  echo "✗ Gateway: DOWN - restarting..." >> "$LOGFILE"
  sudo systemctl restart lavish-gateway
fi

# Disk space
DISK_USAGE=$(df -h / | awk 'NR==2 {print $5}' | sed 's/%//')
if [ "$DISK_USAGE" -gt 80 ]; then
  echo "✗ Disk: ${DISK_USAGE}% (WARNING)" >> "$LOGFILE"
else
  echo "✓ Disk: ${DISK_USAGE}%" >> "$LOGFILE"
fi

# Memory usage
MEM_USAGE=$(free | awk 'NR==2 {printf "%.0f", $3/$2 * 100}')
if [ "$MEM_USAGE" -gt 90 ]; then
  echo "✗ Memory: ${MEM_USAGE}% (WARNING)" >> "$LOGFILE"
else
  echo "✓ Memory: ${MEM_USAGE}%" >> "$LOGFILE"
fi

echo "" >> "$LOGFILE"
EOF

chmod +x ~/.lavish-pilot/scripts/system-health.sh
```

### 5.4 Backup Strategy

**Weekly snapshots (recommended for pilot):**

1. **In Hetzner Console:**
   - Go to your server → **Snapshots**
   - Click **Create Snapshot**
   - Name: `lavish-pilot-YYYY-MM-DD`
   - Cost: €0.01/GB/month (240 GB = €2.40/month per snapshot)

2. **Automate with Hetzner API:**
```bash
# Install hcloud CLI
curl -L https://github.com/hetznercloud/cli/releases/latest/download/hcloud-linux-amd64.tar.gz | tar xz
sudo mv hcloud /usr/local/bin/

# Create API token in Hetzner Console (Security → API Tokens)
# Then configure:
hcloud context create lavish-pilot

# Create weekly snapshot (add to cron)
crontab -e

# Add (Sunday 2 AM):
0 2 * * 0 /usr/local/bin/hcloud server create-image --type snapshot --description "Auto-backup-$(date +\%Y-\%m-\%d)" lavish-pilot-production
```

**Critical data backup (to local machine):**
```bash
# On your local machine, backup API keys + content weekly
rsync -avz --progress lavish-pilot:~/.lavish-pilot/.env ./backups/env-$(date +%Y-%m-%d)
rsync -avz --progress lavish-pilot:~/.lavish-pilot/content/ ./backups/content-$(date +%Y-%m-%d)/
```

### 5.5 Cost Monitoring

**Track your Hetzner spending:**
1. Go to **Billing** → **Invoices** in Hetzner Console
2. Enable email notifications for invoices
3. Set budget alert at €60/month (20% buffer over €50 CPX41 cost)

**Expected monthly costs:**
- **VPS (CPX41):** €49.90/month
- **Traffic:** €0 (20 TB included, way more than needed)
- **Snapshots:** ~€2.40/month (one 240 GB snapshot)
- **Total:** ~€52/month

**Cost optimization tips:**
- Delete old snapshots (keep only last 2-3)
- Use log rotation to prevent disk bloat
- Monitor API costs separately (z.ai, MiniMax are billed separately)

### 5.6 Security Updates

**Automatic security updates are enabled** by the hardening script.

**Manual updates (optional, but recommended monthly):**
```bash
# SSH to server
ssh lavish-pilot

# Update package lists
sudo apt update

# Upgrade all packages (review changes first)
sudo apt upgrade

# Reboot if kernel was updated
sudo reboot

# After reboot, verify services
sudo systemctl status lavish-gateway
curl http://localhost:18789/health
```

**Check for pending updates:**
```bash
# See available updates
apt list --upgradable

# Check for security updates only
sudo unattended-upgrade --dry-run --debug
```

---

## 6. Troubleshooting

### 6.1 Common VPS Issues

#### **Server won't start**
```bash
# Check server status in Hetzner Console
# If stuck in "Starting" state for >5 minutes:
# 1. Power off (Actions → Power Off)
# 2. Wait 30 seconds
# 3. Power on (Actions → Power On)
```

#### **High CPU usage**
```bash
# Check top processes
top

# If clawdbot-gateway is using >400% CPU (on 8 cores):
# Check for runaway agent processes
ps aux | grep clawdbot

# Kill specific process
kill -9 <PID>

# Restart gateway
sudo systemctl restart lavish-gateway
```

#### **Out of disk space**
```bash
# Find what's using space
du -sh ~/.lavish-pilot/* ~/.clawdbot/* | sort -h

# Clean up large files
rm ~/.lavish-pilot/logs/*.log.old
find ~/.lavish-pilot/content -name "*.tmp" -delete

# Or resize server in Hetzner Console (requires downtime)
```

### 6.2 Network Problems

#### **Can't SSH to server**
```bash
# 1. Check server is running in Hetzner Console
# 2. Check firewall allows SSH from your IP:
#    Server → Firewalls → lavish-firewall → Inbound Rules
# 3. Try from different IP (mobile hotspot)
# 4. Use Hetzner Console (Server → Console) as last resort
```

#### **Gateway not accessible from outside**
```bash
# If you want to access gateway remotely (not recommended for security):

# 1. Add firewall rule for port 18789 in Hetzner Console
# 2. Change gateway bind to 0.0.0.0:
sudo nano /etc/systemd/system/lavish-gateway.service
# Change: --bind 127.0.0.1 to --bind 0.0.0.0

# 3. Restart gateway
sudo systemctl daemon-reload
sudo systemctl restart lavish-gateway

# 4. Test from local machine
curl http://XXX.XXX.XXX.XXX:18789/health
```

#### **Slow API responses**
```bash
# Check network latency to API providers
ping -c 5 api.z.ai
ping -c 5 api.minimax.chat

# If high latency (>100ms), check Hetzner network status:
# https://status.hetzner.com/

# Or test from different datacenter (create test server in ash/hel)
```

### 6.3 Gateway Failures

#### **Gateway won't start**
```bash
# Check logs for errors
sudo journalctl -u lavish-gateway -n 50

# Common issues:
# 1. Port 18789 already in use
sudo ss -ltnp | grep 18789
sudo kill $(sudo lsof -t -i:18789)

# 2. Missing environment variables
cat ~/.lavish-pilot/.env | grep -E 'ZAI_API_KEY|MINIMAX_API_KEY'

# 3. Clawdbot not installed correctly
which clawdbot
clawdbot --version

# 4. Node.js version too old
node -v  # Must be 22+
```

#### **Gateway crashes repeatedly**
```bash
# Check crash logs
tail -n 100 ~/.lavish-pilot/logs/gateway-error.log

# If out-of-memory errors:
free -h
# Consider upgrading to CPX51 (64 GB RAM)

# If API errors (rate limits):
# Check your z.ai/MiniMax quota in their dashboards

# Restart gateway with verbose logging
sudo systemctl stop lavish-gateway
clawdbot gateway run --bind 127.0.0.1 --port 18789 --verbose
```

#### **Agents not responding**
```bash
# Test individual agent
clawdbot agent --agent ceo --message "Test"

# If error "agent workspace not found":
ls -la ~/.clawdbot/agents/ceo

# If workspace missing, recreate:
mkdir -p ~/.clawdbot/agents/ceo/{workspace,skills,sessions}

# If error "model provider not configured":
cat ~/.clawdbot/clawdbot.json
# Verify z.ai/MiniMax config is correct
```

### 6.4 SSH Access Issues

#### **"Permission denied (publickey)"**
```bash
# 1. Check SSH key permissions on local machine
chmod 600 ~/.ssh/lavish-hetzner

# 2. Verify correct key in use
ssh -v lavish-pilot 2>&1 | grep "identity file"

# 3. Try with explicit key
ssh -i ~/.ssh/lavish-hetzner lavish@XXX.XXX.XXX.XXX

# 4. If still failing, use Hetzner Console to fix:
#    - Login via web console
#    - Check ~/.ssh/authorized_keys on server
#    - Re-add your public key if missing
```

#### **Locked out after hardening**
```bash
# If you can't login as lavish OR root:

# 1. Use Hetzner Console (web-based terminal)
#    Server → Console

# 2. Login as lavish (or root if enabled)

# 3. Re-add your SSH key
mkdir -p ~/.ssh
chmod 700 ~/.ssh
nano ~/.ssh/authorized_keys
# Paste your public key
chmod 600 ~/.ssh/authorized_keys

# 4. Test from local machine
ssh lavish-pilot
```

### 6.5 Deployment Script Failures

#### **"Missing prerequisites" error**
```bash
# Check what's missing
node -v   # Must be 22+
npm -v    # Must be 10+

# Reinstall Node.js if needed
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash
export NVM_DIR="$HOME/.nvm"
source "$NVM_DIR/nvm.sh"
nvm install 22
nvm use 22
```

#### **"API key missing" error**
```bash
# Edit .env file and fill in keys
nano ~/.lavish-pilot/.env

# Required keys:
# - ZAI_API_KEY
# - MINIMAX_API_KEY
# - MINIMAX_GROUP_ID

# Then re-run deployment
cd lavish-pilot
./deploy.sh
```

#### **"Gateway health check failed"**
```bash
# Check if port is blocked
sudo ufw status | grep 18789

# If blocked, allow it (for localhost only)
sudo ufw allow from 127.0.0.1 to any port 18789

# Check if gateway started
ps aux | grep clawdbot-gateway

# Check logs
tail -n 50 ~/.lavish-pilot/logs/gateway.log
```

---

## Quick Reference Commands

### Daily Operations

```bash
# SSH to server
ssh lavish-pilot

# Check gateway status
sudo systemctl status lavish-gateway

# View gateway logs
sudo journalctl -u lavish-gateway -f

# Test agent
clawdbot agent --agent ceo --message "Status check"

# Check disk usage
df -h

# View today's content production log
tail -f ~/.lavish-pilot/logs/daily-$(date +%Y-%m-%d).log
```

### Maintenance

```bash
# Update system packages
sudo apt update && sudo apt upgrade

# Update Clawdbot
npm update -g clawdbot
sudo systemctl restart lavish-gateway

# Create manual snapshot
# (In Hetzner Console: Server → Snapshots → Create Snapshot)

# Cleanup old logs
find ~/.lavish-pilot/logs -name "*.log" -mtime +30 -delete

# Backup content to local machine
rsync -avz lavish-pilot:~/.lavish-pilot/content/ ./backups/content/
```

### Emergency

```bash
# Restart gateway
sudo systemctl restart lavish-gateway

# Kill all Clawdbot processes
pkill -9 -f clawdbot

# Reboot server (last resort)
sudo reboot
```

---

## Master Deployment Script

**For fully automated setup**, see `deploy-to-hetzner.sh` in this directory.

**Usage:**
```bash
# On your local machine
./deploy-to-hetzner.sh XXX.XXX.XXX.XXX
```

This script will:
1. SSH to the server
2. Run hardening steps
3. Install Node.js
4. Transfer Lavish pilot package
5. Run deployment
6. Setup systemd service
7. Configure cron jobs
8. Verify everything is working

---

## Next Steps After Deployment

1. **Fill in API keys:** `ssh lavish-pilot` → `nano ~/.lavish-pilot/.env`
2. **Test agent communication:** `clawdbot agent --agent ceo --message "Ready for Lavish?"`
3. **Run first daily automation:** `bash ~/.lavish-pilot/scripts/daily-content-production.sh`
4. **Setup monitoring:** Configure alerts for disk/memory/gateway health
5. **Create first content:** Follow `QUICK-START.md` for Week 1 tasks
6. **Take first snapshot:** In Hetzner Console, create baseline snapshot

---

## Support & Resources

**Hetzner Support:**
- Status page: https://status.hetzner.com/
- Support tickets: Hetzner Console → Support
- Community: https://community.hetzner.com/

**Clawdbot Support:**
- Discord: https://discord.gg/clawd
- Docs: https://docs.clawd.bot
- GitHub: https://github.com/clawdbot/clawdbot

**Lavish Pilot Docs:**
- `README.md` - Deployment overview
- `QUICK-START.md` - Week 1 guide
- `GET-MINIMAX-KEY.md` - API key setup

---

**Version:** 1.0
**Last Updated:** January 25, 2026
**Tested on:** Ubuntu 22.04 LTS, Hetzner CPX41

Ready to launch Lavish's AI content agency! 🍸🚀
