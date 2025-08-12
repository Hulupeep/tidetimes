#!/bin/bash

# Claude Flow Setup Script - Robust, Maintainable, and Production-Ready
# Purpose: Initialize a complete Claude Flow development environment with 600+ AI agents
# Author: Claude Flow DevOps Team
# Version: 2.0.0

# ============================================================================
# STRICT MODE - Exit on any error, undefined variable, or pipe failure
# ============================================================================
set -eo pipefail

# ============================================================================
# CONFIGURATION VARIABLES
# ============================================================================
readonly SCRIPT_NAME="$(basename "$0")"
readonly SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
readonly WORKSPACE_DIR="/workspaces/agentists-quickstart"
readonly AGENTS_DIR="${WORKSPACE_DIR}/agents"
readonly AGENTS_REPO_URL="https://github.com/ChrisRoyse/610ClaudeSubagents.git"
readonly TEMP_CLONE_DIR="/tmp/claude-agents-clone-$$"
readonly SUPABASE_VERSION="latest"

# Terminal colors for formatted output
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly CYAN='\033[0;36m'
readonly NC='\033[0m' # No Color
readonly BOLD='\033[1m'

# ============================================================================
# HELPER FUNCTIONS
# ============================================================================

# Print formatted section headers with emoji and color
print_header() {
    local emoji="$1"
    local text="$2"
    echo ""
    echo -e "${CYAN}${BOLD}━━━ ${emoji} ${text} ━━━${NC}"
    echo ""
}

# Execute command and show status (suppress verbose output)
execute_with_status() {
    local description="$1"
    shift
    local cmd="$@"
    
    echo -n -e "${BLUE}→${NC} ${description}... "
    
    # Create temporary file for error output
    local error_file=$(mktemp)
    
    # Execute command, suppress stdout, capture stderr
    if $cmd > /dev/null 2>"$error_file"; then
        echo -e "${GREEN}[Done]${NC}"
        rm -f "$error_file"
        return 0
    else
        local exit_code=$?
        echo -e "${RED}[Failed]${NC}"
        echo -e "${RED}Error details:${NC}"
        cat "$error_file"
        rm -f "$error_file"
        exit $exit_code
    fi
}

# Check if a command exists in PATH
check_dependency() {
    local cmd="$1"
    local install_hint="$2"
    
    if ! command -v "$cmd" &> /dev/null; then
        echo -e "${RED}✗ Missing dependency: ${cmd}${NC}"
        if [[ -n "$install_hint" ]]; then
            echo -e "${YELLOW}  Installation hint: ${install_hint}${NC}"
        fi
        return 1
    else
        echo -e "${GREEN}✓${NC} Found: ${cmd} ($(command -v "$cmd"))"
        return 0
    fi
}

# Clean up any leftover temporary directories
cleanup_temp() {
    if [[ -d "$TEMP_CLONE_DIR" ]]; then
        rm -rf "$TEMP_CLONE_DIR"
    fi
}

# Trap to ensure cleanup on exit
trap cleanup_temp EXIT

# ============================================================================
# PRE-FLIGHT CHECKS
# ============================================================================

print_header "🔍" "Pre-flight Checks"

echo "Verifying essential dependencies..."
echo ""

# Track if all dependencies are met
DEPS_OK=true

# Check each required dependency
check_dependency "git" "apt-get install git" || DEPS_OK=false
check_dependency "npm" "apt-get install npm or install Node.js" || DEPS_OK=false
check_dependency "docker" "Visit https://docs.docker.com/get-docker/" || DEPS_OK=false
check_dependency "curl" "apt-get install curl" || DEPS_OK=false
check_dependency "jq" "apt-get install jq" || DEPS_OK=false

# Exit if any dependency is missing
if [[ "$DEPS_OK" != "true" ]]; then
    echo ""
    echo -e "${RED}${BOLD}Error: Missing required dependencies${NC}"
    echo "Please install the missing dependencies and run this script again."
    exit 1
fi

echo ""
echo -e "${GREEN}All dependencies satisfied!${NC}"

# ============================================================================
# SYSTEM PACKAGES INSTALLATION
# ============================================================================

print_header "📦" "Installing System Packages"

# Update package list quietly
execute_with_status "Updating package list" sudo apt-get update

# Install tmux if not present
if ! command -v tmux &> /dev/null; then
    execute_with_status "Installing tmux" sudo apt-get install -y tmux
