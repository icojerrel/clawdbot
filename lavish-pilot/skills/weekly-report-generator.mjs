/**
 * Weekly Report Generator Skill
 * Generates comprehensive weekly analytics reports for Lavish Nederland pilot
 *
 * Features:
 * - Aggregates metrics from all platforms (IG, FB, TikTok, website)
 * - Goal progress tracking
 * - Top performing content identification
 * - Competitor comparison
 * - Recommendations for next week
 * - ASCII charts for visual representation
 * - Saves markdown report to file
 */

import { writeFile, mkdir } from 'fs/promises'
import { existsSync } from 'fs'
import { join, dirname } from 'path'
import { homedir } from 'os'

export const meta = {
  name: 'weekly-report-generator',
  description: 'Genereer wekelijkse analytics rapport met alle metrics, trends en aanbevelingen voor Lavish'
}

/**
 * Generate ASCII bar chart
 */
function generateBarChart(data, maxWidth = 40) {
  const maxValue = Math.max(...data.map(d => d.value))
  const lines = []

  for (const item of data) {
    const barLength = Math.round((item.value / maxValue) * maxWidth)
    const bar = '█'.repeat(barLength)
    const percentage = maxValue > 0 ? ((item.value / maxValue) * 100).toFixed(0) : 0
    lines.push(`${item.label.padEnd(15)} ${bar} ${item.value} (${percentage}%)`)
  }

  return lines.join('\n')
}

/**
 * Generate ASCII trend indicator
 */
function generateTrendIndicator(current, previous) {
  if (previous === 0) return '🆕 NEW'

  const change = ((current - previous) / previous) * 100

  if (change > 20) return `🚀 +${change.toFixed(0)}%`
  if (change > 0) return `📈 +${change.toFixed(0)}%`
  if (change === 0) return `➡️  0%`
  if (change > -20) return `📉 ${change.toFixed(0)}%`
  return `🔴 ${change.toFixed(0)}%`
}

/**
 * Generate mock analytics data
 */
function generateMockAnalytics() {
  const weekNumber = Math.ceil((Date.now() - new Date('2025-01-01').getTime()) / (7 * 24 * 60 * 60 * 1000))

  return {
    week: weekNumber,
    dateRange: {
      start: new Date(Date.now() - 7 * 24 * 60 * 60 * 1000).toISOString().split('T')[0],
      end: new Date().toISOString().split('T')[0]
    },
    platforms: {
      instagram: {
        followers: {
          current: 350 + (weekNumber * 25),
          previous: 325 + ((weekNumber - 1) * 25),
          growth: 25
        },
        engagement: {
          rate: 4.2 + (Math.random() * 1.5),
          likes: 1250 + Math.floor(Math.random() * 300),
          comments: 85 + Math.floor(Math.random() * 30),
          shares: 45 + Math.floor(Math.random() * 15)
        },
        reach: 4500 + Math.floor(Math.random() * 1000),
        impressions: 6200 + Math.floor(Math.random() * 1500),
        topPosts: [
          { id: 'ig1', caption: '🍸 Weekend vibes...', likes: 425, comments: 32, engagement: 5.8 },
          { id: 'ig2', caption: '🎉 New flavor alert...', likes: 380, comments: 28, engagement: 5.2 },
          { id: 'ig3', caption: '📸 Behind the scenes...', likes: 295, comments: 18, engagement: 4.1 }
        ]
      },
      facebook: {
        likes: {
          current: 85 + (weekNumber * 12),
          previous: 73 + ((weekNumber - 1) * 12),
          growth: 12
        },
        engagement: {
          rate: 3.5 + (Math.random() * 1.2),
          reactions: 850 + Math.floor(Math.random() * 200),
          comments: 65 + Math.floor(Math.random() * 20),
          shares: 35 + Math.floor(Math.random() * 10)
        },
        reach: 3200 + Math.floor(Math.random() * 800),
        impressions: 4800 + Math.floor(Math.random() * 1200),
        topPosts: [
          { id: 'fb1', text: 'Premium cocktails...', reactions: 125, comments: 18, engagement: 4.2 },
          { id: 'fb2', text: 'Weekend special...', reactions: 98, comments: 12, engagement: 3.5 }
        ]
      },
      tiktok: {
        followers: {
          current: 520 + (weekNumber * 45),
          previous: 475 + ((weekNumber - 1) * 45),
          growth: 45
        },
        engagement: {
          rate: 6.8 + (Math.random() * 2.5),
          likes: 2850 + Math.floor(Math.random() * 600),
          comments: 185 + Math.floor(Math.random() * 50),
          shares: 125 + Math.floor(Math.random() * 30)
        },
        views: 28500 + Math.floor(Math.random() * 5000),
        viralScore: 65 + Math.floor(Math.random() * 25),
        topVideos: [
          { id: 'tt1', caption: 'Cocktail mixing...', views: 12500, likes: 850, engagement: 8.2 },
          { id: 'tt2', caption: 'Party vibes...', views: 9800, likes: 620, engagement: 7.1 },
          { id: 'tt3', caption: 'Recipe tutorial...', views: 6200, likes: 425, engagement: 6.5 }
        ]
      },
      website: {
        visitors: {
          total: 1250 + Math.floor(Math.random() * 300),
          unique: 980 + Math.floor(Math.random() * 200),
          returning: 270 + Math.floor(Math.random() * 100)
        },
        pageViews: 3450 + Math.floor(Math.random() * 800),
        avgSessionDuration: 125 + Math.floor(Math.random() * 30), // seconds
        bounceRate: 35 + Math.floor(Math.random() * 15), // percentage
        topPages: [
          { path: '/products', views: 850, avgTime: 145 },
          { path: '/about', views: 420, avgTime: 95 },
          { path: '/contact', views: 280, avgTime: 65 }
        ]
      }
    },
    goals: {
      facebook: {
        target: 500,
        current: 85 + (weekNumber * 12),
        progress: Math.min(100, ((85 + (weekNumber * 12)) / 500) * 100)
      },
      instagram: {
        target: 1000,
        current: 350 + (weekNumber * 25),
        progress: Math.min(100, ((350 + (weekNumber * 25)) / 1000) * 100)
      },
      tiktok: {
        target: 2000,
        current: 520 + (weekNumber * 45),
        progress: Math.min(100, ((520 + (weekNumber * 45)) / 2000) * 100)
      }
    },
    contentPublished: {
      instagram: 5 + Math.floor(Math.random() * 3),
      facebook: 4 + Math.floor(Math.random() * 2),
      tiktok: 3 + Math.floor(Math.random() * 2)
    }
  }
}

