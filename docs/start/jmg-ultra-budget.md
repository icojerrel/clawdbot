---
title: "JMG Content Team: Ultra Budget Edition"
description: "Gebruik Ollama voor €30-50/maand total costs"
summary: "Lokale AI models (Ollama) voor routine tasks + Claude voor high-quality content"
---

# JMG Content Team: Ultra Budget Edition 💰

**Total kosten: €30-80/maand** door Ollama te gebruiken voor routine tasks en Claude alleen voor high-quality content.

## 💡 Concept: Hybrid Local + Cloud

**Ollama (Gratis, lokaal)** voor:
- ✅ Social media posts (eenvoudig, hoog volume)
- ✅ Analytics rapportage (data processing)
- ✅ Content repurposing (blog → social)
- ✅ Email drafts (routine newsletters)
- ✅ SEO meta descriptions
- ✅ Hashtag research

**Claude Sonnet (Betaald)** voor:
- ⭐ Blog posts (high quality)
- ⭐ Client-facing content
- ⭐ Strategic planning
- ⭐ Complex research

---

## 🎯 Ultra Budget Team (4 Agents)

### 1. **Content Director** (Claude Sonnet 4.5)
**Rol:** Strategie + high-quality long-form content

**Gebruik:** ~2-3x per week (blog posts + planning)
**Kosten:** €40-60/maand

**Taken:**
- Wekelijkse content planning
- 2-3 blog posts per week (2000+ woorden)
- Client communication
- Quality review van Ollama output

**Workspace:** `~/.clawdbot/agents/director`
**Model:** `anthropic/sonnet-4.5`

---

### 2. **Social Bot** (Ollama Llama 3.1 8B)
**Rol:** Social media content productie

**Gebruik:** Dagelijks, hoog volume
**Kosten:** €0 (lokaal)

**Taken:**
- 5-10 social posts per dag
- Content repurposing (blog → threads)
- Hashtag suggestions
- Engagement responses (drafts)

**Workspace:** `~/.clawdbot/agents/socialbot`
**Model:** `ollama/llama3.1:8b`

---

### 3. **Analytics Reporter** (Ollama Llama 3.1 8B)
**Rol:** Data tracking en rapportage

**Gebruik:** Dagelijks
**Kosten:** €0 (lokaal)

**Taken:**
- Daily metrics snapshot
- Weekly performance report
- Data visualization (markdown tables)
- Trend alerts

**Workspace:** `~/.clawdbot/agents/reporter`
**Model:** `ollama/llama3.1:8b`

---

### 4. **Email Assistant** (Ollama Llama 3.1 8B)
**Rol:** Newsletter drafts en email content

**Gebruik:** Wekelijks
**Kosten:** €0 (lokaal)

**Taken:**
- Newsletter drafts (Content Director refineert)
- Email sequence templates
- Subject line variations
- Repurpose blog content naar email

**Workspace:** `~/.clawdbot/agents/email`
**Model:** `ollama/llama3.1:8b`

---

## 💰 Ultra Budget Kosten

### Maandelijke Kosten

**Infrastructure:**
- **Hetzner VPS** CPX31 (4 cores, 16GB RAM): €25/maand
  - Genoeg voor Ollama + gateway
  - 16GB RAM voor Llama 3.1 8B models

**API Kosten:**
- **Content Director (Sonnet 4.5)**: €40-60/maand
  - Alleen voor high-quality blogs (2-3x/week)
  - Strategic planning

**Tools:**
- Optioneel (Canva, etc.): €0-15/maand

**TOTAAL: €65-100/maand**

vs Starter (€130-205) = **50% goedkoper**
vs Enterprise (€600-800) = **90% goedkoper**

---

## 🚀 Setup: Ultra Budget (45 min)

### Stap 1: Hetzner VPS met Ollama Support

```bash
# Hetzner: CPX31 (4 cores, 16GB RAM) - €25/maand
# Minimaal 16GB RAM voor Llama 3.1 8B

ssh root@your-vps-ip
useradd -m -s /bin/bash clawdbot
usermod -aG sudo clawdbot
su - clawdbot
```

### Stap 2: Install Ollama

```bash
# Install Ollama
curl -fsSL https://ollama.com/install.sh | sh

# Pull Llama 3.1 8B (snelste, goede quality)
ollama pull llama3.1:8b

# Verify
ollama list
# Output:
# NAME              ID              SIZE      MODIFIED
# llama3.1:8b      abc123          4.7 GB    2 minutes ago

# Test
ollama run llama3.1:8b "Write a tweet about AI content creation"
```

