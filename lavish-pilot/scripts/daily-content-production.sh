#!/bin/bash
# Lavish Pilot - Daily Content Production Automation
# Runs every morning at 06:00 to kickstart the day's content workflow
# Cron: 0 6 * * *

set -e

PILOT_DIR="${PILOT_DIR:-$HOME/.lavish-pilot}"
LOG_FILE="$PILOT_DIR/logs/daily-$(date +%Y-%m-%d).log"

mkdir -p "$PILOT_DIR/logs"

echo "════════════════════════════════════════════════════════════" | tee -a "$LOG_FILE"
echo "  LAVISH DAILY CONTENT PRODUCTION" | tee -a "$LOG_FILE"
echo "  $(date '+%A, %B %d, %Y - %H:%M:%S')" | tee -a "$LOG_FILE"
echo "════════════════════════════════════════════════════════════" | tee -a "$LOG_FILE"
echo "" | tee -a "$LOG_FILE"

# Check if Clawdbot is available
if ! command -v clawdbot &> /dev/null; then
  echo "❌ Clawdbot not found in PATH" | tee -a "$LOG_FILE"
  exit 1
fi

# Check if gateway is running
if ! curl -f http://localhost:18789/health &>/dev/null; then
  echo "⚠️  Gateway not responding - attempting restart..." | tee -a "$LOG_FILE"

  # Try to restart gateway
  if command -v tmux &> /dev/null; then
    tmux kill-session -t lavish-gateway 2>/dev/null || true
    tmux new-session -d -s lavish-gateway "clawdbot gateway run --bind 127.0.0.1 --port 18789"
    sleep 5
  fi

  # Check again
  if ! curl -f http://localhost:18789/health &>/dev/null; then
    echo "❌ Gateway still not responding - aborting" | tee -a "$LOG_FILE"
    exit 1
  fi

  echo "✓ Gateway restarted successfully" | tee -a "$LOG_FILE"
fi

# Helper function: Send agent message
send_message() {
  local agent="$1"
  local message="$2"

  echo "" | tee -a "$LOG_FILE"
  echo "→ Sending to $agent..." | tee -a "$LOG_FILE"

  if clawdbot agent --agent "$agent" --message "$message" >> "$LOG_FILE" 2>&1; then
    echo "  ✓ Message sent to $agent" | tee -a "$LOG_FILE"
    return 0
  else
    echo "  ✗ Failed to send message to $agent" | tee -a "$LOG_FILE"
    return 1
  fi
}

# ═══════════════════════════════════════════════════════════════
# MORNING BRIEFING (06:00)
# ═══════════════════════════════════════════════════════════════

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" | tee -a "$LOG_FILE"
echo "▶ STEP 1: Morning Briefing" | tee -a "$LOG_FILE"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" | tee -a "$LOG_FILE"

# CEO: Morning overview
send_message "ceo" "Good morning! Today is $(date +%A, %B %d, %Y).

Morning tasks:
1. Review yesterday's performance (check Analyst report)
2. Verify today's content calendar
3. Address any urgent team blockers
4. Approve content for publication

Let's make today count! 🚀"

# Analyst: Daily performance snapshot
send_message "analyst" "Generate daily performance snapshot for yesterday:
- Instagram metrics (followers, engagement, top post)
- TikTok metrics (views, top video)
- Facebook metrics (likes, reach)
- Website traffic (if GA4 connected)

Post summary to Slack #analytics and prepare client update for Telegram."

# Strategist: Daily trend check
send_message "strategist" "Morning trend check:
1. Google Trends - any spikes in cocktail/party keywords?
2. TikTok trending audio - what's hot today?
3. Instagram trends - what's working in our niche?
4. Competitor watch - what did they post yesterday?

Share insights in Slack #strategy."

echo "" | tee -a "$LOG_FILE"
echo "✅ Morning briefing sent to CEO, Analyst, Strategist" | tee -a "$LOG_FILE"

