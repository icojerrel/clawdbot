#!/bin/bash
set -e

# Lavish Nederland Pilot - Automated Deployment Script
# Version: 1.0
# Usage: ./deploy.sh [--dry-run]

DRY_RUN=false
if [[ "$1" == "--dry-run" ]]; then
  DRY_RUN=true
  echo "🔍 DRY RUN MODE - No changes will be made"
fi

PILOT_DIR="$HOME/.lavish-pilot"
CLAWDBOT_DIR="$HOME/.clawdbot"

echo "╔══════════════════════════════════════════════════════════════╗"
echo "║                                                              ║"
echo "║       LAVISH NEDERLAND PILOT - DEPLOYMENT SCRIPT             ║"
echo "║                                                              ║"
echo "║  JMG Content Group - 24/7 AI Content Agency                  ║"
echo "║  10 Agents | MiniMax + z.ai | €254-385/maand                 ║"
echo "║                                                              ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo ""

# Function: Check if command exists
command_exists() {
  command -v "$1" >/dev/null 2>&1
}

# Function: Print step
step() {
  echo ""
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "▶ $1"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
}

# Function: Check prerequisites
check_prerequisites() {
  step "STEP 1: Checking Prerequisites"

  local missing=()

  # Check Node.js
  if ! command_exists node; then
    missing+=("Node.js 22+")
  else
    NODE_VERSION=$(node -v | cut -d'v' -f2 | cut -d'.' -f1)
    if [ "$NODE_VERSION" -lt 22 ]; then
      missing+=("Node.js 22+ (current: v$NODE_VERSION)")
    else
      echo "✓ Node.js $(node -v)"
    fi
  fi

  # Check npm
  if ! command_exists npm; then
    missing+=("npm")
  else
    echo "✓ npm $(npm -v)"
  fi

  # Check clawdbot
  if ! command_exists clawdbot; then
    echo "⚠️  Clawdbot not installed - will install"
  else
    echo "✓ clawdbot $(clawdbot --version 2>/dev/null || echo 'installed')"
  fi

  # Check curl
  if ! command_exists curl; then
    missing+=("curl")
  else
    echo "✓ curl"
  fi

  # Check jq (optional but helpful)
  if command_exists jq; then
    echo "✓ jq (optional)"
  fi

  if [ ${#missing[@]} -ne 0 ]; then
    echo ""
    echo "❌ Missing prerequisites:"
    printf '   - %s\n' "${missing[@]}"
    echo ""
    echo "Please install missing prerequisites and try again."
    exit 1
  fi

  echo ""
  echo "✅ All prerequisites met!"
}

# Function: Load or create environment variables
setup_environment() {
  step "STEP 2: Environment Variables Setup"

  ENV_FILE="$PILOT_DIR/.env"

  if [ -f "$ENV_FILE" ]; then
    echo "✓ Found existing .env file at $ENV_FILE"
    source "$ENV_FILE"
  else
    echo "📝 Creating new .env file at $ENV_FILE"

    if [ "$DRY_RUN" = true ]; then
      echo "   [DRY RUN] Would create .env file"
      return
    fi

    mkdir -p "$PILOT_DIR"

    cat > "$ENV_FILE" << 'EOF'
# Lavish Pilot Environment Variables
# Fill in your actual API keys below

# Gateway Auth (generate secure token)
CLAWDBOT_GATEWAY_TOKEN=

# AI Model Providers
ZAI_API_KEY=
MINIMAX_API_KEY=
MINIMAX_GROUP_ID=
OPENAI_API_KEY=

# Messaging Channels
SLACK_BOT_TOKEN=
TELEGRAM_BOT_TOKEN=
ADMIN_TELEGRAM_ID=

# Lavish Social Media (Meta Business Suite)
META_ACCESS_TOKEN=
META_PAGE_ID=
META_INSTAGRAM_ACCOUNT_ID=

# TikTok Business API
TIKTOK_ACCESS_TOKEN=

# Analytics
GA4_PROPERTY_ID=
GA4_MEASUREMENT_ID=

# SEO Tools
AHREFS_API_KEY=
SEMRUSH_API_KEY=

# Email Marketing
MAILCHIMP_API_KEY=
MAILCHIMP_LIST_ID=

# Design Tools
CANVA_API_KEY=
EOF

    chmod 600 "$ENV_FILE"

    echo ""
    echo "⚠️  IMPORTANT: Edit $ENV_FILE and fill in your API keys!"
    echo ""
    echo "   Required keys:"
    echo "   - ZAI_API_KEY (https://z.ai)"
    echo "   - MINIMAX_API_KEY + MINIMAX_GROUP_ID (https://minimaxi.com)"
    echo "   - SLACK_BOT_TOKEN (for team communication)"
    echo "   - TELEGRAM_BOT_TOKEN (for client updates)"
    echo ""
    echo "   Optional but recommended:"
    echo "   - META_ACCESS_TOKEN (for Instagram/Facebook posting)"
    echo "   - TIKTOK_ACCESS_TOKEN (for TikTok analytics)"
    echo "   - GA4_PROPERTY_ID (for website tracking)"
    echo "   - AHREFS_API_KEY (for SEO research)"
    echo "   - MAILCHIMP_API_KEY (for email campaigns)"
    echo ""
    read -p "Press Enter after you've filled in the API keys..."

    source "$ENV_FILE"
  fi

  # Verify critical keys
  local missing_keys=()

  [ -z "$ZAI_API_KEY" ] && missing_keys+=("ZAI_API_KEY")
  [ -z "$MINIMAX_API_KEY" ] && missing_keys+=("MINIMAX_API_KEY")

  if [ ${#missing_keys[@]} -ne 0 ]; then
    echo ""
    echo "❌ Missing critical API keys:"
    printf '   - %s\n' "${missing_keys[@]}"
    echo ""
    echo "Edit $ENV_FILE and run deployment again."
    exit 1
  fi

  echo "✅ Environment variables loaded!"
}

# Function: Install Clawdbot
install_clawdbot() {
  step "STEP 3: Clawdbot Installation"

  if command_exists clawdbot; then
    echo "✓ Clawdbot already installed"

    # Check for updates
    echo "  Checking for updates..."
    if [ "$DRY_RUN" = false ]; then
      npm update -g clawdbot 2>/dev/null || true
    fi
  else
    echo "📦 Installing Clawdbot..."

    if [ "$DRY_RUN" = true ]; then
      echo "   [DRY RUN] Would run: npm install -g clawdbot@latest"
      return
    fi

    npm install -g clawdbot@latest
  fi

  echo "✅ Clawdbot ready: $(clawdbot --version 2>/dev/null || echo 'latest')"
}

# Function: Create directory structure
create_directories() {
  step "STEP 4: Creating Directory Structure"

  AGENTS=(ceo strategist copywriter social seo video email analyst designer pm)

  echo "Creating agent workspaces..."
  for agent in "${AGENTS[@]}"; do
    DIR="$CLAWDBOT_DIR/agents/$agent"

    if [ "$DRY_RUN" = true ]; then
      echo "   [DRY RUN] Would create: $DIR/{workspace,skills,sessions}"
      continue
    fi

    mkdir -p "$DIR"/{workspace,skills,sessions}
    echo "  ✓ $agent"
  done

  echo ""
  echo "Creating content directories..."
  CONTENT_DIRS=(
    "$PILOT_DIR/content/drafts"
    "$PILOT_DIR/content/published/blogs"
    "$PILOT_DIR/content/published/social"
    "$PILOT_DIR/content/published/videos"
    "$PILOT_DIR/content/published/emails"
    "$PILOT_DIR/content/assets/images"
    "$PILOT_DIR/content/assets/videos"
    "$PILOT_DIR/content/assets/templates"
    "$PILOT_DIR/content/calendar"
    "$PILOT_DIR/content/analytics"
    "$PILOT_DIR/scripts"
    "$PILOT_DIR/logs"
  )

  for dir in "${CONTENT_DIRS[@]}"; do
    if [ "$DRY_RUN" = false ]; then
      mkdir -p "$dir"
    fi
    echo "  ✓ $dir"
  done

  echo ""
  echo "✅ Directory structure created!"
}

# Function: Deploy agent configurations
deploy_agent_configs() {
  step "STEP 5: Deploying Agent Configurations"

  echo "Setting up agent personas for Lavish..."

  # This will be called from setup-lavish-agents.sh
  if [ -f "./scripts/setup-lavish-agents.sh" ]; then
    if [ "$DRY_RUN" = false ]; then
      bash ./scripts/setup-lavish-agents.sh
    else
      echo "   [DRY RUN] Would run: ./scripts/setup-lavish-agents.sh"
    fi
  else
    echo "⚠️  Agent setup script not found (will create later)"
  fi

  echo "✅ Agent configurations deployed!"
}

# Function: Deploy skills library
deploy_skills() {
  step "STEP 6: Deploying Skills Library"

  echo "Installing shared skills..."

  if [ -d "./skills" ]; then
    SKILL_COUNT=$(find ./skills -name "*.mjs" | wc -l)
    echo "  Found $SKILL_COUNT skills to deploy"

    if [ "$DRY_RUN" = false ]; then
      mkdir -p "$CLAWDBOT_DIR/skills"
      cp -v ./skills/*.mjs "$CLAWDBOT_DIR/skills/" 2>/dev/null || echo "  (No skills to copy yet)"
    else
      echo "   [DRY RUN] Would copy skills to $CLAWDBOT_DIR/skills/"
    fi
  else
    echo "⚠️  Skills directory not found (will create later)"
  fi

  echo "✅ Skills deployed!"
}

# Function: Configure Clawdbot
configure_clawdbot() {
  step "STEP 7: Configuring Clawdbot"

  CONFIG_FILE="$CLAWDBOT_DIR/clawdbot.json"

  echo "Creating Clawdbot configuration..."

  if [ "$DRY_RUN" = true ]; then
    echo "   [DRY RUN] Would create $CONFIG_FILE"
    return
  fi

  # Copy template config (will be created separately)
  if [ -f "./config/clawdbot.json" ]; then
    cp ./config/clawdbot.json "$CONFIG_FILE"
    echo "  ✓ Configuration copied"
  else
    echo "  ⚠️  Config template not found - using minimal config"

    cat > "$CONFIG_FILE" << 'JSONEOF'
{
  "gateway": {
    "mode": "local",
    "bind": "127.0.0.1",
    "port": 18789
  },
  "models": {
    "providers": {
      "z.ai": {
        "apiKey": "${ZAI_API_KEY}",
        "baseURL": "https://api.z.ai/v1"
      },
      "minimax": {
        "apiKey": "${MINIMAX_API_KEY}",
        "baseURL": "https://api.minimax.chat/v1",
        "groupId": "${MINIMAX_GROUP_ID}"
      }
    }
  }
}
JSONEOF
  fi

  echo "✅ Clawdbot configured!"
}

# Function: Setup automation scripts
setup_automation() {
  step "STEP 8: Setting Up Automation Scripts"

  echo "Deploying cron jobs..."

  if [ "$DRY_RUN" = true ]; then
    echo "   [DRY RUN] Would setup cron jobs for:"
    echo "   - Daily content production (06:00)"
    echo "   - Weekly strategy review (Mon 09:00)"
    echo "   - Monthly review (1st Mon 09:00)"
    echo "   - System health checks (every 30min)"
    return
  fi

  # Copy automation scripts
  if [ -d "./scripts" ]; then
    cp -v ./scripts/*.sh "$PILOT_DIR/scripts/" 2>/dev/null || true
    chmod +x "$PILOT_DIR/scripts"/*.sh 2>/dev/null || true
  fi

  echo "  ✓ Automation scripts deployed to $PILOT_DIR/scripts/"
  echo ""
  echo "  To install cron jobs, run:"
  echo "  crontab -e"
  echo ""
  echo "  And add these lines:"
  echo "  0 6 * * * $PILOT_DIR/scripts/daily-content-production.sh"
  echo "  0 9 * * 1 $PILOT_DIR/scripts/weekly-strategy-review.sh"
  echo "  */30 * * * * $PILOT_DIR/scripts/system-health.sh"

  echo "✅ Automation scripts ready!"
}

# Function: Start gateway
start_gateway() {
  step "STEP 9: Starting Clawdbot Gateway"

  if [ "$DRY_RUN" = true ]; then
    echo "   [DRY RUN] Would start gateway on port 18789"
    return
  fi

  echo "Starting gateway..."

  # Check if already running
  if curl -f http://localhost:18789/health >/dev/null 2>&1; then
    echo "  ✓ Gateway already running"
  else
    echo "  Starting gateway in background..."

    # Start in tmux session for easy monitoring
    if command_exists tmux; then
      tmux new-session -d -s lavish-gateway "clawdbot gateway run --bind 127.0.0.1 --port 18789"
      echo "  ✓ Gateway started in tmux session 'lavish-gateway'"
      echo "  Attach with: tmux attach -t lavish-gateway"
    else
      nohup clawdbot gateway run --bind 127.0.0.1 --port 18789 > "$PILOT_DIR/logs/gateway.log" 2>&1 &
      echo "  ✓ Gateway started (PID: $!)"
      echo "  Logs: $PILOT_DIR/logs/gateway.log"
    fi

    # Wait for startup
    echo "  Waiting for gateway to start..."
    for i in {1..10}; do
      if curl -f http://localhost:18789/health >/dev/null 2>&1; then
        echo "  ✓ Gateway is healthy!"
        break
      fi
      sleep 1
    done
  fi

  echo "✅ Gateway running!"
}

# Function: Verify deployment
verify_deployment() {
  step "STEP 10: Verifying Deployment"

  echo "Running health checks..."

  local failures=0

  # Check gateway
  if curl -f http://localhost:18789/health >/dev/null 2>&1; then
    echo "  ✓ Gateway health check passed"
  else
    echo "  ✗ Gateway health check failed"
    ((failures++))
  fi

  # Check agent directories
  local agent_count=0
  for agent in ceo strategist copywriter social seo video email analyst designer pm; do
    if [ -d "$CLAWDBOT_DIR/agents/$agent" ]; then
      ((agent_count++))
    fi
  done

  if [ $agent_count -eq 10 ]; then
    echo "  ✓ All 10 agent workspaces exist"
  else
    echo "  ✗ Only $agent_count/10 agent workspaces found"
    ((failures++))
  fi

  # Check content directories
  if [ -d "$PILOT_DIR/content" ]; then
    echo "  ✓ Content directory structure exists"
  else
    echo "  ✗ Content directories missing"
    ((failures++))
  fi

  # Check environment variables
  if [ -f "$PILOT_DIR/.env" ]; then
    echo "  ✓ Environment file exists"
  else
    echo "  ✗ Environment file missing"
    ((failures++))
  fi

  echo ""
  if [ $failures -eq 0 ]; then
    echo "✅ All health checks passed!"
  else
    echo "⚠️  $failures health check(s) failed"
  fi

  return $failures
}

# Function: Print next steps
print_next_steps() {
  step "DEPLOYMENT COMPLETE!"

  echo ""
  echo "╔══════════════════════════════════════════════════════════════╗"
  echo "║                                                              ║"
  echo "║  🎉 Lavish Pilot Deployment Successful!                      ║"
  echo "║                                                              ║"
  echo "╚══════════════════════════════════════════════════════════════╝"
  echo ""
  echo "📁 Installation Locations:"
  echo "   Pilot data:    $PILOT_DIR"
  echo "   Clawdbot:      $CLAWDBOT_DIR"
  echo "   Content:       $PILOT_DIR/content"
  echo "   Scripts:       $PILOT_DIR/scripts"
  echo "   Logs:          $PILOT_DIR/logs"
  echo ""
  echo "🔧 Configuration:"
  echo "   Config file:   $CLAWDBOT_DIR/clawdbot.json"
  echo "   Env file:      $PILOT_DIR/.env"
  echo ""
  echo "🚀 Gateway:"
  echo "   Status:        http://localhost:18789/health"
  echo "   Logs:          tmux attach -t lavish-gateway"
  echo ""
  echo "📋 Next Steps:"
  echo ""
  echo "1. Verify API keys are set:"
  echo "   nano $PILOT_DIR/.env"
  echo ""
  echo "2. Test agent communication:"
  echo "   clawdbot agent --agent ceo --message 'Health check - ready for Lavish pilot?'"
  echo ""
  echo "3. Setup cron jobs for automation:"
  echo "   crontab -e"
  echo "   # Add lines from $PILOT_DIR/scripts/crontab.example"
  echo ""
  echo "4. Start Week 1 content production:"
  echo "   bash $PILOT_DIR/scripts/start-week-1.sh"
  echo ""
  echo "5. Monitor system health:"
  echo "   bash $PILOT_DIR/scripts/system-health.sh"
  echo ""
  echo "📚 Documentation:"
  echo "   Pilot plan:    ./docs/start/lavish-pilot-deployment.md"
  echo "   Architecture:  ./docs/start/jmg-enterprise-team-architecture.md"
  echo "   Case study:    ./docs/start/case-lavish-nederland.md"
  echo ""
  echo "💬 Support:"
  echo "   Clawdbot Discord: https://discord.gg/clawd"
  echo "   Docs:             https://docs.clawd.bot"
  echo ""
  echo "═══════════════════════════════════════════════════════════════"
  echo ""
  echo "Ready to start the Lavish pilot! 🍸🎉"
  echo ""
}

# Main deployment flow
main() {
  check_prerequisites
  setup_environment
  install_clawdbot
  create_directories
  deploy_agent_configs
  deploy_skills
  configure_clawdbot
  setup_automation
  start_gateway

  if verify_deployment; then
    print_next_steps
    exit 0
  else
    echo ""
    echo "⚠️  Deployment completed with warnings."
    echo "Please review the health check failures above."
    exit 1
  fi
}

# Run main deployment
main "$@"
