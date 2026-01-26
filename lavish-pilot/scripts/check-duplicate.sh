#!/bin/bash
# Usage: ./check-duplicate.sh <platform> <theme> [threshold_days]

if [ $# -lt 2 ]; then
  echo "Usage: $0 <platform> <theme> [threshold_days]"
  echo ""
  echo "Example:"
  echo "  $0 instagram weekend-vibes 7"
  echo ""
  echo "Returns: exit 0 (safe to post) or exit 1 (duplicate warning)"
  exit 2
fi

PLATFORM=$1
THEME=$2
THRESHOLD=${3:-7}  # Default: 7 days between same theme
MEMORY_DIR="/root/.lavish-pilot/memory"

echo "🔍 Checking for duplicate content..."
echo "   Platform: $PLATFORM"
echo "   Theme: $THEME"
echo "   Threshold: $THRESHOLD days"
echo ""

# Check if platform file exists
PLATFORM_FILE="$MEMORY_DIR/platform-state/${PLATFORM}.json"

if [ ! -f "$PLATFORM_FILE" ]; then
  echo "✅ No history for $PLATFORM - safe to post"
  exit 0
fi

# Get last posted date for this theme
LAST_POSTED=$(jq -r ".themes[\"$THEME\"].last_posted // \"never\"" "$PLATFORM_FILE")

if [ "$LAST_POSTED" == "never" ] || [ "$LAST_POSTED" == "null" ]; then
  echo "✅ Theme '$THEME' never posted on $PLATFORM - safe to post"
  exit 0
fi

# Calculate days since last post
LAST_TIMESTAMP=$(date -d "$LAST_POSTED" +%s 2>/dev/null || echo 0)
NOW_TIMESTAMP=$(date +%s)
DAYS_AGO=$(( (NOW_TIMESTAMP - LAST_TIMESTAMP) / 86400 ))

# Get post count last 30 days
COUNT_30D=$(jq -r ".themes[\"$THEME\"].count_last_30_days // 0" "$PLATFORM_FILE")

echo "📊 Theme Statistics:"
echo "   Last posted: $LAST_POSTED ($DAYS_AGO days ago)"
echo "   Posts (last 30d): $COUNT_30D"
echo ""

# Check threshold
if [ $DAYS_AGO -lt $THRESHOLD ]; then
  echo "⚠️  WARNING: Potential duplicate detected!"
  echo "   Theme '$THEME' posted only $DAYS_AGO days ago on $PLATFORM"
  echo "   Threshold: $THRESHOLD days minimum"
  echo ""
  echo "💡 Recommendations:"
  echo "   1. Choose a different theme"
  echo "   2. Wait $((THRESHOLD - DAYS_AGO)) more days"
  echo "   3. Create variation of same theme (different angle)"
  exit 1
else
  echo "✅ Safe to post!"
  echo "   Theme '$THEME' last posted $DAYS_AGO days ago"
  echo "   Exceeds threshold of $THRESHOLD days"
  exit 0
fi
