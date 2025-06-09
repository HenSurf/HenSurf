#!/bin/bash

# HenSurf Browser Branding Configuration
# This script sets up the custom branding for HenSurf browser

echo "Setting up HenSurf branding..."

# Create branding directory in Firefox source
BRANDING_DIR="$MOZ_OBJDIR/dist/branding"
mkdir -p "$BRANDING_DIR"

# Copy branding files
cp -r "$(dirname "$0")"/* "$BRANDING_DIR/"

# Copy user's custom logo files
cp "/Users/henryperzinski/Developer/HenFire/HenSurfLogo.png" "$BRANDING_DIR/"
cp "/Users/henryperzinski/Developer/HenFire/HenSurfEmblem.svg" "$BRANDING_DIR/"

# Set up macOS app bundle icon
if [[ "$OSTYPE" == "darwin"* ]]; then
    APP_BUNDLE="$MOZ_OBJDIR/dist/HenSurf.app"
    if [ -d "$APP_BUNDLE" ]; then
        cp "$BRANDING_DIR/hensurf.icns" "$APP_BUNDLE/Contents/Resources/firefox.icns"
        echo "Updated macOS app icon"
    fi
fi

echo "HenSurf branding setup complete!"