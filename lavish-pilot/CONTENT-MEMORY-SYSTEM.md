# Content Memory & Tracking System - Lavish Nederland

**Purpose:** Prevent duplicate content, ensure diversity, track what's been posted
**Owner:** CEO Agent + Project Manager Agent
**Status:** Active System

---

## 🧠 PROBLEM STATEMENT

**Without Memory System:**
- ❌ Agents repeat same content ideas
- ❌ Same Instagram post variations every week
- ❌ No tracking of what worked/what didn't
- ❌ No content history = no strategic planning
- ❌ Risk of posting duplicate content to same audience

**With Memory System:**
- ✅ Track every piece of content posted
- ✅ Prevent duplicates on same channel
- ✅ Enable smart content rotation
- ✅ Cross-platform optimization (repost TikTok to Reels, etc.)
- ✅ Performance tracking per content piece
- ✅ Agent context awareness

---

## 📂 CONTENT TRACKING DATABASE

### Location
```
/root/.lavish-pilot/memory/
├── content-history.jsonl         # All published content log
├── content-ideas-pool.json       # Ideas bank (not yet used)
├── performance-cache.json        # Quick performance lookup
├── agent-context/                # Per-agent memory
│   ├── social-manager.json
│   ├── copywriter.json
│   ├── video-creator.json
│   └── [other agents]
└── platform-state/               # Per-platform tracking
    ├── instagram.json
    ├── tiktok.json
    ├── facebook.json
    └── youtube.json
```

---

## 📝 CONTENT HISTORY LOG (JSONL Format)

**File:** `memory/content-history.jsonl`

**Format:** One JSON object per line (append-only log)

**Schema:**
```json
{
  "id": "unique-content-id",
  "timestamp": "2026-01-26T19:00:00Z",
  "platform": "instagram",
  "type": "feed_post",
  "agent": "social-manager",
  "theme": "weekend-party-vibes",
  "caption_hash": "sha256-hash-of-caption",
  "media_type": "photo",
  "status": "published",
  "url": "https://instagram.com/p/...",
  "metrics": {
    "likes": 0,
    "comments": 0,
    "shares": 0,
    "saves": 0,
    "reach": 0
  },
  "tags": ["weekend", "party", "lavish-bottle"],
  "content_fingerprint": "weekend-vibes-rooftop-bar-sunset"
}
```

**Example Entry:**
```json
{"id":"ig-post-20260126-001","timestamp":"2026-01-26T19:00:00Z","platform":"instagram","type":"feed_post","agent":"social-manager","theme":"weekend-party-vibes","caption_hash":"e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855","media_type":"photo","status":"published","url":"https://instagram.com/p/abc123","metrics":{"likes":425,"comments":32,"shares":8,"saves":15,"reach":4687},"tags":["weekend","party","lavish-bottle","rooftop"],"content_fingerprint":"weekend-vibes-rooftop-bar-sunset"}
```

**Why JSONL?**
- Append-only (no file locking issues)
- Each line = complete record
- Easy to grep/parse
- Scales to millions of entries
- No database overhead

---

## 🎯 CONTENT IDEAS POOL

**File:** `memory/content-ideas-pool.json`

**Purpose:** Bank of unused content ideas to prevent repetition

**Schema:**
```json
{
  "ideas": [
    {
      "id": "idea-001",
      "created": "2026-01-26T10:00:00Z",
      "theme": "mixology-tutorial",
      "platform": "tiktok",
      "title": "5-second lime squeeze hack",
      "description": "Show how to squeeze max juice from lime",
      "status": "unused",
      "priority": "high",
      "estimated_views": "50K-100K",
      "tags": ["tutorial", "hack", "mixology"]
    },
    {
      "id": "idea-002",
      "created": "2026-01-26T10:15:00Z",
      "theme": "behind-the-scenes",
      "platform": "instagram",
      "title": "How Lavish bottles are designed",
      "description": "Behind-the-scenes production",
      "status": "used",
      "used_date": "2026-01-27T15:00:00Z",
      "post_id": "ig-post-20260127-003",
      "performance": {"likes": 380, "engagement_rate": "5.2%"},
      "tags": ["bts", "production", "design"]
    }
  ],
  "total_ideas": 2,
  "unused_count": 1,
  "used_count": 1
}
```

**Agent Workflow:**
1. Before creating content → Check ideas pool
2. Pick unused idea OR generate new one
3. Mark idea as "in-progress"
4. After publishing → Mark as "used" + link to post

