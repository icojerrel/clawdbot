# MiniMax API Key - Complete Setup Guide

**Why you need this:** 6 van de 10 Lavish agents draaien op MiniMax (goedkoper dan Claude voor volume werk)

**Cost:** ~€20-30/maand voor 6 agents (versus €450/maand met Claude!)

---

## 🎯 Quick Overview

**MiniMax Agents in Lavish Team:**
1. **Strategist** - Content planning, keywords, trends
2. **Social Manager** - Instagram/TikTok/Facebook posting
3. **SEO Specialist** - Technical SEO, optimization
4. **Email Specialist** - Newsletters, campaigns
5. **Data Analyst** - Performance tracking, dashboards
6. **Project Manager** - Deadlines, task coordination

**Model:** abab6.5-chat (equivalent to GPT-4 level, maar goedkoper)

---

## 📝 Step-by-Step Signup Process

### **Step 1: Go to MiniMax Website**

**URL:** https://www.minimaxi.com

**Important Notes:**
- ⚠️ Website might be in Chinese initially - look for language toggle
- ✅ English interface available
- ✅ International sign-ups accepted
- ✅ Accepts international credit cards

**Alternative URLs to try:**
- https://api.minimax.chat (API docs)
- https://platform.minimaxi.com (platform dashboard)

---

### **Step 2: Create Account**

**Click:** "Sign Up" or "注册" (if Chinese)

**You'll need:**
- Email address (any email works)
- Password (strong password recommended)
- Phone number (international OK)
  - Format: +31 6 12345678 (Netherlands)
  - SMS verification code will be sent

**Verification:**
- Check your email for verification link
- Click link to verify
- You may need to verify phone as well (SMS code)

**Account Type:**
- Select: **Developer/API Access** (not consumer app)
- Or: **Business Account** if available

---

### **Step 3: Navigate to API Keys Section**

After login:

1. **Look for:** Dashboard / Console / API Settings
   - Might be labeled: "API密钥" (Chinese) or "API Keys" (English)
   - Usually in top-right menu or sidebar

2. **Menu path (typical):**
   ```
   Dashboard → Settings → API Keys
   OR
   Console → Credentials → API Keys
   OR
   Account → Developer → API Access
   ```

---

### **Step 4: Create New API Key**

**Click:** "Create API Key" or "新建密钥"

**Fill in:**
- **Key Name:** `Lavish-Pilot` (or any descriptive name)
- **Key Type:** Server-side / Backend (NOT browser/frontend)
- **Permissions:** Full API access (or select: Chat Completion)
- **Rate Limit:** Default (or highest available)
- **IP Whitelist:** Leave empty for now (or add VPS IP later)

**Click:** "Create" or "确认"

---

### **Step 5: Copy Your Credentials**

**You'll receive TWO values:**

1. **API Key** (长密钥)
   - Format: `eyJhbGci...` (long string, starts with eyJ or similar)
   - Example: `eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...`

2. **Group ID** (分组ID)
   - Format: Usually numeric or alphanumeric
   - Example: `1234567890` or `group_abc123`

**⚠️ CRITICAL:**
- **COPY BOTH IMMEDIATELY** - they may only show once!
- **Save to password manager** or secure note
- **Never share publicly**

**Screenshot recommended:** Take a screenshot as backup

---

### **Step 6: Add Credits / Payment**

**MiniMax uses prepaid credits:**

1. **Go to:** Billing / Recharge / 充值
2. **Minimum top-up:** Usually ¥100 CNY (~€13) or $20 USD
3. **Recommended first top-up:** ¥200-500 CNY (~€25-65)
   - This gives you ~1-2 months runway

**Payment methods:**
- International credit card (Visa/Mastercard)
- PayPal (if available)
- Alipay (if you have Chinese account)
- WeChat Pay (if available)

**Pricing (approximate):**
- ¥0.015 per 1K tokens (~€0.002)
- Lavish pilot: ~6-10M tokens/month = ¥90-150 (~€12-20)

