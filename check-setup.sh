#!/bin/bash
# Check the status of Codespace setup

echo "🔍 Checking Claude AI Environment Status..."
echo ""

# Check if setup is complete
if [ -f /tmp/codespace-setup-complete ]; then
    echo "✅ Setup completed!"
else
    echo "⏳ Setup still in progress..."
    echo "   Check logs: tail -f /tmp/codespace-setup.log"
fi

echo ""
echo "📊 Component Status:"

# Check Claude Code
if command -v claude-code &> /dev/null; then
    echo "✅ Claude Code: Installed"
else
    echo "⏳ Claude Code: Installing..."
fi

# Check Claude Flow
if npx claude-flow@alpha --version &> /dev/null 2>&1; then
    echo "✅ Claude Flow: Ready"
else
    echo "⏳ Claude Flow: Setting up..."
fi

# Check Agents
AGENT_COUNT=$(ls -1 /workspaces/Agentic_Codespace/agents/*.md 2>/dev/null | wc -l)
if [ "$AGENT_COUNT" -gt 100 ]; then
    echo "✅ AI Agents: $AGENT_COUNT agents installed"
elif [ "$AGENT_COUNT" -gt 0 ]; then
    echo "⏳ AI Agents: $AGENT_COUNT agents (still downloading...)"
else
    echo "⏳ AI Agents: Downloading..."
fi

# Check Supabase
if npx supabase status &> /dev/null; then
    echo "✅ Supabase: Running on port 54323"
else
    echo "⏳ Supabase: Starting..."
fi

# Check npm install
if [ -d "node_modules" ] && [ -f "package-lock.json" ]; then
    echo "✅ Dependencies: Installed"
else
    echo "⏳ Dependencies: Installing..."
fi

echo ""
echo "💡 Tips:"
echo "   • Claude should work immediately even if setup is ongoing"
echo "   • Try: claude \"hello, are you working?\""
echo "   • Full setup takes 1-2 minutes in background"
echo "   • Check progress: tail -f /tmp/codespace-setup.log"