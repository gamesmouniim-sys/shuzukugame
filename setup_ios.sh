#!/bin/bash
# Shizuku Game Booster — iOS Setup & Diagnostics Script
# Run this from the ShizukuBooster project root on your Mac

set -e
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  Shizuku Game Booster — iOS Setup Script"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# 1. Check Flutter
echo "🔍 Checking Flutter..."
if ! command -v flutter &> /dev/null; then
    echo -e "${RED}✗ Flutter not found. Install from https://flutter.dev${NC}"
    exit 1
fi
FLUTTER_VERSION=$(flutter --version 2>&1 | head -1)
echo -e "${GREEN}✓ $FLUTTER_VERSION${NC}"

# 2. Check we're in the right directory
if [ ! -f "pubspec.yaml" ]; then
    echo -e "${RED}✗ pubspec.yaml not found. Run this script from the ShizukuBooster root directory.${NC}"
    exit 1
fi
echo -e "${GREEN}✓ Project root found${NC}"

# 3. flutter pub get (generates Generated.xcconfig — REQUIRED for iOS build)
echo ""
echo "📦 Running flutter pub get..."
flutter pub get
if [ -f "ios/Flutter/Generated.xcconfig" ]; then
    echo -e "${GREEN}✓ Generated.xcconfig created${NC}"
else
    echo -e "${RED}✗ Generated.xcconfig missing — flutter pub get may have failed${NC}"
    exit 1
fi

# 4. Check CocoaPods
echo ""
echo "🔍 Checking CocoaPods..."
if ! command -v pod &> /dev/null; then
    echo -e "${YELLOW}⚠ CocoaPods not found. Installing...${NC}"
    sudo gem install cocoapods
fi
POD_VERSION=$(pod --version)
echo -e "${GREEN}✓ CocoaPods $POD_VERSION${NC}"

# 5. pod install
echo ""
echo "🔧 Running pod install..."
cd ios
pod install --repo-update
cd ..
echo -e "${GREEN}✓ CocoaPods installed${NC}"

# 6. Verify ENABLE_USER_SCRIPT_SANDBOXING fix
echo ""
echo "🔍 Checking Xcode sandboxing fix..."
if grep -q "ENABLE_USER_SCRIPT_SANDBOXING = NO" ios/Runner.xcodeproj/project.pbxproj; then
    echo -e "${GREEN}✓ ENABLE_USER_SCRIPT_SANDBOXING = NO is set${NC}"
else
    echo -e "${YELLOW}⚠ Adding ENABLE_USER_SCRIPT_SANDBOXING = NO fix...${NC}"
    # Apply via sed if missing
    sed -i '' 's/TARGETED_DEVICE_FAMILY = "1,2";/ENABLE_USER_SCRIPT_SANDBOXING = NO;\n\t\t\t\tTARGETED_DEVICE_FAMILY = "1,2";/g' \
        ios/Runner.xcodeproj/project.pbxproj
    echo -e "${GREEN}✓ Fix applied${NC}"
fi

# 7. Final instructions
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo -e "${GREEN}✅ Setup complete! Next steps:${NC}"
echo ""
echo "  1. Open in Xcode:"
echo "     open ios/Runner.xcworkspace"
echo ""
echo "  2. In Xcode:"
echo "     • Select your device or simulator at the top"
echo "     • Go to: Runner target → Signing & Capabilities"
echo "     • Set your Team (Apple ID)"
echo "     • Change Bundle Identifier if needed"
echo ""
echo "  3. Press ▶ Run  (or use flutter run)"
echo ""
echo "  ⚠️  Always open Runner.xcworkspace, NOT Runner.xcodeproj"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
