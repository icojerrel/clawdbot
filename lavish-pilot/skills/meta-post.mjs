/**
 * Meta Business Suite Posting Skill
 * Posts content to Instagram and/or Facebook via Meta Graph API
 *
 * Usage:
 *   - Post to Instagram only
 *   - Post to Facebook only
 *   - Post to both platforms simultaneously
 *   - Schedule posts for later
 */

export const meta = {
  name: 'meta-post',
  description: 'Post content naar Instagram en/of Facebook via Meta Business Suite API'
}

export async function run(context, params) {
  const {
    platform = 'both',      // 'instagram', 'facebook', or 'both'
    caption,                // Post caption text
    mediaUrl,               // Image/video URL (must be publicly accessible)
    mediaType = 'image',    // 'image' or 'video'
    scheduledTime,          // Optional: Unix timestamp for scheduled post
    altText                 // Optional: Alt text for accessibility
  } = params

  // Validate inputs
  if (!caption) {
    throw new Error('Caption is required')
  }

  if (!mediaUrl) {
    throw new Error('Media URL is required')
  }

  const accessToken = process.env.META_ACCESS_TOKEN
  const pageId = process.env.META_PAGE_ID
  const igAccountId = process.env.META_INSTAGRAM_ACCOUNT_ID

  if (!accessToken) {
    throw new Error('META_ACCESS_TOKEN not found in environment')
  }

  const results = {}

  // Post to Instagram
  if (platform === 'instagram' || platform === 'both') {
    if (!igAccountId) {
      throw new Error('META_INSTAGRAM_ACCOUNT_ID not found in environment')
    }

    try {
      console.log(`📸 Posting to Instagram... (${mediaType})`)

      // Step 1: Create media container
      const containerEndpoint = `https://graph.facebook.com/v18.0/${igAccountId}/media`

      const containerPayload = {
        ...(mediaType === 'image' && { image_url: mediaUrl }),
        ...(mediaType === 'video' && { video_url: mediaUrl, media_type: 'REELS' }),
        caption: caption,
        access_token: accessToken
      }

      const containerResponse = await fetch(containerEndpoint, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(containerPayload)
      })

      if (!containerResponse.ok) {
        const error = await containerResponse.json()
        throw new Error(`Instagram container creation failed: ${JSON.stringify(error)}`)
      }

      const { id: containerId } = await containerResponse.json()
      console.log(`  ✓ Container created: ${containerId}`)

      // Step 2: Publish the media
      const publishEndpoint = `https://graph.facebook.com/v18.0/${igAccountId}/media_publish`

      const publishPayload = {
        creation_id: containerId,
        access_token: accessToken
      }

      const publishResponse = await fetch(publishEndpoint, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(publishPayload)
      })

      if (!publishResponse.ok) {
        const error = await publishResponse.json()
        throw new Error(`Instagram publish failed: ${JSON.stringify(error)}`)
      }

      const { id: postId } = await publishResponse.json()

      results.instagram = {
        success: true,
        postId,
        url: `https://www.instagram.com/p/${postId}`,
        timestamp: new Date().toISOString()
      }

      console.log(`  ✅ Instagram post published: ${postId}`)

    } catch (error) {
      console.error('Instagram posting error:', error)
      results.instagram = {
        success: false,
        error: error.message
      }
    }
  }

  // Post to Facebook
  if (platform === 'facebook' || platform === 'both') {
    if (!pageId) {
      throw new Error('META_PAGE_ID not found in environment')
    }

    try {
      console.log(`📘 Posting to Facebook... (${mediaType})`)

      const endpoint = mediaType === 'video'
        ? `https://graph.facebook.com/v18.0/${pageId}/videos`
        : `https://graph.facebook.com/v18.0/${pageId}/photos`

      const payload = {
        ...(mediaType === 'image' && { url: mediaUrl }),
        ...(mediaType === 'video' && { file_url: mediaUrl }),
        caption: caption,
        access_token: accessToken,
        ...(scheduledTime && {
          scheduled_publish_time: scheduledTime,
          published: false
        })
      }

      const response = await fetch(endpoint, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(payload)
      })

      if (!response.ok) {
        const error = await response.json()
        throw new Error(`Facebook post failed: ${JSON.stringify(error)}`)
      }

      const data = await response.json()

      results.facebook = {
        success: true,
        postId: data.id || data.post_id,
        ...(scheduledTime && { scheduledFor: new Date(scheduledTime * 1000).toISOString() }),
        timestamp: new Date().toISOString()
      }

      console.log(`  ✅ Facebook post ${scheduledTime ? 'scheduled' : 'published'}: ${results.facebook.postId}`)

    } catch (error) {
      console.error('Facebook posting error:', error)
      results.facebook = {
        success: false,
        error: error.message
      }
    }
  }

  // Summary
  const successful = Object.values(results).filter(r => r.success).length
  const failed = Object.values(results).filter(r => !r.success).length

  console.log(`\n📊 Posting complete: ${successful} success, ${failed} failed`)

  return {
    summary: {
      successful,
      failed,
      platforms: Object.keys(results)
    },
    results,
    params: {
      platform,
      caption: caption.substring(0, 100) + '...',
      mediaType,
      scheduledTime: scheduledTime ? new Date(scheduledTime * 1000).toISOString() : null
    }
  }
}

// Example usage (for testing)
if (import.meta.url === `file://${process.argv[1]}`) {
  const testResult = await run(null, {
    platform: 'both',
    caption: '🍸 Weekend vibes with Lavish Premium Cocktails! #LavishNL #PremiumCocktails #WeekendVibes',
    mediaUrl: 'https://example.com/lavish-cocktail.jpg',
    mediaType: 'image'
  })

  console.log('\nTest Result:', JSON.stringify(testResult, null, 2))
}