else
    echo -e "${GREEN}✓${NC} tmux already installed"
fi

# ============================================================================
# SUPABASE CLI INSTALLATION
# ============================================================================

print_header "🗄️" "Installing Supabase CLI"

# Check if Supabase is already installed
if command -v supabase &> /dev/null; then
    echo -e "${GREEN}✓${NC} Supabase CLI already installed: $(supabase --version)"
else
    echo "Fetching latest Supabase release information..."
    
    # Get the latest release URL for amd64 .deb package
    SUPABASE_DEB_URL=$(curl -s https://api.github.com/repos/supabase/cli/releases/latest | \
        jq -r '.assets[] | select(.name | endswith("_linux_amd64.deb")) | .browser_download_url')
    
    if [[ -z "$SUPABASE_DEB_URL" ]]; then
        echo -e "${RED}Failed to fetch Supabase CLI download URL${NC}"
        echo "Attempting alternative installation via npm..."
        execute_with_status "Installing Supabase CLI via npm" npm install -g supabase
    else
        # Download the .deb package
        local deb_file="/tmp/supabase-cli.deb"
        execute_with_status "Downloading Supabase CLI" curl -L -o "$deb_file" "$SUPABASE_DEB_URL"
        
        # Install the package
        execute_with_status "Installing Supabase CLI package" sudo dpkg -i "$deb_file"
        
        # Clean up
        rm -f "$deb_file"
    fi
    
    # Verify installation
    if command -v supabase &> /dev/null; then
        echo -e "${GREEN}✓${NC} Supabase CLI installed successfully: $(supabase --version)"
    else
        echo -e "${YELLOW}⚠${NC} Supabase CLI installation could not be verified"
    fi
fi

# ============================================================================
# NPM PACKAGES INSTALLATION
# ============================================================================

print_header "📦" "Installing NPM Packages"

# Install Claude Code CLI
execute_with_status "Installing Claude Code CLI" npm install -g @anthropic-ai/claude-code

# Install Claude Usage Monitor
execute_with_status "Installing Claude Usage CLI" npm install -g claude-usage-cli

# ============================================================================
# CLAUDE FLOW INITIALIZATION
# ============================================================================

print_header "🔄" "Initializing Claude Flow"

# Create workspace directory if it doesn't exist
mkdir -p "$WORKSPACE_DIR"
cd "$WORKSPACE_DIR"

# Initialize Claude Flow with force flag (idempotent)
execute_with_status "Initializing Claude Flow (alpha)" npx claude-flow@alpha init --force

# ============================================================================
# CLAUDE SUBAGENTS INSTALLATION (SPARSE CHECKOUT)
# ============================================================================

print_header "🤖" "Installing 600+ Claude Subagents"

# Clean up any previous temporary directories
cleanup_temp

# Create agents directory
mkdir -p "$AGENTS_DIR"

echo "Using Git sparse checkout for efficient download..."

# Step 1: Clone with sparse checkout (only metadata, no files)
execute_with_status "Initializing sparse repository" \
    git clone --depth 1 --filter=blob:none --no-checkout "$AGENTS_REPO_URL" "$TEMP_CLONE_DIR"

# Step 2: Configure sparse checkout
cd "$TEMP_CLONE_DIR"
execute_with_status "Configuring sparse checkout" git sparse-checkout set agents

# Step 3: Checkout only the agents directory
execute_with_status "Downloading agents directory" git checkout

# Step 4: Copy agents to destination
if [[ -d "$TEMP_CLONE_DIR/agents" ]]; then
    execute_with_status "Installing agents" cp -r "$TEMP_CLONE_DIR/agents/"*.md "$AGENTS_DIR/" 2>/dev/null || true
    
    # Count installed agents
    local agent_count=$(ls -1 "$AGENTS_DIR/"*.md 2>/dev/null | wc -l)
    echo -e "${GREEN}✓${NC} Installed ${BOLD}${agent_count}${NC} agents in ${AGENTS_DIR}"
else
    echo -e "${YELLOW}⚠${NC} Agents directory not found in repository"
fi

# Return to workspace
cd "$WORKSPACE_DIR"

# ============================================================================
# CLAUDE.MD CONFIGURATION FILE
# ============================================================================

print_header "📝" "Creating Claude.md Configuration"

