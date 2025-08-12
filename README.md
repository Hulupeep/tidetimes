# Tide Times Scraper

A Node.js application that scrapes tide times data from the Port of Galway website and stores it in a Supabase database.

## Features

- Scrapes 366 days of tide times data from https://theportofgalway.ie/galway-tide-times/
- Handles dynamic content loading using Puppeteer
- Stores data in Supabase with location identifiers (country, city, post code)
- Extracts morning/afternoon high/low water times and heights
- Batch processing for efficient database operations
- Duplicate handling with upsert operations

## Setup

### GitHub Codespaces (Recommended for Cloud Development)

This project is configured to run in GitHub Codespaces with automatic Supabase setup.

1. Open the repository in GitHub Codespaces
2. Wait for the container to build and Supabase to start automatically
3. Access Supabase Studio through the forwarded port (54323)
4. The environment is pre-configured with all necessary tools

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