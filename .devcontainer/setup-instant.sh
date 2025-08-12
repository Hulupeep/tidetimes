#!/bin/bash
# Instant Codespace Setup - Returns immediately, runs everything in background
set -e

# Create a log file for background processes
LOG_FILE="/tmp/codespace-setup.log"
echo "Setup started at $(date)" > "$LOG_FILE"

# Launch the actual setup in background and detach completely
(
    exec > "$LOG_FILE" 2>&1
    
    echo "🚀 Background setup starting..."
    
    # Skip Puppeteer download
    export PUPPETEER_SKIP_DOWNLOAD=true
    
    # Quick npm install (don't wait)
    echo "📦 Installing dependencies..."
    npm install --no-audit --no-fund 2>&1 || echo "npm install continuing..."
    
    # Claude tools
    echo "🤖 Installing Claude Code..."
    if ! command -v claude &> /dev/null; then
        echo "Installing Claude Code globally..."
        npm install -g @anthropic-ai/claude-code --no-audit --no-fund 2>&1 || true
        # Create claude alias if needed
        if [ -f /usr/local/lib/node_modules/@anthropic-ai/claude-code/dist/cli.js ]; then
            ln -sf /usr/local/lib/node_modules/@anthropic-ai/claude-code/dist/cli.js /usr/local/bin/claude 2>&1 || true
        fi
    fi
    
    # Skip permissions (only if claude exists)
    if command -v claude &> /dev/null; then
        claude --dangerously-skip-permissions 2>&1 || true
    fi
    
    # Claude Flow
    echo "🔄 Setting up Claude Flow..."
    npx --yes claude-flow@alpha init --force 2>&1 || true
    
    # Agents (sparse checkout)
    echo "🤖 Installing agents..."
    AGENTS_DIR="/workspaces/Agentic_Codespace/agents"
    if [ ! -d "$AGENTS_DIR" ] || [ $(find "$AGENTS_DIR" -name "*.md" 2>/dev/null | wc -l) -lt 50 ]; then
        mkdir -p "$AGENTS_DIR"
        TEMP_DIR="/tmp/agents-$$"
        
        git clone --quiet --depth 1 --filter=blob:none --no-checkout \
            https://github.com/ChrisRoyse/610ClaudeSubagents.git "$TEMP_DIR" 2>&1
        
        cd "$TEMP_DIR"
        git sparse-checkout set agents 2>&1
        git checkout --quiet 2>&1
        
        if [ -d "$TEMP_DIR/agents" ]; then
            cp -r "$TEMP_DIR/agents/"*.md "$AGENTS_DIR/" 2>&1 || true
        fi
        
        rm -rf "$TEMP_DIR"
    fi
    
    # Supabase
    echo "🗄️ Starting Supabase..."
    cd /workspaces/Agentic_Codespace
    npx supabase start 2>&1 || true
    npx supabase db push 2>&1 || true
    
    # Import tide data
    echo "🌊 Importing tide data..."
    if [ -f "/workspaces/Agentic_Codespace/import-tide-data.js" ]; then
        node /workspaces/Agentic_Codespace/import-tide-data.js 2>&1 || echo "Tide data import will retry later"
    fi
    
    # API key setup
    if [ ! -z "$ANTHROPIC_API_KEY" ]; then
        mkdir -p ~/.claude
        echo "echo \${ANTHROPIC_API_KEY}" > ~/.claude/anthropic_key_helper.sh
        chmod +x ~/.claude/anthropic_key_helper.sh
    fi
    
    echo "✅ Background setup completed at $(date)" 
    
    # Create a marker file to indicate completion
    touch /tmp/codespace-setup-complete
    
) </dev/null >/dev/null 2>&1 &

# Disown the background process so it continues even after this script exits
disown

# Print immediate message and exit
echo "🚀 Claude AI Development Environment Starting!"
echo ""
echo "✅ Codespace is ready to use!"
echo ""
echo "📖 WELCOME.md will open with instructions"
echo ""
echo "⏳ Services starting in background (1-2 minutes):"
echo "   • Claude Code & Flow"
echo "   • 600+ AI agents" 
echo "   • Supabase database"
echo ""
echo "💡 You can start using Claude immediately!"
echo "   Just type: claude \"hello\""
echo ""
echo "📊 Check setup progress: tail -f /tmp/codespace-setup.log"

# Exit immediately - don't wait for background tasks
exit 0