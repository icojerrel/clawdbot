#!/bin/bash
set -e

# Lavish Pilot - Hetzner VPS Automated Deployment
# Version: 1.0
# Usage: ./deploy-to-hetzner.sh <server-ip> [--skip-hardening]

if [ -z "$1" ]; then
  echo "Usage: $0 <server-ip> [--skip-hardening]"
  echo ""
  echo "Example: $0 123.45.67.89"
  echo ""
  echo "This script will:"
  echo "  1. Harden the server (create user, setup firewall, fail2ban)"
  echo "  2. Install Node.js 22+"
  echo "  3. Transfer Lavish pilot package"
  echo "  4. Run deployment"
  echo "  5. Setup systemd service"
  echo "  6. Configure cron jobs"
  echo "  7. Verify deployment"
  echo ""
  exit 1
fi

SERVER_IP=$1
SKIP_HARDENING=false

if [[ "$2" == "--skip-hardening" ]]; then
  SKIP_HARDENING=true
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SSH_KEY="${SSH_KEY:-$HOME/.ssh/lavish-hetzner}"
NEW_USER="lavish"

echo "╔══════════════════════════════════════════════════════════════╗"
echo "║                                                              ║"
echo "║   LAVISH PILOT - HETZNER VPS AUTOMATED DEPLOYMENT            ║"
echo "║                                                              ║"
echo "║   Target: $SERVER_IP                                  ║"
echo "║                                                              ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo ""

# Check SSH key exists
if [ ! -f "$SSH_KEY" ]; then
  echo "❌ SSH key not found: $SSH_KEY"
  echo ""
  echo "Please create SSH key first:"
  echo "  ssh-keygen -t ed25519 -f $SSH_KEY"
  echo ""
  echo "Or specify custom key:"
  echo "  SSH_KEY=/path/to/key $0 $SERVER_IP"
  exit 1
fi

echo "✓ Using SSH key: $SSH_KEY"
echo ""

# Test connection
echo "Testing SSH connection to root@$SERVER_IP..."
if ! ssh -i "$SSH_KEY" -o ConnectTimeout=5 -o StrictHostKeyChecking=accept-new root@$SERVER_IP "echo '✓ Connection successful'" 2>/dev/null; then
  echo "❌ Cannot connect to root@$SERVER_IP"
  echo ""
  echo "Troubleshooting:"
  echo "  1. Check server IP is correct"
  echo "  2. Verify SSH key was added to Hetzner server during creation"
  echo "  3. Check firewall allows SSH (port 22) from your IP"
  echo ""
  exit 1
fi

echo ""

# Step 1: Server Hardening
if [ "$SKIP_HARDENING" = false ]; then
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "▶ STEP 1: Server Hardening"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo ""

  # Generate random password for new user
  USER_PASSWORD=$(openssl rand -base64 32)
  echo "Generated password for user '$NEW_USER' (save this!):"
  echo "$USER_PASSWORD"
  echo ""

  # Transfer hardening script
  echo "Transferring hardening script..."
  scp -i "$SSH_KEY" "$SCRIPT_DIR/scripts/harden-server.sh" root@$SERVER_IP:/tmp/harden-server.sh

  # Run hardening
  echo "Running hardening script..."
  ssh -i "$SSH_KEY" root@$SERVER_IP "bash /tmp/harden-server.sh '$NEW_USER' '$USER_PASSWORD'"

  echo ""
  echo "✅ Server hardening complete!"
  echo ""
  echo "IMPORTANT: Root SSH login is now disabled."
  echo "From now on, use: ssh -i $SSH_KEY $NEW_USER@$SERVER_IP"
  echo ""
  read -p "Press Enter to continue..."
else
  echo "⏭️  Skipping hardening (already done)"
fi

# From here on, connect as $NEW_USER
SSH_USER=$NEW_USER

# Step 2: Install Node.js
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "▶ STEP 2: Installing Node.js 22+"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

ssh -i "$SSH_KEY" $SSH_USER@$SERVER_IP <<'ENDSSH'
# Check if Node.js already installed
if command -v node >/dev/null 2>&1; then
  NODE_VERSION=$(node -v | cut -d'v' -f2 | cut -d'.' -f1)
  if [ "$NODE_VERSION" -ge 22 ]; then
    echo "✓ Node.js $(node -v) already installed"
    exit 0
  fi
fi

# Install nvm
echo "Installing nvm..."
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash

