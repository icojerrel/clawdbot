---
title: "JMG Content Team: Quick Start"
description: "Deploy je AI content team in 30 minuten"
summary: "Van nul naar volledig werkend 24/7 content team"
---

# JMG Content Group: Quick Start Guide

Deploy een volledig AI-aangedreven content agency in 30 minuten op een Hetzner VPS.

## Wat Je Krijgt

**10 Gespecialiseerde AI Teamleden:**
- 🎯 **CEO/Orchestrator** (Opus 4.5) - Strategische planning & coördinatie
- 📊 **Content Strategist** (Sonnet 4.5) - Keyword research & planning
- ✍️ **Senior Copywriter** (Opus 4.5) - Blog posts & long-form content
- 📱 **Social Media Manager** (Sonnet 4.5) - Social content & engagement
- 🔍 **SEO Specialist** (Sonnet 4.5) - Technical SEO & optimization
- 🎥 **Video Creator** (Opus 4.5) - Video scripts & YouTube
- 📧 **Email Specialist** (Sonnet 4.5) - Newsletters & campaigns
- 📈 **Data Analyst** (Sonnet 4.5) - Analytics & reporting
- 🎨 **Graphic Designer** (Haiku) - Visual content & graphics
- 📋 **Project Manager** (Sonnet 4.5) - Deadlines & workflow

**24/7 Operatie:**
- Automated daily routines
- Weekly planning & reporting
- Multi-channel communicatie (Slack, Telegram, Discord)
- Quality control pipelines
- Performance monitoring

## 30-Minuten Deployment

### Stap 1: Hetzner VPS Setup (5 min)

```bash
# 1. Login naar Hetzner Cloud Console
# 2. Create server:
#    - Type: CPX41 (8 vCPU, 32GB RAM)
#    - Image: Ubuntu 22.04
#    - Location: Falkenstein (EU)
#    - SSH Key: Upload je public key

# 3. SSH naar server
ssh root@your-server-ip

# 4. Create clawdbot user
useradd -m -s /bin/bash clawdbot
usermod -aG sudo clawdbot
su - clawdbot
```

### Stap 2: System Dependencies (5 min)

```bash
# Install Node.js 22
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash
source ~/.bashrc
nvm install 22
nvm use 22

# Install Clawdbot
npm install -g clawdbot@latest

# Verify installation
clawdbot --version
```

### Stap 3: Environment Setup (5 min)

```bash
# Create .env file
cat > ~/.env << 'EOF'
# Required
ANTHROPIC_API_KEY=sk-ant-your-key-here
CLAWDBOT_GATEWAY_TOKEN=your-secure-random-token

# Optional (maar aanbevolen)
OPENAI_API_KEY=sk-your-openai-key
SLACK_BOT_TOKEN=xoxb-your-slack-token
TELEGRAM_BOT_TOKEN=your-telegram-bot-token
DISCORD_BOT_TOKEN=your-discord-token
ADMIN_CHAT_ID=your-telegram-user-id

# API integrations (optioneel)
AHREFS_API_KEY=your-ahrefs-key
SEMRUSH_API_KEY=your-semrush-key
GOOGLE_ANALYTICS_KEY=your-ga-key
EOF

# Load environment
source ~/.env
```

### Stap 4: Deploy Team (10 min)

```bash
# Download deployment script
curl -O https://raw.githubusercontent.com/clawdbot/clawdbot/main/scripts/deploy-jmg-team.sh

# Make executable
chmod +x deploy-jmg-team.sh

# Run deployment
./deploy-jmg-team.sh

# Expected output:
# ✅ Directories created
# ✅ Agent configurations created
# ✅ Shared skills installed
# ✅ Automation scripts created
# ✅ Cron jobs configured
# ✅ Config created
# 🚀 Your JMG Content Group team is ready!
```

### Stap 5: Start Gateway (5 min)

```bash
# Initialize Clawdbot
clawdbot onboard --install-daemon

# Gateway wordt automatisch gestart als systemd service

# Verify gateway is running
clawdbot channels status

# Expected output:
# Gateway: ✅ Running
# Agents: 10 configured
# Channels: [jouw channels]
```

## Eerste Tests

### Test 1: Meet de CEO

```bash
clawdbot agent --agent ceo --message "Introduce yourself en stel je team voor"
```

**Verwachte output:**
> "Hallo! Ik ben de CEO van JMG Content Group. Ik leid een team van 9 gespecialiseerde AI professionals:
> - Content Strategist (keyword research & planning)
> - Senior Copywriter (blog posts & articles)
> - Social Media Manager (social content & engagement)
> [etc...]"

### Test 2: Content Production Pipeline

```bash
clawdbot agent --agent ceo --message "Create a blog post about 'AI in Content Marketing'. Use the full team pipeline."
```

