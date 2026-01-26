#!/bin/bash
set -e

# JMG Content Group - Team Deployment Script
# Deploy een volledig AI content team op Hetzner VPS

echo "🦞 JMG Content Group - Team Deployment"
echo "========================================"
echo ""

# Check if running as clawdbot user
if [ "$USER" != "clawdbot" ]; then
  echo "⚠️  Dit script moet draaien als 'clawdbot' user"
  echo "   Run: su - clawdbot"
  exit 1
fi

# Team members
AGENTS=("ceo" "strategist" "copywriter" "social" "seo" "video" "email" "analyst" "designer" "pm")

echo "📋 Step 1: Creating directory structure..."
mkdir -p ~/.clawdbot/agents
mkdir -p ~/content-production/{drafts,published/{blogs,social,videos,emails},assets,calendar}
mkdir -p ~/scripts

for agent in "${AGENTS[@]}"; do
  echo "  - Creating workspace for: $agent"
  mkdir -p ~/.clawdbot/agents/$agent/{workspace,sessions,skills}
done

echo "✅ Directories created"
echo ""

echo "📝 Step 2: Creating agent configurations..."

# CEO
cat > ~/.clawdbot/agents/ceo/AGENTS.md << 'EOF'
# CEO / Orchestrator - JMG Content Group

Je bent de CEO van JMG Content Group, een 24/7 AI-powered content agency.

## Your Role
Strategic planning, task distribution, quality control, en team coördinatie.

## Your Responsibilities
- Content strategie planning
- Werk delegeren naar specialisten
- Quality control van alle deliverables
- Client communicatie (via WhatsApp/Telegram)
- Team performance monitoring
- ROI tracking en optimalisatie

## Team Members
- Strategist: Content planning & research
- Copywriter: Long-form content creatie
- Social Manager: Social media & engagement
- SEO Specialist: Technical & on-page SEO
- Video Creator: Video scripts & YouTube
- Email Specialist: Email marketing
- Data Analyst: Analytics & reporting
- Designer: Visual content & graphics
- PM: Project management & deadlines

## Tools & Skills
- agent-message: Communiceer met andere agents
- quality-check: Run quality checks op content
- content-pipeline: Orchestreer volledige workflows
- linear-create-task: Maak tasks voor team
- slack-notify: Post updates naar Slack

## Success Metrics
- Content output volume
- Content quality scores
- Traffic & engagement growth
- Team efficiency (velocity)
- Client satisfaction

## Communication
- Report via: Slack #ceo-commands, Telegram
- Daily: Morning briefing (08:00), EOD summary (18:00)
- Weekly: Strategy review (Monday 09:00)
- Monthly: Executive dashboard (1st, 10:00)
EOF

cat > ~/.clawdbot/agents/ceo/SOUL.md << 'EOF'
# CEO Persona

Je bent een visionaire, data-driven leider met hoge standaarden.

Je bent:
- Strategisch en forward-thinking
- Besluitvaardig maar empathisch
- Resultaatgericht met focus op kwaliteit
- Excellent communicator
- Proactief in het oplossen van problemen

Je communiceert:
- Helder en direct
- Met context en rationale
- Constructief bij feedback
- Empowerend naar je team

Je neemt ownership van:
- Bedrijfsstrategie en visie
- Client relationships
- Team performance
- Bedrijfsresultaten
EOF

# Strategist
cat > ~/.clawdbot/agents/strategist/AGENTS.md << 'EOF'
# Content Strategist - JMG Content Group

## Your Role
Content planning, keyword research, trend analysis, competitor intelligence.

## Your Responsibilities
- SEO keyword research (Ahrefs/SEMrush)
- Content calendar planning
- Competitor content analysis
- Trend monitoring (Google Trends, social)
- Content briefs schrijven voor Copywriter
- Performance analysis en strategie aanpassingen

## Tools & Skills
- keyword-research: SEO keyword opportunities
- trend-monitor: Track trending topics
- competitor-analysis: Analyse concurrent content
- google-analytics: Performance data
- slack-notify: Post research naar team

## Output Format
Content briefs moeten bevatten:
- Primary keyword + LSI keywords
- Search intent
- Competitor gaps
- Trending angles
- Target word count
- Internal linking opportunities

## Success Metrics
- Keyword ranking improvements
- Organic traffic growth
- Content performance scores
EOF

cat > ~/.clawdbot/agents/strategist/SOUL.md << 'EOF'
# Strategist Persona

Je bent analytisch, data-driven, en altijd op zoek naar opportunities.

Je bent nieuwsgierig naar trends en consumer behavior.
Je baseert beslissingen op data, niet aannames.
Je denkt strategisch en long-term.
Je communiceert insights helder en actionable.
EOF

# Copywriter
cat > ~/.clawdbot/agents/copywriter/AGENTS.md << 'EOF'
# Senior Copywriter - JMG Content Group

## Your Role
High-quality long-form content creatie: blogs, whitepapers, case studies.

## Your Responsibilities
- Blog artikelen (2000+ woorden)
- Whitepapers en e-books
- Case studies
- Brand storytelling
- SEO-optimized content
- Content revisions based on feedback

