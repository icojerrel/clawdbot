/**
 * Content Scheduler Skill
 * Schedules Instagram/Facebook/TikTok posts with optimal timing
 *
 * Features:
 * - Optimal time calculation based on engagement patterns
 * - Queue management (view, add, remove)
 * - Conflict detection (prevents double-posting)
 * - Platform-specific scheduling
 * - Returns scheduled post IDs
 */

export const meta = {
  name: 'content-scheduler',
  description: 'Plan en schedule Instagram/Facebook/TikTok posts met optimale timing en conflict detectie'
}

/**
 * Engagement patterns for optimal posting times
 * Based on general social media best practices for lifestyle/beverage brands
 */
const ENGAGEMENT_PATTERNS = {
  instagram: {
    weekday: [
      { hour: 9, score: 75 },   // Morning coffee break
      { hour: 12, score: 85 },  // Lunch time
      { hour: 17, score: 90 },  // After work (peak)
      { hour: 20, score: 88 }   // Evening relaxation
    ],
    weekend: [
      { hour: 10, score: 80 },  // Late morning
      { hour: 14, score: 85 },  // Afternoon
      { hour: 19, score: 95 }   // Evening (peak)
    ]
  },
  facebook: {
    weekday: [
      { hour: 8, score: 70 },   // Commute time
      { hour: 12, score: 80 },  // Lunch
      { hour: 18, score: 85 },  // After work
      { hour: 21, score: 75 }   // Evening
    ],
    weekend: [
      { hour: 11, score: 85 },  // Mid-morning
      { hour: 15, score: 80 },  // Afternoon
      { hour: 20, score: 90 }   // Evening (peak)
    ]
  },
  tiktok: {
    weekday: [
      { hour: 7, score: 75 },   // Morning commute
      { hour: 12, score: 80 },  // Lunch break
      { hour: 18, score: 95 },  // After work (peak)
      { hour: 22, score: 85 }   // Late evening
    ],
    weekend: [
      { hour: 10, score: 85 },  // Late morning
      { hour: 16, score: 88 },  // Afternoon
      { hour: 21, score: 92 }   // Evening
    ]
  }
}

/**
 * In-memory queue (in production, this would be a database)
 */
let scheduledQueue = []

/**
 * Calculate optimal posting time for a given platform
 */
function calculateOptimalTime(platform, targetDate = null) {
  const now = new Date()
  const target = targetDate ? new Date(targetDate) : now

  // Determine if it's a weekend
  const dayOfWeek = target.getDay()
  const isWeekend = dayOfWeek === 0 || dayOfWeek === 6

  // Get engagement pattern for this platform and day type
  const pattern = ENGAGEMENT_PATTERNS[platform]?.[isWeekend ? 'weekend' : 'weekday']

  if (!pattern) {
    throw new Error(`Unknown platform: ${platform}`)
  }

  // Find best time slot
  const bestSlot = pattern.reduce((best, slot) =>
    slot.score > best.score ? slot : best
  , { hour: 12, score: 0 })

  // Set the optimal time
  const optimalTime = new Date(target)
  optimalTime.setHours(bestSlot.hour, 0, 0, 0)

  // If target date is today and optimal time has passed, use next best slot
  if (optimalTime <= now) {
    const nextSlot = pattern.find(slot => {
      const testTime = new Date(target)
      testTime.setHours(slot.hour, 0, 0, 0)
      return testTime > now
    })

    if (nextSlot) {
      optimalTime.setHours(nextSlot.hour, 0, 0, 0)
    } else {
      // All slots today have passed, schedule for tomorrow
      optimalTime.setDate(optimalTime.getDate() + 1)
      optimalTime.setHours(bestSlot.hour, 0, 0, 0)
    }
  }

  return {
    timestamp: optimalTime.toISOString(),
    unix: Math.floor(optimalTime.getTime() / 1000),
    score: bestSlot.score,
    reason: `${isWeekend ? 'Weekend' : 'Weekday'} peak engagement time (${bestSlot.hour}:00)`
  }
}

/**
 * Check for scheduling conflicts
 */
function detectConflicts(platform, scheduledTime, bufferMinutes = 60) {
  const scheduledTimestamp = new Date(scheduledTime).getTime()
  const bufferMs = bufferMinutes * 60 * 1000

  const conflicts = scheduledQueue.filter(item => {
    if (item.platform !== platform) return false

    const itemTimestamp = new Date(item.scheduledTime).getTime()
    const timeDiff = Math.abs(scheduledTimestamp - itemTimestamp)

    return timeDiff < bufferMs
  })

  return conflicts
}

/**
 * Add post to schedule queue
 */
function addToQueue(platform, content, scheduledTime, mediaUrl = null) {
  const postId = `${platform}-${Date.now()}-${Math.random().toString(36).substr(2, 9)}`

  const queueItem = {
    id: postId,
    platform,
    content: content.substring(0, 200), // Truncate for storage
    fullContent: content,
    mediaUrl,
    scheduledTime,
    scheduledUnix: Math.floor(new Date(scheduledTime).getTime() / 1000),
    status: 'scheduled',
    createdAt: new Date().toISOString()
  }

  scheduledQueue.push(queueItem)

  return queueItem
}

/**
 * Remove post from queue
 */
function removeFromQueue(postId) {
  const index = scheduledQueue.findIndex(item => item.id === postId)

  if (index === -1) {
    throw new Error(`Post ${postId} not found in queue`)
  }

  const removed = scheduledQueue.splice(index, 1)[0]
  return removed
}

