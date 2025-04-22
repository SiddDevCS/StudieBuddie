#!/bin/bash

echo "🎓 StudieBuddie Setup 🎓"
echo "--------------------------------"
echo "Setting up your development environment..."

# Check if Xcode is installed
if ! command -v xcodebuild > /dev/null; then
  echo "❌ Xcode not found. Please install Xcode from the App Store."
  exit 1
fi

# Create template files for sensitive data
echo "Creating template files for API keys and credentials..."

# Create template Firebase config
if [ ! -f "Tasker/GoogleService-Info.plist" ]; then
  cat > "Tasker/GoogleService-Info.plist.template" << EOL
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <!-- Add your Firebase configuration here -->
  <key>API_KEY</key>
  <string>YOUR_API_KEY</string>
  <key>PROJECT_ID</key>
  <string>YOUR_PROJECT_ID</string>
  <!-- Add other Firebase config keys as needed -->
</dict>
</plist>
EOL
  echo "✅ Created GoogleService-Info.plist.template"
fi

# Update API keys in code files
sed -i '' 's/apiKey = "YOUR_API_KEY_HERE"/apiKey = "YOUR_API_KEY_HERE" \/\/ Replace with your Hugging Face API key/g' "Tasker/AppFunc/Tools/AIChatbot/ChatAIService.swift" 2>/dev/null || :
sed -i '' 's/apiKey = "YOUR_API_KEY_HERE"/apiKey = "YOUR_API_KEY_HERE" \/\/ Replace with your Hugging Face API key/g' "Tasker/AppFunc/Tools/AIChatbot/ChatViewModel.swift" 2>/dev/null || :
sed -i '' 's/apiKey = "YOUR_API_KEY_HERE"/apiKey = "YOUR_API_KEY_HERE" \/\/ Replace with your Hugging Face API key/g' "Tasker/AppFunc/Home/Studiedoelen/Studiedoels/AIInt/StudyCoachViewModel.swift" 2>/dev/null || :

echo "--------------------------------"
echo "✅ Setup complete!"
echo ""
echo "Next steps:"
echo "1. Replace API keys in the following files:"
echo "   - Tasker/GoogleService-Info.plist (create this from the template)"
echo "   - Tasker/AppFunc/Tools/AIChatbot/ChatAIService.swift"
echo "   - Tasker/AppFunc/Tools/AIChatbot/ChatViewModel.swift"
echo "   - Tasker/AppFunc/Home/Studiedoelen/Studiedoels/AIInt/StudyCoachViewModel.swift"
echo ""
echo "2. Open Tasker.xcodeproj in Xcode"
echo "3. Configure your code signing identity"
echo "4. Build and run the app"
echo ""
echo "Happy coding! 🚀" 