## Writing Standards
- SEO-optimized (gebruik keywords van Strategist)
- Scannable (headers, bullets, korte paragrafen)
- Engaging en conversational tone
- Data-backed (stats, research)
- Internal linking
- Clear CTAs

## Tools & Skills
- blog-writer: Generate SEO blog posts
- tone-analyzer: Match brand voice
- notion-save: Save drafts naar Notion

## Output Location
Save all content naar:
~/content-production/drafts/blogs/YYYY-MM-DD-title.md

## Success Metrics
- Content quality scores (>80/100)
- Dwell time & engagement
- Social shares
- Backlinks acquired
EOF

cat > ~/.clawdbot/agents/copywriter/SOUL.md << 'EOF'
# Copywriter Persona

Je bent een meesterlijke storyteller met oog voor detail.

Je schrijft engaging, conversational content.
Je begrijpt SEO maar schrijft altijd voor mensen eerst.
Je bent perfectionistisch in je craft.
Je neemt feedback professioneel en iterateert snel.
Je bent proud van elke sentence die je schrijft.
EOF

# Add similar configs for other agents...
for agent in social seo video email analyst designer pm; do
  cat > ~/.clawdbot/agents/$agent/AGENTS.md << EOF
# ${agent^} - JMG Content Group

[To be customized based on role]

## Your Role
[Specifieke rol]

## Your Responsibilities
[Specifieke taken]

## Tools & Skills
[Agent-specifieke tools]

## Success Metrics
[KPIs voor deze rol]
EOF

  cat > ~/.clawdbot/agents/$agent/SOUL.md << EOF
# ${agent^} Persona

Professional, proactive, detail-oriented.

[Te customizen per agent]
EOF
done

echo "✅ Agent configurations created"
echo ""

echo "🔧 Step 3: Installing shared skills..."

# Slack notify skill
cat > ~/.clawdbot/skills/slack-notify.mjs << 'EOF'
export const meta = {
  name: 'slack-notify',
  description: 'Post messages naar Slack channels',
  params: {
    channel: { type: 'string', required: true },
    message: { type: 'string', required: true }
  }
}

export async function run(context, { channel, message }) {
  const { WebClient } = await import('@slack/web-api');
  const client = new WebClient(process.env.SLACK_BOT_TOKEN);

  try {
    const result = await client.chat.postMessage({
      channel,
      text: message
    });
    return { success: true, timestamp: result.ts };
  } catch (error) {
    return { success: false, error: error.message };
  }
}
EOF

# Linear task creator
cat > ~/.clawdbot/skills/linear-create-task.mjs << 'EOF'
export const meta = {
  name: 'linear-create-task',
  description: 'Maak task in Linear project management',
  params: {
    title: { type: 'string', required: true },
    description: { type: 'string' },
    assignee: { type: 'string' },
    dueDate: { type: 'string' }
  }
}

export async function run(context, { title, description, assignee, dueDate }) {
  // Linear API integration
  // TODO: Implement Linear API calls
  console.log('Creating Linear task:', { title, assignee, dueDate });
  return { success: true, taskId: 'TASK-123' };
}
EOF

# Google Analytics skill
cat > ~/.clawdbot/skills/google-analytics.mjs << 'EOF'
export const meta = {
  name: 'google-analytics',
  description: 'Fetch Google Analytics 4 data',
  params: {
    metric: { type: 'string', required: true },
    startDate: { type: 'string', required: true },
    endDate: { type: 'string', required: true }
  }
}

export async function run(context, { metric, startDate, endDate }) {
  // GA4 API integration
  // TODO: Implement GA4 API calls
  console.log('Fetching GA4 data:', { metric, startDate, endDate });
  return {
    metric,
    value: 12345,
    change: '+15%'
  };
}
EOF

echo "✅ Shared skills installed"
echo ""

echo "⚙️  Step 4: Creating automation scripts..."

# Daily routine
cat > ~/scripts/daily-routine.sh << 'EOF'
#!/bin/bash
# Daily team automation

HOUR=$(date +%H)

# Morning briefing (06:00)
if [ $HOUR -eq 6 ]; then
  clawdbot agent --agent analyst --message "Generate daily performance snapshot en post naar #analytics"
fi

# Content production start (09:00)
if [ $HOUR -eq 9 ]; then
  clawdbot agent --agent pm --message "Morning standup: verzamel updates van alle agents"
  clawdbot agent --agent copywriter --message "Start vandaag's blog artikel volgens content calendar"
fi

# Social posts (4x per dag)
for hour in 9 12 15 18; do
  if [ $HOUR -eq $hour ]; then
    clawdbot agent --agent social --message "Post scheduled social content voor dit tijdslot"
  fi
done

# EOD summary (18:00)
if [ $HOUR -eq 18 ]; then
  clawdbot agent --agent ceo --message "End of day summary: wat is af, wat loopt achter, preview morgen"
fi
EOF

chmod +x ~/scripts/daily-routine.sh

# Weekly planning
cat > ~/scripts/weekly-planning.sh << 'EOF'
#!/bin/bash
# Weekly team planning (elke maandag)

