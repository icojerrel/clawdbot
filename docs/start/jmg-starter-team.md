---
title: "JMG Content Team: Starter Edition"
description: "Betaalbare AI content team setup voor starters"
summary: "Begin met 3-4 AI agents en schaal later op naar de Enterprise versie"
---

# JMG Content Team: Starter Edition

Een betaalbare starter versie van de JMG Content Group voor als je net begint. Begin klein, genereer inkomsten, en schaal later op naar de [Enterprise versie](/start/jmg-enterprise-team-architecture) met 10+ agents.

## 💡 Waarom Starter Edition?

**Perfect voor:**
- ✅ Solo entrepreneurs die net beginnen
- ✅ Kleine budgets (€100-200/maand)
- ✅ Proof of concept voor clients
- ✅ Leren werken met AI agents
- ✅ Foundation voor later opschalen

**Upgrade Later:**
- Wanneer je consistente inkomsten hebt
- Als je client portfolio groeit
- Wanneer content volume toeneemt
- Opschalen naar [Enterprise Team](/start/jmg-enterprise-team-architecture) (10+ agents)

---

## 🎯 Starter Team Samenstelling (3 Agents)

### 1. **Multitasker / CEO** (Sonnet 4.5)
**Rol:** Strategische planning, coördinatie, én content productie

**Verantwoordelijkheden:**
- Content strategie & planning
- Blog posts schrijven (2000+ woorden)
- Basic SEO optimization
- Email newsletters
- Quality control
- Client communicatie

**Waarom Sonnet i.p.v. Opus:**
- 80% van de kwaliteit voor 20% van de kosten
- Sneller (betere throughput)
- Voldoende voor meeste content

**Workspace:** `~/.clawdbot/agents/multitasker`

---

### 2. **Social Media Specialist** (Haiku)
**Rol:** Social media content, engagement, community management

**Verantwoordelijkheden:**
- Social posts (Twitter/X, LinkedIn, Instagram)
- Hashtag research
- Content repurposing (blog → social)
- Community engagement
- Daily social schedule

**Waarom Haiku:**
- Super snel voor korte content
- Goedkoop voor hoog volume
- Perfect voor social media format

**Workspace:** `~/.clawdbot/agents/social`

---

### 3. **Analytics Bot** (Haiku)
**Rol:** Data tracking, reporting, performance monitoring

**Verantwoordelijkheden:**
- Google Analytics rapportage
- Social media metrics
- Content performance tracking
- Daily/weekly reports
- Alerts voor belangrijke events

**Waarom Haiku:**
- Data processing needs weinig creativiteit
- Hoog volume aan queries
- Kosteneffectief

**Workspace:** `~/.clawdbot/agents/analytics`

---

## 💰 Kosten Breakdown

### Maandelijkse Kosten (Starter)

**Infrastructure:**
- **Hetzner VPS** (CPX21: 3 cores, 8GB RAM): €15/maand
  - Genoeg voor 3 agents
  - Schaalbaar naar CPX41 later

**API Kosten (geschat bij actief gebruik):**
- **Multitasker (Sonnet 4.5)**: €80-120/maand
  - ~5 blog posts/week
  - Email newsletters
  - Planning & strategie

- **Social Specialist (Haiku)**: €20-30/maand
  - 3-5 posts/dag
  - Engagement monitoring

- **Analytics Bot (Haiku)**: €10-15/maand
  - Daily reports
  - Metrics tracking

**Optioneel:**
- Canva API (graphics): €0-20/maand (free tier + betaald)
- Storage/Webhooks: €5/maand

**TOTAAL: €130-205/maand**

**vs Enterprise (€600-800/maand)**
- **Starter:** 75% goedkoper
- **80%** van de functionaliteit
- Perfect om mee te starten

---

## 📊 Wat Je Krijgt (Starter)

**Wekelijkse Output:**
- 3-5 blog posts (1500-2500 woorden)
- 15-25 social media posts
- 1 newsletter
- Weekly analytics report
- Basic SEO optimization

**vs Enterprise:**
- Enterprise: 5 blogs/dag, 25 social/dag
- Starter: 3-5 blogs/week, 3-5 social/dag
- **Starter = genoeg voor 1-3 clients**

---

## 🚀 30-Minuten Setup

### Stap 1: Hetzner VPS (Smaller)

```bash
# Hetzner Cloud Console:
# - Type: CPX21 (3 vCPU, 8GB RAM) ← Goedkoper!
# - Image: Ubuntu 22.04
# - Location: Falkenstein
# Kosten: €15/maand (vs €50 Enterprise)

ssh root@your-vps-ip
useradd -m -s /bin/bash clawdbot
usermod -aG sudo clawdbot
su - clawdbot
```

