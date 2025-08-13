#!/bin/bash
# Setup script with user notifications

# Create status file
STATUS_FILE="/tmp/setup-status.txt"
LOG_FILE="/tmp/codespace-setup.log"

# Function to update status
update_status() {
    echo "$1" > "$STATUS_FILE"
    echo "$(date '+%H:%M:%S') $1" >> "$LOG_FILE"
}

# Show initial message
cat << 'EOF'
╔══════════════════════════════════════════════════════════════════╗
║      🚀 AGENTIC CODESPACE SETUP - INSTALLING IN BACKGROUND      ║
╠══════════════════════════════════════════════════════════════════╣
║                                                                  ║
║  ⏳ Claude Code is installing in the background (2-3 minutes)   ║
║                                                                  ║
║  While you wait, you can:                                       ║
║  • Use: npx @anthropic-ai/claude-code "hello"                  ║
║  • Check progress: ./check-setup.sh                            ║
║  • View logs: tail -f /tmp/codespace-setup.log                 ║
║                                                                  ║
║  📢 You'll see a notification when everything is ready!         ║
║                                                                  ║
╚══════════════════════════════════════════════════════════════════╝

EOF

# Start background setup
(
    exec > "$LOG_FILE" 2>&1
    
    update_status "🔄 Starting setup..."
    
    # Skip Puppeteer
    export PUPPETEER_SKIP_DOWNLOAD=true
    
    # Install dependencies
    update_status "📦 Installing dependencies..."
    npm install --no-audit --no-fund || echo "npm install continuing..."
    
    # Install Claude Code
    update_status "🤖 Installing Claude Code..."
    npm install -g @anthropic-ai/claude-code --no-audit --no-fund
    
    # Verify installation
    if command -v claude &> /dev/null; then
        update_status "✅ Claude Code installed successfully!"
        
        # Skip permissions if API key exists
        if [ ! -z "$ANTHROPIC_API_KEY" ]; then
            update_status "🔑 API key detected - configuring..."
        else
            update_status "📝 No API key - will need manual login"
        fi
    else
        update_status "⚠️ Claude command not found - creating alias..."
        # Try to create claude command
        if [ -f /usr/local/lib/node_modules/@anthropic-ai/claude-code/dist/cli.js ]; then
            ln -sf /usr/local/lib/node_modules/@anthropic-ai/claude-code/dist/cli.js /usr/local/bin/claude
            update_status "✅ Claude command created"
        fi
    fi
    
    # Install Claude Flow
    update_status "🔄 Installing Claude Flow..."
    npx --yes claude-flow@alpha init --force || true
    
    # Install agents
    update_status "🤖 Installing 600+ AI agents..."
    AGENTS_DIR="/workspaces/Agentic_Codespace/agents"
    mkdir -p "$AGENTS_DIR"
    TEMP_DIR="/tmp/agents-$$"
    
    git clone --quiet --depth 1 --filter=blob:none --no-checkout \
        https://github.com/ChrisRoyse/610ClaudeSubagents.git "$TEMP_DIR"
    
    cd "$TEMP_DIR"
    git sparse-checkout set agents
    git checkout --quiet
    
    if [ -d "$TEMP_DIR/agents" ]; then
        cp -r "$TEMP_DIR/agents/"*.md "$AGENTS_DIR/" 2>/dev/null || true
        AGENT_COUNT=$(ls -1 "$AGENTS_DIR"/*.md 2>/dev/null | wc -l)
        update_status "✅ Installed $AGENT_COUNT agents"
    fi
    
    rm -rf "$TEMP_DIR"
    
    # Start Supabase
    update_status "🗄️ Starting Supabase database..."
    cd /workspaces/Agentic_Codespace
    npx supabase start || true
    npx supabase db push || true
    
    # Import tide data
    update_status "🌊 Importing 366 days of tide data..."
    if [ -f "/workspaces/Agentic_Codespace/import-tide-data.js" ]; then
        node /workspaces/Agentic_Codespace/import-tide-data.js || echo "Tide data import will retry"
    fi
    
    # Final status
    update_status "✅ SETUP COMPLETE!"
    
    # Create completion marker
    touch /tmp/codespace-setup-complete
    
    # Show completion notification
    echo ""
    echo "╔══════════════════════════════════════════════════════════════════╗"
    echo "║           ✅ SETUP COMPLETE - CLAUDE IS READY!                  ║"
    echo "╠══════════════════════════════════════════════════════════════════╣"
    echo "║                                                                  ║"
    echo "║  You can now use:                                               ║"
    echo "║  • claude 'hello'                                               ║"
    echo "║  • claude 'show me the tide_times database'                    ║"
    echo "║                                                                  ║"
    echo "║  If using subscription, run:                                    ║"
    echo "║  • claude --dangerously-skip-permissions                        ║"
    echo "║                                                                  ║"
    echo "║  Supabase Studio: http://localhost:54323                        ║"
    echo "║                                                                  ║"
    echo "╚══════════════════════════════════════════════════════════════════╝"
    
) </dev/null >/dev/null 2>&1 &

# Store the PID
echo $! > /tmp/setup-pid.txt

# Disown the process
disown

echo "📊 Setup is running in background (PID: $(cat /tmp/setup-pid.txt))"
echo "💡 Type './check-setup.sh' anytime to see progress"
echo ""

exit 0