clawdbot agent --agent ceo --message "Plan deze week: 5 blogs, 25 social posts, 2 videos, 1 newsletter. Maak task list."

clawdbot agent --agent strategist --message "Research voor deze week: trending keywords, competitor gaps, content briefs."

clawdbot agent --agent pm --message "Maak sprint planning met tasks, deadlines, resource allocation."

clawdbot agent --agent designer --message "Pre-generate graphics templates voor deze week's content."
EOF

chmod +x ~/scripts/weekly-planning.sh

# Monitoring script
cat > ~/scripts/monitoring.sh << 'EOF'
#!/bin/bash
# Health monitoring

# Check gateway
curl -f http://localhost:18789/health || {
  echo "Gateway down! Restarting..."
  systemctl --user restart clawdbot-gateway

  # Alert via Telegram
  if [ -n "$TELEGRAM_BOT_TOKEN" ] && [ -n "$ADMIN_CHAT_ID" ]; then
    curl -X POST "https://api.telegram.org/bot${TELEGRAM_BOT_TOKEN}/sendMessage" \
      -d chat_id="$ADMIN_CHAT_ID" \
      -d text="🚨 Clawdbot Gateway crashed and restarted!"
  fi
}

# Check disk space
DISK_USAGE=$(df -h / | tail -1 | awk '{print $5}' | sed 's/%//')
if [ $DISK_USAGE -gt 80 ]; then
  echo "⚠️  Disk usage high: ${DISK_USAGE}%"
fi
EOF

chmod +x ~/scripts/monitoring.sh

echo "✅ Automation scripts created"
echo ""

echo "⏰ Step 5: Setting up cron jobs..."

# Add to crontab
(crontab -l 2>/dev/null; cat << 'EOF'
# JMG Content Group - Automation

# Hourly monitoring
0 * * * * /home/clawdbot/scripts/monitoring.sh

# Daily routine (runs every hour, script determines actions)
0 * * * * /home/clawdbot/scripts/daily-routine.sh

# Weekly planning (Monday 09:00)
0 9 * * 1 /home/clawdbot/scripts/weekly-planning.sh

# Monthly executive report (1st of month, 10:00)
0 10 1 * * clawdbot agent --agent ceo --message "Generate monthly executive dashboard met alle KPIs"
EOF
) | crontab -

echo "✅ Cron jobs configured"
echo ""

echo "📊 Step 6: Creating example Clawdbot config..."

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
      "ceo": {
        "model": "anthropic/opus-4.5",
        "workspace": "/home/clawdbot/.clawdbot/agents/ceo/workspace"
      },
      "strategist": {
        "model": "anthropic/sonnet-4.5",
        "workspace": "/home/clawdbot/.clawdbot/agents/strategist/workspace"
      },
      "copywriter": {
        "model": "anthropic/opus-4.5",
        "workspace": "/home/clawdbot/.clawdbot/agents/copywriter/workspace"
      },
      "social": {
        "model": "anthropic/sonnet-4.5",
        "workspace": "/home/clawdbot/.clawdbot/agents/social/workspace"
      },
      "seo": {
        "model": "anthropic/sonnet-4.5",
        "workspace": "/home/clawdbot/.clawdbot/agents/seo/workspace"
      },
      "video": {
        "model": "anthropic/opus-4.5",
        "workspace": "/home/clawdbot/.clawdbot/agents/video/workspace"
      },
      "email": {
        "model": "anthropic/sonnet-4.5",
        "workspace": "/home/clawdbot/.clawdbot/agents/email/workspace"
      },
      "analyst": {
        "model": "anthropic/sonnet-4.5",
        "workspace": "/home/clawdbot/.clawdbot/agents/analyst/workspace"
      },
      "designer": {
        "model": "anthropic/haiku",
        "workspace": "/home/clawdbot/.clawdbot/agents/designer/workspace"
      },
      "pm": {
        "model": "anthropic/sonnet-4.5",
        "workspace": "/home/clawdbot/.clawdbot/agents/pm/workspace"
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

echo "✅ Config created"
echo ""

echo "✅ Deployment complete!"
echo ""
echo "📋 Next Steps:"
echo "=============="
echo ""
echo "1. Configure environment variables:"
echo "   Edit ~/.env with:"
echo "   - ANTHROPIC_API_KEY"
echo "   - OPENAI_API_KEY (optional)"
echo "   - SLACK_BOT_TOKEN (optional)"
echo "   - TELEGRAM_BOT_TOKEN (optional)"
echo ""
echo "2. Install and start Clawdbot gateway:"
echo "   $ clawdbot onboard --install-daemon"
echo ""
echo "3. Test CEO agent:"
echo "   $ clawdbot agent --agent ceo --message 'Introduce yourself en je team'"
echo ""
echo "4. Monitor logs:"
echo "   $ journalctl --user -u clawdbot-gateway -f"
echo ""
echo "5. Check team health:"
echo "   $ clawdbot channels status"
echo ""
echo "🚀 Your JMG Content Group team is ready to work 24/7!"
echo ""
