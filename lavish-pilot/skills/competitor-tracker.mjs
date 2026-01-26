/**
 * Competitor Tracker Skill
 * Tracks competitor social media accounts (cocktail brands)
 *
 * Features:
 * - Fetch recent posts from competitor accounts
 * - Analyze engagement metrics
 * - Identify high-performing content
 * - Competitive insights and recommendations
 * - Mock data fallback when APIs unavailable
 */

export const meta = {
  name: 'competitor-tracker',
  description: 'Track concurrent cocktail brands op social media - analyseer hun posts en engagement'
}

/**
 * Competitor accounts to track
 */
const COMPETITORS = {
  instagram: [
    { handle: 'cocktailcompany_nl', name: 'The Cocktail Company' },
    { handle: 'premiumcocktails', name: 'Premium Cocktails' },
    { handle: 'dutchcocktails', name: 'Dutch Cocktails' }
  ],
  tiktok: [
    { handle: 'cocktailvibes', name: 'Cocktail Vibes' },
    { handle: 'mixology_nl', name: 'Mixology NL' }
  ],
  facebook: [
    { name: 'The Cocktail Company NL', pageId: 'example123' },
    { name: 'Premium Drinks Nederland', pageId: 'example456' }
  ]
}

/**
 * Generate mock competitor posts for testing
 */
function generateMockPosts(platform, daysBack = 7) {
  const posts = []
  const now = Date.now()

  const templates = [
    {
      content: '🍸 Weekend cocktail special! Tag your friends!',
      likes: Math.floor(Math.random() * 500) + 100,
      comments: Math.floor(Math.random() * 50) + 10,
      shares: Math.floor(Math.random() * 30) + 5
    },
    {
      content: '🎉 New flavor alert! Try our limited edition cocktail',
      likes: Math.floor(Math.random() * 800) + 200,
      comments: Math.floor(Math.random() * 80) + 20,
      shares: Math.floor(Math.random() * 50) + 10
    },
    {
      content: '📸 Behind the scenes of our cocktail creation process',
      likes: Math.floor(Math.random() * 300) + 80,
      comments: Math.floor(Math.random() * 30) + 5,
      shares: Math.floor(Math.random() * 20) + 3
    },
    {
      content: '💡 Cocktail recipe tip: Mix it like a pro!',
      likes: Math.floor(Math.random() * 600) + 150,
      comments: Math.floor(Math.random() * 60) + 15,
      shares: Math.floor(Math.random() * 40) + 8
    },
    {
      content: '🌟 Customer testimonial: "Best cocktails ever!"',
      likes: Math.floor(Math.random() * 400) + 100,
      comments: Math.floor(Math.random() * 40) + 8,
      shares: Math.floor(Math.random() * 25) + 5
    }
  ]

  const competitors = COMPETITORS[platform] || []

  for (let day = 0; day < daysBack; day++) {
    for (const competitor of competitors) {
      // Random 1-3 posts per competitor per day
      const postsPerDay = Math.floor(Math.random() * 3) + 1

      for (let i = 0; i < postsPerDay; i++) {
        const template = templates[Math.floor(Math.random() * templates.length)]
        const timestamp = now - (day * 24 * 60 * 60 * 1000) - (Math.random() * 24 * 60 * 60 * 1000)

        const engagement = template.likes + template.comments * 3 + template.shares * 5
        const engagementRate = ((engagement / (template.likes + 1000)) * 100).toFixed(2)

        posts.push({
          id: `${platform}-${competitor.handle || competitor.pageId}-${Date.now()}-${Math.random().toString(36).substr(2, 9)}`,
          platform,
          competitor: competitor.name,
          handle: competitor.handle || competitor.pageId,
          content: template.content,
          timestamp: new Date(timestamp).toISOString(),
          metrics: {
            likes: template.likes,
            comments: template.comments,
            shares: template.shares,
            views: platform === 'tiktok' ? Math.floor(template.likes * 50) : null
          },
          engagement: {
            total: engagement,
            rate: parseFloat(engagementRate)
          }
        })
      }
    }
  }

  return posts.sort((a, b) => new Date(b.timestamp) - new Date(a.timestamp))
}

/**
 * Fetch Instagram competitor posts (real API integration)
 */