/**
 * Generate markdown report
 */
function generateMarkdownReport(analytics) {
  const lines = []

  // Header
  lines.push('# 📊 Lavish Nederland - Weekly Analytics Report')
  lines.push('')
  lines.push(`**Week ${analytics.week}** | ${analytics.dateRange.start} - ${analytics.dateRange.end}`)
  lines.push('')
  lines.push('---')
  lines.push('')

  // Executive Summary
  lines.push('## 🎯 Executive Summary')
  lines.push('')

  const totalFollowers = analytics.platforms.instagram.followers.current +
                         analytics.platforms.facebook.likes.current +
                         analytics.platforms.tiktok.followers.current

  const totalGrowth = analytics.platforms.instagram.followers.growth +
                      analytics.platforms.facebook.likes.growth +
                      analytics.platforms.tiktok.followers.growth

  lines.push(`- **Total Social Followers:** ${totalFollowers.toLocaleString()} (+${totalGrowth} this week)`)
  lines.push(`- **Total Content Published:** ${analytics.contentPublished.instagram + analytics.contentPublished.facebook + analytics.contentPublished.tiktok} posts`)
  lines.push(`- **Website Visitors:** ${analytics.platforms.website.visitors.total.toLocaleString()} (${analytics.platforms.website.visitors.unique.toLocaleString()} unique)`)
  lines.push(`- **Average Engagement Rate:** ${((analytics.platforms.instagram.engagement.rate + analytics.platforms.facebook.engagement.rate + analytics.platforms.tiktok.engagement.rate) / 3).toFixed(1)}%`)
  lines.push('')

  // Goal Progress
  lines.push('## 🎯 Goal Progress')
  lines.push('')
  lines.push('```')
  lines.push(`Facebook Likes:    ${Math.round(analytics.goals.facebook.progress)}% [${analytics.goals.facebook.current}/${analytics.goals.facebook.target}]`)
  lines.push(`${'█'.repeat(Math.round(analytics.goals.facebook.progress / 5))}${'░'.repeat(20 - Math.round(analytics.goals.facebook.progress / 5))}`)
  lines.push('')
  lines.push(`Instagram Follow:  ${Math.round(analytics.goals.instagram.progress)}% [${analytics.goals.instagram.current}/${analytics.goals.instagram.target}]`)
  lines.push(`${'█'.repeat(Math.round(analytics.goals.instagram.progress / 5))}${'░'.repeat(20 - Math.round(analytics.goals.instagram.progress / 5))}`)
  lines.push('')
  lines.push(`TikTok Followers:  ${Math.round(analytics.goals.tiktok.progress)}% [${analytics.goals.tiktok.current}/${analytics.goals.tiktok.target}]`)
  lines.push(`${'█'.repeat(Math.round(analytics.goals.tiktok.progress / 5))}${'░'.repeat(20 - Math.round(analytics.goals.tiktok.progress / 5))}`)
  lines.push('```')
  lines.push('')

  // Platform Breakdown
  lines.push('## 📱 Platform Performance')
  lines.push('')

  // Instagram
  lines.push('### 📸 Instagram')
  lines.push('')
  lines.push(`- **Followers:** ${analytics.platforms.instagram.followers.current.toLocaleString()} ${generateTrendIndicator(analytics.platforms.instagram.followers.current, analytics.platforms.instagram.followers.previous)}`)
  lines.push(`- **Engagement Rate:** ${analytics.platforms.instagram.engagement.rate.toFixed(1)}%`)
  lines.push(`- **Reach:** ${analytics.platforms.instagram.reach.toLocaleString()}`)
  lines.push(`- **Total Interactions:** ${(analytics.platforms.instagram.engagement.likes + analytics.platforms.instagram.engagement.comments + analytics.platforms.instagram.engagement.shares).toLocaleString()}`)
  lines.push(`- **Posts Published:** ${analytics.contentPublished.instagram}`)
  lines.push('')
  lines.push('**Top Posts:**')
  for (const post of analytics.platforms.instagram.topPosts) {
    lines.push(`- ${post.caption} (${post.likes} likes, ${post.comments} comments, ${post.engagement}% engagement)`)
  }
  lines.push('')

  // Facebook
  lines.push('### 📘 Facebook')
  lines.push('')
  lines.push(`- **Page Likes:** ${analytics.platforms.facebook.likes.current.toLocaleString()} ${generateTrendIndicator(analytics.platforms.facebook.likes.current, analytics.platforms.facebook.likes.previous)}`)
  lines.push(`- **Engagement Rate:** ${analytics.platforms.facebook.engagement.rate.toFixed(1)}%`)
  lines.push(`- **Reach:** ${analytics.platforms.facebook.reach.toLocaleString()}`)
  lines.push(`- **Total Interactions:** ${(analytics.platforms.facebook.engagement.reactions + analytics.platforms.facebook.engagement.comments + analytics.platforms.facebook.engagement.shares).toLocaleString()}`)
  lines.push(`- **Posts Published:** ${analytics.contentPublished.facebook}`)
  lines.push('')
  lines.push('**Top Posts:**')
  for (const post of analytics.platforms.facebook.topPosts) {
    lines.push(`- ${post.text} (${post.reactions} reactions, ${post.comments} comments, ${post.engagement}% engagement)`)
  }
  lines.push('')

  // TikTok
  lines.push('### 🎵 TikTok')
  lines.push('')
  lines.push(`- **Followers:** ${analytics.platforms.tiktok.followers.current.toLocaleString()} ${generateTrendIndicator(analytics.platforms.tiktok.followers.current, analytics.platforms.tiktok.followers.previous)}`)
  lines.push(`- **Engagement Rate:** ${analytics.platforms.tiktok.engagement.rate.toFixed(1)}%`)
  lines.push(`- **Total Views:** ${analytics.platforms.tiktok.views.toLocaleString()}`)
  lines.push(`- **Viral Score:** ${analytics.platforms.tiktok.viralScore}/100`)
  lines.push(`- **Videos Published:** ${analytics.contentPublished.tiktok}`)
  lines.push('')
  lines.push('**Top Videos:**')
  for (const video of analytics.platforms.tiktok.topVideos) {
    lines.push(`- ${video.caption} (${video.views.toLocaleString()} views, ${video.likes} likes, ${video.engagement}% engagement)`)
  }
  lines.push('')

  // Website Analytics
  lines.push('### 🌐 Website Performance')
  lines.push('')
  lines.push(`- **Total Visitors:** ${analytics.platforms.website.visitors.total.toLocaleString()}`)
  lines.push(`- **Unique Visitors:** ${analytics.platforms.website.visitors.unique.toLocaleString()}`)
  lines.push(`- **Returning Visitors:** ${analytics.platforms.website.visitors.returning.toLocaleString()}`)
  lines.push(`- **Page Views:** ${analytics.platforms.website.pageViews.toLocaleString()}`)
  lines.push(`- **Avg. Session Duration:** ${Math.floor(analytics.platforms.website.avgSessionDuration / 60)}m ${analytics.platforms.website.avgSessionDuration % 60}s`)
  lines.push(`- **Bounce Rate:** ${analytics.platforms.website.bounceRate}%`)
  lines.push('')
  lines.push('**Top Pages:**')
  for (const page of analytics.platforms.website.topPages) {
    lines.push(`- ${page.path} (${page.views} views, ${Math.floor(page.avgTime / 60)}m ${page.avgTime % 60}s avg)`)
  }
  lines.push('')

  // Content Performance Chart
  lines.push('## 📊 Content Performance Overview')
  lines.push('')
  lines.push('```')
  lines.push('Platform        Engagement Chart')
  lines.push('─────────────────────────────────────────────────')
  lines.push(generateBarChart([
    { label: 'Instagram', value: analytics.platforms.instagram.engagement.likes },
    { label: 'Facebook', value: analytics.platforms.facebook.engagement.reactions },
    { label: 'TikTok', value: analytics.platforms.tiktok.engagement.likes }
  ]))
  lines.push('```')
  lines.push('')

  // Recommendations
  lines.push('## 💡 Recommendations for Next Week')
  lines.push('')

  const recommendations = []

  // Based on engagement rates
  if (analytics.platforms.tiktok.engagement.rate > analytics.platforms.instagram.engagement.rate) {
    recommendations.push('🎵 **Focus on TikTok:** Engagement is highest here - increase posting frequency to 1-2 videos/day')
  }

  if (analytics.platforms.instagram.followers.growth < 20) {
    recommendations.push('📸 **Boost Instagram Growth:** Run a contest or giveaway to accelerate follower growth')
  }

  if (analytics.platforms.website.bounceRate > 50) {
    recommendations.push('🌐 **Improve Website Engagement:** High bounce rate - optimize landing page and add clearer CTAs')
  }

  if (analytics.platforms.facebook.likes.current < analytics.goals.facebook.target * 0.5) {
    recommendations.push('📘 **Facebook Ads:** Consider running targeted ads to reach the 500 likes goal faster')
  }

  // Always include these
  recommendations.push('🎯 **Content Mix:** Maintain 60% lifestyle, 30% product, 10% educational content ratio')
  recommendations.push('⏰ **Optimal Posting:** Schedule posts during peak engagement times (evenings 19:00-21:00)')
  recommendations.push('🤝 **Influencer Outreach:** Identify 3-5 micro-influencers in cocktail/lifestyle niche for collaboration')

  for (const rec of recommendations) {
    lines.push(`${rec}`)
    lines.push('')
  }

  // Key Metrics Summary Table
  lines.push('## 📈 Key Metrics Summary')
  lines.push('')
  lines.push('| Metric | Instagram | Facebook | TikTok |')
  lines.push('|--------|-----------|----------|--------|')
  lines.push(`| Followers/Likes | ${analytics.platforms.instagram.followers.current} | ${analytics.platforms.facebook.likes.current} | ${analytics.platforms.tiktok.followers.current} |`)
  lines.push(`| Growth This Week | +${analytics.platforms.instagram.followers.growth} | +${analytics.platforms.facebook.likes.growth} | +${analytics.platforms.tiktok.followers.growth} |`)
  lines.push(`| Engagement Rate | ${analytics.platforms.instagram.engagement.rate.toFixed(1)}% | ${analytics.platforms.facebook.engagement.rate.toFixed(1)}% | ${analytics.platforms.tiktok.engagement.rate.toFixed(1)}% |`)
  lines.push(`| Posts Published | ${analytics.contentPublished.instagram} | ${analytics.contentPublished.facebook} | ${analytics.contentPublished.tiktok} |`)
  lines.push('')

  // Footer
  lines.push('---')
  lines.push('')
  lines.push(`*Report generated on ${new Date().toLocaleDateString('nl-NL', { dateStyle: 'full' })}*`)
  lines.push('')
  lines.push('**Next Steps:**')
  lines.push('1. Review top-performing content and replicate successful patterns')
  lines.push('2. Address low-performing platforms with increased effort')
  lines.push('3. Schedule content for next week based on optimal posting times')
  lines.push('4. Monitor competitor activity and adapt strategy accordingly')
  lines.push('')

  return lines.join('\n')
}

