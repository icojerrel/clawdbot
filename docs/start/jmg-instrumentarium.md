---
title: "JMG Instrumentarium: Essential Tools voor Lavish Pilot"
description: "Complete toolkit voor het JMG Enterprise Team om Lavish Nederland te laten groeien"
summary: "API integrations, skills, tools en workflows voor premium drinks marketing"
---

# JMG Instrumentarium: Essential Tools voor Lavish Pilot

**Voor:** Lavish Nederland (Premium Cocktails & Mixdranken)
**Team:** JMG Content Group Enterprise (10 AI Agents)
**Goal:** Complete A-Z digital exposure met measurable ROI

---

## 🎯 Core Instrumenten Stack

### 1. Social Media Management & Analytics

**Hootsuite / Buffer / Later (Social Scheduling)**
```bash
# API Integration
API_KEY: Hootsuite API voor multi-platform scheduling
Use case: Schedule 50+ posts/week across Instagram, TikTok, Facebook
Cost: €79/maand (Professional plan)

Agents using:
- Social Manager (scheduling all posts)
- CEO (approval workflow)
- Data Analyst (performance tracking)

Skills needed:
~/.clawdbot/skills/hootsuite-schedule.mjs
~/.clawdbot/skills/hootsuite-analytics.mjs
```

**Meta Business Suite API (Instagram + Facebook)**
```javascript
// ~/.clawdbot/skills/meta-post.mjs
export const meta = {
  name: 'meta-post',
  description: 'Post naar Instagram + Facebook via Meta API'
}

export async function run(context, { platform, caption, mediaUrl, scheduledTime }) {
  const accessToken = process.env.META_ACCESS_TOKEN;
  const pageId = process.env.META_PAGE_ID;

  const endpoint = `https://graph.facebook.com/v18.0/${pageId}/photos`;

  const response = await fetch(endpoint, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({
      access_token: accessToken,
      url: mediaUrl,
      caption: caption,
      published: scheduledTime ? false : true,
      scheduled_publish_time: scheduledTime
    })
  });

  return await response.json();
}
```

**TikTok Content Posting API**
```javascript
// ~/.clawdbot/skills/tiktok-post.mjs
export const meta = {
  name: 'tiktok-post',
  description: 'Upload video naar TikTok via API'
}

export async function run(context, { videoPath, caption, hashtags }) {
  // TikTok Business API integration
  const accessToken = process.env.TIKTOK_ACCESS_TOKEN;

  // Upload video
  const uploadUrl = 'https://open-api.tiktok.com/share/video/upload/';

  // Note: TikTok API requires special approval for posting
  // Alternative: Use Zapier webhook as bridge

  return {
    success: true,
    postId: 'tiktok_post_123',
    url: 'https://tiktok.com/@lavish/video/123'
  };
}
```

**YouTube API (Video Management)**
```javascript
// ~/.clawdbot/skills/youtube-upload.mjs
export const meta = {
  name: 'youtube-upload',
  description: 'Upload video naar YouTube met metadata'
}

export async function run(context, { videoPath, title, description, tags }) {
  const { google } = await import('googleapis');

  const youtube = google.youtube({
    version: 'v3',
    auth: process.env.YOUTUBE_API_KEY
  });

  const response = await youtube.videos.insert({
    part: 'snippet,status',
    requestBody: {
      snippet: {
        title,
        description,
        tags,
        categoryId: '22' // People & Blogs
      },
      status: {
        privacyStatus: 'public'
      }
    },
    media: {
      body: fs.createReadStream(videoPath)
    }
  });

  return response.data;
}
```

---

### 2. Analytics & Tracking

**Google Analytics 4 API**
```javascript
// ~/.clawdbot/skills/ga4-report.mjs
export const meta = {
  name: 'ga4-report',
  description: 'Fetch GA4 data voor Lavish website'
}

export async function run(context, { metric, startDate, endDate }) {
  const { BetaAnalyticsDataClient } = await import('@google-analytics/data');

  const analyticsDataClient = new BetaAnalyticsDataClient({
    keyFilename: process.env.GA4_KEY_FILE
  });

  const [response] = await analyticsDataClient.runReport({
    property: `properties/${process.env.GA4_PROPERTY_ID}`,
    dateRanges: [{ startDate, endDate }],
    dimensions: [{ name: 'pagePath' }],
    metrics: [{ name: metric }]
  });

  return formatGAResponse(response);
}
```

**Meta (Facebook/Instagram) Insights API**
```javascript
// ~/.clawdbot/skills/meta-insights.mjs
export const meta = {
  name: 'meta-insights',
  description: 'Get Instagram/Facebook analytics'
}

export async function run(context, { platform, metric, period }) {
  const accessToken = process.env.META_ACCESS_TOKEN;
  const accountId = process.env.META_ACCOUNT_ID;

  const endpoint = platform === 'instagram'
    ? `https://graph.facebook.com/v18.0/${accountId}/insights`
    : `https://graph.facebook.com/v18.0/${accountId}/insights`;

  const response = await fetch(`${endpoint}?metric=${metric}&period=${period}&access_token=${accessToken}`);

  return await response.json();
}
```

**TikTok Analytics API**
```javascript
// ~/.clawdbot/skills/tiktok-analytics.mjs
export const meta = {
  name: 'tiktok-analytics',
  description: 'Fetch TikTok video/account analytics'
}

export async function run(context, { videoId, metrics }) {
  // TikTok Analytics API (requires Business account)
  const accessToken = process.env.TIKTOK_ANALYTICS_TOKEN;

  const endpoint = 'https://open-api.tiktok.com/v2/research/video/query/';

  const response = await fetch(endpoint, {
    method: 'POST',
    headers: {
      'Authorization': `Bearer ${accessToken}`,
      'Content-Type': 'application/json'
    },
    body: JSON.stringify({
      video_ids: [videoId],
      fields: metrics // ['like_count', 'view_count', 'share_count']
    })
  });

  return await response.json();
}
```

---

### 3. Content Creation & Design

**Canva API (Graphics Generation)**
```javascript
// ~/.clawdbot/skills/canva-create.mjs
export const meta = {
  name: 'canva-create',
  description: 'Generate graphics via Canva API'
}

export async function run(context, { templateId, text, images }) {
  // Canva Connect API
  const apiKey = process.env.CANVA_API_KEY;

  const endpoint = 'https://api.canva.com/v1/designs';

  const response = await fetch(endpoint, {
    method: 'POST',
    headers: {
      'Authorization': `Bearer ${apiKey}`,
      'Content-Type': 'application/json'
    },
    body: JSON.stringify({
      template_id: templateId,
      elements: {
        text_elements: text,
        image_elements: images
      }
    })
  });

  const design = await response.json();

  // Export design
  const exportUrl = `https://api.canva.com/v1/designs/${design.id}/export`;
  const exportResponse = await fetch(exportUrl, {
    method: 'POST',
    headers: { 'Authorization': `Bearer ${apiKey}` },
    body: JSON.stringify({ format: 'png', quality: 'high' })
  });

  return await exportResponse.json();
}
```

**DALL-E / Midjourney (AI Image Generation)**
```javascript
// ~/.clawdbot/skills/dalle-generate.mjs
export const meta = {
  name: 'dalle-generate',
  description: 'Generate images met DALL-E voor social posts'
}

export async function run(context, { prompt, size = '1024x1024' }) {
  const openai = await import('openai');
  const client = new openai.OpenAI({
    apiKey: process.env.OPENAI_API_KEY
  });

  const response = await client.images.generate({
    model: 'dall-e-3',
    prompt: `${prompt}. Premium drinks brand aesthetic, vibrant colors, party lifestyle, professional photography style.`,
    n: 1,
    size: size,
    quality: 'hd'
  });

  return {
    url: response.data[0].url,
    prompt: prompt
  };
}
```

**ElevenLabs (Voice/TTS for Videos)**
```javascript
// ~/.clawdbot/skills/elevenlabs-tts.mjs
export const meta = {
  name: 'elevenlabs-tts',
  description: 'Generate voiceover voor video content'
}

