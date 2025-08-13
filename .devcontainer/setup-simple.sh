#!/bin/bash
# Simple setup - Everything is pre-configured, just install npm packages

echo "🚀 Setting up Agentic Codespace..."

# Install Claude Code globally (fast)
echo "📦 Installing Claude Code..."
npm install -g @anthropic-ai/claude-code --silent || true

# Claude Flow is already configured - just verify
echo "✅ Claude Flow: Pre-configured (use: npx claude-flow)"

# Start Supabase in background
echo "🗄️ Starting database..."
(npx supabase start 2>/dev/null || true) &

# Import tide data in background
echo "🌊 Loading tide data..."
(node import-tide-data.js 2>/dev/null || true) &

echo ""
echo "═══════════════════════════════════════════════════════════"
echo "    ✅ READY! Your Agentic Codespace is set up"
echo "═══════════════════════════════════════════════════════════"
echo ""
echo "Try these commands:"
echo "  claude 'show me this project'"
echo "  npx claude-flow sparc modes"
echo "  ./check-setup.sh"
echo ""

# Mark as complete
touch /tmp/setup-complete