### Stap 3: Install Node.js + Clawdbot

```bash
# Node.js 22
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash
source ~/.bashrc
nvm install 22
nvm use 22

# Clawdbot
npm install -g clawdbot@latest
```

### Stap 4: Directory Structure

```bash
mkdir -p ~/.clawdbot/agents/{director,socialbot,reporter,email}/{workspace,sessions,skills}
mkdir -p ~/content-production/{drafts,published,calendar}
mkdir -p ~/scripts

# Environment
cat > ~/.env << 'EOF'
# Claude (alleen voor Content Director)
ANTHROPIC_API_KEY=sk-ant-your-key-here
CLAWDBOT_GATEWAY_TOKEN=your-secure-token

# Ollama (lokaal)
OLLAMA_BASE_URL=http://localhost:11434

# Optional
TELEGRAM_BOT_TOKEN=your-token
EOF

source ~/.env
```

### Stap 5: Clawdbot Config met Ollama

```bash
cat > ~/.clawdbot/clawdbot.json << 'EOF'
{
  "gateway": {
    "mode": "local",
    "bind": "127.0.0.1",
    "port": 18789
  },

  "models": {
    "providers": {
      "anthropic": {
        "apiKey": "${ANTHROPIC_API_KEY}"
      },
      "ollama": {
        "baseURL": "http://localhost:11434"
      }
    }
  },

  "agents": {
    "defaults": {
      "blockStreaming": true,
      "queue": {
        "mode": "followup",
        "debounceMs": 2000
      }
    },

    "routing": {
      "director": {
        "model": "anthropic/sonnet-4.5",
        "workspace": "/home/clawdbot/.clawdbot/agents/director/workspace"
      },
      "socialbot": {
        "model": "ollama/llama3.1:8b",
        "workspace": "/home/clawdbot/.clawdbot/agents/socialbot/workspace"
      },
      "reporter": {
        "model": "ollama/llama3.1:8b",
        "workspace": "/home/clawdbot/.clawdbot/agents/reporter/workspace"
      },
      "email": {
        "model": "ollama/llama3.1:8b",
        "workspace": "/home/clawdbot/.clawdbot/agents/email/workspace"
      }
    }
  },

  "tools": {
    "exec": {
      "enabled": true,
      "policy": "approval"
    }
  }
}
EOF
```

### Stap 6: Agent Configs

```bash
# Content Director (Claude)
cat > ~/.clawdbot/agents/director/AGENTS.md << 'EOF'
# Content Director - Ultra Budget Edition

Je bent de Content Director. Je doet high-quality work waar Claude nodig is.

## When to Use You (Claude Sonnet)
- Blog posts (2000+ woorden, high quality)
- Strategic content planning
- Client-facing content
- Complex research & analysis

## When to Delegate to Ollama Agents
- Social media posts → Social Bot
- Analytics reports → Analytics Reporter
- Email drafts → Email Assistant
- Routine tasks → Ollama agents

## Your Focus
Quality over quantity. Je doet alleen waar premium AI nodig is.

## Collaboration
- Direct Social Bot voor daily social content
- Review Ollama output voor quality
- Refine Email Assistant drafts
- Use Reporter data voor strategie
EOF

# Social Bot (Ollama)
cat > ~/.clawdbot/agents/socialbot/AGENTS.md << 'EOF'
# Social Bot - Ollama Llama 3.1 8B

Je bent de Social Bot. Je draait lokaal op Ollama voor gratis social content.

## Your Role
High-volume social media content productie.

## Responsibilities
- 5-10 posts per dag (Twitter, LinkedIn, Instagram)
- Repurpose blog posts naar social threads
- Generate hashtag suggestions
- Draft engagement responses

## Format Guidelines
- Twitter: Max 280 chars, punchy
- LinkedIn: Professional, 150-300 words
- Instagram: Visual focus, emoji-friendly

## Quality Check
Content Director reviews je output wekelijks.
EOF

# Analytics Reporter (Ollama)
cat > ~/.clawdbot/agents/reporter/AGENTS.md << 'EOF'
# Analytics Reporter - Ollama Llama 3.1 8B

Je bent de Analytics Reporter. Data processing draait gratis lokaal.

## Your Role
Track metrics, generate reports, alert team.

## Responsibilities
- Daily performance snapshot (markdown table)
- Weekly summary report
- Trend alerts (traffic spikes, etc.)
- Simple data visualizations (ASCII/markdown)

## Output Format
Always use markdown tables voor data:

| Metric | Value | Change |
|--------|-------|--------|
| Traffic | 1,234 | +15% |
| Posts | 42 | +5% |
EOF

# Email Assistant (Ollama)
cat > ~/.clawdbot/agents/email/AGENTS.md << 'EOF'
# Email Assistant - Ollama Llama 3.1 8B

Je bent de Email Assistant. Newsletter drafts lokaal, gratis.

## Your Role
Create email content drafts (Content Director refines).

## Responsibilities
- Weekly newsletter drafts
- Repurpose blog content voor email
- Subject line variations (5-10 options)
- Email sequence templates

## Process
1. Generate draft
2. Content Director reviews & refines
3. Final version ready for sending
EOF
```