---

## 🔍 DUPLICATE PREVENTION ALGORITHM

### Content Fingerprinting

**Method 1: Text Similarity (Captions)**
```javascript
// Calculate similarity between new caption and past captions
function calculateSimilarity(newCaption, historyCaptions) {
  // Use Levenshtein distance or cosine similarity
  // Threshold: >70% similar = duplicate warning
  return similarityScore;
}
```

**Method 2: Visual Similarity (Images/Videos)**
```javascript
// Hash image/video to detect near-duplicates
function generateImageHash(imageFile) {
  // Perceptual hash (pHash)
  // Different angles of same scene = similar hash
  return imageHash;
}
```

**Method 3: Theme/Topic Tracking**
```javascript
// Track themes posted per platform
{
  "instagram": {
    "weekend-vibes": {
      "last_posted": "2026-01-26",
      "count_last_30_days": 3,
      "threshold": 4  // Max per month
    },
    "mixology-tutorial": {
      "last_posted": "2026-01-20",
      "count_last_30_days": 2,
      "threshold": 8
    }
  }
}
```

### Pre-Publishing Check

**Agent runs this before posting:**

```bash
#!/bin/bash
# check-duplicate.sh

PLATFORM=$1
THEME=$2
CAPTION=$3

# 1. Check if theme posted recently
RECENT=$(jq -r ".${PLATFORM}.\"${THEME}\".last_posted" memory/platform-state/${PLATFORM}.json)
DAYS_AGO=$(( ($(date +%s) - $(date -d "$RECENT" +%s)) / 86400 ))

if [ $DAYS_AGO -lt 7 ]; then
  echo "WARNING: Theme '${THEME}' posted ${DAYS_AGO} days ago on ${PLATFORM}"
  echo "Consider different theme or wait 7 days"
  exit 1
fi

# 2. Check caption similarity
SIMILAR=$(node scripts/check-caption-similarity.js "$CAPTION" "$PLATFORM")
if [ "$SIMILAR" == "true" ]; then
  echo "WARNING: Caption too similar to recent post"
  echo "Rewrite for uniqueness"
  exit 1
fi

echo "✅ Content unique - safe to post"
exit 0
```

---

## 🔄 SMART CONTENT ROTATION

### Cross-Platform Reposting Strategy

**Rule:** Content can be reposted to DIFFERENT platform after 48h

**Example Flow:**
```
Day 1: TikTok video "3-ingredient hack" → 50K views
Day 3: Repost to Instagram Reels → New audience
Day 5: Repost to Facebook → Older demographic
Day 7: Embed in blog post → SEO traffic
```

**Tracking Matrix:**
```json
{
  "content_id": "tiktok-video-001",
  "original_platform": "tiktok",
  "original_date": "2026-01-26",
  "reposts": [
    {"platform": "instagram", "date": "2026-01-28", "status": "published"},
    {"platform": "facebook", "date": "2026-01-30", "status": "published"},
    {"platform": "blog", "date": "2026-02-02", "status": "embedded"}
  ],
  "repost_eligible": ["youtube", "linkedin"]
}
```

### Variation Strategy

**Same Theme, Different Angles:**

**Week 1:** "Weekend Vibes" - Rooftop bar sunset
**Week 2:** "Weekend Vibes" - House party with friends
**Week 3:** "Weekend Vibes" - Club night energy
**Week 4:** "Weekend Vibes" - Beach party summer

**Different themes, different visuals, same core message = No duplicates**

---

## 👤 AGENT MEMORY CONTEXT

### Per-Agent Context Files

**File:** `memory/agent-context/social-manager.json`

**What Agent Remembers:**
```json
{
  "agent": "social-manager",
  "last_updated": "2026-01-26T19:00:00Z",
  "recent_posts": [
    {"id": "ig-post-001", "theme": "weekend-vibes", "performance": "good"},
    {"id": "ig-post-002", "theme": "mixology-tutorial", "performance": "excellent"}
  ],
  "content_themes_used": {
    "weekend-vibes": 3,
    "mixology-tutorial": 2,
    "behind-the-scenes": 1,
    "festival-prep": 0
  },
  "successful_patterns": [
    "Friday 19:00 posts get 2x engagement",
    "Carousel posts outperform single images",
    "Video reels get 3x reach vs photos"
  ],
  "avoid_patterns": [
    "Monday morning posts underperform",
    "Text-only posts get low engagement",
    "Product-only shots don't convert"
  ],
  "current_focus": "Festival season countdown content",
  "next_themes_to_explore": ["summer-prep", "batch-cocktails", "influencer-collabs"]
}
```