**Verwachte flow:**
1. CEO → Strategist: "Research AI in Content Marketing keywords"
2. Strategist → Copywriter: "Write blog using these keywords: [lijst]"
3. Copywriter → SEO: "Optimize this draft"
4. SEO → Designer: "Create featured image"
5. Designer → Social: "Create social posts"
6. Social → PM: "Track completion"
7. PM → CEO: "Pipeline completed ✅"

### Test 3: Daily Automation

```bash
# Test morning briefing
~/scripts/daily-routine.sh

# Check output in logs
journalctl --user -u clawdbot-gateway -f
```

## Slack Workspace Setup (Optioneel)

Als je Slack gebruikt voor team communicatie:

### Stap 1: Create Slack App

1. Ga naar https://api.slack.com/apps
2. Create New App → "From scratch"
3. Naam: "JMG Content Group"
4. Workspace: [jouw workspace]

### Stap 2: Bot Permissions

Voeg toe onder "OAuth & Permissions":
- `chat:write` - Post berichten
- `channels:read` - Lees channels
- `groups:read` - Lees private channels
- `im:read` - Lees DMs
- `im:write` - Stuur DMs
- `channels:history` - Lees channel history

### Stap 3: Install App & Get Token

1. Install App to Workspace
2. Copy "Bot User OAuth Token" (begint met `xoxb-`)
3. Voeg toe aan `~/.env`:
   ```bash
   SLACK_BOT_TOKEN=xoxb-your-token-here
   ```

### Stap 4: Create Team Channels

Maak deze channels in Slack:
```
#ceo-commands
#strategy
#content-production
#social-media
#seo
#video-production
#email-marketing
#analytics
#design
#project-management
#general
```

Invite de bot naar elk channel: `/invite @JMG Content Group`

### Stap 5: Configure Routing

Update `~/.clawdbot/clawdbot.json`:

```json5
{
  channels: {
    slack: {
      enabled: true,
      token: process.env.SLACK_BOT_TOKEN,
      dm: {
        policy: "allowlist",
        allowFrom: ["U123ABC"] // Jouw Slack user ID
      },
      groups: {
        enabled: true,
        mentionGating: true
      }
    }
  },

  agents: {
    routing: {
      ceo: {
        channels: ["slack:#ceo-commands"]
      },
      strategist: {
        channels: ["slack:#strategy"]
      },
      // etc...
    }
  }
}
```

Herstart gateway:
```bash
systemctl --user restart clawdbot-gateway
```

## Daily Workflow Voorbeeld

### 06:00 - Morning Prep
```
Data Analyst  → Post daily performance naar #analytics
SEO Specialist → Check overnight keyword rankings
```

### 08:00 - Team Standup
```
Project Manager → Verzamel updates van alle agents
CEO → Review performance en set priorities
```

### 09:00 - Content Production
```
Copywriter → Start blog artikel
Video Creator → Werk aan video script
Social Manager → Post morning content
Designer → Genereer daily graphics
```

### 12:00 - Midday Check
```
CEO → Review morning output
PM → Check deadline status
```

### 18:00 - End of Day
```
PM → Send deadline alerts
CEO → EOD summary + tomorrow preview
```

## Cost Breakdown

### Infrastructure
- **Hetzner VPS** (CPX41): €50/maand
  - 8 vCPU, 32GB RAM, 240GB SSD

### API Costs (actief gebruik)
- **Anthropic Claude**: €300-500/maand
  - CEO (Opus 4.5): ~€100
  - Copywriter (Opus 4.5): ~€150
  - Video (Opus 4.5): ~€50
  - Overige (Sonnet 4.5): ~€150

- **Optionele Services**: €250/maand
  - OpenAI (DALL-E, GPT-4 backup): €100
  - Ahrefs/SEMrush API: €100
  - Canva API: €20
  - Misc (storage, webhooks): €30

**Totaal: €600-800/maand**

**ROI:**
- Vervangwaarde 10 FTE: €30.000-50.000/maand
- 24/7 beschikbaarheid
- Geen HR overhead
- Instantly schaalbaar

## Monitoring & Maintenance

### Health Checks

```bash
# Gateway status
systemctl --user status clawdbot-gateway

# Live monitoring
journalctl --user -u clawdbot-gateway -f

# Check all agents
clawdbot channels status

# Disk usage
df -h

# Memory usage
free -h
```

### Backup Strategy

```bash
# Backup script
cat > ~/scripts/backup.sh << 'EOF'
#!/bin/bash
DATE=$(date +%Y%m%d)
BACKUP_DIR=~/backups/$DATE

mkdir -p $BACKUP_DIR

# Backup configs
cp -r ~/.clawdbot $BACKUP_DIR/
cp -r ~/content-production $BACKUP_DIR/
cp ~/.env $BACKUP_DIR/

# Compress
tar -czf ~/backups/jmg-backup-$DATE.tar.gz -C ~/backups $DATE

# Upload to S3/R2 (optioneel)
# aws s3 cp ~/backups/jmg-backup-$DATE.tar.gz s3://your-bucket/

# Cleanup old backups (keep last 7 days)
find ~/backups -name "jmg-backup-*.tar.gz" -mtime +7 -delete

echo "✅ Backup completed: jmg-backup-$DATE.tar.gz"
EOF

chmod +x ~/scripts/backup.sh

# Add to crontab (daily 02:00)
(crontab -l; echo "0 2 * * * ~/scripts/backup.sh") | crontab -
```

