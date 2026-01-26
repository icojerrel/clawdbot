#!/bin/bash

# Weekly Strategy Review Script for Lavish Pilot
# Version: 1.0
# Runs every Monday at 9 AM via cron

PILOT_DIR="$HOME/.lavish-pilot"
LOGFILE="$PILOT_DIR/logs/weekly-review-$(date +%Y-%m-%d).log"

# Load nvm and node
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

# Create log directory if it doesn't exist
mkdir -p "$PILOT_DIR/logs"

# Function to log with timestamp
log() {
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOGFILE"
}

log "╔══════════════════════════════════════════════════════════════╗"
log "║                                                              ║"
log "║        WEEKLY STRATEGY REVIEW - LAVISH PILOT                 ║"
log "║                                                              ║"
log "╚══════════════════════════════════════════════════════════════╝"

# Check if clawdbot is available
if ! command -v clawdbot >/dev/null 2>&1; then
  log "❌ Clawdbot not found in PATH"
  log "Please ensure Node.js and Clawdbot are properly installed"
  exit 1
fi

log "✓ Clawdbot version: $(clawdbot --version 2>/dev/null || echo 'unknown')"

# Check gateway health
log "Checking gateway health..."
if ! curl -f http://localhost:18789/health >/dev/null 2>&1; then
  log "❌ Gateway is not responding"
  log "Starting gateway..."
  if command -v systemctl >/dev/null 2>&1; then
    sudo systemctl start lavish-gateway
    sleep 5
  fi
fi

if curl -f http://localhost:18789/health >/dev/null 2>&1; then
  log "✓ Gateway is healthy"
else
  log "❌ Cannot start gateway - aborting weekly review"
  exit 1
fi

# Calculate week number
WEEK_NUMBER=$(date +%V)
YEAR=$(date +%Y)
log "Starting review for Week $WEEK_NUMBER, $YEAR"

# Step 1: Data Analyst - Performance Review
log ""
log "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
log "▶ STEP 1: Performance Analysis (Data Analyst)"
log "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

clawdbot agent --agent analyst --message "$(cat <<'EOF'
Weekly Performance Review - Week $WEEK_NUMBER

Please analyze the past week's content performance for Lavish Nederland:

1. Social Media Metrics:
   - Instagram: follower growth, engagement rate, top posts
   - Facebook: engagement, reach, top posts
   - TikTok: views, engagement, viral potential

2. Website Metrics (if GA4 is configured):
   - Traffic: sessions, pageviews, bounce rate
   - Top content: most visited pages/posts
   - Conversion: goals, events

3. Email Performance (if Mailchimp is configured):
   - Open rate, click rate
   - Top performing campaigns
   - Subscriber growth

4. SEO Performance:
   - Keyword rankings (if Ahrefs/SEMrush configured)
   - Backlink growth
   - Organic traffic

Please create a summary report and save it to:
~/.lavish-pilot/content/analytics/week-$WEEK_NUMBER-performance.md

Include:
- Key wins (what worked well)
- Areas for improvement
- Recommendations for next week

Use any available skills (tiktok-analytics, etc.) to gather data.
EOF
)" >> "$LOGFILE" 2>&1

log "✓ Performance analysis requested"

# Step 2: Strategist - Strategic Recommendations
log ""
log "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
log "▶ STEP 2: Strategic Planning (Strategist)"
log "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

clawdbot agent --agent strategist --message "$(cat <<'EOF'
Weekly Strategy Update - Week $WEEK_NUMBER

Based on last week's performance (check with Data Analyst), please:

1. Review Content Strategy:
   - What content themes performed best?
   - Are we hitting our target audience?
   - Content gaps or opportunities?

2. Competitive Analysis:
   - What are competitors doing well?
   - Trending topics in hospitality/bar industry
   - Emerging platforms or formats to consider

3. Next Week's Focus:
   - Key themes and topics
   - Platform priorities (where to focus effort)
   - Content mix (video vs. static, educational vs. promotional)

4. Long-term Adjustments:
   - Are we on track for 8-week pilot goals?
   - Any strategy pivots needed?
   - Resource allocation (which agents need more/less work)