# ═══════════════════════════════════════════════════════════════
# CONTENT PRODUCTION (09:00 start)
# ═══════════════════════════════════════════════════════════════

echo "" | tee -a "$LOG_FILE"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" | tee -a "$LOG_FILE"
echo "▶ STEP 2: Content Production Kickoff" | tee -a "$LOG_FILE"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" | tee -a "$LOG_FILE"

DAY_OF_WEEK=$(date +%u) # 1=Monday, 7=Sunday

# Copywriter: Blog posts on Monday & Thursday
if [ "$DAY_OF_WEEK" -eq 1 ] || [ "$DAY_OF_WEEK" -eq 4 ]; then
  send_message "copywriter" "Time to write today's blog post!

Check the content calendar at ~/.lavish-pilot/content/calendar/ for today's topic.

Requirements:
- 2,000+ words
- SEO-optimized (keywords from Strategist)
- Include internal links
- Meta description
- Save draft to ~/. lavish-pilot/content/drafts/

Target completion: 14:00 for CEO approval."
fi

# Social Media Manager: Daily posts
send_message "social" "Good morning! Today's social media schedule:

**Instagram:**
- 09:00: Morning post (check calendar)
- 15:00: Afternoon post (mixology or lifestyle)
- 20:00: Evening post (party vibes)
- Stories: 5-10 throughout the day

**TikTok:**
- 12:00: First video (trending audio)
- 19:00: Second video (mixology or party)

**Facebook:**
- 10:00: Morning community post
- 17:00: Evening engagement post

Monitor comments/DMs - respond within 2 hours!

Check content calendar for specific topics."

# Designer: Generate today's visuals
send_message "designer" "Morning! Today's visual assets needed:

- 3 Instagram post templates (based on calendar)
- 2 TikTok thumbnails
- 1 Facebook event banner (if applicable)

Brand guidelines:
- Colors: Zwart, goud, neon accenten
- Premium aesthetic
- Festival/party vibes

Save to ~/.lavish-pilot/content/assets/

Deadline: 08:00 for Social Manager to use."

echo "" | tee -a "$LOG_FILE"
echo "✅ Content production tasks delegated" | tee -a "$LOG_FILE"

# ═══════════════════════════════════════════════════════════════
# MONITORING & ENGAGEMENT
# ═══════════════════════════════════════════════════════════════

echo "" | tee -a "$LOG_FILE"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" | tee -a "$LOG_FILE"
echo "▶ STEP 3: Monitoring Setup" | tee -a "$LOG_FILE"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" | tee -a "$LOG_FILE"

# PM: Daily task tracking
send_message "pm" "Morning PM tasks:

1. Review yesterday's completed tasks
2. Check today's deadlines (content calendar)
3. Identify any blockers from team
4. Update project board
5. Prepare daily standup summary

Post to Slack #project-management by 09:30."

# SEO: Daily optimization
send_message "seo" "Daily SEO tasks:

1. Check keyword rankings (any changes?)
2. Review yesterday's published content for optimization
3. Internal linking opportunities
4. Technical SEO health check

Quick wins only - save deep work for dedicated SEO days."

echo "" | tee -a "$LOG_FILE"
echo "✅ Monitoring and PM tasks assigned" | tee -a "$LOG_FILE"

# ═══════════════════════════════════════════════════════════════
# EMAIL (if Wednesday)
# ═══════════════════════════════════════════════════════════════

if [ "$DAY_OF_WEEK" -eq 3 ]; then
  echo "" | tee -a "$LOG_FILE"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" | tee -a "$LOG_FILE"
  echo "▶ STEP 4: Wednesday Newsletter" | tee -a "$LOG_FILE"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" | tee -a "$LOG_FILE"

  send_message "email" "It's Wednesday - Newsletter day! 📧

Write and schedule this week's newsletter:
- Subject: Create 3 variants for A/B test
- Content: Week highlights, upcoming events, exclusive offer
- Segments: All subscribers (8K+)
- Send time: 10:00

