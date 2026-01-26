/**
 * Sentiment Analyzer Skill
 * Analyzes comments/DMs sentiment using basic NLP (no external API needed)
 *
 * Features:
 * - Sentiment classification (positive/negative/neutral)
 * - Urgency detection (complaints, issues)
 * - Theme extraction (common topics)
 * - Actionable insights
 * - Dutch language support
 */

export const meta = {
  name: 'sentiment-analyzer',
  description: 'Analyseer sentiment van Instagram/Facebook/TikTok comments en DMs met urgentie detectie'
}

/**
 * Dutch sentiment lexicon (positive/negative keywords)
 */
const SENTIMENT_LEXICON = {
  positive: {
    nl: [
      'geweldig', 'lekker', 'heerlijk', 'top', 'perfect', 'mooi', 'goed', 'leuk',
      'fantastisch', 'prachtig', 'uitstekend', 'super', 'wauw', 'wow', 'love',
      'geweldige', 'beste', 'favoriet', 'aanrader', 'recommended', 'premium',
      'kwaliteit', 'vers', 'smaakvol', 'origineel', 'uniek', 'gaaf'
    ],
    en: [
      'amazing', 'great', 'excellent', 'love', 'perfect', 'awesome', 'wonderful',
      'fantastic', 'beautiful', 'delicious', 'tasty', 'yummy', 'best', 'favorite',
      'recommend', 'quality', 'fresh', 'premium', 'unique', 'cool'
    ]
  },
  negative: {
    nl: [
      'slecht', 'vies', 'teleurstellend', 'matig', 'niet goed', 'jammer',
      'helaas', 'waardeloos', 'verschrikkelijk', 'afschuwelijk', 'duur',
      'te duur', 'overpriced', 'smakeloos', 'niet vers', 'klacht', 'probleem',
      'niet tevreden', 'ontevreden', 'fout', 'verkeerd', 'beschadigd'
    ],
    en: [
      'bad', 'terrible', 'awful', 'disappointing', 'poor', 'hate', 'disgusting',
      'horrible', 'worst', 'expensive', 'overpriced', 'complaint', 'problem',
      'issue', 'wrong', 'broken', 'damaged', 'unhappy', 'dissatisfied'
    ]
  }
}

/**
 * Urgency keywords (complaints requiring immediate attention)
 */
const URGENCY_KEYWORDS = {
  nl: [
    'klacht', 'probleem', 'verkeerd', 'fout', 'beschadigd', 'kapot', 'niet geleverd',
    'te laat', 'klantenservice', 'terugbetaling', 'refund', 'retour', 'nooit weer',
    'advocaat', 'juridisch', 'consumentenbond'
  ],
  en: [
    'complaint', 'problem', 'issue', 'wrong', 'broken', 'damaged', 'not delivered',
    'late', 'customer service', 'refund', 'return', 'never again', 'lawyer', 'legal'
  ]
}

/**
 * Theme keywords (common topics)
 */
const THEME_KEYWORDS = {
  product_quality: {
    nl: ['smaak', 'kwaliteit', 'vers', 'ingrediënten', 'mix', 'cocktail'],
    en: ['taste', 'quality', 'fresh', 'ingredients', 'mix', 'cocktail']
  },
  price: {
    nl: ['prijs', 'duur', 'goedkoop', 'kosten', 'waarde', 'geld'],
    en: ['price', 'expensive', 'cheap', 'cost', 'value', 'money']
  },
  delivery: {
    nl: ['levering', 'bezorging', 'verzending', 'verpakking', 'geleverd'],
    en: ['delivery', 'shipping', 'packaging', 'delivered', 'arrived']
  },
  packaging: {
    nl: ['verpakking', 'fles', 'design', 'uitstraling', 'presentatie'],
    en: ['packaging', 'bottle', 'design', 'appearance', 'presentation']
  },
  customer_service: {
    nl: ['klantenservice', 'service', 'contact', 'reactie', 'antwoord', 'hulp'],
    en: ['customer service', 'service', 'contact', 'response', 'answer', 'help']
  }
}

/**
 * Analyze sentiment of a single text
 */
