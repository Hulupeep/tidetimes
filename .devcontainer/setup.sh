#!/bin/bash
set -e

echo "🚀 Setting up Tide Times Scraper with Claude AI development environment..."

# Install project dependencies
echo "📦 Installing project dependencies..."
npm install

# Install Claude Code globally
echo "🤖 Installing Claude Code..."
npm install -g @anthropic-ai/claude-code || true

# Skip permissions check for Claude Code in container environment
echo "⚙️ Configuring Claude Code..."
claude --dangerously-skip-permissions 2>/dev/null || true

# Install Claude Flow (alpha version for latest features)
echo "🔄 Installing Claude Flow..."
npm install -g claude-flow@alpha || npx claude-flow@alpha init --force

# Copy CLAUDE.md if it exists (for SPARC configuration)
if [ -f "/workspaces/tidetimes/CLAUDE.md" ]; then
    echo "📋 CLAUDE.md configuration found"
fi

# Start Supabase
echo "🗄️ Starting Supabase..."
npx supabase start

# Run database migrations
echo "🔧 Running database migrations..."
npx supabase db push

# Create helper script for API key
if [ ! -z "$ANTHROPIC_API_KEY" ]; then
    echo "🔑 Setting up Anthropic API key..."
    mkdir -p ~/.claude
    echo "echo \${ANTHROPIC_API_KEY}" > ~/.claude/anthropic_key_helper.sh
    chmod +x ~/.claude/anthropic_key_helper.sh
fi

# Initialize Claude Flow configuration
echo "⚡ Initializing Claude Flow..."
npx claude-flow config init 2>/dev/null || true

# Display setup completion info
echo ""
echo "✅ Setup complete! Your development environment is ready."
echo ""
echo "🎯 Quick Start Commands:"
echo "  • claude --help          - Claude Code help"
echo "  • claude-flow --help     - Claude Flow help"
echo "  • npx claude-flow sparc modes - List SPARC development modes"
echo "  • npm start              - Run tide scraper"
echo "  • npm test               - Run tests"
echo ""
echo "📚 Resources:"
echo "  • Supabase Studio: http://localhost:54323"
echo "  • PostgreSQL: postgresql://postgres:postgres@localhost:54322/postgres"
echo ""

# Check if API key is set
if [ -z "$ANTHROPIC_API_KEY" ]; then
    echo "⚠️  ANTHROPIC_API_KEY not set. Add it to Codespace secrets:"
    echo "   1. Go to Settings → Secrets → Codespaces"
    echo "   2. Add secret: ANTHROPIC_API_KEY"
    echo "   3. Restart your Codespace"
    echo ""
fi

echo "🎉 Happy coding with Claude AI!"