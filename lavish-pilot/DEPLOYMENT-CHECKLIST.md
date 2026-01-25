# Lavish Pilot - Deployment Checklist

**Use this checklist to ensure a complete, successful deployment**

---

## Pre-Deployment (Before touching Hetzner)

### Local Machine Setup
- [ ] SSH key generated (`ssh-keygen -t ed25519 -f ~/.ssh/lavish-hetzner`)
- [ ] Public key copied to clipboard (`cat ~/.ssh/lavish-hetzner.pub`)
- [ ] Deployment package downloaded/cloned
- [ ] All scripts are executable (`chmod +x *.sh`)

### API Keys Collected
- [ ] **z.ai API key** - https://z.ai (required)
- [ ] **MiniMax API key + Group ID** - https://minimaxi.com (required)
- [ ] OpenAI API key (optional, for fallback)
- [ ] Slack bot token (optional, for team comms)
- [ ] Telegram bot token (optional, for client updates)
- [ ] Meta access token (optional, for Instagram/Facebook posting)
- [ ] TikTok access token (optional, for analytics)
- [ ] Google Analytics 4 property ID (optional, for tracking)
- [ ] Ahrefs API key (optional, for SEO)
- [ ] SEMrush API key (optional, for SEO)
- [ ] Mailchimp API key + list ID (optional, for emails)
- [ ] Canva API key (optional, for design)

---

## Hetzner Account Setup (5 min)

- [ ] Signed up at https://console.hetzner.cloud/
- [ ] Email verified
- [ ] Payment method added (credit card or PayPal)
- [ ] Optional: Added €20 credit for pilot
- [ ] SSH key added to Hetzner (Security → SSH Keys)
- [ ] Project created: `lavish-pilot`

---

## VPS Creation (10 min)

### Server Configuration
- [ ] Click "Add Server" in Hetzner Console
- [ ] Location: **Falkenstein, Germany** (fsn1)
- [ ] Image: **Ubuntu 22.04 LTS**
- [ ] Type: **CPX41** (8 vCPU, 32 GB RAM, €49.90/mo)
- [ ] IPv4: **Enabled**
- [ ] IPv6: **Enabled** (optional but recommended)
- [ ] SSH key: **lavish-pilot-key** (selected)

### Firewall Setup
- [ ] Created firewall: `lavish-firewall`
- [ ] Inbound rule: SSH (port 22) - from your IP or `0.0.0.0/0`
- [ ] Outbound rule: Allow all (default)
- [ ] Optional: Custom TCP 18789 (for remote gateway access)

### Server Launch
- [ ] Server name: `lavish-pilot-production`
- [ ] Labels: `project=lavish`, `env=production`
- [ ] Backups: Disabled (using snapshots instead)
- [ ] Server created and running
- [ ] Public IP copied: `___________________`

### SSH Config
- [ ] Added server to `~/.ssh/config`:
  ```
  Host lavish-pilot
      HostName YOUR_SERVER_IP
      User lavish
      IdentityFile ~/.ssh/lavish-hetzner
  ```
- [ ] First connection test: `ssh -i ~/.ssh/lavish-hetzner root@YOUR_SERVER_IP`
- [ ] Connection successful

---

## Server Hardening (15 min)

### Automated Hardening (Recommended)
- [ ] Ran `./deploy-to-hetzner.sh YOUR_SERVER_IP`
- [ ] Generated user password saved securely
- [ ] Hardening completed (user created, SSH secured, fail2ban installed, UFW configured)
- [ ] Reconnected as new user: `ssh lavish-pilot`
- [ ] Tested sudo access: `sudo whoami` (should output: root)

### Manual Hardening (Alternative)
- [ ] User `lavish` created with sudo privileges
- [ ] SSH keys copied to new user
- [ ] SSH config updated (PermitRootLogin no, PasswordAuthentication no)
- [ ] fail2ban installed and configured
- [ ] UFW firewall enabled (SSH allowed)
- [ ] Automatic security updates enabled
- [ ] Timezone set to Europe/Amsterdam
- [ ] Root SSH login disabled
- [ ] Verified: `ssh lavish-pilot` works, `ssh root@YOUR_SERVER_IP` fails

---

## Node.js Installation (5 min)

- [ ] nvm installed
- [ ] Node.js 22 installed: `nvm install 22`
- [ ] Node.js 22 set as default: `nvm alias default 22`
- [ ] Verified: `node -v` shows v22.x.x
- [ ] Verified: `npm -v` shows 10.x.x

---

## Lavish Pilot Deployment (20 min)

### Package Transfer
- [ ] Created deployment tarball on local machine
- [ ] Transferred to server via `scp`
- [ ] Extracted on server: `tar xzf lavish-pilot.tar.gz`
- [ ] Verified files: `ls -la ~/lavish-pilot/`