export async function run(context, { text, voiceId = 'preset_energetic' }) {
  const apiKey = process.env.ELEVENLABS_API_KEY;

  const response = await fetch(`https://api.elevenlabs.io/v1/text-to-speech/${voiceId}`, {
    method: 'POST',
    headers: {
      'xi-api-key': apiKey,
      'Content-Type': 'application/json'
    },
    body: JSON.stringify({
      text,
      model_id: 'eleven_multilingual_v2',
      voice_settings: {
        stability: 0.5,
        similarity_boost: 0.75
      }
    })
  });

  const audioBuffer = await response.arrayBuffer();
  const filename = `voiceover_${Date.now()}.mp3`;
  await fs.writeFile(`/tmp/${filename}`, Buffer.from(audioBuffer));

  return { audioPath: `/tmp/${filename}` };
}
```

---

### 4. SEO & Content Optimization

**Ahrefs API (Keyword Research)**
```javascript
// ~/.clawdbot/skills/ahrefs-keywords.mjs
export const meta = {
  name: 'ahrefs-keywords',
  description: 'Keyword research via Ahrefs voor Lavish content'
}

export async function run(context, { seedKeyword, country = 'nl' }) {
  const apiKey = process.env.AHREFS_API_KEY;

  const endpoint = 'https://api.ahrefs.com/v3/keywords-explorer/keyword-ideas';

  const response = await fetch(endpoint, {
    method: 'POST',
    headers: {
      'Authorization': `Bearer ${apiKey}`,
      'Content-Type': 'application/json'
    },
    body: JSON.stringify({
      seed_keywords: [seedKeyword],
      country: country,
      mode: 'phrase_match',
      limit: 50
    })
  });

  const data = await response.json();

  // Filter for high volume, low difficulty
  const opportunities = data.keywords.filter(kw =>
    kw.search_volume > 500 &&
    kw.keyword_difficulty < 30
  );

  return {
    total: opportunities.length,
    keywords: opportunities.map(kw => ({
      keyword: kw.keyword,
      volume: kw.search_volume,
      difficulty: kw.keyword_difficulty,
      cpc: kw.cpc
    }))
  };
}
```

**SEMrush API (Competitor Analysis)**
```javascript
// ~/.clawdbot/skills/semrush-competitor.mjs
export const meta = {
  name: 'semrush-competitor',
  description: 'Analyze concurrent drinks brands'
}

export async function run(context, { competitorDomain }) {
  const apiKey = process.env.SEMRUSH_API_KEY;

  const endpoint = 'https://api.semrush.com/';

  const params = new URLSearchParams({
    type: 'domain_organic',
    key: apiKey,
    domain: competitorDomain,
    database: 'nl',
    display_limit: 100,
    export_columns: 'Ph,Po,Nq,Cp,Co,Kd,Tr'
  });

  const response = await fetch(`${endpoint}?${params}`);
  const csvData = await response.text();

  // Parse CSV and return top keywords
  return parseCompetitorKeywords(csvData);
}
```

**Surfer SEO API (Content Optimization)**
```javascript
// ~/.clawdbot/skills/surfer-optimize.mjs
export const meta = {
  name: 'surfer-optimize',
  description: 'Optimize blog content met Surfer SEO'
}

export async function run(context, { content, targetKeyword }) {
  const apiKey = process.env.SURFER_API_KEY;

  const endpoint = 'https://api.surferseo.com/v1/content_editor';

  const response = await fetch(endpoint, {
    method: 'POST',
    headers: {
      'Authorization': `Bearer ${apiKey}`,
      'Content-Type': 'application/json'
    },
    body: JSON.stringify({
      keyword: targetKeyword,
      content: content,
      country: 'nl'
    })
  });

  const optimization = await response.json();

  return {
    score: optimization.content_score,
    suggestions: optimization.improvements,
    missing_keywords: optimization.terms_to_add,
    optimal_length: optimization.recommended_word_count
  };
}
```

---

### 5. Email Marketing (B2B Horeca + B2C)

**Mailchimp API (Newsletter Management)**
```javascript
// ~/.clawdbot/skills/mailchimp-send.mjs
export const meta = {
  name: 'mailchimp-send',
  description: 'Send newsletter via Mailchimp'
}

export async function run(context, { listId, subject, htmlContent, segment }) {
  const mailchimp = await import('@mailchimp/mailchimp_marketing');

  mailchimp.setConfig({
    apiKey: process.env.MAILCHIMP_API_KEY,
    server: process.env.MAILCHIMP_SERVER
  });

  const campaign = await mailchimp.campaigns.create({
    type: 'regular',
    recipients: {
      list_id: listId,
      segment_opts: segment
    },
    settings: {
      subject_line: subject,
      from_name: 'Lavish Nederland',
      reply_to: 'hello@drinklavish.nl'
    }
  });

  await mailchimp.campaigns.setContent(campaign.id, {
    html: htmlContent
  });

  await mailchimp.campaigns.send(campaign.id);

  return { campaignId: campaign.id, status: 'sent' };
}
```

**SendGrid API (Transactional Emails)**
```javascript
// ~/.clawdbot/skills/sendgrid-send.mjs
export const meta = {
  name: 'sendgrid-send',
  description: 'Send transactional email (B2B leads, confirmations)'
}

export async function run(context, { to, subject, html }) {
  const sgMail = await import('@sendgrid/mail');
  sgMail.setApiKey(process.env.SENDGRID_API_KEY);

  const msg = {
    to: to,
    from: 'hello@drinklavish.nl',
    subject: subject,
    html: html
  };

  await sgMail.send(msg);

  return { success: true, to };
}
```

---

### 6. CRM & Lead Management (B2B Horeca)

**HubSpot API (Horeca Lead Tracking)**
```javascript
// ~/.clawdbot/skills/hubspot-create-deal.mjs
export const meta = {
  name: 'hubspot-create-deal',
  description: 'Create deal voor nieuwe horeca partnership'
}

export async function run(context, { companyName, contactName, email, phone, dealValue }) {
  const hubspot = await import('@hubspot/api-client');
  const client = new hubspot.Client({ accessToken: process.env.HUBSPOT_API_KEY });

  // Create contact
  const contact = await client.crm.contacts.basicApi.create({
    properties: {
      firstname: contactName.split(' ')[0],
      lastname: contactName.split(' ')[1],
      email: email,
      phone: phone,
      company: companyName
    }
  });

  // Create deal
  const deal = await client.crm.deals.basicApi.create({
    properties: {
      dealname: `Horeca Partnership - ${companyName}`,
      amount: dealValue,
      dealstage: 'appointmentscheduled',
      pipeline: 'default'
    },
    associations: [
      {
        to: { id: contact.id },
        types: [{ associationCategory: 'HUBSPOT_DEFINED', associationTypeId: 3 }]
      }
    ]
  });

  return { contactId: contact.id, dealId: deal.id };
}
```

---

### 7. Event & Festival Tools

**Eventbrite API (Festival Ticketing Integration)**
```javascript
// ~/.clawdbot/skills/eventbrite-track.mjs
export const meta = {
  name: 'eventbrite-track',
  description: 'Track festival attendance voor Lavish booth presence'
}

export async function run(context, { eventId }) {
  const apiKey = process.env.EVENTBRITE_API_KEY;

  const response = await fetch(`https://www.eventbriteapi.com/v3/events/${eventId}/`, {
    headers: { 'Authorization': `Bearer ${apiKey}` }
  });

  const event = await response.json();

  return {
    name: event.name.text,
    date: event.start.local,
    attendees: event.capacity,
    location: event.venue
  };
}
```

**Google Calendar API (Event Planning)**
```javascript
// ~/.clawdbot/skills/gcal-add-event.mjs
export const meta = {
  name: 'gcal-add-event',
  description: 'Add festival/event naar team calendar'
}

export async function run(context, { summary, location, startTime, endTime, description }) {
  const { google } = await import('googleapis');

  const calendar = google.calendar({
    version: 'v3',
    auth: process.env.GOOGLE_CALENDAR_API_KEY
  });

  const event = await calendar.events.insert({
    calendarId: 'primary',
    requestBody: {
      summary: summary,
      location: location,
      description: description,
      start: { dateTime: startTime, timeZone: 'Europe/Amsterdam' },
      end: { dateTime: endTime, timeZone: 'Europe/Amsterdam' }
    }
  });

  return event.data;
}
```

---

### 8. Influencer & Partnership Tools

**Instagram Graph API (Influencer Discovery)**
```javascript
// ~/.clawdbot/skills/instagram-search-influencers.mjs
export const meta = {
  name: 'instagram-search-influencers',
  description: 'Find nightlife/bartender influencers voor partnerships'
}

