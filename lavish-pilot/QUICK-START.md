# Lavish Pilot - Quick Start Guide

**Status:** z.ai API key configured ✅
**Next:** Deploy on internet-connected machine

---

## 🚀 You Have Everything You Need

✅ **Deployment package ready** (`lavish-pilot/`)
✅ **z.ai API key configured** (in `~/.lavish-pilot/.env`)
✅ **3 production skills** (meta-post, tiktok-analytics, hashtag-generator)
✅ **10 agent configs** (CEO, Strategist, Copywriter, etc.)
✅ **Daily automation** (cron-ready scripts)

---

## 📋 Current API Key Status

| Provider | Status | Notes |
|----------|--------|-------|
| **z.ai** | ✅ Configured | GLM-4-Flash + GLM-4v (CEO, Copywriter, Video, Designer) |
| **MiniMax** | ⚠️ Missing | abab6.5-chat (6 agents) - Get from minimaxi.com |
| **Slack** | ⚠️ Missing | Team communication |
| **Meta** | ⚠️ Missing | Instagram + Facebook posting |
| **Others** | ⚠️ Optional | TikTok, GA4, Ahrefs, etc. |

---

## 🎯 Next Steps (Choose One)

### **Option A: Deploy Locally (Your Computer)**

**Requirements:**
- macOS/Linux/Windows with WSL
- Node.js 22+ installed
- Internet connection

**Steps:**
```bash
# 1. Copy the lavish-pilot folder to your local machine
scp -r user@remote:/home/user/clawdbot/lavish-pilot ~/

# 2. Copy the .env file (with z.ai key)
scp user@remote:~/.lavish-pilot/.env ~/lavish-pilot/

# 3. Navigate to folder
cd ~/lavish-pilot

# 4. Run deployment
./deploy.sh

# 5. Follow prompts to add remaining API keys
```

---

### **Option B: Deploy on Hetzner VPS** ⭐ RECOMMENDED

**Why Hetzner:**
- 24/7 uptime
- €50/maand (CPX41: 8 cores, 32GB RAM)
- EU data privacy
- Production-ready

**Steps:**

#### 1. **Order Hetzner VPS**
- Go to: https://www.hetzner.com/cloud
- Select: CPX41 (8 vCPU, 32GB RAM, 240GB SSD)
- Location: Falkenstein, Germany
- OS: Ubuntu 22.04 LTS
- Cost: ~€50/maand

#### 2. **SSH Setup**
```bash
# Add your SSH key to Hetzner dashboard
ssh-keygen -t ed25519 -C "lavish-pilot"

# Login to VPS
ssh root@YOUR_VPS_IP
```

#### 3. **Transfer Deployment Package**
```bash
# From your local machine
scp -r lavish-pilot root@YOUR_VPS_IP:/root/

# Or clone from git
ssh root@YOUR_VPS_IP
git clone https://github.com/icojerrel/clawdbot.git
cd clawdbot
git checkout claude/document-use-cases-NYpki
cd lavish-pilot
```

#### 4. **Copy Environment File**
```bash
# Copy .env with z.ai key
scp ~/.lavish-pilot/.env root@YOUR_VPS_IP:/root/.lavish-pilot/

# Or create manually
ssh root@YOUR_VPS_IP
nano /root/.lavish-pilot/.env
# Paste the z.ai key: 0d7d600104584887b1879d6bc5b9ad69.PbzricZAXWSJSH5o
```

#### 5. **Run Deployment**
```bash
# On VPS
cd /root/lavish-pilot

# Test first (dry-run)
./deploy.sh --dry-run

# Deploy for real
./deploy.sh
```

#### 6. **Add Remaining API Keys**

The deployment will prompt you to fill in:

