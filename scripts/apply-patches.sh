#!/bin/bash

# HenFire Patch Application Script
# Applies custom patches and modifications to Firefox source

set -e

echo "🔧 Applying HenFire patches and customizations..."

FIREFOX_SRC="src/firefox"

if [ ! -d "$FIREFOX_SRC" ]; then
    echo "❌ Firefox source not found. Please run bootstrap.sh first."
    exit 1
fi

# Apply memory management patches
echo "📝 Applying memory management patches..."
if [ -f "patches/memory-management.patch" ]; then
    cd "$FIREFOX_SRC"
    git apply ../../patches/memory-management.patch
    cd ../..
fi

# Apply UI customization patches
echo "🎨 Applying UI customization patches..."
if [ -f "patches/ui-cleanup.patch" ]; then
    cd "$FIREFOX_SRC"
    git apply ../../patches/ui-cleanup.patch
    cd ../..
fi

# Copy custom modules
echo "📦 Installing custom modules..."

# Memory Manager Module
if [ -d "modules/memory-manager" ]; then
    cp -r modules/memory-manager/* "$FIREFOX_SRC/browser/modules/"
fi

# UI Cleaner Module
if [ -d "modules/ui-cleaner" ]; then
    cp -r modules/ui-cleaner/* "$FIREFOX_SRC/browser/themes/shared/"
fi

# Privacy Tools Module
if [ -d "modules/privacy-tools" ] && [ "$(ls -A modules/privacy-tools)" ]; then
    cp -r modules/privacy-tools/* "$FIREFOX_SRC/browser/components/"
fi

# Copy custom themes
echo "🎨 Installing custom themes..."
if [ -d "browser/themes" ] && [ "$(ls -A browser/themes)" ]; then
    cp -r browser/themes/* "$FIREFOX_SRC/browser/themes/"
fi

# Copy custom components
echo "🧩 Installing custom components..."
if [ -d "browser/components" ] && [ "$(ls -A browser/components)" ]; then
    cp -r browser/components/* "$FIREFOX_SRC/browser/components/"
fi

# Apply configuration changes
echo "⚙️ Applying configuration changes..."

# Create custom prefs file
cat > "$FIREFOX_SRC/browser/app/profile/henfire.js" << 'EOF'
// HenFire Browser Default Preferences

// Memory Management
pref("henfire.memory.max_usage_mb", 2048);
pref("henfire.memory.tab_suspend_threshold", 1536);
pref("henfire.memory.auto_gc_enabled", true);
pref("henfire.memory.aggressive_gc", true);

// Process Management
pref("dom.ipc.processCount", 2);
pref("dom.ipc.processCount.webIsolated", 1);
pref("fission.autostart", false);

// Cache Optimization
pref("browser.cache.memory.capacity", 524288); // 512MB
pref("browser.cache.disk.capacity", 1048576);  // 1GB
pref("browser.cache.memory.max_entry_size", 51200);

// Tab Management
pref("browser.tabs.loadInBackground", false);
pref("browser.tabs.loadDivertedInBackground", true);
pref("browser.sessionstore.max_tabs_undo", 5);
pref("browser.sessionstore.max_windows_undo", 2);

// Privacy & Security
pref("datareporting.healthreport.uploadEnabled", false);
pref("datareporting.policy.dataSubmissionEnabled", false);
pref("toolkit.telemetry.enabled", false);
pref("toolkit.telemetry.unified", false);
pref("browser.newtabpage.activity-stream.feeds.telemetry", false);
pref("browser.newtabpage.activity-stream.telemetry", false);

// UI Customizations
pref("henfire.ui.clean_mode", true);
pref("henfire.ui.minimal_toolbar", true);
pref("henfire.ui.hide_pocket", true);
pref("browser.toolbars.bookmarks.visibility", "never");

// Performance
pref("gfx.webrender.all", true);
pref("media.hardware-video-decoding.force-enabled", true);
pref("layers.acceleration.force-enabled", true);
EOF

echo "✅ All patches and customizations applied successfully!"
echo "📋 Summary of changes:"
echo "   - Memory management system installed"
echo "   - UI cleanup patches applied"
echo "   - Privacy enhancements enabled"
echo "   - Performance optimizations configured"
echo "   - Custom themes and components installed"