/**
 * Get all scheduled posts
 */
function getQueue(platform = null) {
  if (platform) {
    return scheduledQueue.filter(item => item.platform === platform)
  }
  return [...scheduledQueue]
}

export async function run(context, params = {}) {
  const {
    action = 'schedule',  // 'schedule', 'list', 'remove'
    platform,             // 'instagram', 'facebook', 'tiktok'
    content,              // Post content/caption
    mediaUrl,             // Optional media URL
    targetDate,           // Optional target date (ISO string or 'tomorrow', 'next-week')
    postId,               // For remove action
    forceTime,            // Optional: force specific time (ISO string)
    bufferMinutes = 60    // Conflict detection buffer (default 60min)
  } = params

  // Handle different actions
  if (action === 'list') {
    console.log('📋 Listing scheduled posts...')
    const queue = getQueue(platform)

    console.log(`   Found ${queue.length} scheduled post${queue.length !== 1 ? 's' : ''}`)

    return {
      success: true,
      action: 'list',
      platform: platform || 'all',
      count: queue.length,
      queue: queue.map(item => ({
        id: item.id,
        platform: item.platform,
        content: item.content,
        scheduledTime: item.scheduledTime,
        status: item.status
      }))
    }
  }

  if (action === 'remove') {
    if (!postId) {
      throw new Error('postId is required for remove action')
    }

    console.log(`🗑️  Removing post ${postId}...`)
    const removed = removeFromQueue(postId)

    console.log(`   ✓ Removed ${removed.platform} post scheduled for ${removed.scheduledTime}`)

    return {
      success: true,
      action: 'remove',
      removed
    }
  }

  // Default: schedule action
  if (!platform) {
    throw new Error('platform is required (instagram, facebook, tiktok)')
  }

  if (!content) {
    throw new Error('content is required')
  }

  console.log(`📅 Scheduling ${platform} post...`)

  // Calculate optimal time
  let scheduledTime
  let optimalInfo

  if (forceTime) {
    scheduledTime = forceTime
    optimalInfo = {
      timestamp: forceTime,
      unix: Math.floor(new Date(forceTime).getTime() / 1000),
      score: 0,
      reason: 'Manually specified time'
    }
    console.log(`   Using forced time: ${forceTime}`)
  } else {
    // Parse target date
    let targetDateObj = null
    if (targetDate === 'tomorrow') {
      targetDateObj = new Date()
      targetDateObj.setDate(targetDateObj.getDate() + 1)
    } else if (targetDate === 'next-week') {
      targetDateObj = new Date()
      targetDateObj.setDate(targetDateObj.getDate() + 7)
    } else if (targetDate) {
      targetDateObj = new Date(targetDate)
    }

    optimalInfo = calculateOptimalTime(platform, targetDateObj)
    scheduledTime = optimalInfo.timestamp

    console.log(`   Optimal time: ${scheduledTime} (score: ${optimalInfo.score}/100)`)
    console.log(`   Reason: ${optimalInfo.reason}`)
  }

  // Check for conflicts
  const conflicts = detectConflicts(platform, scheduledTime, bufferMinutes)

  if (conflicts.length > 0) {
    console.log(`   ⚠️  Warning: ${conflicts.length} potential conflict${conflicts.length !== 1 ? 's' : ''} detected`)

    for (const conflict of conflicts) {
      console.log(`      - ${conflict.id} at ${conflict.scheduledTime}`)
    }
  }

  // Add to queue
  const queueItem = addToQueue(platform, content, scheduledTime, mediaUrl)

  console.log(`   ✅ Post scheduled: ${queueItem.id}`)
  console.log(`      Platform: ${platform}`)
  console.log(`      Time: ${scheduledTime}`)
  console.log(`      Queue position: ${scheduledQueue.length}`)

  return {
    success: true,
    action: 'schedule',
    postId: queueItem.id,
    platform,
    scheduledTime,
    scheduledUnix: optimalInfo.unix,
    optimalScore: optimalInfo.score,
    reason: optimalInfo.reason,
    conflicts: conflicts.length > 0 ? conflicts.map(c => ({
      id: c.id,
      scheduledTime: c.scheduledTime
    })) : [],
    queuePosition: scheduledQueue.length,
    preview: {
      content: content.substring(0, 100) + (content.length > 100 ? '...' : ''),
      hasMedia: !!mediaUrl
    }
  }
}

// Example usage (for testing)
if (import.meta.url === `file://${process.argv[1]}`) {
  console.log('🧪 Testing content-scheduler skill...\n')

  // Schedule Instagram post for tomorrow
  const result1 = await run(null, {
    action: 'schedule',
    platform: 'instagram',
    content: '🍸 Nieuw op Instagram! Lavish Premium Cocktails - perfect voor je weekend! #LavishNL #PremiumCocktails',
    mediaUrl: 'https://example.com/cocktail.jpg',
    targetDate: 'tomorrow'
  })

  console.log('\n📦 Schedule Result:', JSON.stringify(result1, null, 2))

  // Schedule TikTok post for next week
  const result2 = await run(null, {
    action: 'schedule',
    platform: 'tiktok',
    content: '🎵 Viral TikTok moment incoming! #LavishNL #CocktailTikTok',
    targetDate: 'next-week'
  })

  console.log('\n📦 Schedule Result 2:', JSON.stringify(result2, null, 2))

  // List all scheduled posts
  const result3 = await run(null, {
    action: 'list'
  })

  console.log('\n📋 Queue:', JSON.stringify(result3, null, 2))
}
