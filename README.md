# Tide Times Scraper

A Node.js application that scrapes tide times data from the Port of Galway website and stores it in a Supabase database.

## Features

- Scrapes 366 days of tide times data from https://theportofgalway.ie/galway-tide-times/
- Handles dynamic content loading using Puppeteer
- Stores data in Supabase with location identifiers (country, city, post code)
- Extracts morning/afternoon high/low water times and heights
- Batch processing for efficient database operations
- Duplicate handling with upsert operations
- **AI-Powered Development**: Integrated Claude Code and Claude Flow for SPARC methodology

## Setup

### GitHub Codespaces (Recommended for Cloud Development)

This project is configured to run in GitHub Codespaces with automatic Supabase setup, Claude Code, and Claude Flow.

#### Setup Steps:

1. **Add your Anthropic API Key to GitHub Secrets**:
   - Go to Settings → Secrets and variables → Codespaces
   - Click "New repository secret"
   - Name: `ANTHROPIC_API_KEY`
   - Value: Your API key from https://console.anthropic.com/settings/keys

2. **Create a Codespace**:
   - Click the green "Code" button → "Codespaces" tab
   - Click "Create codespace on master"

3. **Automatic Setup**:
   The container will automatically:
   - Install Node.js dependencies
   - Start Supabase locally
   - Install Claude Code and Claude Flow
   - Configure SPARC development environment
   - Forward all necessary ports

4. **Access Points**:
   - Supabase Studio: Port 54323
   - PostgreSQL: Port 54322
   - Claude AI tools ready in terminal

### Local Development

#### Quick Setup
```bash
./setup.sh
```

This will:
- Start local Supabase if not running
- Install npm dependencies
- Create .env file with local Supabase keys
- Run database migrations

#### Manual Setup

1. Start local Supabase:
```bash
npx supabase start
```

2. Install dependencies:
```bash
npm install
```

3. Run database migrations:
```bash
npx supabase db push
```

4. Configure environment variables:
   - Copy `.env.example` to `.env`
   - Get your local Supabase keys: `npx supabase status`
   - Update the keys in your `.env` file

5. Run the scraper:
```bash
npm start    # Full scrape and store
npm test     # Test scraping only
```

## Data Structure

The scraper extracts and stores:
- **Location**: Country, City, Post Code
- **Date**: Date of tide times
- **Morning High Water**: Time and height
- **Afternoon High Water**: Time and height  
- **Morning Low Water**: Time and height
- **Afternoon Low Water**: Time and height

## Environment Variables

- `SUPABASE_URL`: Your Supabase project URL
- `SUPABASE_ANON_KEY`: Supabase anonymous key
- `SUPABASE_SERVICE_KEY`: Supabase service role key (for write operations)
- `LOCATION_COUNTRY`: Default "Ireland"
- `LOCATION_CITY`: Default "Galway"
- `LOCATION_POST_CODE`: Default "H91"

## Database Schema

The tide data is stored in a `tide_times` table with proper indexing for location and date queries. See `supabase-schema.sql` for the complete schema.

## Error Handling

- Handles network timeouts and page loading issues
- Graceful error recovery with batch processing
- Comprehensive logging of success/failure counts
- Duplicate prevention with unique constraints

## AI Development with Claude

This project includes Claude Code and Claude Flow for AI-assisted development using the SPARC methodology.

### Claude Code Commands
```bash
# Basic usage
claude --help                    # Show help
claude "explain this code"       # Ask Claude about code

# Development tasks
claude "add error handling to scraper.js"
claude "write tests for import-tide-data.js"
claude "optimize database queries"
```

### Claude Flow SPARC Commands
```bash
# List available SPARC modes
npx claude-flow sparc modes

# Run specific development modes
npx claude-flow sparc run spec-pseudocode "design batch processing improvement"
npx claude-flow sparc run architect "design real-time tide alerts system"
npx claude-flow sparc tdd "implement tide prediction algorithm"
npx claude-flow sparc run debug "fix puppeteer timeout issues"

# Quick AI coordination
npx claude-flow swarm "add data validation to scraper"

# Memory management
npx claude-flow memory store tide_specs "tide calculation requirements"
npx claude-flow memory query tide_implementation
```

### SPARC Development Modes
- **spec-pseudocode**: Requirements and algorithm planning
- **architect**: System design and architecture
- **tdd**: Test-driven development
- **code**: Clean code implementation
- **debug**: Troubleshooting and fixes
- **security-review**: Security analysis
- **integration**: Component integration
- **docs-writer**: Documentation creation

For detailed SPARC methodology, see the [CLAUDE.md](CLAUDE.md) file in the project root.