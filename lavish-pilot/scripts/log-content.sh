#!/bin/bash
# Usage: ./log-content.sh <platform> <type> <theme> <url> [agent]

if [ $# -lt 4 ]; then
  echo "Usage: $0 <platform> <type> <theme> <url> [agent]"
  echo ""
  echo "Example:"
  echo "  $0 instagram feed_post weekend-vibes https://instagram.com/p/abc123 social-manager"
  exit 1
fi

PLATFORM=$1
TYPE=$2
THEME=$3
URL=$4
AGENT=${5:-"social-manager"}

MEMORY_DIR="/root/.lavish-pilot/memory"
TIMESTAMP=$(date -u +%Y-%m-%dT%H:%M:%SZ)
ID="${PLATFORM}-$(date +%Y%m%d)-$(openssl rand -hex 3)"

# Create JSON entry
cat >> "$MEMORY_DIR/content-history.jsonl" << EOF
{"id":"$ID","timestamp":"$TIMESTAMP","platform":"$PLATFORM","type":"$TYPE","agent":"$AGENT","theme":"$THEME","status":"published","url":"$URL","metrics":{"likes":0,"comments":0,"shares":0,"saves":0,"reach":0},"tags":[]}
EOF

# Update platform state
PLATFORM_FILE="$MEMORY_DIR/platform-state/${PLATFORM}.json"

if [ ! -f "$PLATFORM_FILE" ]; then
  echo "Error: Platform file not found: $PLATFORM_FILE"
  exit 1
fi

# Increment total posts
CURRENT_COUNT=$(jq -r '.total_posts // 0' "$PLATFORM_FILE")
NEW_COUNT=$((CURRENT_COUNT + 1))

# Update theme tracking
jq ".total_posts = $NEW_COUNT | 
    .last_updated = \"$TIMESTAMP\" | 
    .themes[\"$THEME\"].last_posted = \"$TIMESTAMP\" | 
    .themes[\"$THEME\"].count_last_30_days = (.themes[\"$THEME\"].count_last_30_days // 0) + 1" \
  "$PLATFORM_FILE" > /tmp/platform-state-$$.json && \
  mv /tmp/platform-state-$$.json "$PLATFORM_FILE"

echo "✅ Logged content: $ID"
echo "   Platform: $PLATFORM"
echo "   Type: $TYPE"
echo "   Theme: $THEME"
echo "   URL: $URL"
echo "   Agent: $AGENT"
