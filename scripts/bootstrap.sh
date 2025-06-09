#!/bin/bash

# HenFire Browser Bootstrap Script
# This script sets up the development environment and downloads Firefox source code

set -e

echo "🔥 HenFire Browser Bootstrap Script"
echo "===================================="

# Check if we're on macOS
if [[ "$OSTYPE" != "darwin"* ]]; then
    echo "❌ This script is designed for macOS. Please check the documentation for other platforms."
    exit 1
fi

# Check for required tools
echo "📋 Checking prerequisites..."

# Check for Xcode Command Line Tools
if ! xcode-select -p &> /dev/null; then
    echo "❌ Xcode Command Line Tools not found. Please install with: xcode-select --install"
    exit 1
fi

# Check for Python 3.11+
if ! command -v python3 &> /dev/null; then
    echo "❌ Python 3 not found. Please install Python 3.11 or later."
    exit 1
fi

PYTHON_VERSION=$(python3 -c "import sys; print(f'{sys.version_info.major}.{sys.version_info.minor}')")
if [[ $(echo "$PYTHON_VERSION < 3.11" | bc -l) -eq 1 ]]; then
    echo "❌ Python 3.11+ required. Found version $PYTHON_VERSION"
    exit 1
fi

# Check for Git
if ! command -v git &> /dev/null; then
    echo "❌ Git not found. Please install Git."
    exit 1
fi

echo "✅ Prerequisites check passed"

# Create necessary directories
echo "📁 Creating project structure..."
mkdir -p browser/themes
mkdir -p browser/components
mkdir -p browser/locales
mkdir -p modules/memory-manager
mkdir -p modules/ui-cleaner
mkdir -p modules/privacy-tools
mkdir -p patches
mkdir -p config
mkdir -p src

# Download Firefox source code
echo "📥 Downloading Firefox source code..."
cd src

if [ ! -d "firefox" ]; then
    echo "Cloning Firefox repository (this may take a while)..."
    git clone https://github.com/mozilla/gecko-dev.git firefox
    cd firefox
    # Use the default branch (master)
    echo "Using default branch for Firefox source"
else
    echo "Firefox source already exists, updating..."
    cd firefox
    git pull origin master
fi

cd ../..

# Install Python dependencies
echo "🐍 Installing Python dependencies..."
pip3 install --user mercurial

# Download and run Mozilla's bootstrap script
echo "🚀 Running Mozilla bootstrap..."
cd src/firefox
curl -o bootstrap.py https://raw.githubusercontent.com/mozilla/gecko-dev/master/python/mozboot/bin/bootstrap.py
python3 bootstrap.py --application-choice=browser --no-interactive

cd ../..

# Apply HenFire patches
echo "🔧 Applying HenFire customizations..."
./scripts/apply-patches.sh

# Create mozconfig
echo "⚙️ Creating build configuration..."
cp config/mozconfig.template src/firefox/mozconfig

echo "✅ Bootstrap completed successfully!"
echo ""
echo "Next steps:"
echo "1. cd into the project directory"
echo "2. Run './mach build' to build HenFire"
echo "3. Run './mach run' to launch HenFire"
echo ""
echo "For more information, see the README.md file."