**Critical (pilot won't work without):**
- `MINIMAX_API_KEY` + `MINIMAX_GROUP_ID`
  - Sign up: https://www.minimaxi.com
  - Cost: ~€20-30/maand for 6 agents

**Recommended for full functionality:**
- `SLACK_BOT_TOKEN` (team communication)
  - Create at: https://api.slack.com/apps
  - Free for small teams

- `TELEGRAM_BOT_TOKEN` (client updates)
  - Create with @BotFather on Telegram
  - Free

**Optional (add later):**
- Meta, TikTok, GA4, Ahrefs, Mailchimp, Canva

---

### **Option C: Test Locally First (Mock Mode)**

If you want to test without API keys:

```bash
# On your local machine
cd lavish-pilot

# Run with mock data
export MOCK_MODE=true
./deploy.sh

# Agents will use mock responses instead of real API calls
# Good for testing workflows before spending money
```

---

## 🔑 Getting Additional API Keys

### **MiniMax (REQUIRED - 6 agents)**
1. Go to: https://www.minimaxi.com
2. Sign up with email
3. Navigate to API Keys section
4. Create new key
5. Copy `MINIMAX_API_KEY` and `MINIMAX_GROUP_ID`
6. Add to `.env` file

**Cost:** ~€0.004 per 1K tokens
**Estimated:** €20-30/maand for 6 agents (volume work)

---

### **Slack (Recommended - team communication)**
1. Go to: https://api.slack.com/apps
2. Click "Create New App" → "From scratch"
3. Name: "Lavish Content Team"
4. Workspace: Select or create workspace
5. Install App → Copy "Bot User OAuth Token"
6. Invite bot to channels: `/invite @LavishContentTeam`
7. Add to `.env`: `SLACK_BOT_TOKEN=xoxb-...`

**Cost:** Free for basic usage

---

### **Telegram (Recommended - client updates)**
1. Open Telegram, message @BotFather
2. Send `/newbot`
3. Name: "Lavish Content Manager"
4. Username: `@LavishContentBot` (must end in 'bot')
5. Copy token
6. Get your chat ID:
   - Message your bot
   - Visit: `https://api.telegram.org/bot<TOKEN>/getUpdates`
   - Find your `chat_id`
7. Add to `.env`:
   ```
   TELEGRAM_BOT_TOKEN=123456:ABC...
   ADMIN_TELEGRAM_ID=123456789
   ```

**Cost:** Free

---

### **Meta Business Suite (Instagram + Facebook)**
1. Go to: https://business.facebook.com
2. Create Business Account (or use existing)
3. Add Instagram account (professional/creator account)
4. Add Facebook Page
5. Go to: https://developers.facebook.com
6. Create App → Business type
7. Add "Instagram" and "Pages" products
8. Generate long-lived access token
9. Get Page ID and Instagram Account ID
10. Add to `.env`:
    ```
    META_ACCESS_TOKEN=...
    META_PAGE_ID=...
    META_INSTAGRAM_ACCOUNT_ID=...
    ```

**Cost:** Free (API usage)

---

## 🧪 Verify Deployment

After deployment completes:

```bash
# 1. Check gateway
curl http://localhost:18789/health

# 2. Test agent
clawdbot agent --agent ceo --message "Lavish pilot ready?"

# 3. Test skill
clawdbot agent --agent social --message "Use hashtag-generator skill with topic=mixology"

# 4. View logs
tail -f ~/.lavish-pilot/logs/daily-$(date +%Y-%m-%d).log

# 5. Monitor gateway
tmux attach -t lavish-gateway
```

**Expected output:**
```
✅ Gateway healthy
✅ Agent responded
✅ Skill executed
✅ Logs generating
```

---

## 📅 Setup Cron Jobs

After successful deployment:

```bash
crontab -e
```

Add these lines:
```cron
# Daily content production (06:00)
0 6 * * * /root/.lavish-pilot/scripts/daily-content-production.sh

# Weekly strategy review (Monday 09:00)
0 9 * * 1 /root/.lavish-pilot/scripts/weekly-strategy-review.sh

# System health checks (every 30 min)
*/30 * * * * /root/.lavish-pilot/scripts/system-health.sh
```

Save and exit (Ctrl+X, Y, Enter)

---

## 💰 Cost Breakdown (First Month)

**Setup (one-time):**
- Hetzner VPS: €50 (monthly)
- z.ai credits: €10 (top-up)
- MiniMax credits: €20 (top-up)
**Total setup: €80**

**Monthly recurring:**
- VPS: €50
- z.ai API: €15-25 (CEO, Copywriter, Video, Designer)
- MiniMax API: €20-30 (6 agents)
- OpenAI: €0-50 (only if needed as backup)
**Total monthly: €85-125**

**8-week pilot (2 months):**
- Setup: €80
- Month 1: €85-125
- Month 2: €85-125
**Total: €250-330**

(Still way under the €740 budget in the docs, which included all optional tools)

---

## 🎯 Success Metrics to Track

Once running, monitor these weekly:

| Metric | Week 1 | Week 4 | Week 8 (Target) |
|--------|--------|--------|-----------------|
| **Facebook avg likes** | 2 | 50-100 | 500+ |
| **Instagram followers** | 5,200 | 5,800 | 6,800 |
| **TikTok video views** | 500 | 5,000 | 100K+ (1 viral) |
| **Newsletter subs** | 8,000 | 10,000 | 15,000 |

Track in: `~/.lavish-pilot/content/analytics/weekly-report.md`

---

## 🐛 Troubleshooting

### "Gateway won't start"
```bash
# Check port
ss -ltnp | grep 18789

# Kill any existing
pkill -f "clawdbot gateway"

# Restart
clawdbot gateway run --bind 127.0.0.1 --port 18789
```

### "Agent not responding"
```bash
# Check if gateway is healthy
curl http://localhost:18789/health

# Check agent workspace exists
ls -la ~/.clawdbot/agents/ceo/

# View gateway logs
journalctl -u clawdbot-gateway -f
# or
tmux attach -t lavish-gateway
```

### "Skill not found"
```bash
# List skills
clawdbot skills list

# Reload
clawdbot skills reload

# Check skill file
cat ~/.clawdbot/skills/meta-post.mjs
```

### "API key errors"
```bash
# Verify .env file
cat ~/.lavish-pilot/.env

# Check if sourced
echo $ZAI_API_KEY

# Reload environment
source ~/.lavish-pilot/.env
```

---

## 📞 Support

**Issues?**
1. Check logs first: `~/.lavish-pilot/logs/`
2. Verify API keys: `nano ~/.lavish-pilot/.env`
3. Test gateway: `curl http://localhost:18789/health`
4. Discord: https://discord.gg/clawd
5. Docs: https://docs.clawd.bot

---

## ✅ You're Ready When...

- [ ] Hetzner VPS ordered (or local machine ready)
- [ ] lavish-pilot folder transferred
- [ ] .env file with z.ai key copied
- [ ] MiniMax API key obtained
- [ ] Deployment completed successfully
- [ ] Gateway running & healthy
- [ ] Test agent message sent
- [ ] Cron jobs configured
- [ ] Week 1 content calendar ready

**Then:** Start Week 1 of the pilot! 🚀

---

**Current Status:**
- ✅ Deployment package ready
- ✅ z.ai API key configured (0d7d...JSH5o)
- ⚠️ Needs internet-connected environment
- ⚠️ Needs MiniMax key for full team

**Next:** Choose Option A (local) or B (Hetzner VPS) above