export async function run(context, { hashtag, minFollowers = 5000, maxFollowers = 50000 }) {
  // Use Instagram Graph API to search hashtags
  const accessToken = process.env.INSTAGRAM_ACCESS_TOKEN;

  const endpoint = `https://graph.instagram.com/ig_hashtag_search?user_id=${process.env.INSTAGRAM_USER_ID}&q=${hashtag}&access_token=${accessToken}`;

  const response = await fetch(endpoint);
  const data = await response.json();

  // Get recent media for hashtag
  const hashtagId = data.data[0].id;
  const mediaEndpoint = `https://graph.instagram.com/${hashtagId}/recent_media?user_id=${process.env.INSTAGRAM_USER_ID}&fields=id,caption,like_count,comments_count,owner&access_token=${accessToken}`;

  const mediaResponse = await fetch(mediaEndpoint);
  const posts = await mediaResponse.json();

  // Filter accounts by follower count
  // (Note: Full implementation requires additional API calls per user)

  return {
    hashtag,
    potentialInfluencers: posts.data.slice(0, 20).map(post => ({
      username: post.owner.username,
      engagement: post.like_count + post.comments_count
    }))
  };
}
```

---

### 9. Media & Asset Management

**Cloudinary (Media Storage & Optimization)**
```javascript
// ~/.clawdbot/skills/cloudinary-upload.mjs
export const meta = {
  name: 'cloudinary-upload',
  description: 'Upload en optimize media assets'
}

export async function run(context, { filePath, folder = 'lavish' }) {
  const cloudinary = await import('cloudinary').v2;

  cloudinary.config({
    cloud_name: process.env.CLOUDINARY_CLOUD_NAME,
    api_key: process.env.CLOUDINARY_API_KEY,
    api_secret: process.env.CLOUDINARY_API_SECRET
  });

  const result = await cloudinary.uploader.upload(filePath, {
    folder: folder,
    resource_type: 'auto',
    quality: 'auto',
    fetch_format: 'auto'
  });

  return {
    url: result.secure_url,
    publicId: result.public_id,
    format: result.format,
    size: result.bytes
  };
}
```

---

### 10. Monitoring & Alerts

**Slack Webhooks (Team Notifications)**
```javascript
// ~/.clawdbot/skills/slack-alert.mjs
export const meta = {
  name: 'slack-alert',
  description: 'Send alerts naar team Slack'
}

export async function run(context, { channel, message, level = 'info' }) {
  const webhookUrl = process.env.SLACK_WEBHOOK_URL;

  const emoji = {
    success: ':white_check_mark:',
    warning: ':warning:',
    error: ':rotating_light:',
    info: ':information_source:'
  };

  const response = await fetch(webhookUrl, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({
      channel: channel,
      text: `${emoji[level]} ${message}`,
      username: 'JMG Bot'
    })
  });

  return { success: response.ok };
}
```

**Sentry (Error Tracking)**
```javascript
// ~/.clawdbot/skills/sentry-log-error.mjs
export const meta = {
  name: 'sentry-log-error',
  description: 'Log errors naar Sentry voor debugging'
}

export async function run(context, { error, agent, task }) {
  const Sentry = await import('@sentry/node');

  Sentry.init({
    dsn: process.env.SENTRY_DSN,
    environment: 'production'
  });

  Sentry.captureException(error, {
    tags: {
      agent: agent,
      task: task
    }
  });

  return { logged: true };
}
```

---

## 🔄 Task-Based Skill Orchestration

**Advanced workflow patterns voor complex campaigns met multi-agent coordination.**

Het JMG Enterprise Team gebruikt task-based orchestration om complexe marketing campaigns te automatiseren. Skills worden gecoördineerd via dependency graphs, parallel execution, en conditional chains.

---

### 1. Multi-Skill Workflows: Sequential Chaining

**Use Case: Complete Instagram Campaign Creation**

Een Instagram campaign vereist multiple skills in sequence: hashtag research → visual design → content posting. De CEO agent creëert een task graph die deze skills choreert.

**Task Graph (JSON):**

```json
{
  "taskListId": "campaign_instagram_summer_launch",
  "createdBy": "ceo",
  "tasks": [
    {
      "id": "task_1",
      "content": "Generate trending hashtags for summer cocktails campaign",
      "activeForm": "Generating hashtags with hashtag-generator skill",
      "status": "pending",
      "assignedTo": "strategist",
      "skill": "hashtag-generator",
      "skillParams": {
        "seedKeywords": ["summer cocktails", "lavish drinks", "festival drinks"],
        "targetPlatform": "instagram",
        "count": 30
      },
      "dependencies": [],
      "output": null
    },
    {
      "id": "task_2",
      "content": "Design Instagram visual using generated hashtags",
      "activeForm": "Creating visual with DALL-E based on hashtag themes",
      "status": "pending",
      "assignedTo": "designer",
      "skill": "dalle-generate",
      "skillParams": {
        "prompt": "${task_1.output.topHashtags} - vibrant summer drinks, festival aesthetic",
        "size": "1080x1080"
      },
      "dependencies": ["task_1"],
      "output": null
    },
    {
      "id": "task_3",
      "content": "Upload visual to Cloudinary for CDN hosting",
      "activeForm": "Uploading to Cloudinary",
      "status": "pending",
      "assignedTo": "designer",
      "skill": "cloudinary-upload",
      "skillParams": {
        "filePath": "${task_2.output.url}",
        "folder": "lavish/campaigns/summer-2026"
      },
      "dependencies": ["task_2"],
      "output": null
    },
    {
      "id": "task_4",
      "content": "Publish Instagram post with hashtags and visual",
      "activeForm": "Publishing to Instagram via meta-post skill",
      "status": "pending",
      "assignedTo": "social",
      "skill": "meta-post",
      "skillParams": {
        "platform": "instagram",
        "caption": "Summer is here! 🍹☀️ ${task_1.output.caption}\n\n${task_1.output.hashtags}",
        "mediaUrl": "${task_3.output.url}",
        "scheduledTime": null
      },
      "dependencies": ["task_1", "task_3"],
      "output": null
    }
  ]
}
```

**Skill Invocation Code:**

```javascript
// ~/.clawdbot/agents/ceo/workflows/instagram-campaign.mjs
export const meta = {
  name: 'instagram-campaign',
  description: 'Orchestrate full Instagram campaign with multi-skill chain'
}

export async function run(context, { theme, scheduledTime }) {
  const taskListId = `campaign_instagram_${theme}_${Date.now()}`;

  // Step 1: Generate hashtags (Task 1)
  const hashtagTask = await context.createTask({
    taskListId,
    content: `Generate trending hashtags for ${theme} campaign`,
    assignedTo: 'strategist',
    skill: 'hashtag-generator',
    skillParams: {
      seedKeywords: [theme, 'lavish drinks', 'cocktails'],
      targetPlatform: 'instagram',
      count: 30
    }
  });

  const hashtagResult = await context.runSkill('hashtag-generator', hashtagTask.skillParams);
  await context.completeTask(hashtagTask.id, { output: hashtagResult });

  // Step 2: Design visual (Task 2 - blockedBy Task 1)
  const visualTask = await context.createTask({
    taskListId,
    content: 'Design Instagram visual using generated hashtags',
    assignedTo: 'designer',
    skill: 'dalle-generate',
    skillParams: {
      prompt: `${hashtagResult.topHashtags.join(' ')} - vibrant drinks, premium aesthetic`,
      size: '1080x1080'
    },
    dependencies: [hashtagTask.id]
  });

  const visualResult = await context.runSkill('dalle-generate', visualTask.skillParams);
  await context.completeTask(visualTask.id, { output: visualResult });

  // Step 3: Upload to CDN (Task 3 - blockedBy Task 2)
  const uploadTask = await context.createTask({
    taskListId,
    content: 'Upload visual to Cloudinary',
    assignedTo: 'designer',
    skill: 'cloudinary-upload',
    skillParams: {
      filePath: visualResult.url,
      folder: `lavish/campaigns/${theme}`
    },
    dependencies: [visualTask.id]
  });

  const cdnResult = await context.runSkill('cloudinary-upload', uploadTask.skillParams);
  await context.completeTask(uploadTask.id, { output: cdnResult });

  // Step 4: Publish to Instagram (Task 4 - blockedBy Tasks 1 & 3)
  const publishTask = await context.createTask({
    taskListId,
    content: 'Publish Instagram post',
    assignedTo: 'social',
    skill: 'meta-post',
    skillParams: {
      platform: 'instagram',
      caption: `${hashtagResult.caption}\n\n${hashtagResult.hashtags.join(' ')}`,
      mediaUrl: cdnResult.url,
      scheduledTime: scheduledTime
    },
    dependencies: [hashtagTask.id, uploadTask.id]
  });

  const publishResult = await context.runSkill('meta-post', publishTask.skillParams);
  await context.completeTask(publishTask.id, { output: publishResult });

  return {
    taskListId,
    campaign: theme,
    postId: publishResult.postId,
    hashtags: hashtagResult.hashtags,
    imageUrl: cdnResult.url
  };
}
```

**Usage:**

```bash
# CEO triggers campaign workflow
clawdbot agent --agent ceo --message "Create Instagram campaign for 'Festival Season' scheduled for tomorrow 6PM"

