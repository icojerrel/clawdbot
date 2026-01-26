#!/bin/bash

MEMORY_DIR="/root/.lavish-pilot/memory"

echo "🧠 Initializing Lavish Content Memory System..."

# Create directory structure
mkdir -p "$MEMORY_DIR/agent-context"
mkdir -p "$MEMORY_DIR/platform-state"

# Initialize content history log
touch "$MEMORY_DIR/content-history.jsonl"

# Initialize content ideas pool
cat > "$MEMORY_DIR/content-ideas-pool.json" << 'EOF'
{
  "ideas": [],
  "total_ideas": 0,
  "unused_count": 0,
  "used_count": 0,
  "last_updated": "'$(date -u +%Y-%m-%dT%H:%M:%SZ)'"
}
EOF

# Initialize performance cache
cat > "$MEMORY_DIR/performance-cache.json" << 'EOF'
{
  "last_updated": "'$(date -u +%Y-%m-%dT%H:%M:%SZ)'",
  "posts": {}
}
EOF

# Initialize platform state files
for platform in instagram tiktok facebook youtube; do
  cat > "$MEMORY_DIR/platform-state/${platform}.json" << EOF
{
  "platform": "$platform",
  "last_updated": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "total_posts": 0,
  "themes": {}
}
EOF
  echo "  ✓ Created platform state: $platform"
done

# Initialize agent context files
for agent in social-manager copywriter video-creator strategist designer analyst pm ceo; do
  cat > "$MEMORY_DIR/agent-context/${agent}.json" << EOF
{
  "agent": "$agent",
  "last_updated": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "recent_posts": [],
  "content_themes_used": {},
  "successful_patterns": [],
  "avoid_patterns": [],
  "current_focus": "Festival season content",
  "next_themes_to_explore": []
}
EOF
  echo "  ✓ Created agent context: $agent"
done

echo ""
echo "✅ Memory system initialized at $MEMORY_DIR"
echo ""
echo "📂 Directory structure:"
tree -L 2 "$MEMORY_DIR" 2>/dev/null || find "$MEMORY_DIR" -type f
echo ""
echo "📋 Next steps:"
echo "1. Agents: Read from memory before creating content"
echo "2. Log: Use scripts/log-content.sh after publishing"
echo "3. Check: Use scripts/check-duplicate.sh before posting"
echo "4. Query: Use scripts/query-content.sh to analyze history"