### Environment Setup
- [ ] Ran `./deploy.sh` (or `./deploy.sh --dry-run` first)
- [ ] `.env` file created at `~/.lavish-pilot/.env`
- [ ] All API keys filled in `.env`:
  - [ ] `ZAI_API_KEY`
  - [ ] `MINIMAX_API_KEY`
  - [ ] `MINIMAX_GROUP_ID`
  - [ ] `CLAWDBOT_GATEWAY_TOKEN` (generated)
  - [ ] Other optional keys as needed
- [ ] `.env` file permissions: `600` (secure)

### Clawdbot Installation
- [ ] Clawdbot installed: `npm install -g clawdbot`
- [ ] Verified: `clawdbot --version`
- [ ] Configuration created: `~/.clawdbot/clawdbot.json`

### Directory Structure
- [ ] Agent workspaces created (10 agents): `ls ~/.clawdbot/agents/`
- [ ] Content directories created: `ls ~/.lavish-pilot/content/`
- [ ] Skills deployed: `ls ~/.clawdbot/skills/`
- [ ] Scripts deployed: `ls ~/.lavish-pilot/scripts/`

### Systemd Service
- [ ] Service file created: `/etc/systemd/system/lavish-gateway.service`
- [ ] Service enabled: `sudo systemctl enable lavish-gateway`
- [ ] Service started: `sudo systemctl start lavish-gateway`
- [ ] Service running: `sudo systemctl status lavish-gateway`
- [ ] Gateway healthy: `curl http://localhost:18789/health`

### Cron Jobs
- [ ] Crontab edited: `crontab -e`
- [ ] Daily automation: `0 6 * * *` (6 AM)
- [ ] Weekly review: `0 9 * * 1` (Monday 9 AM)
- [ ] Health checks: `*/30 * * *` (every 30 min)
- [ ] Log cleanup: `0 0 * * 0` (Sunday midnight)
- [ ] Cron jobs verified: `crontab -l`

---

## Deployment Verification (5 min)

### Health Checks
- [ ] Gateway health: `curl http://localhost:18789/health` ✅
- [ ] Systemd service: `sudo systemctl status lavish-gateway` ✅
- [ ] All 10 agent workspaces exist: `ls ~/.clawdbot/agents/` ✅
- [ ] Environment file exists: `ls ~/.lavish-pilot/.env` ✅
- [ ] Cron jobs configured: `crontab -l | grep lavish` ✅

### Agent Communication
- [ ] CEO test: `clawdbot agent --agent ceo --message "Health check"`
- [ ] Response received successfully
- [ ] No errors in gateway logs: `sudo journalctl -u lavish-gateway -n 20`

### Skills Check
- [ ] Skills loaded: `clawdbot skills list`
- [ ] Expected skills: meta-post, tiktok-analytics, hashtag-generator

### System Resources
- [ ] Disk space: `df -h` (should have >180 GB free on 240 GB disk)
- [ ] Memory usage: `free -h` (should have >25 GB free on 32 GB RAM)
- [ ] CPU load: `uptime` (load should be < 2.0 on idle)

---

## Post-Deployment Setup (10 min)

### Baseline Snapshot
- [ ] Created first snapshot in Hetzner Console:
  - Server → Snapshots → Create Snapshot
  - Name: `baseline-deployment-YYYY-MM-DD`
  - This is your recovery point!

### Documentation
- [ ] Saved server IP to password manager
- [ ] Saved `lavish` user password to password manager
- [ ] Backed up `.env` file to secure location (local machine)
- [ ] Documented any customizations or deviations from guide

### SSH Alias Setup (local machine)
- [ ] Updated `~/.ssh/config` with `User lavish` (not root)
- [ ] Tested: `ssh lavish-pilot` works without password

### Monitoring Setup
- [ ] Ran first health check: `bash ~/.lavish-pilot/scripts/system-health.sh`
- [ ] Reviewed health log: `cat ~/.lavish-pilot/logs/health-$(date +%Y-%m-%d).log`
- [ ] Optional: Setup email alerts in `system-health.sh`

---

## First Content Production (Optional)

### Manual Test Run
- [ ] Ran daily automation: `bash ~/.lavish-pilot/scripts/daily-content-production.sh`
- [ ] Reviewed output log: `tail -f ~/.lavish-pilot/logs/daily-$(date +%Y-%m-%d).log`
- [ ] Checked content directory: `ls ~/.lavish-pilot/content/drafts/`

### Client Onboarding
- [ ] Sent welcome message to Lavish via configured channel (Telegram/Slack)
- [ ] Shared access to content repository (if applicable)
- [ ] Scheduled first strategy call

---

## Security Hardening Verification

### SSH Security
- [ ] Root login disabled: `ssh root@YOUR_SERVER_IP` should fail
- [ ] Password auth disabled: `grep PasswordAuthentication /etc/ssh/sshd_config.d/99-hardening.conf`
- [ ] Only key-based auth works