# The workflow executes sequentially:
# 1. Strategist runs hashtag-generator → saves to task state
# 2. Designer waits for hashtags → runs dalle-generate
# 3. Designer uploads to Cloudinary → saves CDN URL
# 4. Social Manager publishes post with all outputs combined
```

---

### 2. Parallel Skill Execution: Independent Tasks

**Use Case: Multi-Platform Content Blitz**

Launch simultaneous content across Instagram, TikTok, and Facebook using different skills in parallel (no dependencies).

**Task Graph (Parallel Execution):**

```json
{
  "taskListId": "blitz_weekend_promotion",
  "createdBy": "ceo",
  "tasks": [
    {
      "id": "task_analytics_1",
      "content": "Fetch TikTok analytics for last week",
      "activeForm": "Analyzing TikTok performance data",
      "status": "in_progress",
      "assignedTo": "analyst",
      "skill": "tiktok-analytics",
      "skillParams": {
        "videoId": "all",
        "metrics": ["view_count", "like_count", "share_count"]
      },
      "dependencies": [],
      "parallel": true
    },
    {
      "id": "task_post_1",
      "content": "Post Friday night promo to Instagram",
      "activeForm": "Publishing Instagram Story with meta-post",
      "status": "in_progress",
      "assignedTo": "social",
      "skill": "meta-post",
      "skillParams": {
        "platform": "instagram",
        "caption": "Friday Night Vibes 🎉 Get your Lavish on!",
        "mediaUrl": "https://cdn.lavish.nl/weekend-promo.jpg"
      },
      "dependencies": [],
      "parallel": true
    },
    {
      "id": "task_hashtags_1",
      "content": "Generate hashtags for weekend nightlife campaign",
      "activeForm": "Generating trending hashtags",
      "status": "in_progress",
      "assignedTo": "strategist",
      "skill": "hashtag-generator",
      "skillParams": {
        "seedKeywords": ["weekend nightlife", "party drinks", "club vibes"],
        "targetPlatform": "tiktok",
        "count": 20
      },
      "dependencies": [],
      "parallel": true
    }
  ]
}
```

**Parallel Execution Code:**

```javascript
// ~/.clawdbot/agents/ceo/workflows/parallel-blitz.mjs
export const meta = {
  name: 'parallel-blitz',
  description: 'Execute multiple skills simultaneously with no dependencies'
}

export async function run(context, { campaign }) {
  const taskListId = `blitz_${campaign}_${Date.now()}`;

  // Create all tasks upfront (no dependencies = parallel eligible)
  const tasks = [
    {
      skill: 'tiktok-analytics',
      assignedTo: 'analyst',
      params: { videoId: 'all', metrics: ['view_count', 'like_count', 'share_count'] }
    },
    {
      skill: 'meta-post',
      assignedTo: 'social',
      params: { platform: 'instagram', caption: 'Weekend Vibes!', mediaUrl: 'https://...' }
    },
    {
      skill: 'hashtag-generator',
      assignedTo: 'strategist',
      params: { seedKeywords: ['weekend nightlife'], targetPlatform: 'tiktok', count: 20 }
    }
  ];

  // Execute all skills in parallel using Promise.all
  const results = await Promise.all(
    tasks.map(async (task) => {
      const taskRecord = await context.createTask({
        taskListId,
        content: `Run ${task.skill} skill`,
        assignedTo: task.assignedTo,
        skill: task.skill,
        skillParams: task.params,
        dependencies: [],  // No dependencies = parallel execution
        parallel: true
      });

      // Execute skill
      const result = await context.runSkill(task.skill, task.params);

      // Complete task with output
      await context.completeTask(taskRecord.id, { output: result });

      return { task: task.skill, result };
    })
  );

  return {
    taskListId,
    campaign,
    executed: results.length,
    outputs: results
  };
}
```

**Execution Timeline (Parallel):**

```
Time 0s:   All 3 tasks start simultaneously
           ├─ tiktok-analytics (analyst)
           ├─ meta-post (social)
           └─ hashtag-generator (strategist)

Time 2s:   meta-post completes (fastest)
Time 4s:   hashtag-generator completes
Time 7s:   tiktok-analytics completes (slowest)

Total: 7 seconds (vs 13s sequential)
```

---

### 3. Conditional Skill Chains: Dynamic Workflows

**Use Case: Performance-Triggered Content Strategy**

Analytics skill detects low engagement → triggers strategist skill → conditionally triggers content creation skills based on recommendations.

**Conditional Task Graph:**

```json
{
  "taskListId": "adaptive_strategy_week_12",
  "createdBy": "ceo",
  "tasks": [
    {
      "id": "task_monitor",
      "content": "Monitor Instagram engagement rates",
      "activeForm": "Checking Instagram Insights API",
      "status": "completed",
      "assignedTo": "analyst",
      "skill": "meta-insights",
      "skillParams": {
        "platform": "instagram",
        "metric": "engagement_rate",
        "period": "week"
      },
      "dependencies": [],
      "output": {
        "engagement_rate": 2.1,
        "threshold": 3.5,
        "status": "below_target"
      }
    },
    {
      "id": "task_diagnose",
      "content": "Analyze root cause of low engagement",
      "activeForm": "Running strategist diagnosis",
      "status": "completed",
      "assignedTo": "strategist",
      "skill": "engagement-analyzer",
      "skillParams": {
        "currentRate": "${task_monitor.output.engagement_rate}",
        "targetRate": "${task_monitor.output.threshold}"
      },
      "dependencies": ["task_monitor"],
      "condition": "${task_monitor.output.engagement_rate} < ${task_monitor.output.threshold}",
      "output": {
        "diagnosis": "Content frequency too low, hashtag diversity insufficient",
        "recommendations": [
          "increase_posting_frequency",
          "diversify_hashtags",
          "add_video_content"
        ]
      }
    },
    {
      "id": "task_action_1",
      "content": "Generate new diverse hashtag sets",
      "activeForm": "Creating fresh hashtag strategy",
      "status": "in_progress",
      "assignedTo": "strategist",
      "skill": "hashtag-generator",
      "skillParams": {
        "seedKeywords": ["cocktails", "nightlife", "bartending", "mixology", "summer"],
        "targetPlatform": "instagram",
        "count": 50,
        "diversityMode": true
      },
      "dependencies": ["task_diagnose"],
      "condition": "'diversify_hashtags' in ${task_diagnose.output.recommendations}"
    },
    {
      "id": "task_action_2",
      "content": "Create additional video content for TikTok",
      "activeForm": "Scripting TikTok videos",
      "status": "pending",
      "assignedTo": "video",
      "skill": "tiktok-script-generator",
      "skillParams": {
        "theme": "behind-the-scenes bartending",
        "count": 5,
        "duration": "15-30s"
      },
      "dependencies": ["task_diagnose"],
      "condition": "'add_video_content' in ${task_diagnose.output.recommendations}"
    }
  ]
}
```

**Conditional Execution Code:**

```javascript
// ~/.clawdbot/agents/ceo/workflows/adaptive-strategy.mjs
export const meta = {
  name: 'adaptive-strategy',
  description: 'Monitor performance and trigger conditional skill chains'
}