### Performance Tuning

Als je performance issues hebt:

```bash
# Meer resources voor Node.js
export NODE_OPTIONS="--max-old-space-size=8192"

# Verhoog file descriptors
ulimit -n 65536

# Enable swap (voor memory peaks)
sudo fallocate -l 8G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile
```

## Troubleshooting

### Gateway start niet

```bash
# Check logs
journalctl --user -u clawdbot-gateway -n 50

# Verify config
clawdbot config get

# Test manually
clawdbot gateway run --verbose
```

### Agent antwoordt niet

```bash
# Check agent workspace
ls -la ~/.clawdbot/agents/[agent]/workspace

# Test agent direct
clawdbot agent --agent ceo --message "ping"

# Check API keys
echo $ANTHROPIC_API_KEY | head -c 20
```

### Hoge API kosten

```bash
# Switch meer agents naar Haiku
# Edit ~/.clawdbot/clawdbot.json
{
  agents: {
    routing: {
      designer: { model: "anthropic/haiku" },
      social: { model: "anthropic/haiku" },
      // Keep Opus voor CEO, Copywriter, Video
    }
  }
}

# Restart gateway
systemctl --user restart clawdbot-gateway
```

### Disk vol

```bash
# Check grote files
du -h ~ | sort -h | tail -20

# Cleanup old sessions
find ~/.clawdbot/agents/*/sessions -name "*.jsonl" -mtime +30 -delete

# Cleanup published content (keep originals elsewhere)
rm -rf ~/content-production/published/*
```

## Uitbreidingen

### Add 11e Agent: Outreach Specialist

```bash
# Create workspace
mkdir -p ~/.clawdbot/agents/outreach/{workspace,sessions,skills}

# Config
cat > ~/.clawdbot/agents/outreach/AGENTS.md << 'EOF'
# Outreach Specialist

## Role
Link building, guest posting, influencer outreach

## Responsibilities
- Find link opportunities
- Outreach email campaigns
- Partnership negotiations
- Backlink tracking
EOF

# Add to routing config
# Edit ~/.clawdbot/clawdbot.json
```

### Integrate met WordPress

```javascript
// ~/.clawdbot/skills/wordpress-publish.mjs
export const meta = {
  name: 'wordpress-publish',
  description: 'Publish content naar WordPress via API'
}

export async function run(context, { title, content, categories }) {
  const response = await fetch('https://yoursite.com/wp-json/wp/v2/posts', {
    method: 'POST',
    headers: {
      'Authorization': `Bearer ${process.env.WORDPRESS_TOKEN}`,
      'Content-Type': 'application/json'
    },
    body: JSON.stringify({
      title,
      content,
      status: 'draft',
      categories
    })
  });

  return await response.json();
}
```

### Custom Analytics Dashboard

```javascript
// ~/.clawdbot/agents/analyst/skills/custom-dashboard.mjs
export const meta = {
  name: 'custom-dashboard',
  description: 'Generate custom analytics dashboard'
}

export async function run(context) {
  const data = {
    traffic: await getGAData('pageviews'),
    social: await getSocialMetrics(),
    revenue: await getCRMData('revenue'),
    team: await getTeamMetrics()
  };

  // Generate HTML dashboard
  const html = generateDashboard(data);

  // Save to public folder
  await writeFile('~/public_html/dashboard.html', html);

  return { url: 'https://yoursite.com/dashboard.html' };
}
```

## Next Steps

1. **Customize Agent Personas**
   - Edit `~/.clawdbot/agents/*/SOUL.md`
   - Match your brand voice

2. **Add Brand Guidelines**
   - Create `~/content-production/brand-guidelines.md`
   - Reference in AGENTS.md files

3. **Setup Content Calendar**
   - Use Notion/Airtable API
   - Sync with PM agent

4. **Integrate CRM**
   - Connect HubSpot/Salesforce
   - Track content → leads

5. **Scale Team**
   - Add meer specialisten
   - Industry-specific agents

## Resources

- [Full Architecture Doc](/start/jmg-content-team-architecture)
- [Clawdbot Docs](https://docs.clawd.bot)
- [Multi-Agent Guide](/concepts/multi-agent)
- [Discord Community](https://discord.gg/clawd)

## Support

Vragen of issues?
- Discord: [#showcase channel](https://discord.gg/clawd)
- GitHub: [Issues](https://github.com/clawdbot/clawdbot/issues)

---

**Gebouwd met Clawdbot 🦞**

*Je eigen AI content agency, 24/7, volledig geautomatiseerd.*