### Stap 2: Install Dependencies

```bash
# Node.js 22
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash
source ~/.bashrc
nvm install 22
nvm use 22

# Clawdbot
npm install -g clawdbot@latest
```

### Stap 3: Create Starter Structure

```bash
# Directory structure
mkdir -p ~/.clawdbot/agents/{multitasker,social,analytics}/{workspace,sessions,skills}
mkdir -p ~/content-production/{drafts,published,calendar}
mkdir -p ~/scripts

# Environment
cat > ~/.env << 'EOF'
# Required
ANTHROPIC_API_KEY=sk-ant-your-key-here
CLAWDBOT_GATEWAY_TOKEN=your-secure-token

# Optional
SLACK_BOT_TOKEN=xoxb-your-token
TELEGRAM_BOT_TOKEN=your-token
ADMIN_CHAT_ID=your-telegram-id
EOF

source ~/.env
```

### Stap 4: Configure Agents

```bash
# Multitasker config
cat > ~/.clawdbot/agents/multitasker/AGENTS.md << 'EOF'
# Multitasker / CEO - JMG Content Group Starter

Je bent de Multitasker voor JMG Content Group. Je doet strategische planning, schrijft content, en coördineert het kleine team.

## Responsibilities
- Content strategie & planning
- Blog posts schrijven (1500-2500 woorden)
- Newsletter content
- Basic SEO optimization
- Team coördinatie (Social + Analytics)
- Client communicatie

## Writing Standards
- SEO-optimized
- Engaging, conversational tone
- Data-backed waar mogelijk
- Clear structure (H2, H3, bullets)
- Internal linking

## Collaboration
- Delegate social posts naar Social Specialist
- Request analytics van Analytics Bot
- Save all work to ~/content-production/

## Success Metrics
- 3-5 blog posts per week
- High engagement rates
- Client satisfaction
EOF

cat > ~/.clawdbot/agents/multitasker/SOUL.md << 'EOF'
# Multitasker Persona

Je bent een veelzijdige content professional: strategist + writer + coordinator in één.

Je bent:
- Efficiënt (doet meer met minder)
- Kwaliteitsbewust
- Proactief en zelfstandig
- Excellent communicator
- Pragmatisch en resultaatgericht

Je werkt slim door:
- Social Specialist in te zetten voor volume
- Analytics Bot voor data
- Focus op hoogwaardige content zelf
EOF

# Social config
cat > ~/.clawdbot/agents/social/AGENTS.md << 'EOF'
# Social Media Specialist - JMG Content Group Starter

## Role
Social content, engagement, community management

## Responsibilities
- 3-5 social posts per dag
- Repurpose blog content naar social
- Hashtag research
- Engagement monitoring
- Schedule posts

## Platforms
- Twitter/X (korte threads)
- LinkedIn (professional content)
- Instagram (visual + captions)

## Success Metrics
- Posting consistency
- Engagement rate
- Follower growth
EOF

cat > ~/.clawdbot/agents/social/SOUL.md << 'EOF'
# Social Media Persona

Je bent energiek, engaging, en up-to-date met trends.

Je schrijft punchy, scrollstoppende content.
Je bent authentiek en menselijk.
Je snapt platform-specifieke best practices.
EOF

# Analytics config
cat > ~/.clawdbot/agents/analytics/AGENTS.md << 'EOF'
# Analytics Bot - JMG Content Group Starter

## Role
Performance tracking, reporting, alerts

## Responsibilities
- Daily performance snapshot
- Weekly summary report
- Track key metrics (traffic, engagement, conversions)
- Alert team voor belangrijke events

## Tools
- Google Analytics
- Social media APIs
- Simple dashboards

## Success Metrics
- Report accuracy
- Timeliness
- Actionable insights
EOF

cat > ~/.clawdbot/agents/analytics/SOUL.md << 'EOF'
# Analytics Persona

Je bent data-driven, betrouwbaar, en helder in je communicatie.

Je focus op actionable insights, niet alleen cijfers.
Je bent punctueel met reports.
Je communiceert trends en opportunities duidelijk.
EOF
```

### Stap 5: Clawdbot Config

