#!/bin/bash
# Check the status of Codespace setup with clear messages

echo ""
echo "═══════════════════════════════════════════════════════════"
echo "     🔍 AGENTIC CODESPACE STATUS CHECK"
echo "═══════════════════════════════════════════════════════════"
echo ""

# Check if setup is complete
if [ -f /tmp/codespace-setup-complete ]; then
    echo "✅ Setup Status: COMPLETE!"
    echo ""
else
    if [ -f /tmp/setup-status.txt ]; then
        CURRENT_STATUS=$(cat /tmp/setup-status.txt)
        echo "⏳ Setup Status: IN PROGRESS"
        echo "   Current step: $CURRENT_STATUS"
        echo ""
    else
        echo "⚠️  Setup Status: NOT STARTED"
        echo "   Run: ./.devcontainer/setup-with-status.sh"
        echo ""
    fi
fi

echo "📊 Component Status:"
echo "───────────────────────────────────────────────────────────"

# Check Claude Code
if command -v claude &> /dev/null; then
    echo "✅ Claude Code: INSTALLED (try: claude 'hello')"
else
    if command -v npx &> /dev/null; then
        echo "⏳ Claude Code: Installing... (use: npx @anthropic-ai/claude-code 'hello')"
    else
        echo "❌ Claude Code: NOT INSTALLED"
    fi
fi

# Check Claude Flow
if npx claude-flow@alpha --version &> /dev/null 2>&1; then
    echo "✅ Claude Flow: READY"
else
    echo "⏳ Claude Flow: Setting up..."
fi

# Check Agents
AGENT_COUNT=$(ls -1 /workspaces/Agentic_Codespace/agents/*.md 2>/dev/null | wc -l)
if [ "$AGENT_COUNT" -gt 600 ]; then
    echo "✅ AI Agents: $AGENT_COUNT agents installed"
elif [ "$AGENT_COUNT" -gt 0 ]; then
    echo "⏳ AI Agents: $AGENT_COUNT/600+ downloading..."
else
    echo "⏳ AI Agents: Starting download..."
fi

# Check Supabase
if npx supabase status &> /dev/null 2>&1; then
    echo "✅ Supabase: RUNNING (Studio: http://localhost:54323)"
else
    echo "⏳ Supabase: Starting..."
fi

# Check tide data
if [ -f /workspaces/Agentic_Codespace/supabase/.branches/main/dump.sql ]; then
    echo "✅ Tide Data: Imported"
else
    echo "⏳ Tide Data: Importing 366 days..."
fi

echo ""
echo "═══════════════════════════════════════════════════════════"
echo ""

# Show what to do next
if [ -f /tmp/codespace-setup-complete ]; then
    echo "🎯 READY TO USE! Try these commands:"
    echo "───────────────────────────────────────────────────────────"
    if [ ! -z "$ANTHROPIC_API_KEY" ]; then
        echo "   claude 'show me what is in this project'"
        echo "   claude 'query the tide_times database'"
    else
        echo "   claude --dangerously-skip-permissions  (login first)"
        echo "   claude 'show me what is in this project'"
    fi
    echo "   node examples/view-database.js         (see tide data)"
    echo ""
else
    echo "💡 WHILE WAITING, YOU CAN:"
    echo "───────────────────────────────────────────────────────────"
    echo "   npx @anthropic-ai/claude-code 'hello'  (works now!)"
    echo "   tail -f /tmp/codespace-setup.log       (watch progress)"
    echo "   ./quick-setup.sh                       (manual setup)"
    echo ""
    echo "⏱️  Estimated time remaining: 2-3 minutes"
fi

echo "═══════════════════════════════════════════════════════════"
echo ""