#!/bin/bash
# Quick Manual Setup for Claude Code
# Run this if Claude isn't working: ./quick-setup.sh

echo "🚀 Quick Setup for Claude Code"
echo "=============================="
echo ""

# Check if Claude is already installed
if command -v claude &> /dev/null; then
    echo "✅ Claude is already installed!"
    claude --version
else
    echo "📦 Installing Claude Code..."
    npm install -g @anthropic-ai/claude-code
    
    # Check if installation succeeded
    if command -v claude &> /dev/null; then
        echo "✅ Claude Code installed successfully!"
    else
        echo "⚠️  Claude command not found. Trying alternative..."
        # Try to find and link claude manually
        CLAUDE_PATH=$(find /usr -name "claude" -type f 2>/dev/null | head -1)
        if [ ! -z "$CLAUDE_PATH" ]; then
            ln -sf "$CLAUDE_PATH" /usr/local/bin/claude
            echo "✅ Created claude command link"
        else
            echo "❌ Could not find claude executable"
            echo "Try running: npx @anthropic-ai/claude-code"
        fi
    fi
fi

# Check API key
if [ ! -z "$ANTHROPIC_API_KEY" ]; then
    echo "✅ API key is configured"
else
    echo "ℹ️  No API key found. You'll need to login with your Claude subscription"
    echo "   Run: claude --dangerously-skip-permissions"
fi

# Check Supabase
echo ""
echo "🗄️ Checking Supabase..."
if npx supabase status &> /dev/null; then
    echo "✅ Supabase is running"
else
    echo "🚀 Starting Supabase..."
    npx supabase start
fi

echo ""
echo "✨ Setup complete! Try these commands:"
echo "   claude 'hello'"
echo "   claude 'show me the tide_times database'"
echo ""
echo "📖 If Claude doesn't work, try:"
echo "   npx @anthropic-ai/claude-code 'hello'"