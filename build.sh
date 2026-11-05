#!/bin/bash

# LocalSend Clone Build Script
# This script will help you build the LocalSend clone APK

set -e  # Exit on error

echo "=========================================="
echo "  LocalSend Clone - Build Script"
echo "=========================================="
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if Flutter is installed
echo -e "${YELLOW}[1/8] Checking Flutter installation...${NC}"
if ! command -v flutter &> /dev/null; then
    echo -e "${RED}❌ Flutter is not installed!${NC}"
    echo "Please install Flutter from: https://flutter.dev/docs/get-started/install"
    exit 1
fi
echo -e "${GREEN}✅ Flutter is installed${NC}"
flutter --version
echo ""

# Check Flutter doctor
echo -e "${YELLOW}[2/8] Running Flutter doctor...${NC}"
flutter doctor -v
echo ""

# Clean previous build
echo -e "${YELLOW}[3/8] Cleaning previous build...${NC}"
flutter clean
echo -e "${GREEN}✅ Clean completed${NC}"
echo ""

# Get dependencies
echo -e "${YELLOW}[4/8] Getting dependencies...${NC}"
flutter pub get
echo -e "${GREEN}✅ Dependencies installed${NC}"
echo ""

# Run code generation (if needed)
echo -e "${YELLOW}[5/8] Running code generation...${NC}"
if grep -q "build_runner" pubspec.yaml; then
    flutter pub run build_runner build --delete-conflicting-outputs
    echo -e "${GREEN}✅ Code generation completed${NC}"
else
    echo -e "${YELLOW}⏭️  No code generation needed${NC}"
fi
echo ""

# Check for connected devices
echo -e "${YELLOW}[6/8] Checking for devices...${NC}"
flutter devices
echo ""

# Ask user which build type
echo -e "${YELLOW}[7/8] Select build type:${NC}"
echo "1) Debug APK (for testing)"
echo "2) Release APK (optimized, smaller size)"
echo "3) App Bundle (for Play Store)"
echo "4) Run on connected device"
echo ""
read -p "Enter your choice (1-4): " choice

case $choice in
    1)
        echo -e "${YELLOW}Building debug APK...${NC}"
        flutter build apk --debug
        APK_PATH="build/app/outputs/flutter-apk/app-debug.apk"
        ;;
    2)
        echo -e "${YELLOW}Building release APK...${NC}"
        flutter build apk --release
        APK_PATH="build/app/outputs/flutter-apk/app-release.apk"
        ;;
    3)
        echo -e "${YELLOW}Building app bundle...${NC}"
        flutter build appbundle --release
        APK_PATH="build/app/outputs/bundle/release/app-release.aab"
        ;;
    4)
        echo -e "${YELLOW}Running on device...${NC}"
        flutter run
        exit 0
        ;;
    *)
        echo -e "${RED}Invalid choice!${NC}"
        exit 1
        ;;
esac

echo ""
echo -e "${YELLOW}[8/8] Build process...${NC}"
echo ""

# Check if build succeeded
if [ -f "$APK_PATH" ]; then
    echo -e "${GREEN}=========================================="
    echo "  ✅ BUILD SUCCESSFUL!"
    echo "==========================================${NC}"
    echo ""
    echo "📦 Output file: $APK_PATH"
    echo "📊 File size: $(du -h "$APK_PATH" | cut -f1)"
    echo ""
    echo "Next steps:"
    echo "1. Transfer the APK to your Android device"
    echo "2. Install the APK (enable 'Install from Unknown Sources' if needed)"
    echo "3. Open LocalSend and start sharing files!"
    echo ""
    
    # Offer to open file location
    read -p "Open output folder? (y/n): " open_folder
    if [ "$open_folder" = "y" ] || [ "$open_folder" = "Y" ]; then
        case "$(uname -s)" in
            Linux*)
                xdg-open "$(dirname "$APK_PATH")" 2>/dev/null || nautilus "$(dirname "$APK_PATH")" 2>/dev/null || echo "Please open: $(dirname "$APK_PATH")"
                ;;
            Darwin*)
                open "$(dirname "$APK_PATH")"
                ;;
            MINGW*|MSYS*|CYGWIN*)
                explorer "$(dirname "$APK_PATH")"
                ;;
            *)
                echo "Output location: $(dirname "$APK_PATH")"
                ;;
        esac
    fi
else
    echo -e "${RED}=========================================="
    echo "  ❌ BUILD FAILED!"
    echo "==========================================${NC}"
    echo ""
    echo "Please check the error messages above."
    echo "Common issues:"
    echo "- Missing Android SDK"
    echo "- Gradle configuration errors"
    echo "- Dependency conflicts"
    echo ""
    echo "For help, visit: ${AppConstants.githubIssues}"
    exit 1
fi

echo ""
echo -e "${GREEN}Thank you for using LocalSend Clone!${NC}"
echo ""
