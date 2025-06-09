#!/bin/bash

# HenSurf Multi-Platform Build Script

set -e

echo "🏄 Building HenSurf Browser for all platforms..."

cd src/firefox

# Clean previous builds
./mach clobber

echo "🔨 Building HenSurf..."
./mach build

echo "📦 Creating packages..."

# Create different package formats based on platform
if [[ "$OSTYPE" == "darwin"* ]]; then
    echo "🍎 Creating macOS package..."
    ./mach package
    ./mach dmg
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    echo "🐧 Creating Linux packages..."
    ./mach package
    # Create AppImage if available
    if command -v appimagetool &> /dev/null; then
        echo "📱 Creating AppImage..."
        ./mach appimage
    fi
elif [[ "$OSTYPE" == "msys" ]] || [[ "$OSTYPE" == "cygwin" ]]; then
    echo "🪟 Creating Windows package..."
    ./mach package
    ./mach installer
else
    echo "📦 Creating generic package..."
    ./mach package
fi

echo "✅ HenSurf build completed!"
echo "📁 Build artifacts are in: obj-*/dist/"