**How Agent Uses This:**
1. Before generating content → Read context file
2. Check what themes already used this month
3. Avoid repeating recent patterns
4. Prioritize underused themes
5. Learn from successful patterns

---

## 📊 PERFORMANCE TRACKING INTEGRATION

### Link Content to Metrics

**Every 24h, update performance:**

```javascript
// scripts/update-content-metrics.js

// 1. Read content-history.jsonl
// 2. For each published post (last 30 days)
// 3. Fetch metrics from platform API
// 4. Update metrics in JSONL (append new line with updated metrics)
// 5. Update performance-cache.json for quick lookups

{
  "ig-post-20260126-001": {
    "likes": 425,
    "comments": 32,
    "engagement_rate": 5.8,
    "last_updated": "2026-01-27T10:00:00Z",
    "performance_category": "good"  // poor/ok/good/excellent
  }
}
```

**Agent Decision Making:**
```javascript
// If theme performed well → Use similar angle next time
// If theme performed poorly → Try different approach or skip

if (performanceCache["weekend-vibes"].engagement_rate > 6.0) {
  console.log("Weekend-vibes content performs well - prioritize");
} else {
  console.log("Weekend-vibes underperforming - try different theme");
}
```

---

## 🛠️ IMPLEMENTATION SCRIPTS

### 1. Initialize Memory System

**Script:** `scripts/init-memory-system.sh`

```bash
#!/bin/bash

MEMORY_DIR="/root/.lavish-pilot/memory"

echo "🧠 Initializing Lavish Content Memory System..."

# Create directory structure
mkdir -p "$MEMORY_DIR/agent-context"
mkdir -p "$MEMORY_DIR/platform-state"

# Initialize content history log
touch "$MEMORY_DIR/content-history.jsonl"

# Initialize content ideas pool
cat > "$MEMORY_DIR/content-ideas-pool.json" << 'EOF'
{
  "ideas": [],
  "total_ideas": 0,
  "unused_count": 0,
  "used_count": 0
}
EOF

# Initialize performance cache
cat > "$MEMORY_DIR/performance-cache.json" << 'EOF'
{}
EOF

# Initialize platform state files
for platform in instagram tiktok facebook youtube; do
  cat > "$MEMORY_DIR/platform-state/${platform}.json" << EOF
{
  "platform": "$platform",
  "last_updated": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "total_posts": 0,
  "themes": {}
}
EOF
done

# Initialize agent context files
for agent in social-manager copywriter video-creator strategist; do
  cat > "$MEMORY_DIR/agent-context/${agent}.json" << EOF
{
  "agent": "$agent",
  "last_updated": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "recent_posts": [],
  "content_themes_used": {},
  "successful_patterns": [],
  "avoid_patterns": [],
  "current_focus": "",
  "next_themes_to_explore": []
}
EOF
done

echo "✅ Memory system initialized at $MEMORY_DIR"
echo ""
echo "Next steps:"
echo "1. Agents: Read from memory before creating content"
echo "2. Log: Append to content-history.jsonl after publishing"
echo "3. Update: Run update-metrics.sh daily"
```

---

### 2. Log Published Content

**Script:** `scripts/log-content.sh`

```bash
#!/bin/bash
# Usage: ./log-content.sh <platform> <type> <theme> <url>

PLATFORM=$1
TYPE=$2
THEME=$3
URL=$4
AGENT=${5:-"social-manager"}

MEMORY_DIR="/root/.lavish-pilot/memory"
TIMESTAMP=$(date -u +%Y-%m-%dT%H:%M:%SZ)
ID="${PLATFORM}-post-$(date +%Y%m%d)-$(openssl rand -hex 3)"

# Create JSON entry
cat >> "$MEMORY_DIR/content-history.jsonl" << EOF
{"id":"$ID","timestamp":"$TIMESTAMP","platform":"$PLATFORM","type":"$TYPE","agent":"$AGENT","theme":"$THEME","status":"published","url":"$URL","metrics":{"likes":0,"comments":0,"shares":0,"saves":0,"reach":0},"tags":[]}
EOF

# Update platform state
PLATFORM_FILE="$MEMORY_DIR/platform-state/${PLATFORM}.json"
CURRENT_COUNT=$(jq -r '.total_posts' "$PLATFORM_FILE")
NEW_COUNT=$((CURRENT_COUNT + 1))

jq ".total_posts = $NEW_COUNT | .last_updated = \"$TIMESTAMP\" | .themes.\"$THEME\".last_posted = \"$TIMESTAMP\" | .themes.\"$THEME\".count_last_30_days += 1" "$PLATFORM_FILE" > /tmp/platform-state.json
mv /tmp/platform-state.json "$PLATFORM_FILE"

echo "✅ Logged content: $ID"
echo "   Platform: $PLATFORM"
echo "   Theme: $THEME"
echo "   URL: $URL"
```