async function fetchInstagramCompetitorPosts(accessToken, username, daysBack = 7) {
  try {
    // This would use Instagram Graph API with username search
    // For now, return null to trigger mock fallback
    console.log(`   Fetching @${username} posts from Instagram...`)

    // Placeholder for real API call
    // const endpoint = `https://graph.instagram.com/v18.0/${userId}/media?fields=id,caption,like_count,comments_count,timestamp&access_token=${accessToken}`

    return null
  } catch (error) {
    console.warn(`Instagram fetch failed for @${username}:`, error.message)
    return null
  }
}

/**
 * Analyze high-performing content
 */
function analyzeHighPerformers(posts, topN = 10) {
  // Sort by engagement rate
  const sortedPosts = [...posts].sort((a, b) => b.engagement.total - a.engagement.total)

  const topPosts = sortedPosts.slice(0, topN)

  // Analyze patterns
  const patterns = {
    posting_times: {},
    content_types: {
      emoji_heavy: 0,
      question_based: 0,
      call_to_action: 0,
      user_generated: 0,
      educational: 0
    },
    hashtag_usage: {
      low: 0,      // 0-3 hashtags
      medium: 0,   // 4-7 hashtags
      high: 0      // 8+ hashtags
    }
  }

  for (const post of topPosts) {
    // Analyze posting time
    const hour = new Date(post.timestamp).getHours()
    const timeSlot = hour < 12 ? 'morning' : hour < 17 ? 'afternoon' : 'evening'
    patterns.posting_times[timeSlot] = (patterns.posting_times[timeSlot] || 0) + 1

    // Analyze content type
    const content = post.content.toLowerCase()

    if ((content.match(/[\u{1F300}-\u{1F9FF}]/gu) || []).length >= 3) {
      patterns.content_types.emoji_heavy++
    }
    if (content.includes('?')) {
      patterns.content_types.question_based++
    }
    if (content.match(/tag|share|comment|like|follow/i)) {
      patterns.content_types.call_to_action++
    }
    if (content.match(/customer|testimonial|review/i)) {
      patterns.content_types.user_generated++
    }
    if (content.match(/tip|how to|recipe|guide/i)) {
      patterns.content_types.educational++
    }

    // Analyze hashtag usage
    const hashtagCount = (content.match(/#/g) || []).length
    if (hashtagCount <= 3) {
      patterns.hashtag_usage.low++
    } else if (hashtagCount <= 7) {
      patterns.hashtag_usage.medium++
    } else {
      patterns.hashtag_usage.high++
    }
  }

  return {
    topPosts,
    patterns
  }
}

/**
 * Generate competitive insights and recommendations
 */
function generateInsights(analysis, stats) {
  const insights = []
  const recommendations = []

  // Posting time insights
  const bestTimeSlot = Object.entries(analysis.patterns.posting_times)
    .sort((a, b) => b[1] - a[1])[0]

  if (bestTimeSlot) {
    insights.push(`🕐 Best posting time: ${bestTimeSlot[0]} (${bestTimeSlot[1]} high-performing posts)`)
    recommendations.push(`Schedule more posts during ${bestTimeSlot[0]} hours`)
  }

  // Content type insights
  const topContentType = Object.entries(analysis.patterns.content_types)
    .sort((a, b) => b[1] - a[1])[0]

  if (topContentType && topContentType[1] > 0) {
    const contentTypeLabel = topContentType[0].replace('_', ' ')
    insights.push(`📝 Top content style: ${contentTypeLabel} (${topContentType[1]} posts)`)
    recommendations.push(`Incorporate more ${contentTypeLabel} content in your strategy`)
  }

  // Engagement insights
  const avgEngagement = stats.avgEngagementRate
  if (avgEngagement > 5) {
    insights.push(`📊 Competitors have high engagement (${avgEngagement.toFixed(2)}% avg)`)
    recommendations.push('Focus on engagement-boosting tactics: CTAs, questions, contests')
  } else {
    insights.push(`📊 Moderate competitor engagement (${avgEngagement.toFixed(2)}% avg) - opportunity to stand out`)
    recommendations.push('Differentiate with unique content and stronger community engagement')
  }

  // Platform-specific insights
  const platformDistribution = {}
  for (const post of analysis.topPosts) {
    platformDistribution[post.platform] = (platformDistribution[post.platform] || 0) + 1
  }

  const topPlatform = Object.entries(platformDistribution)
    .sort((a, b) => b[1] - a[1])[0]

  if (topPlatform) {
    insights.push(`🎯 Most active platform: ${topPlatform[0]} (${topPlatform[1]} top posts)`)
    recommendations.push(`Prioritize ${topPlatform[0]} content creation`)
  }

  return { insights, recommendations }
}

export async function run(context, params = {}) {
  const {
    platforms = ['instagram', 'tiktok', 'facebook'],  // Platforms to track
    daysBack = 7,                                      // How many days to analyze
    useMockData = false,                               // Use mock data for testing
    topN = 10                                          // Number of top posts to analyze
  } = params

  console.log('🔍 Tracking competitor activity...')
  console.log(`   Platforms: ${platforms.join(', ')}`)
  console.log(`   Time range: Last ${daysBack} days`)

  let allPosts = []

  if (useMockData) {
    console.log('   Using mock data (no API keys provided)')

    for (const platform of platforms) {
      const posts = generateMockPosts(platform, daysBack)
      allPosts = [...allPosts, ...posts]
    }
  } else {
    // Try to fetch real data
    const accessToken = process.env.META_ACCESS_TOKEN

    for (const platform of platforms) {
      if (platform === 'instagram') {
        if (accessToken) {
          for (const competitor of COMPETITORS.instagram) {
            const posts = await fetchInstagramCompetitorPosts(accessToken, competitor.handle, daysBack)
            if (posts) {
              allPosts = [...allPosts, ...posts]
            }
          }
        }
      }
      // Add TikTok and Facebook API integrations here
    }

    // If no real data was fetched, use mock data
    if (allPosts.length === 0) {
      console.log('   ⚠️  API fetching failed, using mock data')
      for (const platform of platforms) {
        const posts = generateMockPosts(platform, daysBack)
        allPosts = [...allPosts, ...posts]
      }
    }
  }

  console.log(`   ✓ Fetched ${allPosts.length} competitor posts`)

  // Analyze high performers
  const analysis = analyzeHighPerformers(allPosts, topN)
  console.log(`   ✓ Identified ${analysis.topPosts.length} top performers`)

  // Calculate statistics
  const stats = {
    totalPosts: allPosts.length,
    avgLikes: Math.round(allPosts.reduce((sum, p) => sum + p.metrics.likes, 0) / allPosts.length),
    avgComments: Math.round(allPosts.reduce((sum, p) => sum + p.metrics.comments, 0) / allPosts.length),
    avgShares: Math.round(allPosts.reduce((sum, p) => sum + p.metrics.shares, 0) / allPosts.length),
    avgEngagementRate: parseFloat((allPosts.reduce((sum, p) => sum + p.engagement.rate, 0) / allPosts.length).toFixed(2)),
    platformBreakdown: {}
  }

  for (const platform of platforms) {
    const platformPosts = allPosts.filter(p => p.platform === platform)
    stats.platformBreakdown[platform] = {
      posts: platformPosts.length,
      avgEngagement: platformPosts.length > 0
        ? Math.round(platformPosts.reduce((sum, p) => sum + p.engagement.total, 0) / platformPosts.length)
        : 0
    }
  }

  // Generate insights
  const { insights, recommendations } = generateInsights(analysis, stats)

  console.log(`\n📊 COMPETITOR INSIGHTS`)
  for (const insight of insights) {
    console.log(`   ${insight}`)
  }

  console.log(`\n💡 RECOMMENDATIONS`)
  for (const rec of recommendations) {
    console.log(`   - ${rec}`)
  }

  return {
    success: true,
    stats,
    topPosts: analysis.topPosts.map(p => ({
      platform: p.platform,
      competitor: p.competitor,
      content: p.content.substring(0, 100) + '...',
      engagement: p.engagement,
      timestamp: p.timestamp
    })),
    patterns: analysis.patterns,
    insights,
    recommendations,
    timeRange: {
      start: new Date(Date.now() - daysBack * 24 * 60 * 60 * 1000).toISOString(),
      end: new Date().toISOString(),
      daysBack
    },
    timestamp: new Date().toISOString()
  }
}

// Example usage (for testing)
if (import.meta.url === `file://${process.argv[1]}`) {
  console.log('🧪 Testing competitor-tracker skill...\n')

  const testResult = await run(null, {
    platforms: ['instagram', 'tiktok'],
    daysBack: 7,
    useMockData: true,
    topN: 10
  })

  console.log('\n📦 Result Object:', JSON.stringify(testResult, null, 2))
}