export async function run(context, { platform, metric, threshold }) {
  const taskListId = `adaptive_${platform}_${Date.now()}`;

  // Task 1: Monitor metrics
  const monitorTask = await context.createTask({
    taskListId,
    content: `Monitor ${platform} ${metric}`,
    assignedTo: 'analyst',
    skill: 'meta-insights',
    skillParams: { platform, metric, period: 'week' }
  });

  const metrics = await context.runSkill('meta-insights', monitorTask.skillParams);
  await context.completeTask(monitorTask.id, { output: metrics });

  // Conditional: Only proceed if performance is below threshold
  if (metrics.engagement_rate >= threshold) {
    await context.logInfo(`Performance OK (${metrics.engagement_rate}% >= ${threshold}%)`);
    return { status: 'no_action_needed', metrics };
  }

  // Task 2: Diagnose issues (conditional on low performance)
  const diagnoseTask = await context.createTask({
    taskListId,
    content: 'Analyze root cause of low engagement',
    assignedTo: 'strategist',
    skill: 'engagement-analyzer',
    skillParams: {
      currentRate: metrics.engagement_rate,
      targetRate: threshold,
      platform: platform
    },
    dependencies: [monitorTask.id]
  });

  const diagnosis = await context.runSkill('engagement-analyzer', diagnoseTask.skillParams);
  await context.completeTask(diagnoseTask.id, { output: diagnosis });

  // Task 3+: Execute recommended actions (conditional chains)
  const actionTasks = [];

  if (diagnosis.recommendations.includes('diversify_hashtags')) {
    const hashtagTask = await context.createTask({
      taskListId,
      content: 'Generate diverse hashtag strategy',
      assignedTo: 'strategist',
      skill: 'hashtag-generator',
      skillParams: {
        seedKeywords: ['cocktails', 'nightlife', 'bartending'],
        targetPlatform: platform,
        count: 50,
        diversityMode: true
      },
      dependencies: [diagnoseTask.id]
    });

    const hashtags = await context.runSkill('hashtag-generator', hashtagTask.skillParams);
    await context.completeTask(hashtagTask.id, { output: hashtags });
    actionTasks.push({ action: 'hashtags', result: hashtags });
  }

  if (diagnosis.recommendations.includes('add_video_content')) {
    const videoTask = await context.createTask({
      taskListId,
      content: 'Create TikTok video scripts',
      assignedTo: 'video',
      skill: 'tiktok-script-generator',
      skillParams: {
        theme: 'behind-the-scenes',
        count: 5,
        duration: '15-30s'
      },
      dependencies: [diagnoseTask.id]
    });

    const scripts = await context.runSkill('tiktok-script-generator', videoTask.skillParams);
    await context.completeTask(videoTask.id, { output: scripts });
    actionTasks.push({ action: 'video', result: scripts });
  }

  if (diagnosis.recommendations.includes('increase_posting_frequency')) {
    await context.updateAgentConfig('social', {
      posting_schedule: {
        instagram: { frequency: '3x_daily' },
        tiktok: { frequency: '2x_daily' }
      }
    });
    actionTasks.push({ action: 'schedule_update', result: 'increased frequency' });
  }

  return {
    taskListId,
    status: 'actions_executed',
    metrics,
    diagnosis,
    actions: actionTasks
  };
}
```

**Execution Flow:**

```
Start: Monitor engagement
  ↓
  engagement < threshold?
  ├─ NO  → Exit (no action needed)
  └─ YES → Diagnose issues
            ↓
            Recommendations?
            ├─ diversify_hashtags → Run hashtag-generator
            ├─ add_video_content → Run tiktok-script-generator
            └─ increase_frequency → Update social agent config
```

---

### 4. Skill + Task Persistence: State Management

**Use Case: Multi-Day Campaign with Saved State**

A week-long campaign requires skills to save outputs to task state so subsequent agents can access results days later.

**Persistent Task List with CLAUDE_CODE_TASK_LIST_ID:**

```bash
# Day 1: CEO creates campaign task list
export CLAUDE_CODE_TASK_LIST_ID="lavish_summer_campaign_2026"

clawdbot agent --agent ceo --message "Create week-long summer campaign:
1. Research trending summer hashtags (save to task state)
2. Generate content calendar for 7 days (save to task state)
3. Create visual assets (save CDN URLs to task state)

Save all outputs to task list: $CLAUDE_CODE_TASK_LIST_ID"
```

**Task State Persistence Code:**

```javascript
// ~/.clawdbot/agents/ceo/workflows/persistent-campaign.mjs
export const meta = {
  name: 'persistent-campaign',
  description: 'Multi-day campaign with persistent task state'
}

export async function run(context, { campaignName, duration }) {
  // Use persistent task list ID from environment
  const taskListId = process.env.CLAUDE_CODE_TASK_LIST_ID || `campaign_${campaignName}`;

  // Day 1: Research phase
  const researchTask = await context.createTask({
    taskListId,
    content: 'Research trending hashtags for campaign',
    assignedTo: 'strategist',
    skill: 'hashtag-generator',
    skillParams: {
      seedKeywords: [campaignName, 'summer', 'cocktails'],
      targetPlatform: 'instagram',
      count: 100
    },
    persist: true  // Save to disk, not just memory
  });

  const hashtags = await context.runSkill('hashtag-generator', researchTask.skillParams);

  // Save to task state (persisted across sessions)
  await context.saveTaskState(taskListId, researchTask.id, {
    hashtags: hashtags.hashtags,
    topHashtags: hashtags.topHashtags,
    savedAt: new Date().toISOString()
  });

  await context.completeTask(researchTask.id, { output: hashtags });

  // Day 2: Content planning (uses Day 1 state)
  const planningTask = await context.createTask({
    taskListId,
    content: 'Generate 7-day content calendar',
    assignedTo: 'pm',
    skill: 'content-calendar-generator',
    skillParams: {
      duration: duration,
      hashtags: '${task_research.output.topHashtags}',  // Reference saved state
      platforms: ['instagram', 'tiktok', 'facebook']
    },
    dependencies: [researchTask.id],
    persist: true
  });

  // Load hashtags from previous task state
  const savedHashtags = await context.loadTaskState(taskListId, researchTask.id);

  const calendar = await context.runSkill('content-calendar-generator', {
    ...planningTask.skillParams,
    hashtags: savedHashtags.topHashtags  // Use persisted data
  });

  await context.saveTaskState(taskListId, planningTask.id, {
    calendar: calendar.posts,
    savedAt: new Date().toISOString()
  });

  await context.completeTask(planningTask.id, { output: calendar });

  return {
    taskListId,
    campaign: campaignName,
    persistedTasks: [researchTask.id, planningTask.id],
    message: 'Campaign state saved. Resume anytime with: export CLAUDE_CODE_TASK_LIST_ID=' + taskListId
  };
}
```

**State Access Across Sessions:**

```javascript
// ~/.clawdbot/agents/social/skills/resume-campaign.mjs
export const meta = {
  name: 'resume-campaign',
  description: 'Resume multi-day campaign from saved task state'
}

export async function run(context, { taskListId, day }) {
  // Load entire task list state
  const taskList = await context.loadTaskList(taskListId);

  // Access saved hashtags from Day 1
  const hashtagTask = taskList.tasks.find(t => t.skill === 'hashtag-generator');
  const savedHashtags = await context.loadTaskState(taskListId, hashtagTask.id);

  // Access saved calendar from Day 2
  const calendarTask = taskList.tasks.find(t => t.skill === 'content-calendar-generator');
  const savedCalendar = await context.loadTaskState(taskListId, calendarTask.id);

  // Get today's content from calendar
  const todayContent = savedCalendar.calendar.find(post => post.day === day);

  // Create new task for today's posting (uses saved state)
  const postTask = await context.createTask({
    taskListId,
    content: `Post Day ${day} content to Instagram`,
    assignedTo: 'social',
    skill: 'meta-post',
    skillParams: {
      platform: 'instagram',
      caption: `${todayContent.caption}\n\n${savedHashtags.topHashtags.slice(0, 10).join(' ')}`,
      mediaUrl: todayContent.imageUrl
    },
    dependencies: [calendarTask.id]
  });

  const result = await context.runSkill('meta-post', postTask.skillParams);
  await context.completeTask(postTask.id, { output: result });

  return {
    taskListId,
    day,
    posted: result.postId,
    usedHashtags: savedHashtags.topHashtags.slice(0, 10),
    usedCalendar: todayContent
  };
}
```

**Day-by-Day Execution:**

```bash
# Day 1: Create campaign (saves state)
export CLAUDE_CODE_TASK_LIST_ID="lavish_summer_2026"
clawdbot agent --agent ceo --message "Start summer campaign"

# Day 2: Resume campaign (loads Day 1 state)
export CLAUDE_CODE_TASK_LIST_ID="lavish_summer_2026"
clawdbot agent --agent social --message "Post today's content using saved campaign state"