### Stap 7: Daily Automation

```bash
cat > ~/scripts/ultra-daily.sh << 'EOF'
#!/bin/bash
HOUR=$(date +%H)

# Morning analytics (07:00) - Ollama (gratis)
if [ $HOUR -eq 7 ]; then
  clawdbot agent --agent reporter --message "Daily performance snapshot"
fi

# Social posts (3x per dag) - Ollama (gratis)
for hour in 10 14 18; do
  if [ $HOUR -eq $hour ]; then
    clawdbot agent --agent socialbot --message "Create 2-3 social posts voor nu"
  fi
done

# Weekly planning (Monday 09:00) - Claude (betaald, 1x/week)
if [ $(date +%u) -eq 1 ] && [ $HOUR -eq 9 ]; then
  clawdbot agent --agent director --message "Plan deze week:
  - Blog topics (2-3)
  - Social themes
  - Email newsletter
  Delegate waar mogelijk naar Ollama agents."
fi
EOF

chmod +x ~/scripts/ultra-daily.sh

# Cron
(crontab -l 2>/dev/null; echo "0 * * * * ~/scripts/ultra-daily.sh") | crontab -
```

### Stap 8: Start Services

```bash
# Start Ollama (als service)
sudo systemctl enable ollama
sudo systemctl start ollama

# Verify Ollama
curl http://localhost:11434/api/tags

# Start Clawdbot gateway
clawdbot onboard --install-daemon

# Verify
clawdbot channels status
```

---

## 📊 Workload Verdeling: Claude vs Ollama

### Claude Sonnet (Betaald - €40-60/maand)
**Gebruik: 2-3x per week**

```
Maandag:
  09:00 - Weekly planning (10 min) ← Claude

Dinsdag:
  10:00 - Blog post #1 (30-60 min) ← Claude

Donderdag:
  10:00 - Blog post #2 (30-60 min) ← Claude

Vrijdag (optioneel):
  14:00 - Blog post #3 (30-60 min) ← Claude

Totaal Claude usage: ~3-4 uur/week
= €10-15/week = €40-60/maand ✅
```

### Ollama (Gratis - lokaal)
**Gebruik: Dagelijks, hoog volume**

```
Elke dag:
  07:00 - Analytics snapshot ← Ollama
  10:00 - 2-3 social posts ← Ollama
  14:00 - 2-3 social posts ← Ollama
  18:00 - 2-3 social posts ← Ollama

Wekelijks:
  Woensdag 15:00 - Newsletter draft ← Ollama
  Vrijdag 16:00 - Weekly analytics ← Ollama

Totaal Ollama usage: ~2 uur/dag
= Gratis! ✅
```

---

## 🎯 Weekly Output (Ultra Budget)

**Content:**
- 📝 **2-3 blog posts** (Claude, high quality)
- 📱 **20-30 social posts** (Ollama)
- 📧 **1 newsletter** (Ollama draft → Claude refine)
- 📊 **Daily + weekly reports** (Ollama)

**Kosten:**
- **€65-100/maand** total
- **€15-20 per blog post** (Claude)
- **€0 per social post** (Ollama)
- **€0 per report** (Ollama)

---

## ⚡ Performance Tips: Ollama Optimization

### 1. Model Selectie

```bash
# RECOMMENDED: Llama 3.1 8B (beste balance)
ollama pull llama3.1:8b
# 4.7 GB, snel, goede quality

# BUDGET: Gemma 2B (super snel, basic tasks)
ollama pull gemma:2b
# 1.7 GB, zeer snel, simpelere content

# PREMIUM: Llama 3.1 70B (als je RAM hebt)
# Niet aanbevolen voor budget setup
```

### 2. Concurrent Runs

