# Lavish Nederland - Agent Memory Context

**Last Updated**: 2026-02-01
**Brand**: Lavish Nederland (Premium Ready-to-Drink Cocktails)
**Campaign Period**: January 2026 - Ongoing

---

## 🎯 BRAND IDENTITY & VOICE

### Core Positioning
- **Target Audience**: 18-35 year olds, urban nightlife enthusiasts, festival-goers
- **Brand Personality**: Bold, energetic, premium, inclusive, responsible
- **Price Point**: €4.50-6.00 per bottle (premium RTD category)
- **Distribution**: Supermarkets, clubs, festivals, online delivery

### Voice Guidelines
- **Language**: English ONLY (no Dutch/English mixing)
- **Tone**: Confident, energetic, aspirational but accessible
- **Key Phrases**: "The Lavish Life", "Weekend mode: ACTIVATED", "Premium vibes"
- **Avoid**: Aggressive drinking encouragement, exclusivity, elitism

---

## 📊 RECENT CONTENT PERFORMANCE (Last 30 Days)

### Top Performing Themes
1. **Weekend-vibes** (3 posts) - Avg engagement: 4.2%
2. **Mixology-tutorial** (2 posts) - Avg engagement: 5.8%
3. **Festival-prep** (2 posts) - Avg engagement: 3.9%

### Platform Insights
- **Instagram**: Reels outperform static posts 3:1
- **TikTok**: Tutorial content gets 2x saves vs party content
- **YouTube**: Longer tutorials (8-10min) have 65% completion rate
- **Facebook**: Event tie-ins drive highest engagement

### Best Posting Times
- Instagram: Thu-Sat, 18:00-21:00 CET
- TikTok: Wed-Fri, 19:00-22:00 CET
- YouTube: Tuesday uploads, 14:00 CET
- Facebook: Friday, 17:00 CET (weekend preview)

---

## 🎨 CONTENT THEMES ROTATION

### High Rotation (Post Every 7-10 Days)
- Weekend party vibes
- Festival season content
- New product launches
- Customer testimonials

### Medium Rotation (Post Every 14-21 Days)
- Mixology tutorials
- Behind-the-scenes brewery/production
- Bartender collaborations
- Recipe experiments

### Low Rotation (Post Every 30+ Days)
- Company milestones
- Sustainability initiatives
- Community partnerships
- Brand history

### Recently Used (Avoid for 7+ Days)
*Check memory/content-history.jsonl for real-time data*
- Last posted: `jq -r 'select(.timestamp >= (now - 604800 | todate)) | .theme' ~/.lavish-pilot/memory/content-history.jsonl | sort | uniq -c`

---

## ⚖️ LEGAL COMPLIANCE (MANDATORY)

### Age Restrictions
- **Netherlands Legal Age**: 18+
- **Always Include**: Age disclaimer on EVERY piece of content
- **Compliance Law**: Dutch Alcoholwet (Alcohol Licensing and Catering Act)

### Platform-Specific Disclaimers

**Instagram/Facebook Posts:**
```
---
18+ only | Drink responsibly | Don't drink and drive
Enjoy Lavish responsibly 🍸
```

**TikTok Videos:**
- Video overlay (2 sec): "18+ ONLY"
- Caption: "18+ | Drink responsibly"
- Pinned comment: "⚠️ This content is for adults 18+ only. Please drink responsibly and never drink and drive. Enjoy Lavish safely! 🍸"

**YouTube Videos:**
- Opening screen (5 sec): "⚠️ 18+ ONLY | DRINK RESPONSIBLY"
- Description: Full legal disclaimer with Alcoholhulp.nl resource

**Blog Posts:**
- Footer disclaimer with help resources (Alcoholhulp.nl, 088-2352500)

---

## 🚫 CONTENT QUALITY GATES

### BEFORE Publishing, Verify:
1. ✅ **Language Check**: 100% English, no Dutch words mixed in sentences
2. ✅ **Age Disclaimer**: Present on all content
3. ✅ **Duplicate Check**: Run `check-duplicate.sh <platform> <theme>`
4. ✅ **Responsible Messaging**: No excessive drinking encouragement
5. ✅ **Brand Alignment**: Matches premium, inclusive positioning
6. ✅ **Visual Quality**: High-res images, professional editing
7. ✅ **Call-to-Action**: Clear, measurable CTA in caption

### Automatic Rejection Triggers
- ❌ Dutch words mixed with English in same sentence
- ❌ Missing age disclaimer
- ❌ Same theme posted <7 days ago on same platform
- ❌ Encouraging excessive/binge drinking
- ❌ Showing people under 18
- ❌ Low-quality visuals (blurry, poorly lit)

---

## 🎬 SUCCESSFUL CONTENT FORMULAS

### Instagram Reel Formula (15-30 sec)
1. **Hook** (0-3 sec): Visual impact + question/statement
2. **Value** (4-20 sec): Tutorial, tip, or entertainment
3. **CTA** (21-30 sec): Tag friends, comment, save
4. **Always**: Trending audio + text overlay + age disclaimer

### TikTok Tutorial Formula (60 sec)
1. **Pattern Interrupt** (0-2 sec): "Stop scrolling!"
2. **Promise** (3-5 sec): What they'll learn
3. **Steps** (6-50 sec): 3-5 clear steps with text overlay
4. **Payoff** (51-60 sec): Final result + CTA

