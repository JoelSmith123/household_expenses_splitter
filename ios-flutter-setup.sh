#!/bin/bash

# to run, simply run in terminal:
# ./ios-flutter-setup.sh

# --- Configuration ---
PROJECT_NAME="BillShareProject"
# LOG_FILE="./setup_log_$(date +%Y%m%d_%H%M%S).txt"

# Colors for better terminal output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

# Function to log and echo
log_and_echo() {
    # echo -e "${GREEN}---> $1${NC}" | tee -a "$LOG_FILE"
    echo -e "${GREEN}---> $1${NC}"
}

log_error() {
    # echo -e "${RED}*** ERROR: $1${NC}" | tee -a "$LOG_FILE"
    echo -e "${RED}*** ERROR: $1${NC}"
}

# --- Start Script Execution ---
log_and_echo "Starting $PROJECT_NAME development environment setup..."
# log_and_echo "Logging output to $LOG_FILE"
echo "=================================================="

# 1. Update Flutter and Dependencies
# ----------------------------------
log_and_echo "1. Checking/Updating Flutter SDK..."
flutter upgrade
if [ $? -ne 0 ]; then
    log_error "Flutter upgrade failed. Check connection or Flutter installation."
    # Exit or continue, depending on how critical this is. Let's continue for now.
fi

log_and_echo "2. Getting Dart/Flutter dependencies..."
flutter pub get
if [ $? -ne 0 ]; then
    log_error "Failed to get Dart dependencies."
    # Exit or continue
fi

# 2. Check/Fix iOS/Xcode Environment
# ----------------------------------
log_and_echo "3. Checking iOS/Xcode environment status..."
flutter doctor --ios
# NOTE: flutter doctor will prompt for most common issues,
# but it's a good check.

log_and_echo "4. Checking/Updating CocoaPods..."
# CocoaPods is crucial for native iOS dependencies
which pod > /dev/null
if [ $? -ne 0 ]; then
    log_and_echo "   CocoaPods not found. Installing now (requires sudo)..."
    sudo gem install cocoapods
fi

log_and_echo "5. Running pod install for iOS project..."
# Navigate to the iOS directory and install/update pods
(cd ios && pod install)
if [ $? -ne 0 ]; then
    log_error "Failed to run 'pod install'. Ensure Xcode is installed and configured."
    # NOTE: If Xcode has been majorly updated, you might need to run
    # 'sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer' manually.
fi

# 3. Clean and Build (Optional but Recommended)
# ---------------------------------------------
log_and_echo "6. Cleaning project artifacts..."
flutter clean

# 4. Launch Simulator and App
# -----------------------------
log_and_echo "7. Finding an available iOS Simulator..."
# Finds the name of the first available iPhone simulator
SIMULATOR_NAME=$(flutter devices | grep -E 'iPhone.*(simulator)' | head -n 1 | awk '{print $1}')

if [ -z "$SIMULATOR_NAME" ]; then
    log_error "Could not find an available iOS Simulator. You may need to launch Xcode to create one."
    log_and_echo "Setup complete, but unable to launch the app automatically."
else
    log_and_echo "8. Launching app on $SIMULATOR_NAME..."
    # You can choose to run with --debug or just let it start.
    # The `&` runs this in the background, so the script completes but the app keeps running.
    # NOTE: It's better to launch this *outside* the script if you want to keep the terminal for live output.
    # For a *setup* script, let's just make sure the environment is ready and then prompt the user.
    # flutter run -d "$SIMULATOR_NAME" &
    # log_and_echo "   App is launching in the background. Check the simulator."
    log_and_echo "   Environment ready. Now run 'flutter run' in your terminal or click 'Run' in VS Code."
fi

log_and_echo "=================================================="
log_and_echo "${GREEN}✅ Setup Complete! You should now be able to code and run the project.${NC}"
