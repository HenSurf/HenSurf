#!/bin/bash

# HenFire Branding Configuration
# This script sets up the custom branding for HenFire browser

set -e

echo "🔥 Setting up HenFire branding..."

BRANDING_DIR="browser/branding/henfire"
FIREFOX_SRC="src/firefox"

if [ ! -d "$FIREFOX_SRC" ]; then
    echo "❌ Firefox source not found. Please run bootstrap.sh first."
    exit 1
fi

# Create branding directory in Firefox source
mkdir -p "$FIREFOX_SRC/$BRANDING_DIR"

# Copy branding files
cp -r browser/branding/henfire/* "$FIREFOX_SRC/$BRANDING_DIR/"

echo "✅ HenFire branding configured successfully!"