### YouTube Script Formula (8-10 min)
1. **Opening** (0-45 sec): Hook + what's covered + age warning
2. **Content** (1-8 min): 3-5 recipes/tips with clear steps
3. **Engagement** (Throughout): Questions, polls, "comment below"
4. **Outro** (8-10 min): Recap + subscribe CTA + legal disclaimer

### Blog Post Formula (1,500-2,500 words)
1. **SEO Title**: Include primary keyword + number/benefit
2. **Opening**: Problem statement + solution preview
3. **Subheadings**: H2/H3 structure, keyword-rich
4. **Actionable Content**: Step-by-step, bullet lists, visuals
5. **Conclusion**: Recap + CTA + legal disclaimer

---

## 📈 CONTENT CALENDAR PRINCIPLES

### Weekly Content Mix (Target)
- 40% Educational (tutorials, tips, recipes)
- 30% Lifestyle (parties, festivals, events)
- 20% Product-focused (features, launches, promos)
- 10% Community (UGC, testimonials, engagement)

### Platform Distribution
- **Instagram**: 5-7 posts/week (3 Reels + 2 Feed + 2 Stories)
- **TikTok**: 4-5 videos/week (mix of quick tips + tutorials)
- **YouTube**: 1 video/week (Tuesday 14:00 upload)
- **Facebook**: 3-4 posts/week (event focus, community)
- **Blog**: 1-2 posts/month (SEO-optimized long-form)

---

## 🤝 BRAND PARTNERSHIPS & COLLABORATIONS

### Active Partnerships
- **Festivals**: Awakenings, Dekmantel, Down The Rabbit Hole
- **Bartenders**: Amsterdam Cocktail Week collaborators
- **Influencers**: Micro-influencers (10K-100K followers, nightlife/food)

### Partnership Content Guidelines
- Always tag partners + credit creators
- Ensure partner content meets our quality gates
- Co-branded content needs both disclaimers (ours + theirs)
- UGC requires explicit consent + age verification

---

## 💾 MEMORY SYSTEM INTEGRATION

### Real-Time Content History
**Location**: `~/.lavish-pilot/memory/content-history.jsonl`

**Query Recent Posts**:
```bash
# Last 7 days of content
tail -n 50 ~/.lavish-pilot/memory/content-history.jsonl | jq -s 'map(select(.timestamp >= (now - 604800 | todate)))'

# Most used themes this month
jq -r 'select(.timestamp >= (now - 2592000 | todate)) | .theme' ~/.lavish-pilot/memory/content-history.jsonl | sort | uniq -c | sort -rn
```

### Agent Context Files
Each agent has persistent context: `~/.lavish-pilot/memory/agent-context/<agent-name>.json`

**Before Creating Content**:
1. Check your agent context for recent themes used
2. Review underused themes: `node -e "import('./skills/content-memory.mjs').then(m => console.log(JSON.stringify(m.getUnderusedThemes('${AGENT_NAME}'), null, 2)))"`
3. Run duplicate check: `./scripts/check-duplicate.sh <platform> <theme>`

---

## 🎯 CURRENT CAMPAIGN OBJECTIVES (Q1 2026)

### Primary KPIs
- **Follower Growth**: +25% across all platforms (Jan-Mar 2026)
- **Engagement Rate**: Maintain >3.5% average
- **Video Completion**: >55% for Reels/TikToks
- **Website Traffic**: +40% from social referrals
- **UGC Volume**: 50+ tagged posts/month

### Content Priorities This Quarter
1. Festival season prep content (Feb-Mar)
2. New flavor launch campaign (March)
3. Bartender collaboration series (Ongoing)
4. YouTube channel growth (1K subscribers by March)

---

## 🛠️ AGENT-SPECIFIC REMINDERS

### Social Manager
- Always check duplicate status before scheduling
- Prioritize underused themes
- Balance educational vs lifestyle content
- Track engagement patterns weekly

### Copywriter
- English ONLY (quality gate #1)
- Match brand voice (energetic, premium, accessible)
- Every piece needs age disclaimer
- CTA in every caption

### Video Creator
- Tutorial content outperforms party content
- Text overlays boost completion rates
- Age disclaimer must be visible (2+ sec)
- Trending audio = 2x reach

### SEO Specialist
- Target keywords: "ready-to-drink cocktails", "premium RTD", "best cocktails Netherlands"
- Long-form content: 1,500-2,500 words
- Blog footer always includes legal disclaimer
- Internal linking to product pages

---

## 🔄 LAST UPDATED CONTEXT

**Recent Wins**:
- Instagram Reel "Weekend Mode" hit 12K views (2x avg)
- TikTok tutorial "3-Ingredient Mojito" saved 450 times
- YouTube subscriber count: 487 (+23% this month)

**Recent Challenges**:
- Facebook organic reach declining (avg 2.1% vs 3.2% last month)
- Need more UGC volume (32 posts/month vs 50 target)

**Upcoming Events**:
- Amsterdam Cocktail Week (Feb 14-20) - content series planned
- New flavor launch (Passion Fruit Margarita) - March 1
- Awakenings Festival sponsorship - March 15

---

**END OF MEMORY CONTEXT**

*This file is automatically loaded by Clawdbot agents at session start. Update this file when brand strategy, performance insights, or compliance requirements change.*
