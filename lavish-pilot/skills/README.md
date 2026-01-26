# Lavish Nederland Pilot - Skills Library

Production-ready skills for managing the Lavish Nederland social media pilot campaign.

## Available Skills

### 1. 🎯 goal-tracker.mjs
**Track pilot goals and generate progress reports**

**Features:**
- Real-time metrics from Meta/TikTok APIs (with mock fallback)
- Progress calculation toward goals (2→500 FB likes, IG/TikTok growth)
- Weekly growth rates
- Visual progress reports

**Usage:**
```javascript
import { run } from './goal-tracker.mjs'

const result = await run(null, {
  useMockData: false,  // Set true for testing without API keys
  goals: {
    facebook: { likes: 500 },
    instagram: { followers: 1000 },
    tiktok: { followers: 2000 }
  }
})

console.log(result.report)  // Formatted progress report
```

**Environment Variables:**
- `META_ACCESS_TOKEN` - Meta Graph API token
- `META_PAGE_ID` - Facebook Page ID
- `META_INSTAGRAM_ACCOUNT_ID` - Instagram Business Account ID
- `TIKTOK_ACCESS_TOKEN` - TikTok API token

---

### 2. 📅 content-scheduler.mjs
**Schedule posts with optimal timing and conflict detection**

**Features:**
- Optimal time calculation based on engagement patterns
- Queue management (add, list, remove)
- Conflict detection (prevents double-posting within 60min)
- Platform-specific scheduling

**Usage:**
```javascript
import { run } from './content-scheduler.mjs'

// Schedule a post
const result = await run(null, {
  action: 'schedule',
  platform: 'instagram',
  content: '🍸 Weekend vibes with Lavish! #LavishNL',
  mediaUrl: 'https://example.com/image.jpg',
  targetDate: 'tomorrow'  // or 'next-week' or ISO date
})

// List scheduled posts
const queue = await run(null, {
  action: 'list',
  platform: 'instagram'  // optional filter
})

// Remove a post
await run(null, {
  action: 'remove',
  postId: 'instagram-123456'
})
```

**Optimal Posting Times:**
- Instagram: 9AM, 12PM, 5PM, 8PM (weekday) / 10AM, 2PM, 7PM (weekend)
- Facebook: 8AM, 12PM, 6PM, 9PM (weekday) / 11AM, 3PM, 8PM (weekend)
- TikTok: 7AM, 12PM, 6PM, 10PM (weekday) / 10AM, 4PM, 9PM (weekend)

---

### 3. 💬 sentiment-analyzer.mjs
**Analyze comment/DM sentiment with Dutch NLP**

**Features:**
- Sentiment classification (positive/negative/neutral)
- Urgency detection (complaints requiring immediate response)
- Theme extraction (product quality, pricing, delivery, etc.)
- Actionable insights
- Dutch + English support

**Usage:**
```javascript
import { run } from './sentiment-analyzer.mjs'

const result = await run(null, {
  comments: [
    {
      id: 'c1',
      platform: 'instagram',
      author: 'user123',
      text: 'Geweldige cocktails! Love it!',
      timestamp: new Date().toISOString()
    }
  ],
  useMockData: false  // Set true for demo data
})

console.log(result.stats)        // Overall sentiment stats
console.log(result.topThemes)    // Common discussion themes
console.log(result.actionItems)  // Prioritized action items
```

**Detected Themes:**
- `product_quality` - Taste, ingredients, freshness
- `price` - Pricing, value for money
- `delivery` - Shipping, packaging, timing
- `packaging` - Design, presentation
- `customer_service` - Support, communication

---

### 4. 🔍 competitor-tracker.mjs
**Track competitor social media performance**

**Features:**
- Fetch recent competitor posts (last 7 days)
- Analyze engagement metrics
- Identify high-performing content patterns
- Generate competitive insights and recommendations

