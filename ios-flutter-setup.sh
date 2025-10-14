#!/bin/bash

# BEFORE RUNNING
# for simpler setup, simply run: 
# flutter run

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

log_notice() {
    echo -e "${YELLOW} $1${NC}"
}

# --- Start Script Execution ---
log_and_echo "Starting $PROJECT_NAME development environment setup..."
sudo
# log_and_echo "Logging output to $LOG_FILE"
echo "=================================================="

# Update Brew
# ----------------------------------
log_and_echo "Updating Brew ..."
brew update
if [ $? -ne 0 ]; then
    log_error "Brew update failed."
    exit 1
fi
brew upgrade
if [ $? -ne 0 ]; then
    log_error "Brew upgrade failed."
    exit 1
fi

# Update Flutter and Dependencies
# ----------------------------------
log_and_echo "Updating Flutter SDK..."
flutter upgrade
if [ $? -ne 0 ]; then
    log_error "Flutter upgrade failed. Check connection or Flutter installation."
    exit 1
fi

log_and_echo "Updating Dart/Flutter dependencies..."
flutter pub upgrade --major-versions
if [ $? -ne 0 ]; then
    log_error "Failed to update Dart/Flutter dependencies."
    exit 1
fi

# Check/Fix iOS/Xcode Environment
# ----------------------------------
log_and_echo "Checking iOS/Xcode environment status..."
log_notice "Skipping 'flutter doctor' for now."
# flutter doctor

log_and_echo "Updating CocoaPods..."
# CocoaPods is crucial for native iOS dependencies
gem install cocoapods
if [ $? -ne 0 ]; then
    log_error "Failed to update CocoaPods."
    exit 1
fi

pod setup
if [ $? -ne 0 ]; then
    log_error "Failed to run CocoaPods setup."
    exit 1
fi

log_and_echo "Running pod update for iOS project..."
# Navigate to the iOS directory and install/update pods
(cd ios && pod install --repo-update)
if [ $? -ne 0 ]; then
    log_error "Failed to run update pods. Ensure Xcode is installed and configured."
    # NOTE: If Xcode has been majorly updated, you might need to run
    # 'sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer' manually.
    exit 1
fi

# Clean and Build (Optional but Recommended)
# ---------------------------------------------
log_and_echo "Cleaning project artifacts..."
flutter clean
if [ $? -ne 0 ]; then
    log_error "Failed to clean project artifacts."
fi

# Start iOS Simulator
# -----------------------------
log_and_echo "Starting iOS Simulator..."
open -a Simulator
if [ $? -ne 0 ]; then
    log_error "Failed to start iOS Simulator."
    exit 1
fi

# Launch Flutter App
# -----------------------------
log_and_echo "Launching Flutter app on iOS Simulator..."
flutter run
if [ $? -ne 0 ]; then
    log_error "Failed to launch."
    exit 1
fi

log_and_echo "=================================================="
log_and_echo "${GREEN}✅ Setup Complete! You should now be able to code and run the project.${NC}"