### Firewall
- [ ] UFW enabled: `sudo ufw status`
- [ ] Only SSH (22) open from outside
- [ ] Gateway (18789) only accessible from localhost

### fail2ban
- [ ] Service running: `sudo systemctl status fail2ban`
- [ ] SSH jail enabled: `sudo fail2ban-client status sshd`
- [ ] No banned IPs (unless you tested it)

### Automatic Updates
- [ ] Service enabled: `sudo systemctl status unattended-upgrades`
- [ ] Config correct: `cat /etc/apt/apt.conf.d/20auto-upgrades`

---

## Documentation & Handoff

### Files to Review
- [ ] Read `HETZNER-VPS-SETUP.md` - Full deployment guide
- [ ] Read `VPS-QUICK-REFERENCE.md` - Daily operations
- [ ] Read `README.md` - Pilot overview
- [ ] Read `QUICK-START.md` - Week 1 tasks

### Access Documentation
- [ ] Documented for team:
  - Server IP: `___________________`
  - SSH command: `ssh lavish-pilot`
  - Gateway URL (local): `http://localhost:18789`
  - Dashboard (if applicable): `___________________`

### Backup Strategy
- [ ] Weekly snapshot schedule set (manual or automated)
- [ ] Local backup of `.env` file
- [ ] Local backup of critical content (weekly rsync)

### Monitoring
- [ ] Hetzner email notifications enabled
- [ ] Budget alert set at €60/month
- [ ] Optional: Uptime monitoring (external service)

---

## Week 1 Tasks (Post-Deployment)

- [ ] Day 1: Social media audit (existing Lavish accounts)
- [ ] Day 2: Create first content calendar (7 days)
- [ ] Day 3: Design first batch of Instagram posts (5 posts)
- [ ] Day 4: Write first blog articles (3 articles)
- [ ] Day 5: Schedule all content for posting
- [ ] Day 6: Setup analytics tracking
- [ ] Day 7: First weekly review (test the automation)

---

## Troubleshooting Checklist

If something goes wrong, check:

### Gateway Issues
- [ ] Gateway logs: `sudo journalctl -u lavish-gateway -n 50`
- [ ] Error log: `tail -n 50 ~/.lavish-pilot/logs/gateway-error.log`
- [ ] Port availability: `sudo ss -ltnp | grep 18789`
- [ ] Environment variables: `cat ~/.lavish-pilot/.env`
- [ ] Restart: `sudo systemctl restart lavish-gateway`

### Agent Issues
- [ ] Agent workspace exists: `ls ~/.clawdbot/agents/AGENT_NAME/`
- [ ] Config file valid: `cat ~/.clawdbot/clawdbot.json | jq .`
- [ ] API keys set: `grep -E 'ZAI|MINIMAX' ~/.lavish-pilot/.env`

### Server Issues
- [ ] Disk space: `df -h` (need at least 10% free)
- [ ] Memory: `free -h` (swap usage should be minimal)
- [ ] CPU: `top` (no process using >80% consistently)
- [ ] Network: `ping -c 3 8.8.8.8`

---

## Success Criteria

**Deployment is successful when:**

✅ Gateway responds to health checks
✅ All 10 agents can receive and respond to messages
✅ Cron jobs are scheduled correctly
✅ Systemd service starts automatically on boot
✅ SSH access works (as lavish user, not root)
✅ Firewall is active and configured correctly
✅ Automatic security updates are enabled
✅ Baseline snapshot created
✅ All API keys are configured
✅ First manual test run completed successfully

---

## Post-Deployment Notes

**Document any issues encountered:**

Issue 1: _______________________________________________
Resolution: ____________________________________________

Issue 2: _______________________________________________
Resolution: ____________________________________________

Issue 3: _______________________________________________
Resolution: ____________________________________________

**Customizations made:**

1. ___________________________________________________
2. ___________________________________________________
3. ___________________________________________________

**Next review date:** ___________________

**Deployment completed by:** ___________________
**Date:** ___________________
**Time:** ___________________

---

## Quick Verification Commands

```bash
# Run these to verify everything is working:

# 1. Gateway health
curl http://localhost:18789/health

# 2. Systemd service
sudo systemctl status lavish-gateway --no-pager

# 3. Agent test
clawdbot agent --agent ceo --message "Deployment verification test"

# 4. Disk space
df -h /

# 5. Memory
free -h

# 6. Firewall
sudo ufw status

# 7. Cron jobs
crontab -l | grep lavish

# 8. Agent workspaces
ls -d ~/.clawdbot/agents/*/

# If all pass, deployment is successful! 🎉
```

---

**Version:** 1.0
**Last Updated:** January 25, 2026

🍸 **Ready to launch Lavish Pilot!**
