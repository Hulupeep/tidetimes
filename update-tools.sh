#!/bin/bash
# Update Claude tools to latest versions

echo "🔄 Updating Claude Tools..."
echo "═══════════════════════════════════════════"

# Update Claude Code
echo "📦 Updating Claude Code..."
npm update -g @anthropic-ai/claude-code 2>/dev/null || npm install -g @anthropic-ai/claude-code

# Update Claude Flow  
echo "🔄 Updating Claude Flow..."
npx claude-flow@latest --version

# Check versions
echo ""
echo "✅ Current Versions:"
echo "───────────────────────────────────────────"
claude --version 2>/dev/null || echo "Claude Code: Run 'npm install -g @anthropic-ai/claude-code'"
npx claude-flow@alpha --version 2>/dev/null || echo "Claude Flow: Ready via npx"

echo ""
echo "✨ Update complete!"