---

### **Step 7: Verify API Key Works**

**Quick test (on machine with internet):**

```bash
# Save this as test-minimax.sh
curl -X POST https://api.minimax.chat/v1/text/chatcompletion_v2 \
  -H "Authorization: Bearer YOUR_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "model": "abab6.5-chat",
    "tokens_to_generate": 50,
    "messages": [
      {
        "sender_type": "USER",
        "text": "Say: MiniMax working for Lavish!"
      }
    ],
    "bot_setting": [
      {
        "bot_name": "Test",
        "content": "You are a helpful assistant."
      }
    ]
  }' \
  --header "GroupId: YOUR_GROUP_ID"
```

**Expected response:**
```json
{
  "reply": "MiniMax working for Lavish!",
  "usage": {
    "total_tokens": 15
  }
}
```

**If successful:** ✅ Your key works!
**If error:** Check API key, Group ID, and credits balance

---

### **Step 8: Add to Lavish Pilot .env File**

**On your deployment machine:**

```bash
# Edit environment file
nano ~/.lavish-pilot/.env

# Add these lines (replace with YOUR values):
MINIMAX_API_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
MINIMAX_GROUP_ID=1234567890

# Save: Ctrl+X, Y, Enter
```

**Verify it's saved:**
```bash
cat ~/.lavish-pilot/.env | grep MINIMAX
```

**Should show:**
```
MINIMAX_API_KEY=eyJ...
MINIMAX_GROUP_ID=123...
```

---

## 🔧 Troubleshooting

### **Problem: Website is all Chinese**

**Solutions:**
1. **Chrome auto-translate:** Right-click → "Translate to English"
2. **Look for language toggle:** Usually top-right (EN/中文)
3. **Use Chrome DevTools:** F12 → Look for API endpoints to call directly

### **Problem: Can't verify phone number**

**Solutions:**
1. Try different phone number format: `+31612345678` (no spaces)
2. Use Google Voice number (if available in your country)
3. Contact support (usually has English option)
4. Try alternative: Some APIs allow email-only signup

### **Problem: Payment not accepted**

**Solutions:**
1. Ensure card is enabled for international transactions
2. Try PayPal if available
3. Use virtual card (Revolut, Wise)
4. Contact bank to authorize transaction
5. Try smaller amount first (minimum top-up)

### **Problem: API Key not working**

**Check:**
1. ✅ Credits balance > 0
2. ✅ API key copied completely (no spaces/truncation)
3. ✅ Group ID is correct
4. ✅ Endpoint URL is correct: `https://api.minimax.chat/v1/...`
5. ✅ Model name exact: `abab6.5-chat` (not abab6.5 or abab-6.5)

### **Problem: Rate limit errors**

**Solutions:**
1. Check your tier/plan limits
2. Upgrade plan if needed
3. Add delays between requests
4. Contact support to increase limits

---

## 💰 Pricing & Budget Planning

### **MiniMax Pricing (as of 2026):**

**Model: abab6.5-chat**
- Input: ¥0.015 per 1K tokens (~€0.002)
- Output: ¥0.015 per 1K tokens (~€0.002)

**Lavish Pilot Usage Estimate:**

| Agent | Daily Tokens | Monthly Tokens | Monthly Cost |
|-------|--------------|----------------|--------------|
| Strategist | 50K | 1.5M | €3-4 |
| Social Manager | 80K | 2.4M | €5-6 |
| SEO Specialist | 30K | 900K | €2-3 |
| Email Specialist | 40K | 1.2M | €2-3 |
| Data Analyst | 50K | 1.5M | €3-4 |
| Project Manager | 30K | 900K | €2-3 |
| **TOTAL** | **280K** | **8.4M** | **€17-23** |

**Add 30% buffer:** €22-30/maand

**Top-up recommendation:**
- **First month:** ¥300 (~€40) - gives you 2 months runway
- **After that:** ¥150-200/month (~€20-25)

---

## 📊 Cost Comparison

