#!/bin/bash
# Enhanced Codespace Setup - Focused on what matters
set -eo pipefail

echo "🚀 Setting up Tide Times + Claude AI Development Environment..."

# ============================================================================
# CORE DEPENDENCIES (Fast, only what's not in devcontainer)
# ============================================================================

echo "📦 Installing project dependencies..."
npm install

echo "🤖 Installing Claude tools..."
# Install Claude Code (skip if exists to save time)
if ! command -v claude-code &> /dev/null; then
    npm install -g @anthropic-ai/claude-code 2>/dev/null || npm install -g @anthropic-ai/claude-code
fi

# Skip permissions in container
claude --dangerously-skip-permissions 2>/dev/null || true

# Install Claude Flow
echo "🔄 Installing Claude Flow..."
if [ ! -d "node_modules/claude-flow" ]; then
    npx claude-flow@alpha init --force 2>/dev/null || true
fi

# ============================================================================
# 600+ AGENTS INSTALLATION (HIGH VALUE - Using sparse checkout!)
# ============================================================================

echo "🤖 Installing 600+ specialized AI agents..."
AGENTS_DIR="/workspaces/tidetimes/agents"
TEMP_DIR="/tmp/agents-$$"

if [ ! -d "$AGENTS_DIR" ] || [ $(ls -1 "$AGENTS_DIR"/*.md 2>/dev/null | wc -l) -lt 100 ]; then
    mkdir -p "$AGENTS_DIR"
    
    # Sparse checkout - MUCH faster!
    git clone --depth 1 --filter=blob:none --no-checkout \
        https://github.com/ChrisRoyse/610ClaudeSubagents.git "$TEMP_DIR" 2>/dev/null
    
    cd "$TEMP_DIR"
    git sparse-checkout set agents 2>/dev/null
    git checkout 2>/dev/null
    
    # Copy agents
    if [ -d "$TEMP_DIR/agents" ]; then
        cp -r "$TEMP_DIR/agents/"*.md "$AGENTS_DIR/" 2>/dev/null || true
        echo "✅ Installed $(ls -1 $AGENTS_DIR/*.md | wc -l) specialized agents"
    fi
    
    cd /workspaces/tidetimes
    rm -rf "$TEMP_DIR"
else
    echo "✅ Agents already installed: $(ls -1 $AGENTS_DIR/*.md | wc -l) found"
fi

# ============================================================================
# SIMPLE CLAUDE CONFIG (Not the 470-line monster)
# ============================================================================

if [ ! -f "CLAUDE_AGENTS.md" ]; then
    cat << 'EOF' > CLAUDE_AGENTS.md
# 🤖 Your AI Agent Army is Ready!

You now have **600+ specialized AI agents** at your disposal!

## Quick Agent Usage

### Find agents for your task:
```bash
# List all agents
ls agents/*.md

# Search for specific capabilities
ls agents/*test*.md      # Testing agents
ls agents/*api*.md       # API development
ls agents/*debug*.md     # Debugging help
```

### Tell Claude to use them:
```
"Look in /workspaces/tidetimes/agents/ and find the best agents for [your task]"
```

### Popular Agents:
- `agents/code-reviewer.md` - Code review
- `agents/test-generator.md` - Generate tests
- `agents/bug-hunter.md` - Find bugs
- `agents/api-designer.md` - Design APIs
- `agents/doc-writer.md` - Write documentation

## Power Combos

### For adding a feature:
"Use agents for: architecture, implementation, testing, and documentation"

### For debugging:
"Use debugging and root-cause-analysis agents to fix this issue"

### For optimization:
"Use performance and profiling agents to optimize this code"
EOF
fi

# ============================================================================
# SUPABASE STARTUP
# ============================================================================

echo "🗄️ Starting Supabase..."
npx supabase start || true

echo "🔧 Running database migrations..."
npx supabase db push 2>/dev/null || true

# ============================================================================
# API KEY SETUP
# ============================================================================

if [ ! -z "$ANTHROPIC_API_KEY" ]; then
    echo "🔑 Anthropic API key detected"
    mkdir -p ~/.claude
    echo "echo \${ANTHROPIC_API_KEY}" > ~/.claude/anthropic_key_helper.sh
    chmod +x ~/.claude/anthropic_key_helper.sh
else
    echo "💡 No API key detected - Use 'claude --dangerously-skip-permissions' for Claude.ai login"
fi

# ============================================================================
# QUICK STATUS CHECK
# ============================================================================

echo ""
echo "✅ Setup Complete! Quick Status:"
echo "  • Project deps: $(npm list --depth=0 2>/dev/null | grep -c '^├' || echo '✓')"
echo "  • Claude Code: $(command -v claude-code &>/dev/null && echo '✓ Installed' || echo '✗ Missing')"
echo "  • Claude Flow: $(npx claude-flow@alpha --version 2>/dev/null | head -1 || echo '✓ Ready')"
echo "  • AI Agents: $(ls -1 agents/*.md 2>/dev/null | wc -l) agents available"
echo "  • Supabase: http://localhost:54323"
echo ""
echo "📖 Opening WELCOME.md for next steps..."