---

### 3. Check for Duplicates Before Posting

**Script:** `scripts/check-duplicate.sh`

```bash
#!/bin/bash
# Usage: ./check-duplicate.sh <platform> <theme>

PLATFORM=$1
THEME=$2
MEMORY_DIR="/root/.lavish-pilot/memory"

echo "🔍 Checking for duplicate content..."

# Check if theme posted recently on this platform
PLATFORM_FILE="$MEMORY_DIR/platform-state/${PLATFORM}.json"

if [ ! -f "$PLATFORM_FILE" ]; then
  echo "✅ No history for $PLATFORM - safe to post"
  exit 0
fi

LAST_POSTED=$(jq -r ".themes.\"$THEME\".last_posted // \"never\"" "$PLATFORM_FILE")

if [ "$LAST_POSTED" == "never" ]; then
  echo "✅ Theme '$THEME' never posted on $PLATFORM - safe to post"
  exit 0
fi

# Calculate days since last post
LAST_TIMESTAMP=$(date -d "$LAST_POSTED" +%s 2>/dev/null || echo 0)
NOW_TIMESTAMP=$(date +%s)
DAYS_AGO=$(( (NOW_TIMESTAMP - LAST_TIMESTAMP) / 86400 ))

THRESHOLD=7  # Minimum days between same theme posts

if [ $DAYS_AGO -lt $THRESHOLD ]; then
  echo "⚠️  WARNING: Theme '$THEME' posted $DAYS_AGO days ago on $PLATFORM"
  echo "   Threshold: $THRESHOLD days"
  echo "   Recommendation: Choose different theme or wait $((THRESHOLD - DAYS_AGO)) more days"
  exit 1
else
  echo "✅ Theme '$THEME' last posted $DAYS_AGO days ago - safe to post"
  exit 0
fi
```

---

### 4. Query Content History

**Script:** `scripts/query-content.sh`

```bash
#!/bin/bash
# Usage: ./query-content.sh [options]

MEMORY_DIR="/root/.lavish-pilot/memory"
HISTORY_FILE="$MEMORY_DIR/content-history.jsonl"

# Query examples
case "$1" in
  "recent")
    echo "📅 Recent posts (last 7 days):"
    cat "$HISTORY_FILE" | grep -E "2026-01-(2[0-9]|3[0-1])" | jq -r '"\(.platform) | \(.theme) | \(.timestamp)"' | tail -20
    ;;
  "platform")
    PLATFORM=$2
    echo "📱 All $PLATFORM posts:"
    cat "$HISTORY_FILE" | jq -r "select(.platform == \"$PLATFORM\") | \"\(.timestamp) | \(.theme) | \(.url)\""
    ;;
  "theme")
    THEME=$2
    echo "🎯 All '$THEME' posts:"
    cat "$HISTORY_FILE" | jq -r "select(.theme == \"$THEME\") | \"\(.platform) | \(.timestamp) | \(.url)\""
    ;;
  "stats")
    echo "📊 Content Statistics:"
    echo ""
    echo "Total posts: $(wc -l < "$HISTORY_FILE")"
    echo ""
    echo "By platform:"
    cat "$HISTORY_FILE" | jq -r '.platform' | sort | uniq -c
    echo ""
    echo "By theme:"
    cat "$HISTORY_FILE" | jq -r '.theme' | sort | uniq -c | head -10
    ;;
  *)
    echo "Usage: ./query-content.sh {recent|platform|theme|stats} [arg]"
    ;;
esac
```

---

## 🤖 AGENT INTEGRATION

### How Agents Use Memory System

**Social Media Manager Agent Workflow:**

