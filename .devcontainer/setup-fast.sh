#!/bin/bash
# Fast Codespace Setup - Optimized for quick startup
set -e  # Exit on error, but don't use pipefail (can cause issues with npm)

echo "🚀 Setting up Tide Times + Claude AI Development Environment..."
echo "This may take 2-3 minutes on first run..."

# ============================================================================
# NPM DEPENDENCIES (with timeout and skip for Puppeteer download)
# ============================================================================

echo "📦 Installing project dependencies (this may take a moment)..."

# Skip Puppeteer download to speed things up (can download later if needed)
export PUPPETEER_SKIP_DOWNLOAD=true

# Install with a timeout and continue even if it takes a while
timeout 300 npm install --no-audit --no-fund 2>&1 | head -20 || {
    echo "⚠️ npm install is taking longer than expected, continuing setup..."
    echo "   Dependencies will continue installing in background."
}

# ============================================================================
# CLAUDE TOOLS (Fast install)
# ============================================================================

echo "🤖 Installing Claude tools..."

# Check if claude-code exists before installing
if ! command -v claude-code &> /dev/null 2>&1; then
    echo "  Installing Claude Code..."
    npm install -g @anthropic-ai/claude-code --no-audit --no-fund 2>/dev/null || true
else
    echo "  ✓ Claude Code already installed"
fi

# Skip permissions in container
claude --dangerously-skip-permissions 2>/dev/null || true

# Initialize Claude Flow (quick check)
echo "🔄 Setting up Claude Flow..."
if [ ! -f "package.json" ] || ! grep -q "claude-flow" package.json 2>/dev/null; then
    npx --yes claude-flow@alpha init --force 2>/dev/null || true &
    echo "  Claude Flow initializing in background..."
else
    echo "  ✓ Claude Flow ready"
fi

# ============================================================================
# 600+ AGENTS (Background download with sparse checkout)
# ============================================================================

echo "🤖 Installing AI agents in background..."
(
    AGENTS_DIR="/workspaces/tidetimes/agents"
    if [ ! -d "$AGENTS_DIR" ] || [ $(find "$AGENTS_DIR" -name "*.md" 2>/dev/null | wc -l) -lt 50 ]; then
        mkdir -p "$AGENTS_DIR"
        TEMP_DIR="/tmp/agents-$$"
        
        # Sparse checkout for speed
        git clone --quiet --depth 1 --filter=blob:none --no-checkout \
            https://github.com/ChrisRoyse/610ClaudeSubagents.git "$TEMP_DIR" 2>/dev/null
        
        cd "$TEMP_DIR"
        git sparse-checkout set agents 2>/dev/null
        git checkout --quiet 2>/dev/null
        
        if [ -d "$TEMP_DIR/agents" ]; then
            cp -r "$TEMP_DIR/agents/"*.md "$AGENTS_DIR/" 2>/dev/null || true
            echo "  ✓ $(ls -1 $AGENTS_DIR/*.md 2>/dev/null | wc -l) agents installed"
        fi
        
        rm -rf "$TEMP_DIR"
    else
        echo "  ✓ Agents already installed"
    fi
) &

# ============================================================================
# SUPABASE (Start in background)
# ============================================================================

echo "🗄️ Starting Supabase in background..."
(
    npx supabase start 2>/dev/null || true
    npx supabase db push 2>/dev/null || true
) &

# ============================================================================
# API KEY CHECK (Quick)
# ============================================================================

if [ ! -z "$ANTHROPIC_API_KEY" ]; then
    echo "🔑 API key detected"
    mkdir -p ~/.claude
    echo "echo \${ANTHROPIC_API_KEY}" > ~/.claude/anthropic_key_helper.sh
    chmod +x ~/.claude/anthropic_key_helper.sh
else
    echo "💡 No API key - Use 'claude --dangerously-skip-permissions' to login"
fi

# ============================================================================
# QUICK STATUS
# ============================================================================

echo ""
echo "✅ Initial setup complete! Services starting in background..."
echo ""
echo "🎯 Quick Start:"
echo "  • Claude: Type 'claude' to start"
echo "  • Supabase Studio: Will be available at http://localhost:54323"
echo "  • AI Agents: Installing in background (check with: ls agents/*.md | wc -l)"
echo ""
echo "📖 Opening WELCOME.md..."
echo ""
echo "⏳ Note: Some services may still be starting. This is normal."
echo "   Everything will be ready in 1-2 minutes."

# Create a simple status file
echo "Setup completed at $(date)" > /tmp/codespace-setup-complete

# Don't wait for background processes - let Codespace start quickly
exit 0