function analyzeSentiment(text) {
  const lowerText = text.toLowerCase()

  let positiveScore = 0
  let negativeScore = 0

  // Count positive keywords
  for (const lang of ['nl', 'en']) {
    for (const word of SENTIMENT_LEXICON.positive[lang]) {
      const regex = new RegExp(`\\b${word}\\b`, 'gi')
      const matches = lowerText.match(regex)
      if (matches) {
        positiveScore += matches.length
      }
    }
  }

  // Count negative keywords
  for (const lang of ['nl', 'en']) {
    for (const word of SENTIMENT_LEXICON.negative[lang]) {
      const regex = new RegExp(`\\b${word}\\b`, 'gi')
      const matches = lowerText.match(regex)
      if (matches) {
        negativeScore += matches.length
      }
    }
  }

  // Determine sentiment
  let sentiment = 'neutral'
  let confidence = 0

  if (positiveScore > negativeScore) {
    sentiment = 'positive'
    confidence = Math.min(100, (positiveScore / (positiveScore + negativeScore)) * 100)
  } else if (negativeScore > positiveScore) {
    sentiment = 'negative'
    confidence = Math.min(100, (negativeScore / (positiveScore + negativeScore)) * 100)
  } else if (positiveScore === 0 && negativeScore === 0) {
    sentiment = 'neutral'
    confidence = 50
  } else {
    sentiment = 'neutral'
    confidence = 50
  }

  return {
    sentiment,
    confidence: Math.round(confidence),
    scores: {
      positive: positiveScore,
      negative: negativeScore
    }
  }
}

/**
 * Detect urgency (complaints requiring immediate action)
 */
function detectUrgency(text) {
  const lowerText = text.toLowerCase()

  let urgencyScore = 0
  const matchedKeywords = []

  for (const lang of ['nl', 'en']) {
    for (const word of URGENCY_KEYWORDS[lang]) {
      const regex = new RegExp(`\\b${word}\\b`, 'gi')
      if (regex.test(lowerText)) {
        urgencyScore += 1
        matchedKeywords.push(word)
      }
    }
  }

  return {
    isUrgent: urgencyScore > 0,
    urgencyLevel: urgencyScore >= 3 ? 'high' : urgencyScore >= 1 ? 'medium' : 'low',
    matchedKeywords
  }
}

/**
 * Extract common themes from text
 */
function extractThemes(text) {
  const lowerText = text.toLowerCase()
  const detectedThemes = []

  for (const [theme, keywords] of Object.entries(THEME_KEYWORDS)) {
    let themeScore = 0

    for (const lang of ['nl', 'en']) {
      for (const word of keywords[lang]) {
        const regex = new RegExp(`\\b${word}\\b`, 'gi')
        const matches = lowerText.match(regex)
        if (matches) {
          themeScore += matches.length
        }
      }
    }

    if (themeScore > 0) {
      detectedThemes.push({
        theme,
        score: themeScore
      })
    }
  }

  // Sort by score
  detectedThemes.sort((a, b) => b.score - a.score)

  return detectedThemes
}

/**
 * Generate mock comments for testing
 */
function generateMockComments() {
  return [
    {
      id: 'c1',
      platform: 'instagram',
      author: 'cocktail_lover_nl',
      text: 'Wauw, deze cocktails zijn echt geweldig! Perfecte smaak en mooie verpakking! 🍸',
      timestamp: new Date(Date.now() - 2 * 60 * 60 * 1000).toISOString()
    },
    {
      id: 'c2',
      platform: 'facebook',
      author: 'jan_de_vries',
      text: 'Helaas teleurstellend. De prijs is te duur en de kwaliteit is niet wat ik verwachtte.',
      timestamp: new Date(Date.now() - 5 * 60 * 60 * 1000).toISOString()
    },
    {
      id: 'c3',
      platform: 'tiktok',
      author: 'party_queen',
      text: 'Love this! Perfect for the weekend! 🎉',
      timestamp: new Date(Date.now() - 1 * 60 * 60 * 1000).toISOString()
    },
    {
      id: 'c4',
      platform: 'instagram',
      author: 'unhappy_customer',
      text: 'Klacht! Levering was te laat en de verpakking was beschadigd. Niet tevreden met de klantenservice.',
      timestamp: new Date(Date.now() - 30 * 60 * 1000).toISOString()
    },
    {
      id: 'c5',
      platform: 'facebook',
      author: 'party_host',
      text: 'Goede cocktails voor ons feestje. Gasten waren enthousiast!',
      timestamp: new Date(Date.now() - 3 * 60 * 60 * 1000).toISOString()
    },
    {
      id: 'c6',
      platform: 'tiktok',
      author: 'mix_master',
      text: 'Lekkere mix maar wat aan de prijs kant. Kwaliteit is wel top!',
      timestamp: new Date(Date.now() - 4 * 60 * 60 * 1000).toISOString()
    }
  ]
}

/**
 * Generate actionable insights from sentiment analysis
 */