```javascript
// 1. BEFORE creating content
const memory = readJSON('memory/agent-context/social-manager.json');
const platformState = readJSON('memory/platform-state/instagram.json');

// Check what themes used recently
const recentThemes = memory.content_themes_used;
const underusedThemes = Object.keys(recentThemes)
  .filter(theme => recentThemes[theme] < 3)  // Less than 3 times this month
  .sort((a, b) => recentThemes[a] - recentThemes[b]);

console.log(`Prioritize these themes: ${underusedThemes.join(', ')}`);

// 2. GENERATE content (using underused theme)
const newPost = generateInstagramPost({
  theme: underusedThemes[0],
  avoid_patterns: memory.avoid_patterns,
  use_patterns: memory.successful_patterns
});

// 3. CHECK for duplicates
const isDuplicate = await checkDuplicate('instagram', underusedThemes[0]);
if (isDuplicate) {
  console.log('Duplicate detected - trying different angle');
  newPost = generateInstagramPost({ theme: underusedThemes[1] });
}

// 4. AFTER publishing
await logContent({
  platform: 'instagram',
  type: 'feed_post',
  theme: underusedThemes[0],
  url: publishedURL
});

// Update agent memory
memory.recent_posts.push({id: postID, theme: underusedThemes[0]});
memory.content_themes_used[underusedThemes[0]] += 1;
writeJSON('memory/agent-context/social-manager.json', memory);
```

---

## 📈 PERFORMANCE-DRIVEN CONTENT DECISIONS

### Learning Loop

```
1. Post content → Log to memory
2. Wait 24-48h → Collect metrics
3. Analyze performance → Update performance cache
4. Agent reads cache → Learns what works
5. Generate new content → Apply learnings
6. Repeat
```

**Example Decision Tree:**

```javascript
// Agent reads performance data
const performanceCache = readJSON('memory/performance-cache.json');

// Analyze last month's content
const weekendVibePosts = Object.values(performanceCache)
  .filter(p => p.theme === 'weekend-vibes');

const avgEngagement = weekendVibePosts.reduce((sum, p) =>
  sum + p.engagement_rate, 0) / weekendVibePosts.length;

if (avgEngagement > 6.0) {
  // Weekend vibes perform well → Create more
  console.log('Weekend-vibes content is winning - prioritize this theme');
  priorityThemes.push('weekend-vibes');
} else if (avgEngagement < 3.0) {
  // Poor performance → Try different angle or reduce frequency
  console.log('Weekend-vibes underperforming - try new approach');
  avoidThemes.push('weekend-vibes');
}
```

---

## 🔒 DATA RETENTION & PRIVACY

**Retention Policy:**
- Content history: Keep forever (business intelligence)
- Performance metrics: Keep last 12 months
- Agent context: Keep last 90 days
- Ideas pool: Never delete (keep as archive)

**Backup Strategy:**
```bash
# Daily backup
tar -czf "memory-backup-$(date +%Y%m%d).tar.gz" /root/.lavish-pilot/memory/

# Weekly offsite backup
# Upload to cloud storage (encrypted)
```

---

## 📋 MAINTENANCE CHECKLIST

**Daily:**
- [ ] Update performance metrics (automated cron)
- [ ] Backup memory files
- [ ] Check agent context files updated

**Weekly:**
- [ ] Review content history for patterns
- [ ] Update ideas pool with new concepts
- [ ] Audit duplicate prevention (any slip-throughs?)

**Monthly:**
- [ ] Generate content performance report
- [ ] Archive old performance data (>12mo)
- [ ] Review and update agent successful_patterns

---

## 🚀 NEXT STEPS

**Phase 1: Setup (Today)**
- [x] Create memory system documentation
- [ ] Run init-memory-system.sh
- [ ] Test logging scripts

**Phase 2: Integration (This Week)**
- [ ] Update agent TOOLS.md with memory scripts
- [ ] Train agents to check memory before posting
- [ ] Implement duplicate check in posting workflow

**Phase 3: Automation (Next Week)**
- [ ] Automate metrics collection (daily cron)
- [ ] Set up performance analysis dashboard
- [ ] Enable cross-platform content rotation

---

**REMEMBER: Memory prevents repetition, enables learning, drives performance** 🧠✨

---

_System Owner: CEO Agent + Project Manager Agent_
_Last Updated: 2026-01-26_
_Status: Ready for Implementation_
