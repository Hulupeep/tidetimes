# 🤖 Claude AI Development Starter Kit

**Build AI-powered apps with Claude Code & Claude Flow** - Includes real tide data to get you started!

## 🎯 What is This?

A complete GitHub Codespaces environment pre-configured with:
- **Claude Code** - Your AI coding assistant
- **Claude Flow** - Orchestrate multiple AI agents for complex tasks
- **600+ Specialized AI Agents** - From testing to architecture
- **Real Tide Data** - Actual tide times from Galway, Ireland as your starter dataset
- **Supabase Database** - PostgreSQL with visual Studio interface

## 🚀 Quick Start (2 Minutes!)

### 1. Add Your API Key to GitHub
Go to: Settings → Secrets → Codespaces → New secret
- Name: `ANTHROPIC_API_KEY`
- Value: Get from https://console.anthropic.com/settings/keys

### 2. Launch Your Codespace
[![Open in GitHub Codespaces](https://github.com/codespaces/badge.svg)](https://codespace.new/Hulupeep/tidetimes)

### 3. Start Building!
The WELCOME.md will open automatically with example projects.

## 🏊 Example Apps You Can Build

Using the included tide data (366 days of high/low tides for Galway):

### 🌊 "Can I Swim Now?" App
```bash
claude "Using the tide_times table, build a simple web app that shows:
- Is it safe to swim now? (high tide = yes)
- When is the next good swimming time?
- Add weather data from OpenWeatherMap API
- Show water temperature if available"
```

### 📱 SMS Tide Alerts
```bash
claude "Create a system that:
- Texts me 1 hour before high tide
- Only on days when weather is good
- Use Twilio for SMS
- Include water temperature from ERDDAP Marine API"
```

### 📊 Tide Dashboard with Marine Data
```bash
claude "Build a dashboard that combines:
- Tide times from our database
- Water temp from https://erddap.marine.ie/erddap/tabledap/
- Wind speed and direction
- Best swimming times highlighted
- 7-day forecast view"
```

### ⚠️ Swimming Safety System
```bash
claude "Create a warning system that:
- Checks tide height, wind speed, water temp
- Generates safety score (1-10)
- Warns about dangerous conditions
- Suggests alternative swimming times"
```

## 🎨 Build & Share Challenge

1. **Pick a project** or invent your own
2. **Use Claude** to build it: `claude "help me build..."`
3. **Deploy it** (Vercel, Netlify, etc.)
4. **Share on LinkedIn** with #ClaudeBuiltThis

Example LinkedIn post:
> "Built a smart swimming advisor app in 30 minutes using Claude AI! 
> It checks tides, weather, and water temp to find perfect swimming times 🏊
> 
> Built with: @AnthropicAI Claude, Supabase, and real marine data
> #ClaudeBuiltThis #AI #Coding"

## 📚 Available Data Sources

### In Your Database
- **tide_times table**: 366 days of tide data
  - High/low times and heights
  - Morning and afternoon tides
  - Location: Galway, Ireland

### External APIs to Integrate
- **Marine Institute**: https://erddap.marine.ie/erddap/tabledap/
  - Water temperature
  - Wave height
  - Salinity
  - Ocean currents
  
- **Weather APIs**:
  - OpenWeatherMap
  - WeatherAPI
  - Met Éireann

## 🛠️ What's Included

### AI Tools
- **Claude Code**: Direct AI assistance in terminal
- **Claude Flow**: Multi-agent orchestration
- **600+ Specialized Agents**: Testing, debugging, architecture, etc.

### Database
- **Supabase** (PostgreSQL): Local instance with Studio UI
- **Tide Data**: Pre-loaded with Galway tide times
- **Ready for Extension**: Add weather, temperature, user preferences

### Development
- **Node.js 20**: Latest LTS
- **GitHub Copilot**: If you have access
- **Docker**: For containerization
- **Web Scraper**: Example code for gathering more data

## 💡 Project Ideas

### Beginner
- **High Tide Notifier**: Simple alert when tide is high
- **Swimming Calendar**: Show best swimming days this week
- **Tide API**: REST endpoint for tide data

### Intermediate  
- **Smart Swimming Advisor**: Combine tide + weather + temperature
- **Tide Prediction**: ML model for future predictions
- **Multi-Location Support**: Extend beyond Galway

### Advanced
- **Community Platform**: Users share swimming conditions
- **Computer Vision**: Analyze beach webcams for conditions
- **IoT Integration**: Connect to water sensors

## 🎯 Learning Path

1. **Start Simple**: Ask Claude to explain the database
   ```bash
   claude "explain the tide_times table structure"
   ```

2. **Build Basic**: Create a simple query
   ```bash
   claude "show me today's high tides"
   ```

3. **Add Features**: Enhance with external data
   ```bash
   claude "add weather data to the tide query"
   ```

4. **Deploy**: Share your creation
   ```bash
   claude "help me deploy this to Vercel"
   ```

## 🤝 Community

Built something cool? 
- Share on LinkedIn with **#ClaudeBuiltThis**
- Tag **@AnthropicAI**
- Submit PRs with your examples

## 📖 Documentation

- [Claude Code Docs](https://docs.anthropic.com/en/docs/claude-code)
- [Claude Flow Guide](https://github.com/ruvnet/claude-flow)
- [Supabase Docs](https://supabase.com/docs)
- [Marine Data API](https://erddap.marine.ie/erddap/tabledap/)

## 🚨 Troubleshooting

**Codespace slow to start?**
- First launch takes 2-3 minutes
- Subsequent launches are faster

**Claude not working?**
- Check API key is set in GitHub Secrets
- Or use: `claude --dangerously-skip-permissions` for browser login

**Database issues?**
- Restart Supabase: `npx supabase stop && npx supabase start`

---

**Ready to build?** Launch your Codespace and let Claude help you create something amazing with real tide data! 🌊🤖