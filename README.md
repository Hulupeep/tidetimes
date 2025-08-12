# 🤖 Agentic Coding Starter Kit - Build Marine Apps with Claude AI

**Get started with agentic coding in minutes!** This repo sets up a GitHub Codespace with Claude Code & Claude Flow, plus real tide data and marine APIs to build something useful.

## 🎯 What This Does

Sets up a **complete agentic coding environment** in 2 minutes:
- ✅ **Claude Code** - Your AI coding assistant (works with Pro/Teams subscription OR API key)
- ✅ **Claude Flow** - Orchestrate multiple AI agents for complex tasks
- ✅ **600+ Specialized Agents** - Testing, architecture, debugging, etc.
- ✅ **Supabase Database** - Pre-loaded with 366 days of Galway tide data
- ✅ **Working Examples** - Copy-paste prompts that actually work
- ✅ **Marine Data Access** - Real-time waves, temperature, weather from ERDDAP

## 🚀 Quick Start (2 Minutes)

### Option A: Using Claude Pro/Teams Subscription
1. **Launch Codespace**: [![Open in GitHub Codespaces](https://github.com/codespaces/badge.svg)](https://codespace.new/Hulupeep/tidetimes)
2. **Login to Claude**: When terminal opens, type:
   ```bash
   claude --dangerously-skip-permissions
   ```
   Follow browser login (uses your Claude.ai subscription)
3. **Start Building!** Copy any prompt from below

### Option B: Using API Key
1. **Add API Key**: Go to Settings → Secrets → Codespaces → New secret
   - Name: `ANTHROPIC_API_KEY`
   - Value: Get from https://console.anthropic.com/settings/keys
2. **Launch Codespace**: Click badge above
3. **Start Building!** Claude is ready immediately

## 🏊 Your Challenge: Build a Swimming/Surfing/Safety System

**Goal**: Build an app for the West of Ireland coast using real data. Here are working prompts you can copy-paste:

### 🌊 Example 1: "Can I Swim Now?" Dashboard
```bash
claude "Using the tide_times table in Supabase, build a dashboard that shows:
- Current tide status for Galway (query the actual database)
- Is it safe to swim? (high tide within 2 hours = yes)
- Create an HTML file with live-updating display
- Add CSS to make it look like a beach safety sign
- Color code: Green (swim), Yellow (caution), Red (danger)"
```

### 🏄 Example 2: Surfer's Friend - Wave & Wind Tracker
```bash
claude "Build a surfing conditions app. Here's working code to get wave data:
import requests
url = 'https://erddap.marine.ie/erddap/tabledap/IWBNetwork.csv?station_id,time,WaveHeight,WindSpeed&station_id=%22M3%22&time%3E=now-1day'
response = requests.get(url)
Parse this data and create a surf report showing:
- Wave height (good surf = 1-3m)
- Wind speed (offshore best)
- Traffic light system for surf conditions
- Save as surf-report.html"
```

### ⚠️ Example 3: Coastal Flooding Alert System
```bash
claude "Create a storm surge warning system:
1. Query our tide_times table for next 48 hours high tides
2. Fetch current atmospheric pressure from M2 buoy (low pressure = danger)
3. If high tide > 4.5m AND pressure < 990mb = FLOOD RISK
4. Build a Node.js script that checks every hour
5. Log warnings with timestamp
URL for pressure: https://erddap.marine.ie/erddap/tabledap/IWBNetwork.csv?time,AtmosphericPressure&station_id=%22M2%22&time%3E=now-1hour"
```

### 📱 Example 4: SMS High Tide Alerts
```bash
claude "Build a system that texts me before high tide:
1. Query tide_times for tomorrow's high tides
2. Check if high tide is between 10am-6pm (swimming hours)
3. Set up a cron job to run daily at 8am
4. Log the alert (we'll add Twilio later)
5. Include tide height and exact time
Test with: SELECT * FROM tide_times WHERE date = CURRENT_DATE + 1"
```

### 📊 Example 5: Water Temperature Visualization
```bash
claude "Create a water temperature tracker:
Fetch sea temperature from M2 buoy using this URL:
https://erddap.marine.ie/erddap/tabledap/IWBNetwork.csv?time,SeaTemperature&station_id=%22M2%22&time%3E=now-7days
- Parse the CSV data
- Create a line chart showing temperature over past week
- Add swimming comfort zones: Cold (<12°C), OK (12-16°C), Nice (>16°C)
- Use Chart.js or similar
- Save as temperature-chart.html"
```

## 📚 What's in Your Database

You have **366 days of real tide data** for Galway, Ireland:

```sql
-- Table: tide_times
-- Columns: date, morning_high_time, morning_high_height, 
--          afternoon_high_time, afternoon_high_height,
--          morning_low_time, morning_low_height,
--          afternoon_low_time, afternoon_low_height

-- Example queries that work:
SELECT * FROM tide_times WHERE date = CURRENT_DATE;
SELECT * FROM tide_times WHERE morning_high_height > 4.5;
SELECT date, morning_high_time FROM tide_times WHERE date BETWEEN CURRENT_DATE AND CURRENT_DATE + 7;
```

## 🌐 Working Marine Data APIs

These URLs are tested and work (just copy-paste):

### Wave Heights - M2 Buoy (off Galway)
```
https://erddap.marine.ie/erddap/tabledap/IWBNetwork.csv?time,WaveHeight&station_id=%22M2%22&time%3E=now-1day
```

### Water Temperature - All Buoys
```
https://erddap.marine.ie/erddap/tabledap/IWBNetwork.csv?station_id,SeaTemperature&time%3E=now-1hour
```

### Wind Speed & Direction - M3 Buoy
```
https://erddap.marine.ie/erddap/tabledap/IWBNetwork.csv?time,WindSpeed,WindDirection&station_id=%22M3%22&time%3E=now-6hours
```

### Live Tide Gauge - Galway Port
```
https://erddap.marine.ie/erddap/tabledap/IrishNationalTideGaugeNetwork.csv?time,Water_Level_LAT&station_id=%22Galway%20Port%22&time%3E=now-1day
```

## 🛠️ What Gets Installed (Automatically)

When you launch the Codespace, everything installs in background:
1. **Claude Code** - Terminal AI assistant
2. **Claude Flow** - Multi-agent orchestration
3. **600+ AI Agents** - Specialized helpers
4. **Supabase** - Local PostgreSQL with web UI
5. **Node.js** - For running your apps
6. **Python** - For data processing

**Status Check**: Run `./check-setup.sh` to see progress

## 💡 More Project Ideas

### Beginner (15 minutes)
- **High Tide Calendar**: Show this week's swimming times
- **Beach Status API**: Simple endpoint returning "SAFE" or "DANGER"
- **Tide Height Graph**: Visualize today's tide curve

### Intermediate (30 minutes)
- **Smart Swimming Advisor**: Combine tide + temperature + weather
- **Fisherman's Helper**: Best fishing times (2 hours before high tide)
- **Kayaking Planner**: Find slack water periods (safest for beginners)

### Advanced (1 hour)
- **Multi-Beach Dashboard**: Track conditions at 5 locations
- **ML Tide Predictor**: Train model on historical data
- **Emergency Response System**: Coordinate coastal warnings

## 🚢 Share Your Creation!

Built something cool? Share it:

1. **Deploy** to Vercel/Netlify (ask Claude how)
2. **Post on LinkedIn** with #ClaudeBuiltThis
3. **Tag** @agentics_org and @AnthropicAI
4. **Include** screenshot and what it does

**Example LinkedIn Post:**
> Built a real-time surf conditions app using Claude AI in 20 minutes! 🏄
> 
> It pulls live wave data from Irish Marine buoys and shows:
> 🌊 Wave height & period
> 💨 Wind speed & direction  
> 🌡️ Water temperature
> 
> Built with Claude Code + real marine data APIs
> Try it: [your-url]
> 
> #ClaudeBuiltThis #AgenticCoding @agentics_org

## 📁 Project Structure

```
/
├── .devcontainer/     # Codespace configuration
├── tidedata/          # ERDDAP examples & docs
│   ├── docs/          # API documentation
│   ├── examples/      # Working Python examples
│   └── src/           # Marine data modules
├── agents/            # 600+ AI agents (auto-installed)
├── supabase/          # Database setup
└── WELCOME.md         # Opens automatically with prompts
```

## 🆘 Troubleshooting

### Claude not responding?
```bash
# If using subscription:
claude --dangerously-skip-permissions

# If using API key:
echo $ANTHROPIC_API_KEY  # Should show your key
```

### Database not connecting?
```bash
npx supabase status      # Check if running
npx supabase start       # Start if needed
```

### Want to see what's installed?
```bash
./check-setup.sh         # Shows installation progress
```

### Supabase Studio (Database GUI)
- Open browser to http://localhost:54323
- Username: Leave blank
- Password: Leave blank

## 📖 Learn More

- **Claude Code Docs**: https://docs.anthropic.com/en/docs/claude-code
- **Claude Flow**: https://github.com/ruvnet/claude-flow
- **Marine Data**: https://erddap.marine.ie/erddap/
- **Agentics.org**: Community & resources

## 🎯 Start Now!

1. Launch your Codespace (2 minutes)
2. Pick a prompt from above
3. Copy-paste into terminal
4. Watch Claude build your app
5. Share what you made!

**Your first command:**
```bash
claude "show me what's in the tide_times database and let's build something cool!"
```

---

*Built by the community at [agentics.org](https://agentics.org) - Advancing agentic coding for everyone*