| Provider | 6 Agents Cost | Notes |
|----------|---------------|-------|
| **Claude (Sonnet 4.5)** | €450/maand | Premium quality |
| **OpenAI (GPT-4)** | €300/maand | High cost |
| **MiniMax (abab6.5)** | €22-30/maand | ⭐ **93% cheaper!** |

**Lavish Pilot Total (with MiniMax + z.ai):**
- z.ai (4 agents): €15-25
- MiniMax (6 agents): €22-30
- **Total AI costs:** €37-55/maand

vs.

- All Claude: €600-800/maand

**Savings: €545-745/maand (91% reduction!)**

---

## ✅ Success Checklist

After getting your MiniMax key:

- [ ] Account created on minimaxi.com
- [ ] Email verified
- [ ] Phone verified (if required)
- [ ] API key created and copied
- [ ] Group ID copied
- [ ] Credits added (¥100+ minimum)
- [ ] Test API call successful
- [ ] Keys added to ~/.lavish-pilot/.env
- [ ] .env file permissions: 600 (secure)

**Then you're ready to deploy!**

---

## 🔐 Security Best Practices

**DO:**
- ✅ Store keys in .env file only
- ✅ Set file permissions: `chmod 600 ~/.lavish-pilot/.env`
- ✅ Use environment variables (never hardcode)
- ✅ Rotate keys every 90 days
- ✅ Monitor usage in MiniMax dashboard

**DON'T:**
- ❌ Commit keys to git
- ❌ Share keys in screenshots/docs
- ❌ Use same key across projects
- ❌ Store keys in plaintext files
- ❌ Share keys in Slack/Discord

---

## 📞 Support Resources

**MiniMax Official:**
- Docs: https://api.minimax.chat/document
- Support: Usually has live chat in dashboard
- Email: Check "Contact Us" in platform

**Community:**
- Clawdbot Discord: https://discord.gg/clawd (ask #help-needed)
- This deployment: Check lavish-pilot/README.md

**If stuck:**
1. Check dashboard for error messages
2. Verify credits balance
3. Test with curl command above
4. Contact MiniMax support (usually responsive)

---

## 🎯 Next Steps After Getting Key

1. **Add to .env:**
   ```bash
   nano ~/.lavish-pilot/.env
   # Add MINIMAX_API_KEY and MINIMAX_GROUP_ID
   ```

2. **Verify configuration:**
   ```bash
   source ~/.lavish-pilot/.env
   echo $MINIMAX_API_KEY  # Should show your key
   ```

3. **Run deployment:**
   ```bash
   cd /path/to/lavish-pilot
   ./deploy.sh
   ```

4. **Test agents:**
   ```bash
   clawdbot agent --agent strategist --message "Test: Can you hear me?"
   ```

**Then:** You're live! Start Week 1 of the Lavish pilot 🚀

---

## 🌐 Alternative: If MiniMax Doesn't Work

**If you can't get MiniMax (China restrictions, payment issues, etc.):**

**Option 1: Use OpenAI instead**
- Cost: Higher (~€50-80/maand for 6 agents)
- Model: gpt-4-turbo or gpt-3.5-turbo
- Easy signup: https://platform.openai.com

**Option 2: Use Anthropic Claude**
- Cost: Much higher (~€450/maand)
- Model: Claude Sonnet 4.5
- Known to work well

**Option 3: Mix of providers**
- 2 agents on OpenAI
- 2 agents on Claude Haiku (cheaper)
- 2 agents on Ollama local (free but slower)

**Edit in .env:**
```bash
# If using OpenAI instead of MiniMax
OPENAI_API_KEY=sk-...

# Then edit clawdbot config to use openai/gpt-4-turbo
# for the 6 agents instead of minimax/abab6.5-chat
```

---

**Current Status:**
- ✅ z.ai configured (4 agents)
- ⏳ MiniMax needed (6 agents)
- 🎯 Next: Get MiniMax key following this guide

**Total time:** 10-15 minutes (including verification)

Good luck! 🚀
