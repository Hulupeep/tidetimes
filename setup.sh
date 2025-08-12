#!/bin/bash

echo "🌊 Tide Times Scraper Setup"
echo "========================="

# Check if Supabase CLI is running
if ! curl -s http://127.0.0.1:54421 > /dev/null 2>&1; then
    echo "⚠️  Local Supabase is not running. Starting Supabase..."
    npx supabase start
else
    echo "✅ Local Supabase is running"
fi

# Install npm dependencies
echo ""
echo "📦 Installing npm dependencies..."
npm install

# Create .env file if it doesn't exist
if [ ! -f .env ]; then
    echo ""
    echo "📝 Creating .env file from template..."
    cp .env.example .env
    
    # Get Supabase keys
    echo ""
    echo "🔑 Getting Supabase keys..."
    ANON_KEY=$(npx supabase status | grep -E "anon key" | awk '{print $3}')
    SERVICE_KEY=$(npx supabase status | grep -E "service_role key" | awk '{print $3}')
    
    # Update .env with local keys
    if [ "$(uname)" == "Darwin" ]; then
        # macOS
        sed -i '' "s/your_supabase_anon_key/$ANON_KEY/g" .env
        sed -i '' "s/your_supabase_service_role_key/$SERVICE_KEY/g" .env
    else
        # Linux
        sed -i "s/your_supabase_anon_key/$ANON_KEY/g" .env
        sed -i "s/your_supabase_service_role_key/$SERVICE_KEY/g" .env
    fi
    
    echo "✅ Updated .env with local Supabase keys"
fi

# Run migrations
echo ""
echo "🗄️  Running database migrations..."
npx supabase db push

echo ""
echo "✅ Setup complete! You can now run:"
echo "   npm start    - to scrape and store tide data"
echo "   npm test     - to test scraping without storing"