Include:
- Top performing content from this week
- Behind-the-scenes story
- Festival season preview (if applicable)
- CTA (event, product, engagement)

Draft in Mailchimp, send test to CEO for approval by 09:00."

  echo "" | tee -a "$LOG_FILE"
  echo "✅ Newsletter task assigned (Wednesday)" | tee -a "$LOG_FILE"
fi

# ═══════════════════════════════════════════════════════════════
# VIDEO (if Tuesday)
# ═══════════════════════════════════════════════════════════════

if [ "$DAY_OF_WEEK" -eq 2 ]; then
  echo "" | tee -a "$LOG_FILE"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" | tee -a "$LOG_FILE"
  echo "▶ STEP 4: Tuesday Video Script Day" | tee -a "$LOG_FILE"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" | tee -a "$LOG_FILE"

  send_message "video" "It's Tuesday - Video script day! 🎬

Write scripts for this week's video content:
1. TikTok tutorial (15-30 sec) - cocktail recipe
2. Instagram Reel (30-60 sec) - party vibes
3. YouTube short (if applicable)

Focus:
- Trending audio (check Strategist input)
- Quick cuts, high energy
- Mixology hack or party tip
- Brand integration (subtle)

Save scripts to ~/.lavish-pilot/content/published/videos/

Target: 3 scripts by 14:00."

  echo "" | tee -a "$LOG_FILE"
  echo "✅ Video script task assigned (Tuesday)" | tee -a "$LOG_FILE"
fi

# ═══════════════════════════════════════════════════════════════
# SUMMARY
# ═══════════════════════════════════════════════════════════════

echo "" | tee -a "$LOG_FILE"
echo "════════════════════════════════════════════════════════════" | tee -a "$LOG_FILE"
echo "✅ DAILY AUTOMATION COMPLETE" | tee -a "$LOG_FILE"
echo "════════════════════════════════════════════════════════════" | tee -a "$LOG_FILE"
echo "" | tee -a "$LOG_FILE"
echo "📋 Summary:" | tee -a "$LOG_FILE"
echo "  - Morning briefings sent to CEO, Analyst, Strategist" | tee -a "$LOG_FILE"
echo "  - Content tasks assigned to Copywriter, Social, Designer" | tee -a "$LOG_FILE"
echo "  - Monitoring setup for PM, SEO" | tee -a "$LOG_FILE"

if [ "$DAY_OF_WEEK" -eq 3 ]; then
  echo "  - Newsletter task assigned (Wednesday)" | tee -a "$LOG_FILE"
fi

if [ "$DAY_OF_WEEK" -eq 2 ]; then
  echo "  - Video scripts task assigned (Tuesday)" | tee -a "$LOG_FILE"
fi

echo "" | tee -a "$LOG_FILE"
echo "📁 Log saved to: $LOG_FILE" | tee -a "$LOG_FILE"
echo "" | tee -a "$LOG_FILE"
echo "Next automation:" | tee -a "$LOG_FILE"
echo "  - EOD summary: 18:00 (see eod-summary.sh)" | tee -a "$LOG_FILE"
echo "  - Weekly review: Monday 09:00 (see weekly-strategy-review.sh)" | tee -a "$LOG_FILE"
echo "" | tee -a "$LOG_FILE"

# Success notification (if Telegram configured)
if [ -n "$TELEGRAM_BOT_TOKEN" ] && [ -n "$ADMIN_TELEGRAM_ID" ]; then
  curl -X POST "https://api.telegram.org/bot${TELEGRAM_BOT_TOKEN}/sendMessage" \
    -d "chat_id=${ADMIN_TELEGRAM_ID}" \
    -d "text=✅ Lavish daily automation complete ($(date '+%H:%M'))

Morning briefings sent
Content production kicked off
All agents active

Log: $LOG_FILE" \
    &>/dev/null || true
fi

echo "🎉 Have a productive day!" | tee -a "$LOG_FILE"