# Day 3-7: Continue (all access same persistent task list)
export CLAUDE_CODE_TASK_LIST_ID="lavish_summer_2026"
clawdbot agent --agent social --message "Resume campaign, post Day 3 content"
```

**Persistent State Storage:**

```
~/.clawdbot/task-lists/
  └── lavish_summer_2026/
      ├── task-list.json           # Task graph metadata
      ├── task_research.state.json # Saved hashtags
      ├── task_planning.state.json # Saved calendar
      └── task_post_day*.state.json # Daily post results
```

---

### Best Practices: Skill Orchestration

**1. Dependency Management:**
```javascript
// Good: Explicit dependencies
{
  dependencies: ['task_1', 'task_2'],  // Wait for both
  condition: '${task_1.output.success} === true'
}

// Bad: Implicit assumptions
{
  // Assumes task_1 completed (race condition risk)
}
```

**2. Error Handling:**
```javascript
// Skill execution with fallback
try {
  const result = await context.runSkill('meta-post', params);
  await context.completeTask(taskId, { output: result });
} catch (error) {
  // Log error and create remediation task
  await context.failTask(taskId, { error: error.message });
  await context.createTask({
    content: 'Manual review required for failed post',
    assignedTo: 'ceo',
    priority: 'high',
    dependencies: [taskId]
  });
}
```

**3. State Cleanup:**
```javascript
// Clean up old campaign states (weekly)
export async function cleanupOldCampaigns(context, { olderThanDays = 30 }) {
  const taskLists = await context.listTaskLists();

  for (const list of taskLists) {
    const age = Date.now() - new Date(list.createdAt).getTime();
    const daysOld = age / (1000 * 60 * 60 * 24);

    if (daysOld > olderThanDays && list.status === 'completed') {
      await context.archiveTaskList(list.id);
    }
  }
}
```

**4. Monitoring & Alerts:**
```javascript
// Alert on task failures
export async function monitorTasks(context, { taskListId }) {
  const tasks = await context.getTaskList(taskListId);
  const failedTasks = tasks.filter(t => t.status === 'failed');

  if (failedTasks.length > 0) {
    await context.runSkill('slack-alert', {
      channel: '#lavish-alerts',
      message: `⚠️ ${failedTasks.length} tasks failed in ${taskListId}`,
      level: 'error'
    });
  }
}
```

---

## 🤖 AI Model Provider Strategy

### Opties: Claude vs MiniMax vs z.ai vs Ollama

**De Trade-off:**
- **Claude (Opus/Sonnet/Haiku):** Beste quality, hoogste kosten
- **MiniMax:** Goede quality, veel goedkoper, focus op Chinese/Asian markets
- **z.ai:** Emerging provider, competitive pricing
- **Ollama (Llama 3.1):** FREE (lokaal), lower quality maar 100% gratis

---

### Recommended Hybrid Strategy voor Lavish Pilot

**Phase 1: Bootstrap (Month 1-2) - Minimale Kosten**

```json5
// ~/.clawdbot/clawdbot.json
{
  "models": {
    "providers": {
      "ollama": {
        "baseURL": "http://localhost:11434"
      },
      "anthropic": {
        "apiKey": "${ANTHROPIC_API_KEY}"
      }
    }
  },

  "agents": {
    "routing": {
      // HIGH-VALUE CONTENT = Claude (alleen waar kwaliteit cruciaal is)
      "ceo": {
        "model": "anthropic/sonnet-4.5",  // Strategie + planning
        "workspace": "~/.clawdbot/agents/ceo/workspace"
      },
      "copywriter": {
        "model": "anthropic/sonnet-4.5",  // Blog posts (client-facing)
        "workspace": "~/.clawdbot/agents/copywriter/workspace"
      },

      // VOLUME CONTENT = Ollama (gratis, hoog volume)
      "social": {
        "model": "ollama/llama3.1:8b",  // Social posts (volume over quality)
        "workspace": "~/.clawdbot/agents/social/workspace"
      },
      "analyst": {
        "model": "ollama/llama3.1:8b",  // Data rapportage (facts, geen creativiteit)
        "workspace": "~/.clawdbot/agents/analyst/workspace"
      },
      "email": {
        "model": "ollama/llama3.1:8b",  // Newsletter drafts (CEO refineert)
        "workspace": "~/.clawdbot/agents/email/workspace"
      },
      "designer": {
        "model": "ollama/llama3.1:8b",  // Prompts voor DALL-E/Canva
        "workspace": "~/.clawdbot/agents/designer/workspace"
      },
      "pm": {
        "model": "ollama/llama3.1:8b",  // Task tracking
        "workspace": "~/.clawdbot/agents/pm/workspace"
      },

      // MEDIUM TASKS = Mix (depends on workload)
      "strategist": {
        "model": "ollama/llama3.1:8b",  // Research drafts
        "fallback": "anthropic/haiku",   // Complex analysis
        "workspace": "~/.clawdbot/agents/strategist/workspace"
      },
      "seo": {
        "model": "ollama/llama3.1:8b",  // Meta descriptions, alt tags
        "workspace": "~/.clawdbot/agents/seo/workspace"
      },
      "video": {
        "model": "ollama/llama3.1:8b",  // TikTok scripts (snappy, short)
        "workspace": "~/.clawdbot/agents/video/workspace"
      }
    }
  }
}
```

**Cost Breakdown (Phase 1):**
```
Claude Sonnet (CEO + Copywriter only):
  - CEO: 2-3x/week planning = €20-30/maand
  - Copywriter: 2-3 blogs/week = €40-60/maand
  Subtotal Claude: €60-90/maand

Ollama (7 agents, all routine work):
  - Social, Analyst, Email, Designer, PM, Strategist, SEO, Video
  - Cost: €0/maand (lokaal)

Total AI costs: €60-90/maand (vs €480 full Claude)
SAVINGS: €390-420/maand (82% reduction!)
```

---

### Alternative: MiniMax voor Volume Work

**Als Ollama lokaal niet werkt (VPS te klein):**

```json5
{
  "models": {
    "providers": {
      "minimax": {
        "apiKey": "${MINIMAX_API_KEY}",
        "baseURL": "https://api.minimax.chat"
      },
      "anthropic": {
        "apiKey": "${ANTHROPIC_API_KEY}"
      }
    }
  },

  "agents": {
    "routing": {
      // Premium content = Claude
      "ceo": { "model": "anthropic/sonnet-4.5" },
      "copywriter": { "model": "anthropic/sonnet-4.5" },

      // Volume content = MiniMax (cheap)
      "social": { "model": "minimax/abab6-chat" },
      "analyst": { "model": "minimax/abab6-chat" },
      "email": { "model": "minimax/abab6-chat" },
      "designer": { "model": "minimax/abab6-chat" },
      "pm": { "model": "minimax/abab6-chat" },
      "strategist": { "model": "minimax/abab6-chat" },
      "seo": { "model": "minimax/abab6-chat" },
      "video": { "model": "minimax/abab6-chat" }
    }
  }
}
```

**MiniMax Pricing:**
```
abab6-chat: ~$0.0001 per 1K tokens (10x cheaper than Claude Haiku)

Estimated monthly (8 agents, high volume):
  - 10M tokens/maand = €10-15/maand

vs Claude Haiku (8 agents):
  - 10M tokens = €120-150/maand