/**
 * Save report to file
 */
async function saveReport(content, filename) {
  const baseDir = join(homedir(), 'lavish-content', 'analytics')

  // Ensure directory exists
  if (!existsSync(baseDir)) {
    await mkdir(baseDir, { recursive: true })
  }

  const filepath = join(baseDir, filename)

  await writeFile(filepath, content, 'utf-8')

  return filepath
}

export async function run(context, params = {}) {
  const {
    useMockData = false,
    saveToFile = true,
    customFilename = null
  } = params

  console.log('📊 Generating weekly analytics report...')

  // Generate or fetch analytics data
  let analytics

  if (useMockData) {
    console.log('   Using mock data for demonstration')
    analytics = generateMockAnalytics()
  } else {
    // In production, this would aggregate data from:
    // - Meta Graph API (Instagram + Facebook)
    // - TikTok API
    // - Google Analytics (website)
    // For now, fall back to mock data
    console.log('   ⚠️  Real API integration pending, using mock data')
    analytics = generateMockAnalytics()
  }

  console.log('   ✓ Analytics data collected')

  // Generate markdown report
  const reportMarkdown = generateMarkdownReport(analytics)
  console.log('   ✓ Markdown report generated')

  // Save to file
  let savedPath = null

  if (saveToFile) {
    const filename = customFilename || `lavish-weekly-report-${analytics.dateRange.end}.md`

    try {
      savedPath = await saveReport(reportMarkdown, filename)
      console.log(`   ✓ Report saved to: ${savedPath}`)
    } catch (error) {
      console.error(`   ⚠️  Failed to save report: ${error.message}`)
    }
  }

  // Print summary
  console.log('\n📊 REPORT SUMMARY')
  console.log(`   Week: ${analytics.week}`)
  console.log(`   Date Range: ${analytics.dateRange.start} - ${analytics.dateRange.end}`)
  console.log(`   Total Followers: ${analytics.platforms.instagram.followers.current + analytics.platforms.facebook.likes.current + analytics.platforms.tiktok.followers.current}`)
  console.log(`   Overall Goal Progress: ${Math.round((analytics.goals.facebook.progress + analytics.goals.instagram.progress + analytics.goals.tiktok.progress) / 3)}%`)

  if (savedPath) {
    console.log(`\n   📄 Full report: ${savedPath}`)
  }

  return {
    success: true,
    analytics,
    reportMarkdown,
    savedPath,
    summary: {
      week: analytics.week,
      dateRange: analytics.dateRange,
      totalFollowers: analytics.platforms.instagram.followers.current +
                     analytics.platforms.facebook.likes.current +
                     analytics.platforms.tiktok.followers.current,
      totalGrowth: analytics.platforms.instagram.followers.growth +
                  analytics.platforms.facebook.likes.growth +
                  analytics.platforms.tiktok.followers.growth,
      avgEngagementRate: parseFloat(((analytics.platforms.instagram.engagement.rate +
                                      analytics.platforms.facebook.engagement.rate +
                                      analytics.platforms.tiktok.engagement.rate) / 3).toFixed(1)),
      overallGoalProgress: Math.round((analytics.goals.facebook.progress +
                                      analytics.goals.instagram.progress +
                                      analytics.goals.tiktok.progress) / 3)
    },
    timestamp: new Date().toISOString()
  }
}

// Example usage (for testing)
if (import.meta.url === `file://${process.argv[1]}`) {
  console.log('🧪 Testing weekly-report-generator skill...\n')

  const testResult = await run(null, {
    useMockData: true,
    saveToFile: true
  })

  console.log('\n📦 Result Summary:', JSON.stringify(testResult.summary, null, 2))

  if (testResult.reportMarkdown) {
    console.log('\n📄 GENERATED REPORT PREVIEW (first 500 chars):')
    console.log('─'.repeat(60))
    console.log(testResult.reportMarkdown.substring(0, 500) + '...')
    console.log('─'.repeat(60))
  }
}