**Usage:**
```javascript
import { run } from './competitor-tracker.mjs'

const result = await run(null, {
  platforms: ['instagram', 'tiktok'],
  daysBack: 7,
  topN: 10,
  useMockData: false  // Set true for testing
})

console.log(result.insights)          // Key competitive insights
console.log(result.recommendations)   // Strategic recommendations
console.log(result.topPosts)          // Best performing competitor posts
```

**Tracked Competitors:**
- Instagram: @cocktailcompany_nl, @premiumcocktails, @dutchcocktails
- TikTok: @cocktailvibes, @mixology_nl
- Facebook: The Cocktail Company NL, Premium Drinks Nederland

---

### 5. 📊 weekly-report-generator.mjs
**Generate comprehensive weekly analytics reports**

**Features:**
- Aggregate all platform metrics (IG, FB, TikTok, website)
- Goal progress tracking with visual bars
- Top performing content identification
- ASCII charts and trend indicators
- Recommendations for next week
- Auto-save to `~/lavish-content/analytics/`

**Usage:**
```javascript
import { run } from './weekly-report-generator.mjs'

const result = await run(null, {
  useMockData: false,
  saveToFile: true,
  customFilename: 'week-4-report.md'  // optional
})

console.log(result.summary)           // Week summary
console.log(result.savedPath)         // Path to saved report
console.log(result.reportMarkdown)    // Full markdown content
```

**Generated Report Includes:**
- Executive summary
- Goal progress bars
- Platform breakdowns (IG, FB, TikTok, Website)
- Top performing content
- Engagement charts
- Recommendations for next week
- Key metrics comparison table

**Output Location:**
`~/lavish-content/analytics/lavish-weekly-report-YYYY-MM-DD.md`

---

## Testing Skills

All skills include standalone test mode. Run directly with Node:

```bash
# Test individual skills
node goal-tracker.mjs
node content-scheduler.mjs
node sentiment-analyzer.mjs
node competitor-tracker.mjs
node weekly-report-generator.mjs
```

## Integration with Lavish Agents

These skills are designed to be used by Clawdbot agents managing the Lavish pilot:

```javascript
// In agent configuration
const agentConfig = {
  name: 'Lavish Social Manager',
  skills: [
    './lavish-pilot/skills/goal-tracker.mjs',
    './lavish-pilot/skills/content-scheduler.mjs',
    './lavish-pilot/skills/sentiment-analyzer.mjs',
    './lavish-pilot/skills/competitor-tracker.mjs',
    './lavish-pilot/skills/weekly-report-generator.mjs'
  ]
}
```

## Mock Data vs Live APIs

All skills support **mock data mode** for testing without API credentials:

```javascript
// Use mock data
const result = await run(null, { useMockData: true })

// Use live APIs (requires environment variables)
const result = await run(null, { useMockData: false })
```

**Required Environment Variables for Live Mode:**
- `META_ACCESS_TOKEN` - Meta Graph API access token
- `META_PAGE_ID` - Facebook Page ID
- `META_INSTAGRAM_ACCOUNT_ID` - Instagram Business Account ID
- `TIKTOK_ACCESS_TOKEN` - TikTok API access token
- Google Analytics API credentials (for website metrics)

## Skill Dependencies

All skills are standalone with no external npm dependencies except Node.js built-ins:
- `fs/promises` (file operations)
- `path` (path utilities)
- `os` (home directory)

## Error Handling

Each skill implements:
- Input validation with clear error messages
- API fallback to mock data when credentials missing
- Try-catch blocks around all API calls
- Graceful degradation when services unavailable

## Contributing

When adding new skills:
1. Follow the existing skill structure
2. Export `meta` with `name` and `description`
3. Implement async `run(context, params)` function
4. Include mock data fallback
5. Add JSDoc comments
6. Include example usage section
7. Test standalone before committing

---

**Created for Lavish Nederland Pilot Campaign**
*Last updated: January 25, 2026*