```bash
cat > ~/.clawdbot/clawdbot.json << 'EOF'
{
  "gateway": {
    "mode": "local",
    "bind": "127.0.0.1",
    "port": 18789
  },

  "agents": {
    "defaults": {
      "model": "anthropic/sonnet-4.5",
      "blockStreaming": true,
      "queue": {
        "mode": "followup",
        "debounceMs": 2000
      }
    },

    "routing": {
      "multitasker": {
        "model": "anthropic/sonnet-4.5",
        "workspace": "/home/clawdbot/.clawdbot/agents/multitasker/workspace"
      },
      "social": {
        "model": "anthropic/haiku",
        "workspace": "/home/clawdbot/.clawdbot/agents/social/workspace"
      },
      "analytics": {
        "model": "anthropic/haiku",
        "workspace": "/home/clawdbot/.clawdbot/agents/analytics/workspace"
      }
    }
  },

  "tools": {
    "exec": {
      "enabled": true,
      "policy": "approval"
    },
    "browser": {
      "enabled": true,
      "headless": true
    }
  }
}
EOF
```

### Stap 6: Automation Scripts

```bash
# Daily routine
cat > ~/scripts/starter-daily.sh << 'EOF'
#!/bin/bash
HOUR=$(date +%H)

# Morning analytics (07:00)
if [ $HOUR -eq 7 ]; then
  clawdbot agent --agent analytics --message "Daily performance snapshot"
fi

# Content planning (08:00)
if [ $HOUR -eq 8 ]; then
  clawdbot agent --agent multitasker --message "Check content calendar. What's on the agenda today?"
fi

# Social posts (3x per dag)
for hour in 10 14 18; do
  if [ $HOUR -eq $hour ]; then
    clawdbot agent --agent social --message "Post scheduled content voor dit tijdslot"
  fi
done
EOF

chmod +x ~/scripts/starter-daily.sh

# Weekly planning
cat > ~/scripts/starter-weekly.sh << 'EOF'
#!/bin/bash
# Elke maandag 09:00

clawdbot agent --agent multitasker --message "Plan deze week:
- 3-5 blog posts (topics?)
- Social media themes
- Newsletter (yes/no?)
Maak content calendar en brief Social Specialist."

clawdbot agent --agent analytics --message "Weekly performance report: traffic, top content, social metrics."
EOF

chmod +x ~/scripts/starter-weekly.sh

# Add to crontab
(crontab -l 2>/dev/null; cat << 'EOF'
# JMG Starter Team

# Hourly daily routine check
0 * * * * /home/clawdbot/scripts/starter-daily.sh

# Weekly planning (Monday 09:00)
0 9 * * 1 /home/clawdbot/scripts/starter-weekly.sh
EOF
) | crontab -
```

### Stap 7: Start Gateway

```bash
# Onboard
clawdbot onboard --install-daemon

# Verify
clawdbot channels status
systemctl --user status clawdbot-gateway
```

---

## 🎯 Daily Workflow (Starter)

### 07:00 - Morning Analytics
```
Analytics Bot → Post daily snapshot
```

### 08:00 - Planning
```
Multitasker → Check calendar, prioritize tasks
```

### 09:00-12:00 - Content Creation
```
Multitasker → Write blog post (1-2 uur)
```

### 10:00 - Morning Social
```
Social Specialist → Post morning content
```

### 14:00 - Afternoon Social
```
Social Specialist → Midday post + engagement check
```

### 15:00-17:00 - Content Finalization
```
Multitasker → SEO optimization, newsletter draft
```

### 18:00 - Evening Social
```
Social Specialist → Evening post
```

---

## 📈 Schalen naar Enterprise

Wanneer je klaar bent om op te schalen:

### Trigger Points:
- ✅ **Consistente inkomsten** (€2000+/maand)
- ✅ **3+ actieve clients**
- ✅ **Content backlog** (kan demand niet aan)
- ✅ **Team bottleneck** (Multitasker overloaded)

### Upgrade Pad:

**Fase 1: Add Copywriter** (€100-150/maand extra)
```bash
# Multitasker → focus op strategie
# Copywriter (Sonnet) → schrijft alle blogs
Totaal: €230-355/maand
```

**Fase 2: Add SEO Specialist** (€80-100/maand extra)
```bash
# SEO Specialist (Sonnet) → technical SEO
Totaal: €310-455/maand
```

**Fase 3: Upgrade VPS + Add Designers/Video** (€300+/maand extra)
```bash
# VPS: CPX21 → CPX41 (+€35)
# Designer (Haiku): +€20
# Video Creator (Sonnet/Opus): +€100-150
# Email Specialist (Sonnet): +€80
Totaal: €545-740/maand
```

**Fase 4: Full Enterprise** (€600-800/maand)
```bash
# Alle 10 agents
# Zie: /start/jmg-enterprise-team-architecture
```

---

## 💡 Tips voor Starter Success