# Create the comprehensive claude.md file
cat << 'EOF' > "$WORKSPACE_DIR/claude.md"
# Claude Code Configuration - SPARC Development Environment

## 🚨 CRITICAL: Concurrent Execution Rules

**ABSOLUTE RULE**: ALL operations MUST be concurrent/parallel in ONE message

### Core Commands
- `npx claude-flow sparc modes` - List all available SPARC modes
- `npx claude-flow sparc run <mode> "<task>"` - Execute specific mode
- `npx claude-flow sparc tdd "<feature>"` - Test-driven development workflow

### Available Agents
Check `/workspaces/agentists-quickstart/agents/` for 600+ specialized agents

### Quick Start
1. Use `claude --help` for Claude Code assistance
2. Use `npx claude-flow --help` for Flow commands
3. View agents: `ls /workspaces/agentists-quickstart/agents/*.md`

### Performance Tips
- Batch all operations in single messages
- Use parallel execution for multiple tasks
- Leverage agent specialization for complex work
EOF

echo -e "${GREEN}✓${NC} Claude.md configuration created"

# ============================================================================
# FINAL VERIFICATION
# ============================================================================

print_header "✅" "Verification & Summary"

echo -e "${BOLD}Verification Steps:${NC}"
echo ""

# Check tmux
echo -n "1. tmux: "
if command -v tmux &> /dev/null; then
    echo -e "${GREEN}✓ Installed${NC} - Run 'tmux' to start a session"
else
    echo -e "${RED}✗ Not found${NC}"
fi

# Check Claude Code
echo -n "2. claude-code: "
if command -v claude-code &> /dev/null; then
    echo -e "${GREEN}✓ Installed${NC} - Run 'claude-code --help' for usage"
else
    echo -e "${YELLOW}⚠ Check with 'npm list -g @anthropic-ai/claude-code'${NC}"
fi

# Check Supabase
echo -n "3. supabase: "
if command -v supabase &> /dev/null; then
    echo -e "${GREEN}✓ Installed${NC} - Version: $(supabase --version 2>/dev/null | head -1)"
else
    echo -e "${RED}✗ Not found${NC}"
fi

# Check Claude Flow
echo -n "4. claude-flow: "
if [[ -d "$WORKSPACE_DIR/node_modules/claude-flow" ]] || npx claude-flow@alpha --version &>/dev/null; then
    echo -e "${GREEN}✓ Installed${NC} - Run 'npx claude-flow@alpha --help' for usage"
else
    echo -e "${YELLOW}⚠ Run 'npx claude-flow@alpha init' to reinitialize${NC}"
fi

# Check agents
echo -n "5. AI Agents: "
agent_count=$(ls -1 "$AGENTS_DIR/"*.md 2>/dev/null | wc -l || echo "0")
if [[ $agent_count -gt 0 ]]; then
    echo -e "${GREEN}✓ ${agent_count} agents installed${NC}"
else
    echo -e "${RED}✗ No agents found${NC}"
fi

# ============================================================================
# COMPLETION MESSAGE
# ============================================================================

print_header "🎉" "Setup Complete!"

cat << EOF
${BOLD}Your Claude Flow development environment is ready!${NC}

${CYAN}${BOLD}Quick Test Commands:${NC}
  ${GREEN}tmux${NC} - Start terminal multiplexer
  ${GREEN}claude --help${NC} - Claude Code help
  ${GREEN}npx claude-flow@alpha --help${NC} - Claude Flow help
  ${GREEN}supabase --version${NC} - Check Supabase CLI
  ${GREEN}ls ${AGENTS_DIR}/*.md | wc -l${NC} - Count agents

${CYAN}${BOLD}Next Steps:${NC}
  1. Set your Anthropic API key: ${YELLOW}export ANTHROPIC_API_KEY="your-key"${NC}
  2. Initialize a project: ${YELLOW}npx claude-flow@alpha init${NC}
  3. Start using agents: ${YELLOW}npx claude-flow@alpha swarm "your task"${NC}

${CYAN}${BOLD}Resources:${NC}
  📚 Documentation: https://github.com/ruvnet/claude-flow
  🤖 Agent Directory: ${AGENTS_DIR}
  📝 Configuration: ${WORKSPACE_DIR}/claude.md

${GREEN}${BOLD}Happy coding with Claude Flow! 🚀${NC}
EOF

# Clean exit
exit 0