```bash
# Ollama kan parallel draaien
# Meerdere agents tegelijk

# In clawdbot.json:
{
  "agents": {
    "concurrency": 3  // 3 Ollama agents parallel
  }
}
```

### 3. Caching

Ollama heeft ingebouwde context caching - hergebruik van eerdere context is gratis!

### 4. System Resources

```bash
# Check Ollama memory usage
ollama ps

# Optimize
export OLLAMA_NUM_PARALLEL=2  # Max 2 concurrent
export OLLAMA_MAX_LOADED_MODELS=2
```

---

## 📈 Upgrade Path: Ultra → Starter → Enterprise

### Phase 1: Ultra Budget (now)
```
Kosten: €65-100/maand
Output: 2-3 blogs/week, 20-30 social/week
Capacity: 1-2 clients
```

### Phase 2: Hybrid (€150-200/maand)
```
Add: Claude Haiku voor meer volume
Keep: Ollama voor routine
Output: 5-7 blogs/week, 30-40 social/week
Capacity: 3-4 clients
```

### Phase 3: Starter (€200-300/maand)
```
More Claude (Sonnet + Haiku)
Less Ollama (only analytics/reports)
Output: 10+ blogs/week, 50+ social/week
Capacity: 5-8 clients
```

### Phase 4: Enterprise (€600-800/maand)
```
Full Claude (Opus + Sonnet + Haiku)
10+ specialized agents
Unlimited capacity
See: /start/jmg-enterprise-team-architecture
```

---

## 🔧 Troubleshooting

### Ollama Model Niet Gevonden

```bash
# Check models
ollama list

# Pull opnieuw
ollama pull llama3.1:8b

# Test direct
ollama run llama3.1:8b "test"
```

### Ollama Traag / Out of Memory

```bash
# Check RAM
free -h

# Kleinere model
ollama pull gemma:2b

# Stop andere models
ollama stop llama3.1:8b
```

### Claude API Kosten Te Hoog

```bash
# Reduce Claude usage
# Edit configs - gebruik alleen voor blogs:

# In director/AGENTS.md:
"ONLY use me for:
1. Blog posts (2x/week max)
2. Weekly planning (1x/week)
3. Critical client communication

DELEGATE everything else to Ollama agents."
```

---

## 💡 Pro Tips

### 1. Quality Control Pattern

```
Ollama creates draft →
Claude reviews/refines →
Published ✅

Example:
- Social Bot (Ollama) writes 10 posts
- Content Director (Claude) reviews in 1 batch
- Approve 8, refine 2
```

### 2. Batch Claude Requests

```bash
# Instead of:
# Claude run 1: Plan Monday
# Claude run 2: Write blog Tuesday
# Claude run 3: Review Friday

# Do:
# Claude run 1 (Monday): "Plan week + outline 3 blogs"
# Claude run 2 (Tuesday): "Write all 3 blogs in 1 session"

# = Fewer API calls, lower cost
```

### 3. Template Everything (Ollama)

```bash
# Create templates voor Ollama
# Ollama is great at filling templates

# Social post template:
cat > ~/templates/social-post.md << 'EOF'
Topic: [TOPIC]
Platform: [Twitter/LinkedIn/Instagram]
Tone: [Professional/Casual/Inspiring]
Length: [Short/Medium/Long]
Include: [Hashtags yes/no]

Generate post following these params.
EOF

# Ollama fills it in - consistent, fast, gratis
```

---

## 📚 Resources

- **Ollama Docs:** [ollama.ai/docs](https://ollama.ai/docs)
- **Starter Edition:** [JMG Starter Team](/start/jmg-starter-team)
- **Enterprise Edition:** [JMG Enterprise Architecture](/start/jmg-enterprise-team-architecture)
- **Clawdbot Multi-Agent:** [Multi-Agent Guide](/concepts/multi-agent)

---

## ✅ Summary: Ultra Budget Edition

**Perfect voor:**
- Absolute beginners
- Bootstrap mode (minimale budget)
- Experimenteren/leren
- Proof of concept

**Kosten:**
- €65-100/maand (90% goedkoper dan Enterprise)

**Output:**
- 2-3 blogs/week (Claude quality)
- 20-30 social posts/week (Ollama volume)
- Daily analytics (Ollama)
- Weekly newsletter (Ollama + Claude)

**Strategie:**
- Ollama voor volume & routine
- Claude voor quality & strategie
- Start klein, bewijs waarde, schaal op

---

**Gebouwd met Clawdbot + Ollama 🦞**

*Enterprise capabilities. Startup budget.*