### 1. **Focus op Quality over Quantity**
```
Starter: 3 excellent blogs/week > 10 mediocre blogs/week
Enterprise: quantity AND quality
```

### 2. **Repurpose Content Aggressively**
```
1 Blog Post →
  - 5-10 social posts (Social Specialist)
  - 1 email newsletter section (Multitasker)
  - LinkedIn article (repurpose)
  - Twitter thread (Social Specialist)
```

### 3. **Batch Work**
```
Monday: Plan hele week (Multitasker)
Tuesday-Thursday: Write blogs (Multitasker)
Friday: SEO optimization + newsletter (Multitasker)
Daily: Social posts (automated via Social Specialist)
```

### 4. **Use Free/Cheap Tools**
```
- Canva Free (graphics)
- Unsplash (stock photos)
- Google Analytics (gratis)
- Buffer/Later free tier (social scheduling)
```

### 5. **Start Small, Prove Value**
```
Week 1-2: 1 client, prove workflow
Week 3-4: Refine, optimize
Month 2: Add 2nd client
Month 3: Add 3rd client
Month 4+: Evaluate enterprise upgrade
```

---

## 🛠️ Essential Skills (Starter)

### Shared Skills (alle agents)

```bash
# Install essentials
mkdir -p ~/.clawdbot/skills

# Slack notify
cat > ~/.clawdbot/skills/slack-notify.mjs << 'EOF'
export const meta = {
  name: 'slack-notify',
  description: 'Post naar Slack channels'
}

export async function run(context, { channel, message }) {
  const { WebClient } = await import('@slack/web-api');
  const client = new WebClient(process.env.SLACK_BOT_TOKEN);

  return await client.chat.postMessage({ channel, text: message });
}
EOF

# Simple analytics
cat > ~/.clawdbot/skills/simple-analytics.mjs << 'EOF'
export const meta = {
  name: 'simple-analytics',
  description: 'Basic GA metrics'
}

export async function run(context, { metric, days = 7 }) {
  // TODO: Implement GA4 API
  console.log(`Fetching ${metric} for last ${days} days`);
  return { metric, value: 'N/A', trend: 'up' };
}
EOF
```

---

## 📊 Starter vs Enterprise Comparison

| Feature | Starter | Enterprise |
|---------|---------|------------|
| **Agents** | 3 | 10+ |
| **Kosten/maand** | €130-205 | €600-800 |
| **VPS** | CPX21 (€15) | CPX41 (€50) |
| **Blog posts/week** | 3-5 | 25-35 |
| **Social posts/day** | 3-5 | 20-30 |
| **Model mix** | Sonnet + Haiku | Opus + Sonnet + Haiku |
| **Setup tijd** | 30 min | 1-2 uur |
| **Client capacity** | 1-3 clients | 10+ clients |
| **Specialisatie** | Generalist | Volledig gespecialiseerd |
| **Schaalbaarheid** | Limited | Unlimited |
| **Best voor** | Solo starters | Agencies |

---

## ✅ Next Steps

1. **Deploy Starter Team** (vandaag)
   ```bash
   # Follow setup hierboven
   # 30 minuten total
   ```

2. **Test & Refine** (week 1-2)
   ```bash
   # Experimenteer met prompts
   # Optimize workflows
   # Learn agent capabilities
   ```

3. **Acquire 1st Client** (week 3-4)
   ```bash
   # Prove value
   # Build portfolio
   # Refine processes
   ```

4. **Scale Revenue** (month 2-3)
   ```bash
   # Add 2-3 clients
   # Optimize costs
   # Build war chest
   ```

5. **Upgrade to Enterprise** (when ready)
   ```bash
   # See trigger points hierboven
   # Migrate to /start/jmg-enterprise-team-architecture
   # 10+ agents, full automation
   ```

---

## 📚 Resources

- **Enterprise Version:** [JMG Enterprise Team Architecture](/start/jmg-enterprise-team-architecture)
- **Quick Start (Enterprise):** [Enterprise Quick Start](/start/jmg-enterprise-quick-start)
- **Use Cases:** [10 Real-World Use Cases](/start/use-cases)
- **Clawdbot Docs:** [docs.clawd.bot](https://docs.clawd.bot)
- **Multi-Agent Guide:** [Multi-Agent Concepts](/concepts/multi-agent)

---

## 💬 Support

- [Discord Community](https://discord.gg/clawd) - #showcase channel
- [GitHub Issues](https://github.com/clawdbot/clawdbot/issues)

---

**Gebouwd met Clawdbot 🦞**

*Start klein. Schaal slim. Bouw je empire.*
