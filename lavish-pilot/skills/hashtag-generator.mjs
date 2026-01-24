/**
 * Hashtag Generator for Lavish Content
 * Generates platform-specific, topic-relevant hashtags
 */

export const meta = {
  name: 'hashtag-generator',
  description: 'Genereer trending en relevante hashtags voor Lavish social content'
}

const LAVISH_CORE = ['#LavishNL', '#PremiumCocktails', '#DrinkLavish']

const TOPIC_HASHTAGS = {
  mixology: [
    '#MixologyMagic', '#CocktailRecipes', '#HomeBartender', '#Cocktails',
    '#Bartending', '#CocktailArt', '#DrinkPorn', '#CocktailHour',
    '#MixologyMonday', '#CocktailCrafting'
  ],
  party: [
    '#PartyVibes', '#Nightlife', '#WeekendVibes', '#PartyTime',
    '#NightOut', '#PartyHard', '#ClubLife', '#PartyMode',
    '#WeekendMood', '#PartyPeople'
  ],
  festival: [
    '#FestivalSeason', '#Pinkpop', '#Lowlands', '#FestivalLife',
    '#MusicFestival', '#FestivalVibes', '#SummerFestival', '#FestivalReady',
    '#Mysteryland', '#FestivalStyle'
  ],
  tutorial: [
    '#CocktailTutorial', '#MixologyTips', '#BartenderLife', '#DrinkRecipes',
    '#HowToMix', '#CocktailLesson', '#MixologyClass', '#LearnToMix',
    '#BartenderTricks', '#CocktailMaking'
  ],
  lifestyle: [
    '#LuxuryLifestyle', '#PremiumLife', '#Lifestyle', '#LuxuryVibes',
    '#UpscaleLiving', '#PremiumQuality', '#LuxuryBrand', '#HighLife',
    '#LuxuryDrinks', '#PremiumExperience'
  ],
  event: [
    '#EventVibes', '#PartyEvent', '#NightEvent', '#EventPhotography',
    '#EventCoverage', '#LiveEvent', '#EventLife', '#SpecialEvent'
  ],
  weekend: [
    '#WeekendVibes', '#WeekendMood', '#FridayNight', '#SaturdayNight',
    '#SundayFunday', '#WeekendGoals', '#WeekendReady', '#WeekendLife'
  ]
}

const PLATFORM_SPECIFIC = {
  instagram: [
    '#InstaGood', '#InstaDaily', '#Netherlands', '#Amsterdam',
    '#PhotoOfTheDay', '#InstaFood', '#InstaLuxury', '#InstaParty',
    '#DutchLife', '#NetherlandsLife'
  ],
  tiktok: [
    '#FYP', '#ForYou', '#Viral', '#Trending', '#FYPage',
    '#ForYouPage', '#TikTokNL', '#DutchTikTok', '#Viral2026'
  ],
  facebook: [
    '#CommunityVibes', '#LocalEvents', '#Netherlands'
  ]
}

const SEASONAL = {
  spring: ['#Spring2026', '#SpringVibes', '#SpringCocktails'],
  summer: ['#Summer2026', '#SummerVibes', '#SummerCocktails', '#FestivalSummer'],
  fall: ['#Fall2026', '#AutumnVibes', '#FallCocktails'],
  winter: ['#Winter2026', '#WinterVibes', '#WinterCocktails', '#NYE2026']
}