# Load nvm
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

# Install Node.js 22
echo "Installing Node.js 22..."
nvm install 22
nvm use 22
nvm alias default 22

# Verify
echo "✓ Node.js $(node -v) installed"
echo "✓ npm $(npm -v) installed"
ENDSSH

echo ""
echo "✅ Node.js installation complete!"

# Step 3: Transfer Pilot Package
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "▶ STEP 3: Transferring Lavish Pilot Package"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Create tarball
echo "Creating deployment package..."
cd "$SCRIPT_DIR"
tar czf /tmp/lavish-pilot.tar.gz \
  deploy.sh \
  scripts/ \
  skills/ \
  config/ \
  templates/ \
  agents/ \
  README.md \
  QUICK-START.md \
  GET-MINIMAX-KEY.md \
  HETZNER-VPS-SETUP.md

echo "Transferring to server..."
scp -i "$SSH_KEY" /tmp/lavish-pilot.tar.gz $SSH_USER@$SERVER_IP:~/

echo "Extracting package..."
ssh -i "$SSH_KEY" $SSH_USER@$SERVER_IP "tar xzf lavish-pilot.tar.gz && rm lavish-pilot.tar.gz"

rm /tmp/lavish-pilot.tar.gz

echo ""
echo "✅ Package transferred!"

# Step 4: Run Deployment
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "▶ STEP 4: Running Lavish Pilot Deployment"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

echo "⚠️  The deployment script will pause to let you fill in API keys."
echo "When prompted, SSH to the server and edit ~/.lavish-pilot/.env"
echo ""
read -p "Press Enter to continue..."

ssh -i "$SSH_KEY" $SSH_USER@$SERVER_IP <<'ENDSSH'
# Load nvm
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

# Make deploy script executable
chmod +x ~/lavish-pilot/deploy.sh

# Run deployment
cd ~/lavish-pilot
./deploy.sh
ENDSSH

echo ""
echo "✅ Deployment complete!"

# Step 5: Setup Systemd Service
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "▶ STEP 5: Setting Up Systemd Service"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

ssh -i "$SSH_KEY" $SSH_USER@$SERVER_IP <<'ENDSSH'
# Load nvm to get clawdbot path
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

CLAWDBOT_PATH=$(which clawdbot)
NODE_VERSION=$(node -v | cut -d'v' -f2)

echo "Using clawdbot: $CLAWDBOT_PATH"

# Create systemd service
sudo tee /etc/systemd/system/lavish-gateway.service > /dev/null <<EOF
[Unit]
Description=Lavish Pilot - Clawdbot Gateway
After=network-online.target
Wants=network-online.target

[Service]
Type=simple
User=lavish
WorkingDirectory=/home/lavish
EnvironmentFile=/home/lavish/.lavish-pilot/.env
ExecStart=$CLAWDBOT_PATH gateway run --bind 127.0.0.1 --port 18789 --force
Restart=always
RestartSec=10
StandardOutput=append:/home/lavish/.lavish-pilot/logs/gateway.log
StandardError=append:/home/lavish/.lavish-pilot/logs/gateway-error.log

# Security hardening
NoNewPrivileges=true
PrivateTmp=true
ProtectSystem=strict
ProtectHome=read-only
ReadWritePaths=/home/lavish/.lavish-pilot /home/lavish/.clawdbot

[Install]
WantedBy=multi-user.target
EOF

# Reload systemd
sudo systemctl daemon-reload

# Enable and start service
sudo systemctl enable lavish-gateway
sudo systemctl start lavish-gateway

# Wait for startup
sleep 3

# Check status
sudo systemctl status lavish-gateway --no-pager
ENDSSH

echo ""
echo "✅ Systemd service configured!"

# Step 6: Configure Cron Jobs
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "▶ STEP 6: Configuring Cron Jobs"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

ssh -i "$SSH_KEY" $SSH_USER@$SERVER_IP <<'ENDSSH'
# Add cron jobs
(crontab -l 2>/dev/null || true; cat <<CRON
# Lavish Pilot Automation
0 6 * * * /home/lavish/.lavish-pilot/scripts/daily-content-production.sh >> /home/lavish/.lavish-pilot/logs/cron-daily.log 2>&1
0 9 * * 1 /home/lavish/.lavish-pilot/scripts/weekly-strategy-review.sh >> /home/lavish/.lavish-pilot/logs/cron-weekly.log 2>&1
*/30 * * * * /home/lavish/.lavish-pilot/scripts/system-health.sh >> /home/lavish/.lavish-pilot/logs/cron-health.log 2>&1
0 0 * * 0 find /home/lavish/.lavish-pilot/logs -name "*.log" -mtime +30 -delete
CRON
) | crontab -