Please create a strategy document at:
~/.lavish-pilot/content/analytics/week-$WEEK_NUMBER-strategy.md

Include:
- Top 3 strategic priorities for next week
- Content calendar themes
- Specific tactics for each channel
EOF
)" >> "$LOGFILE" 2>&1

log "✓ Strategic planning requested"

# Step 3: CEO - Team Alignment & Client Update
log ""
log "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
log "▶ STEP 3: Team Alignment (CEO)"
log "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

clawdbot agent --agent ceo --message "$(cat <<'EOF'
Weekly Team Sync & Client Update - Week $WEEK_NUMBER

Please coordinate the weekly review:

1. Review Performance Report (from Data Analyst)
   - Read: ~/.lavish-pilot/content/analytics/week-$WEEK_NUMBER-performance.md
   - Identify key metrics to share with client

2. Review Strategy (from Strategist)
   - Read: ~/.lavish-pilot/content/analytics/week-$WEEK_NUMBER-strategy.md
   - Align team on priorities for next week

3. Create Client Update:
   - Summary of week's achievements
   - Key metrics (growth, engagement, reach)
   - Highlights (best performing content)
   - Next week's plan
   - Save to: ~/.lavish-pilot/content/analytics/week-$WEEK_NUMBER-client-update.md

4. Team Task Assignment:
   - Based on strategy, assign tasks to team members
   - Create task list for daily automation to pick up
   - Ensure workload is balanced across agents

5. Risk Assessment:
   - Any blockers or concerns?
   - Resource constraints?
   - Client feedback to address?

If TELEGRAM_BOT_TOKEN is configured, send the client update to Lavish.
Otherwise, save for manual delivery.
EOF
)" >> "$LOGFILE" 2>&1

log "✓ Team alignment and client update requested"

# Step 4: Project Manager - Weekly Planning
log ""
log "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
log "▶ STEP 4: Weekly Planning (Project Manager)"
log "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

clawdbot agent --agent pm --message "$(cat <<'EOF'
Weekly Planning - Week $WEEK_NUMBER

Please organize next week's work:

1. Review Strategy Priorities:
   - Read: ~/.lavish-pilot/content/analytics/week-$WEEK_NUMBER-strategy.md
   - Break down into concrete tasks

2. Create Weekly Task List:
   - Content creation tasks (Copywriter, Designer, Video Creator)
   - Social media tasks (Social Manager)
   - SEO tasks (SEO Specialist)
   - Email campaigns (Email Specialist)
   - Deadlines for each task

3. Update Content Calendar:
   - Plan posting schedule for next 7 days
   - Balance across platforms
   - Save to: ~/.lavish-pilot/content/calendar/week-$WEEK_NUMBER.md

4. Resource Allocation:
   - Estimate agent workload
   - Flag if any agent is over/under-utilized
   - Recommend adjustments

5. Risk Management:
   - Identify dependencies between tasks
   - Highlight blockers or tight deadlines
   - Contingency plans for high-risk items

Please create a detailed plan at:
~/.lavish-pilot/content/calendar/week-$WEEK_NUMBER-plan.md
EOF
)" >> "$LOGFILE" 2>&1

log "✓ Weekly planning requested"

# Summary
log ""
log "╔══════════════════════════════════════════════════════════════╗"
log "║                                                              ║"
log "║  ✅ WEEKLY STRATEGY REVIEW INITIATED                         ║"
log "║                                                              ║"
log "╚══════════════════════════════════════════════════════════════╝"
log ""
log "Deliverables:"
log "  1. Performance report: content/analytics/week-$WEEK_NUMBER-performance.md"
log "  2. Strategy update: content/analytics/week-$WEEK_NUMBER-strategy.md"
log "  3. Client update: content/analytics/week-$WEEK_NUMBER-client-update.md"
log "  4. Weekly plan: content/calendar/week-$WEEK_NUMBER-plan.md"
log ""
log "Agents will complete these tasks asynchronously."
log "Check logs at: $LOGFILE"
log ""
log "Next steps:"
log "  - Review generated reports in ~/.lavish-pilot/content/analytics/"
log "  - Approve and send client update to Lavish"
log "  - Ensure daily automation picks up weekly tasks"
log ""
log "Review completed at: $(date)"