SAVINGS: €105-135/maand (88% reduction)
```

---

### Alternative: z.ai (Coming Soon)

**z.ai positioning:**
- Focus: Speed + cost efficiency
- Pricing: TBD (expected competitive with Groq/Together)
- Best for: Real-time responses, high throughput

**Recommended when available:**
```json5
{
  "agents": {
    "routing": {
      // Real-time agents = z.ai (fast, cheap)
      "social": { "model": "z.ai/fast-model" },
      "analyst": { "model": "z.ai/fast-model" },

      // Strategic = Claude
      "ceo": { "model": "anthropic/sonnet-4.5" },
      "copywriter": { "model": "anthropic/sonnet-4.5" }
    }
  }
}
```

---

### Quality Comparison Matrix

| Task Type | Claude Opus | Claude Sonnet | Claude Haiku | MiniMax | Ollama Llama 3.1 | z.ai |
|-----------|-------------|---------------|--------------|---------|------------------|------|
| **Blog Posts (2000+ words)** | 10/10 ⭐⭐⭐ | 9/10 ⭐⭐ | 7/10 ⭐ | 6/10 | 5/10 | TBD |
| **Social Posts (short)** | 10/10 (overkill) | 9/10 (overkill) | 8/10 ✅ | 7/10 ✅ | 7/10 ✅ | TBD |
| **TikTok Scripts** | 10/10 (overkill) | 9/10 ✅ | 8/10 ✅ | 7/10 ✅ | 6/10 | TBD |
| **Analytics Reports** | 8/10 (overkill) | 8/10 (overkill) | 8/10 ✅ | 7/10 ✅ | 8/10 ✅ | TBD |
| **Email Drafts** | 9/10 (overkill) | 8/10 ✅ | 7/10 ✅ | 6/10 | 6/10 ✅ | TBD |
| **Strategic Planning** | 10/10 ⭐⭐⭐ | 9/10 ⭐⭐ | 6/10 | 5/10 | 4/10 | TBD |
| **Cost per 1M tokens** | €15 | €3 | €0.25 | €0.15 | €0 | TBD |

**Legend:**
- ⭐⭐⭐ = Best choice for this task
- ✅ = Good enough, cost-effective
- TBD = z.ai not yet fully tested

---

### Recommended Starting Configuration (Ultra Budget)

**For Lavish Pilot - Month 1:**

```bash
# VPS: Hetzner CPX31 (4 cores, 16GB RAM) - €25/maand
# Enough for: Ollama Llama 3.1 8B + Clawdbot Gateway

# Install Ollama
curl -fsSL https://ollama.com/install.sh | sh
ollama pull llama3.1:8b

# Configure Clawdbot to use Ollama by default
cat >> ~/.clawdbot/clawdbot.json << 'EOF'
{
  "agents": {
    "defaults": {
      "model": "ollama/llama3.1:8b"
    },

    "routing": {
      // Only use Claude for CEO + Copywriter
      "ceo": {
        "model": "anthropic/sonnet-4.5",
        "maxTurns": 5  // Limit to reduce costs
      },
      "copywriter": {
        "model": "anthropic/sonnet-4.5",
        "maxTurns": 3
      }

      // All other agents use Ollama (free)
      // No explicit config needed - inherits defaults
    }
  }
}
EOF
```

**Expected Costs (Month 1):**
```
VPS: €25/maand (Ollama hosting)
Claude: €60-90/maand (only CEO + Copywriter, limited usage)
Tools: €151/maand (essential stack)

TOTAL: €236-266/maand

vs Full Claude Enterprise: €730 + €151 = €881/maand
SAVINGS: €615-645/maand (70% reduction!)
```

---

### Quality Control: Hybrid Approach

**Problem:** Ollama quality kan inconsistent zijn voor client-facing content.

**Solution:** Two-pass workflow

```javascript
// ~/.clawdbot/agents/social/skills/two-pass-content.mjs
export const meta = {
  name: 'two-pass-content',
  description: 'Ollama draft → Claude refine (only if needed)'
}

export async function run(context, { topic, platform }) {
  // Pass 1: Ollama creates draft (free)
  const draft = await context.runAgent('social', {
    model: 'ollama/llama3.1:8b',
    message: `Create ${platform} post about: ${topic}`
  });

  // Quality check
  const qualityScore = evaluateQuality(draft);

  if (qualityScore > 7) {
    // Good enough - use Ollama draft
    return { content: draft, model: 'ollama', cost: 0 };
  } else {
    // Pass 2: Claude refines (paid, only when needed)
    const refined = await context.runAgent('ceo', {
      model: 'anthropic/haiku',  // Cheap refinement
      message: `Improve this ${platform} post:\n\n${draft}\n\nMake it more engaging and on-brand for Lavish.`
    });

    return { content: refined, model: 'claude-haiku', cost: 0.02 };
  }
}
```

**Result:**
- 70% of posts: Ollama (free)
- 30% of posts: Ollama draft + Claude refinement (€0.02 each)
- Average cost per post: €0.006 (vs €0.10 full Claude)

---

### Migration Path: Start Cheap, Scale Smart

**Month 1-2: Bootstrap**
```
Setup: Ollama + minimal Claude
Goal: Prove concept, build baseline
Cost: €236-266/maand
```

**Month 3-4: Growth**
```
Add: MiniMax for high-volume tasks
Upgrade: More Claude for quality content
Cost: €350-450/maand
```

**Month 5-6: Scale**
```
Optimize: Mix of Ollama, MiniMax, Claude based on learnings
Quality: Use Claude where ROI is proven
Cost: €500-700/maand
```

**Month 7+: Full Operation**
```
Mature: Data-driven model selection
ROI: Each model earns its cost back
Cost: €600-1,000/maand (but revenue covers it)
```

---

### Decision Matrix: Which Model When?

| Content Type | Start (Month 1) | Growth (Month 3) | Scale (Month 6) |
|--------------|-----------------|------------------|-----------------|
| **Blog posts** | Sonnet (2x/week) | Sonnet (3x/week) | Opus (5x/week) |
| **Social posts** | Ollama | MiniMax or Ollama | Haiku |
| **TikTok scripts** | Ollama | Ollama | Haiku |
| **Email drafts** | Ollama | Ollama | Haiku |
| **Analytics** | Ollama | Ollama | Ollama |
| **Strategy** | Sonnet (1x/week) | Sonnet (2x/week) | Opus (weekly) |
| **SEO work** | Ollama | MiniMax | Haiku |

---

### API Setup: Multi-Provider

```bash
# .env file voor multi-provider setup
cat >> ~/.env << 'EOF'
# Ollama (local, free)
OLLAMA_BASE_URL=http://localhost:11434

# Claude (premium quality)
ANTHROPIC_API_KEY=sk-ant-your-key

# MiniMax (budget volume)
MINIMAX_API_KEY=your-minimax-key
MINIMAX_BASE_URL=https://api.minimax.chat

# z.ai (when available)
# ZAI_API_KEY=your-zai-key
# ZAI_BASE_URL=https://api.z.ai

# Fallback strategy
AI_FALLBACK_ENABLED=true
AI_FALLBACK_ORDER=ollama,minimax,anthropic
EOF
```

---

## 💰 Kosten Overzicht (Maandelijks)

### Essential Tools (Minimum Viable Stack)

| Tool | Cost | Purpose |
|------|------|---------|
| **Hootsuite/Buffer** | €79/mo | Social scheduling |
| **Canva Pro** | €12/mo | Graphics design |
| **Mailchimp** | €35/mo | Email marketing (2,000 contacts) |
| **Google Analytics 4** | FREE | Website analytics |
| **Meta Business Suite** | FREE | Instagram/Facebook analytics |
| **Cloudinary** | €25/mo | Media storage/optimization |
| **Slack** | FREE | Team communication |

**Subtotal Essential:** €151/maand

---

### Professional Tools (Recommended for Growth)

| Tool | Cost | Purpose |
|------|------|---------|
| **Ahrefs** | €99/mo | Keyword research, SEO |
| **Surfer SEO** | €59/mo | Content optimization |
| **HubSpot Starter** | €45/mo | CRM for horeca leads |
| **SendGrid** | €15/mo | Transactional emails |
| **ElevenLabs** | €22/mo | AI voiceovers |

**Subtotal Professional:** €240/maand

---

### Premium Tools (For Scaling)

| Tool | Cost | Purpose |
|------|------|---------|
| **SEMrush** | €119/mo | Competitor analysis |
| **TikTok Ads Manager** | Variable | Paid promotion |
| **Meta Ads** | Variable | Instagram/Facebook ads |
| **Influencer platform** | €99/mo | Partnership management |

**Subtotal Premium:** €218/mo + ad spend

---

## 🎯 Total Monthly Tool Costs

**Tier 1 - Essential (Start):** €151/maand
**Tier 2 - Professional (Growth):** €391/maand
**Tier 3 - Premium (Scale):** €609/maand + ads

**Combined with JMG Team:**
- Essential: €151 + €730 = **€881/maand**
- Professional: €391 + €730 = **€1,121/maand**
- Premium: €609 + €730 + €500-1500 ads = **€1,839-2,339/maand**

---

## 📋 Setup Checklist voor Lavish Pilot

### Week 1: Foundation Setup

**Day 1-2: API Keys & Accounts**
```bash
# Create accounts & get API keys for:
□ Meta Business Suite (Instagram + Facebook)
□ TikTok Business Account
□ YouTube Channel + API
□ Google Analytics 4
□ Mailchimp account
□ Canva Pro
□ Cloudinary
□ Slack workspace