echo "✓ Cron jobs installed"
crontab -l | grep -A 4 "Lavish Pilot"
ENDSSH

echo ""
echo "✅ Cron jobs configured!"

# Step 7: Verify Deployment
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "▶ STEP 7: Verifying Deployment"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

ssh -i "$SSH_KEY" $SSH_USER@$SERVER_IP <<'ENDSSH'
# Load nvm
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

echo "Running health checks..."
echo ""

FAILURES=0

# Check gateway health
if curl -f http://localhost:18789/health >/dev/null 2>&1; then
  echo "✓ Gateway health check passed"
else
  echo "✗ Gateway health check failed"
  ((FAILURES++))
fi

# Check systemd service
if sudo systemctl is-active lavish-gateway >/dev/null 2>&1; then
  echo "✓ Systemd service is active"
else
  echo "✗ Systemd service is not running"
  ((FAILURES++))
fi

# Check agent directories
AGENT_COUNT=$(ls -d ~/.clawdbot/agents/*/ 2>/dev/null | wc -l)
if [ "$AGENT_COUNT" -eq 10 ]; then
  echo "✓ All 10 agent workspaces exist"
else
  echo "✗ Only $AGENT_COUNT/10 agent workspaces found"
  ((FAILURES++))
fi

# Check environment file
if [ -f ~/.lavish-pilot/.env ]; then
  echo "✓ Environment file exists"
else
  echo "✗ Environment file missing"
  ((FAILURES++))
fi

# Check cron jobs
CRON_COUNT=$(crontab -l | grep -c "lavish-pilot" || true)
if [ "$CRON_COUNT" -ge 3 ]; then
  echo "✓ Cron jobs configured ($CRON_COUNT jobs)"
else
  echo "✗ Cron jobs missing"
  ((FAILURES++))
fi

echo ""
if [ $FAILURES -eq 0 ]; then
  echo "✅ All health checks passed!"
else
  echo "⚠️  $FAILURES health check(s) failed"
  echo ""
  echo "Check logs:"
  echo "  sudo journalctl -u lavish-gateway -n 50"
  echo "  tail -n 50 ~/.lavish-pilot/logs/gateway-error.log"
fi

exit $FAILURES
ENDSSH

VERIFY_EXIT=$?

echo ""

# Final Report
echo ""
echo "╔══════════════════════════════════════════════════════════════╗"
echo "║                                                              ║"
echo "║  🎉 DEPLOYMENT COMPLETE!                                     ║"
echo "║                                                              ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo ""
echo "📡 Server: $SERVER_IP"
echo "👤 User: $SSH_USER"
echo "🔑 SSH Key: $SSH_KEY"
echo ""
echo "🚀 Gateway Status:"
echo "   http://$SERVER_IP:18789/health (if you opened port 18789)"
echo "   Or from server: curl http://localhost:18789/health"
echo ""
echo "📋 Next Steps:"
echo ""
echo "1. SSH to server:"
echo "   ssh -i $SSH_KEY $SSH_USER@$SERVER_IP"
echo ""
echo "2. Verify API keys are set:"
echo "   nano ~/.lavish-pilot/.env"
echo ""
echo "3. Test agent communication:"
echo "   clawdbot agent --agent ceo --message 'Are we ready for Lavish?'"
echo ""
echo "4. View gateway logs:"
echo "   sudo journalctl -u lavish-gateway -f"
echo ""
echo "5. Run first daily automation:"
echo "   bash ~/.lavish-pilot/scripts/daily-content-production.sh"
echo ""
echo "6. Take a snapshot in Hetzner Console (baseline backup)"
echo ""
echo "📚 Documentation:"
echo "   HETZNER-VPS-SETUP.md - Full VPS guide"
echo "   README.md - Pilot overview"
echo "   QUICK-START.md - Week 1 tasks"
echo ""

if [ $VERIFY_EXIT -eq 0 ]; then
  echo "✅ All systems operational! Ready to launch Lavish pilot! 🍸🚀"
  exit 0
else
  echo "⚠️  Deployment completed with warnings. Review health checks above."
  exit 1
fi
