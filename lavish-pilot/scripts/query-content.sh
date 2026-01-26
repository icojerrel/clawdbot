#!/bin/bash
# Usage: ./query-content.sh {recent|platform|theme|stats} [arg]

MEMORY_DIR="/root/.lavish-pilot/memory"
HISTORY_FILE="$MEMORY_DIR/content-history.jsonl"

if [ ! -f "$HISTORY_FILE" ]; then
  echo "No content history found. Post some content first!"
  exit 1
fi

# Check if history file is empty
if [ ! -s "$HISTORY_FILE" ]; then
  echo "Content history is empty. Post some content first!"
  exit 0
fi

case "$1" in
  "recent")
    echo "📅 Recent Posts (Last 7 Days):"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    cat "$HISTORY_FILE" | jq -r '"\(.timestamp) | \(.platform) | \(.theme) | \(.id)"' | tail -20
    ;;
    
  "platform")
    PLATFORM=$2
    if [ -z "$PLATFORM" ]; then
      echo "Usage: $0 platform <platform-name>"
      echo "Available: instagram, tiktok, facebook, youtube"
      exit 1
    fi
    echo "📱 All $PLATFORM Posts:"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    cat "$HISTORY_FILE" | jq -r "select(.platform == \"$PLATFORM\") | \"\(.timestamp) | \(.theme) | \(.url)\""
    ;;
    
  "theme")
    THEME=$2
    if [ -z "$THEME" ]; then
      echo "Usage: $0 theme <theme-name>"
      exit 1
    fi
    echo "🎯 All '$THEME' Posts:"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    cat "$HISTORY_FILE" | jq -r "select(.theme == \"$THEME\") | \"\(.platform) | \(.timestamp) | \(.url)\""
    ;;
    
  "stats")
    echo "📊 Content Statistics"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    TOTAL=$(wc -l < "$HISTORY_FILE")
    echo "Total Posts: $TOTAL"
    echo ""
    echo "By Platform:"
    cat "$HISTORY_FILE" | jq -r '.platform' | sort | uniq -c | awk '{printf "  %-15s %s\n", $2":", $1}'
    echo ""
    echo "By Theme (Top 10):"
    cat "$HISTORY_FILE" | jq -r '.theme' | sort | uniq -c | sort -rn | head -10 | awk '{printf "  %-25s %s\n", $2":", $1}'
    echo ""
    echo "By Agent:"
    cat "$HISTORY_FILE" | jq -r '.agent' | sort | uniq -c | awk '{printf "  %-20s %s\n", $2":", $1}'
    ;;
    
  "last")
    COUNT=${2:-10}
    echo "📝 Last $COUNT Posts:"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    cat "$HISTORY_FILE" | tail -n "$COUNT" | jq -r '"\(.id) | \(.platform) | \(.theme)"'
    ;;
    
  *)
    echo "Lavish Content Query Tool"
    echo ""
    echo "Usage: $0 {command} [args]"
    echo ""
    echo "Commands:"
    echo "  recent              Show recent posts (last 7 days)"
    echo "  platform <name>     Show all posts for platform"
    echo "  theme <name>        Show all posts for theme"
    echo "  stats               Show overall statistics"
    echo "  last [n]            Show last N posts (default: 10)"
    echo ""
    echo "Examples:"
    echo "  $0 recent"
    echo "  $0 platform instagram"
    echo "  $0 theme weekend-vibes"
    echo "  $0 stats"
    ;;
esac