# Store in .env:
cat >> ~/.env << 'EOF'
META_ACCESS_TOKEN=your_token
META_PAGE_ID=your_page_id
TIKTOK_ACCESS_TOKEN=your_token
YOUTUBE_API_KEY=your_key
GA4_PROPERTY_ID=your_id
MAILCHIMP_API_KEY=your_key
MAILCHIMP_SERVER=us12
CANVA_API_KEY=your_key
CLOUDINARY_CLOUD_NAME=your_name
CLOUDINARY_API_KEY=your_key
SLACK_WEBHOOK_URL=your_webhook
EOF
```

**Day 3-4: Install Skills**
```bash
# Install all Lavish-specific skills
cd ~/.clawdbot/skills

# Social media skills
curl -O https://raw.githubusercontent.com/.../meta-post.mjs
curl -O https://raw.githubusercontent.com/.../tiktok-post.mjs
curl -O https://raw.githubusercontent.com/.../youtube-upload.mjs

# Analytics skills
curl -O https://raw.githubusercontent.com/.../ga4-report.mjs
curl -O https://raw.githubusercontent.com/.../meta-insights.mjs
curl -O https://raw.githubusercontent.com/.../tiktok-analytics.mjs

# Content creation skills
curl -O https://raw.githubusercontent.com/.../canva-create.mjs
curl -O https://raw.githubusercontent.com/.../dalle-generate.mjs
curl -O https://raw.githubusercontent.com/.../elevenlabs-tts.mjs

# SEO skills (if budget allows)
curl -O https://raw.githubusercontent.com/.../ahrefs-keywords.mjs
curl -O https://raw.githubusercontent.com/.../surfer-optimize.mjs

# Email skills
curl -O https://raw.githubusercontent.com/.../mailchimp-send.mjs

# CRM skills
curl -O https://raw.githubusercontent.com/.../hubspot-create-deal.mjs

# Utility skills
curl -O https://raw.githubusercontent.com/.../cloudinary-upload.mjs
curl -O https://raw.githubusercontent.com/.../slack-alert.mjs

chmod +x *.mjs
```

**Day 5: Test All Integrations**
```bash
# Test each skill
clawdbot agent --agent ceo --message "Test all API integrations:
1. Post test content to Meta (unpublished)
2. Fetch GA4 data for last 7 days
3. Generate test image with DALL-E
4. Upload to Cloudinary
5. Send test Slack notification

Report which integrations work and which need fixing."
```

---

### Week 2: Content Templates & Workflows

**Social Media Templates (Canva)**
```bash
# Create reusable Canva templates:
□ Instagram Feed Post (1080x1080)
□ Instagram Story (1080x1920)
□ TikTok Cover (1080x1920)
□ Facebook Event Cover (1920x1080)
□ YouTube Thumbnail (1280x720)
□ Email Newsletter Header (600x200)

# Save template IDs in config
cat >> ~/.clawdbot/lavish-config.json << 'EOF'
{
  "canva_templates": {
    "instagram_feed": "template_id_123",
    "instagram_story": "template_id_456",
    "tiktok_cover": "template_id_789",
    "facebook_event": "template_id_abc",
    "youtube_thumb": "template_id_def",
    "email_header": "template_id_ghi"
  }
}
EOF
```

**Content Calendar Setup (Google Calendar)**
```bash
# Create calendars:
□ Lavish Content Calendar (all posts)
□ Lavish Events Calendar (festivals, club nights)
□ Lavish Deadlines Calendar (campaign launches)

# Share with all agents
```

---

### Week 3: Monitoring & Reporting

**Daily Dashboard (Google Sheets + API)**
```javascript
// ~/.clawdbot/skills/daily-dashboard-update.mjs
export const meta = {
  name: 'daily-dashboard-update',
  description: 'Update Google Sheets dashboard met daily metrics'
}

export async function run(context) {
  const { google } = await import('googleapis');
  const sheets = google.sheets('v4');

  // Fetch all metrics
  const instagramData = await context.runSkill('meta-insights', {
    platform: 'instagram',
    metric: 'impressions,reach,engagement',
    period: 'day'
  });

  const gaData = await context.runSkill('ga4-report', {
    metric: 'sessions',
    startDate: 'yesterday',
    endDate: 'today'
  });

  // Update Google Sheet
  await sheets.spreadsheets.values.update({
    spreadsheetId: process.env.LAVISH_DASHBOARD_SHEET_ID,
    range: `Dashboard!A${getNextRow()}:F${getNextRow()}`,
    valueInputOption: 'RAW',
    requestBody: {
      values: [[
        new Date().toISOString().split('T')[0],
        instagramData.impressions,
        instagramData.engagement,
        gaData.sessions,
        // ... more metrics
      ]]
    }
  });

  return { updated: true };
}
```

---

## 🚀 Quick Start Commands

### Daily Routine (Automated)
```bash
# Add to cron (06:00 daily)
0 6 * * * clawdbot agent --agent analyst --message "Run daily routine:
1. Fetch yesterday's analytics (GA4, Instagram, TikTok, Facebook)
2. Update dashboard
3. Alert if any metric dropped >20%
4. Post summary to Slack #lavish-daily"
```

### Content Production (Morning)
```bash
# 08:00 - Content Strategist
clawdbot agent --agent strategist --message "Morning planning:
1. Check trending hashtags (#cocktails, #nightlife, etc)
2. Analyze competitor posts from yesterday
3. Suggest 3 content ideas for today based on trends
4. Post to Slack #lavish-content"

# 09:00 - Social Manager
clawdbot agent --agent social --message "Create today's content:
1. Generate 3 social posts (use trending ideas)
2. Create graphics via Canva
3. Schedule for 10AM, 2PM, 6PM
4. Preview in Slack for approval"
```

### Weekly Reporting (Monday 09:00)
```bash
clawdbot agent --agent ceo --message "Generate weekly report:
1. Analyze last week's performance (all channels)
2. Top 3 performing posts
3. Growth metrics (followers, engagement, traffic)
4. Horeca leads generated
5. Recommendations for this week
6. Send via email to stakeholders"
```

---

## 📊 Success Metrics Dashboard

**KPIs to Track (Automated):**

```javascript
// Daily metrics
const dailyKPIs = {
  social: {
    instagram: ['likes', 'comments', 'shares', 'saves', 'reach', 'impressions'],
    tiktok: ['views', 'likes', 'comments', 'shares', 'followers'],
    facebook: ['likes', 'comments', 'shares', 'reach'],
    youtube: ['views', 'watch_time', 'subscribers']
  },
  website: {
    ga4: ['sessions', 'users', 'pageviews', 'bounce_rate', 'avg_session_duration']
  },
  email: {
    mailchimp: ['sent', 'opens', 'clicks', 'unsubscribes']
  },
  business: {
    crm: ['new_leads', 'deals_created', 'revenue_pipeline']
  }
};

// Weekly reporting
const weeklyReporting = {
  follower_growth: 'All platforms',
  engagement_rate: 'All platforms',
  top_posts: 'Top 10 by engagement',
  traffic_sources: 'GA4 breakdown',
  conversion_rate: 'Website → Email signups',
  horeca_pipeline: 'New partnerships'
};
```

---

## ✅ Final Checklist: Ready for Pilot

**Pre-Launch (Before Day 1):**
```
□ All API keys configured in .env
□ All skills installed and tested
□ Canva templates created
□ Content calendar setup
□ Email lists imported (B2C + B2B)
□ CRM configured (horeca leads)
□ Google Analytics 4 tracking installed on website
□ Social media business accounts verified
□ Team Slack workspace active
□ Dashboard created (Google Sheets or custom)
□ Backup system configured (daily backups)
□ Monitoring alerts configured (Slack + email)
```

**Week 1 Goals:**
```
□ Post 7 Instagram feed posts
□ Post 14 Instagram stories
□ Post 10 TikTok videos
□ Post 7 Facebook posts
□ Send 1 email newsletter (B2C)
□ Send 1 B2B horeca email
□ Generate 5+ horeca leads
□ Achieve 100+ new followers (combined)
□ Test all automation workflows
□ Establish baseline metrics
```

---

**Klaar voor deployment! Met deze instrumenten heeft het JMG team alles wat nodig is om Lavish te laten exploderen.** 🦞🍹🚀