function generateActionItems(results) {
  const actionItems = []

  // Urgent issues
  const urgentItems = results.comments.filter(c => c.urgency.isUrgent && c.sentiment.sentiment === 'negative')
  if (urgentItems.length > 0) {
    actionItems.push({
      priority: 'high',
      action: 'immediate_response',
      description: `🚨 ${urgentItems.length} urgent complaint${urgentItems.length !== 1 ? 's' : ''} requiring immediate response`,
      items: urgentItems.map(c => ({ id: c.id, author: c.author, text: c.text.substring(0, 80) + '...' }))
    })
  }

  // Negative sentiment without urgency
  const negativeItems = results.comments.filter(c => c.sentiment.sentiment === 'negative' && !c.urgency.isUrgent)
  if (negativeItems.length > 0) {
    actionItems.push({
      priority: 'medium',
      action: 'address_concerns',
      description: `⚠️  ${negativeItems.length} negative comment${negativeItems.length !== 1 ? 's' : ''} to address`,
      items: negativeItems.map(c => ({ id: c.id, author: c.author }))
    })
  }

  // Positive engagement opportunities
  const positiveItems = results.comments.filter(c => c.sentiment.sentiment === 'positive' && c.sentiment.confidence > 70)
  if (positiveItems.length > 0) {
    actionItems.push({
      priority: 'low',
      action: 'engage_positive',
      description: `✅ ${positiveItems.length} positive comment${positiveItems.length !== 1 ? 's' : ''} - engage and thank!`,
      items: positiveItems.map(c => ({ id: c.id, author: c.author }))
    })
  }

  return actionItems
}

export async function run(context, params = {}) {
  const {
    comments = null,     // Array of comment objects { id, platform, author, text, timestamp }
    useMockData = false  // Use mock data for testing
  } = params

  console.log('🔍 Analyzing sentiment...')

  // Use mock data if no comments provided or explicitly requested
  const commentsToAnalyze = useMockData || !comments ? generateMockComments() : comments

  console.log(`   Analyzing ${commentsToAnalyze.length} comment${commentsToAnalyze.length !== 1 ? 's' : ''}...`)

  // Analyze each comment
  const analyzedComments = commentsToAnalyze.map(comment => {
    const sentiment = analyzeSentiment(comment.text)
    const urgency = detectUrgency(comment.text)
    const themes = extractThemes(comment.text)

    return {
      ...comment,
      sentiment,
      urgency,
      themes
    }
  })

  // Calculate overall statistics
  const stats = {
    total: analyzedComments.length,
    positive: analyzedComments.filter(c => c.sentiment.sentiment === 'positive').length,
    negative: analyzedComments.filter(c => c.sentiment.sentiment === 'negative').length,
    neutral: analyzedComments.filter(c => c.sentiment.sentiment === 'neutral').length,
    urgent: analyzedComments.filter(c => c.urgency.isUrgent).length
  }

  // Extract common themes across all comments
  const allThemes = {}
  for (const comment of analyzedComments) {
    for (const theme of comment.themes) {
      allThemes[theme.theme] = (allThemes[theme.theme] || 0) + theme.score
    }
  }

  const topThemes = Object.entries(allThemes)
    .map(([theme, score]) => ({ theme, score }))
    .sort((a, b) => b.score - a.score)
    .slice(0, 5)

  // Generate action items
  const actionItems = generateActionItems({ comments: analyzedComments })

  console.log('   ✓ Analysis complete')
  console.log(`\n📊 SENTIMENT SUMMARY`)
  console.log(`   Positive: ${stats.positive} (${Math.round(stats.positive / stats.total * 100)}%)`)
  console.log(`   Negative: ${stats.negative} (${Math.round(stats.negative / stats.total * 100)}%)`)
  console.log(`   Neutral: ${stats.neutral} (${Math.round(stats.neutral / stats.total * 100)}%)`)
  console.log(`   Urgent: ${stats.urgent} 🚨`)

  if (topThemes.length > 0) {
    console.log(`\n🏷️  TOP THEMES`)
    for (const theme of topThemes) {
      console.log(`   - ${theme.theme.replace('_', ' ')}: ${theme.score} mentions`)
    }
  }

  if (actionItems.length > 0) {
    console.log(`\n✅ ACTION ITEMS (${actionItems.length})`)
    for (const item of actionItems) {
      console.log(`   ${item.description}`)
    }
  }

  return {
    success: true,
    stats,
    topThemes,
    actionItems,
    comments: analyzedComments,
    timestamp: new Date().toISOString()
  }
}

// Example usage (for testing)
if (import.meta.url === `file://${process.argv[1]}`) {
  console.log('🧪 Testing sentiment-analyzer skill...\n')

  const testResult = await run(null, {
    useMockData: true
  })

  console.log('\n📦 Result Object:', JSON.stringify(testResult, null, 2))
}