export async function run(context, params) {
  const {
    topic = 'mixology',     // Main topic
    platform = 'instagram', // Target platform
    maxTags = 30,          // Maximum hashtags to return
    includeSeasonal = true, // Include seasonal tags
    customTags = []        // Additional custom tags
  } = params

  console.log(`🏷️  Generating hashtags for: ${topic} on ${platform}`)

  const tags = new Set()

  // 1. Always include Lavish core hashtags
  LAVISH_CORE.forEach(tag => tags.add(tag))

  // 2. Add topic-specific hashtags
  const topicTags = TOPIC_HASHTAGS[topic] || TOPIC_HASHTAGS.mixology
  topicTags.slice(0, 10).forEach(tag => tags.add(tag))

  // 3. Add platform-specific hashtags
  const platformTags = PLATFORM_SPECIFIC[platform] || PLATFORM_SPECIFIC.instagram
  platformTags.slice(0, 5).forEach(tag => tags.add(tag))

  // 4. Add seasonal hashtags if enabled
  if (includeSeasonal) {
    const season = getCurrentSeason()
    const seasonalTags = SEASONAL[season] || []
    seasonalTags.forEach(tag => tags.add(tag))
  }

  // 5. Add custom tags
  customTags.forEach(tag => {
    if (!tag.startsWith('#')) {
      tag = '#' + tag
    }
    tags.add(tag)
  })

  // Convert to array and limit
  let finalTags = Array.from(tags).slice(0, maxTags)

  // Sort: Core first, then alphabetically
  finalTags = [
    ...finalTags.filter(t => LAVISH_CORE.includes(t)),
    ...finalTags.filter(t => !LAVISH_CORE.includes(t)).sort()
  ]

  // Generate copy-paste string
  const hashtagString = finalTags.join(' ')

  // Platform-specific recommendations
  const recommendations = getPlatformRecommendations(platform, finalTags.length)

  return {
    success: true,
    topic,
    platform,
    count: finalTags.length,
    hashtags: finalTags,
    hashtagString,
    recommendations,
    breakdown: {
      core: LAVISH_CORE.length,
      topicSpecific: topicTags.slice(0, 10).length,
      platform: platformTags.slice(0, 5).length,
      seasonal: includeSeasonal ? (SEASONAL[getCurrentSeason()] || []).length : 0,
      custom: customTags.length
    },
    timestamp: new Date().toISOString()
  }
}

function getCurrentSeason() {
  const month = new Date().getMonth() + 1 // 1-12

  if (month >= 3 && month <= 5) return 'spring'
  if (month >= 6 && month <= 8) return 'summer'
  if (month >= 9 && month <= 11) return 'fall'
  return 'winter'
}

function getPlatformRecommendations(platform, count) {
  const recs = []

  if (platform === 'instagram') {
    if (count < 20) {
      recs.push('Instagram allows up to 30 hashtags - consider adding more')
    }
    if (count > 30) {
      recs.push('⚠️  Instagram limit is 30 hashtags - truncate to avoid issues')
    }
    recs.push('Mix popular and niche hashtags for best reach')
    recs.push('Place hashtags in first comment for cleaner captions')
  }

  if (platform === 'tiktok') {
    if (count > 5) {
      recs.push('TikTok works best with 3-5 focused hashtags')
    }
    recs.push('Prioritize #FYP and trending hashtags')
    recs.push('Video content matters more than hashtags on TikTok')
  }

  if (platform === 'facebook') {
    if (count > 3) {
      recs.push('Facebook: 1-3 hashtags perform better than many')
    }
    recs.push('Focus on community-building hashtags')
  }

  return recs
}

// Preset combinations for common Lavish content types
export const PRESETS = {
  'weekend-party': {
    topic: 'party',
    platform: 'instagram',
    customTags: ['Weekend', 'FridayNight', 'SaturdayNight']
  },
  'festival-coverage': {
    topic: 'festival',
    platform: 'instagram',
    customTags: ['LiveCoverage', 'FestivalPhotography']
  },
  'mixology-tutorial': {
    topic: 'tutorial',
    platform: 'tiktok',
    maxTags: 5
  },
  'product-launch': {
    topic: 'lifestyle',
    platform: 'instagram',
    customTags: ['NewProduct', 'ProductLaunch', 'Exclusive']
  }
}

// Example usage
if (import.meta.url === `file://${process.argv[1]}`) {
  console.log('🏷️  Hashtag Generator Test\n')

  const mixology = await run(null, { topic: 'mixology', platform: 'instagram' })
  console.log('Mixology Instagram:', mixology.hashtagString)
  console.log('Count:', mixology.count)
  console.log('Recommendations:', mixology.recommendations)

  console.log('\n---\n')

  const festival = await run(null, { topic: 'festival', platform: 'tiktok', maxTags: 5 })
  console.log('Festival TikTok:', festival.hashtagString)
  console.log('Count:', festival.count)

  console.log('\n---\n')

  const party = await run(null, {
    topic: 'party',
    platform: 'facebook',
    customTags: ['WeekendVibes', 'AmsterdamNightlife']
  })
  console.log('Party Facebook:', party.hashtagString)
  console.log('Breakdown:', party.breakdown)
}
