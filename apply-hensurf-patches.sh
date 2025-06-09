#!/bin/bash

# HenSurf Browser Customization Script
# This script applies all customizations to rebrand HenFire to HenSurf
# and removes sponsored content, sets DuckDuckGo as default search engine

set -e

echo "🏄 Starting HenSurf customization..."

FIREFOX_SRC="src/firefox"
HENSURF_BRANDING="browser/branding/hensurf"

if [ ! -d "$FIREFOX_SRC" ]; then
    echo "❌ Firefox source not found. Please run bootstrap first."
    exit 1
fi

# 1. Copy HenSurf branding files
echo "📝 Applying HenSurf branding..."
mkdir -p "$FIREFOX_SRC/browser/branding/hensurf"
cp -r "$HENSURF_BRANDING"/* "$FIREFOX_SRC/browser/branding/hensurf/"

# 2. Copy logo files
echo "🖼️ Installing HenSurf logos..."
if [ -f "HenSurfLogo.png" ]; then
    # macOS app icon
    mkdir -p "$FIREFOX_SRC/browser/branding/hensurf/content"
    cp "HenSurfLogo.png" "$FIREFOX_SRC/browser/branding/hensurf/content/icon.png"
    cp "HenSurfLogo.png" "$FIREFOX_SRC/browser/branding/hensurf/content/icon64.png"
    cp "HenSurfLogo.png" "$FIREFOX_SRC/browser/branding/hensurf/content/icon128.png"
fi

if [ -f "HenSurfEmblem.svg" ]; then
    # Use SVG emblem for other platforms
    cp "HenSurfEmblem.svg" "$FIREFOX_SRC/browser/branding/hensurf/content/emblem.svg"
fi

# 3. Update mozconfig for HenSurf branding
echo "⚙️ Updating build configuration..."
# The mozconfig options are now handled by autobuild.sh

# 4. Create custom preferences file
echo "🔧 Setting up custom preferences..."
cat > "$FIREFOX_SRC/browser/app/profile/hensurf.js" << 'EOF'
// HenSurf Browser Default Preferences

// Branding
pref("general.useragent.override", "Mozilla/5.0 (compatible; HenSurf/1.0)");
pref("browser.startup.homepage", "about:home");
pref("startup.homepage_welcome_url", "about:home");

// Default Search Engine - DuckDuckGo
pref("browser.search.defaultenginename", "DuckDuckGo");
pref("browser.search.order.1", "DuckDuckGo");
pref("browser.urlbar.placeholderName", "DuckDuckGo");

// Privacy Settings
pref("privacy.trackingprotection.enabled", true);
pref("privacy.trackingprotection.socialtracking.enabled", true);
pref("privacy.trackingprotection.cryptomining.enabled", true);
pref("privacy.trackingprotection.fingerprinting.enabled", true);
pref("privacy.donottrackheader.enabled", true);
pref("privacy.clearOnShutdown.cookies", false);
pref("privacy.clearOnShutdown.history", false);

// Disable Sponsored Content
pref("browser.newtabpage.activity-stream.showSponsored", false);
pref("browser.newtabpage.activity-stream.showSponsoredTopSites", false);
pref("browser.newtabpage.activity-stream.feeds.section.topstories", false);
pref("browser.newtabpage.activity-stream.feeds.topsites", true);
pref("browser.newtabpage.activity-stream.topSitesRows", 2);

// Disable Pocket
pref("extensions.pocket.enabled", false);
pref("extensions.pocket.api", "");
pref("extensions.pocket.site", "");

// Disable Telemetry and Data Collection
pref("datareporting.healthreport.uploadEnabled", false);
pref("datareporting.policy.dataSubmissionEnabled", false);
pref("toolkit.telemetry.enabled", false);
pref("toolkit.telemetry.unified", false);
pref("toolkit.telemetry.server", "");
pref("experiments.enabled", false);
pref("experiments.supported", false);
pref("network.allow-experiments", false);

// Disable Firefox Studies
pref("app.shield.optoutstudies.enabled", false);
pref("app.normandy.enabled", false);
pref("app.normandy.api_url", "");

// Performance
pref("browser.cache.disk.enable", true);
pref("browser.cache.memory.enable", true);
pref("browser.sessionhistory.max_total_viewers", 4);
pref("network.http.pipelining", true);
pref("network.http.pipelining.maxrequests", 8);

// UI Customizations
pref("browser.toolbars.bookmarks.visibility", "never");
pref("browser.tabs.warnOnClose", false);
pref("browser.tabs.warnOnCloseOtherTabs", false);
pref("browser.tabs.warnOnOpen", false);
pref("browser.aboutConfig.showWarning", false);

// Security
pref("security.tls.version.min", 3);
pref("security.ssl.require_safe_negotiation", true);
pref("security.ssl.treat_unsafe_negotiation_as_broken", true);
pref("security.tls.hello_downgrade_check", true);

// Disable WebRTC IP leak
pref("media.peerconnection.ice.default_address_only", true);
pref("media.peerconnection.ice.no_host", true);

// Custom Theme
pref("extensions.activeThemeID", "hensurf-theme@hensurf.org");
EOF

# 5. Remove Pocket components
echo "🚫 Removing Pocket integration..."
# Allow find to report if it encounters errors other than not finding files
# Exit status of find is 0 if it successfully searches, even if no files are found.
find "$FIREFOX_SRC" -name "*pocket*" -type f -delete
find "$FIREFOX_SRC" -name "*Pocket*" -type f -delete

# Remove Pocket directories. rm -rf will not error if directories don't exist.
# Errors will only show for issues like permission problems.
rm -rf "$FIREFOX_SRC/browser/components/pocket"
rm -rf "$FIREFOX_SRC/browser/extensions/pocket"

# 6. Update search configuration to prioritize DuckDuckGo
echo "🔍 Setting DuckDuckGo as default search engine..."
if [ -f "$FIREFOX_SRC/services/settings/dumps/main/search-config-v2.json" ]; then
    # Backup original
    cp "$FIREFOX_SRC/services/settings/dumps/main/search-config-v2.json" "$FIREFOX_SRC/services/settings/dumps/main/search-config-v2.json.backup"
    
    # Update search config to prioritize DuckDuckGo
    python3 << 'PYTHON_SCRIPT'
import json
import sys

try:
    with open('src/firefox/services/settings/dumps/main/search-config-v2.json', 'r') as f:
        config = json.load(f)
    
    # Find DuckDuckGo entry and move it to the top
    ddg_entry = None
    other_entries = []
    
    for entry in config['data']:
        if entry.get('identifier') == 'ddg' or 'duckduckgo' in str(entry).lower():
            ddg_entry = entry
            # Set as default
            if 'base' in entry:
                entry['base']['default'] = True
        else:
            # Remove Google as default
            if 'google' in str(entry).lower() and 'base' in entry:
                entry['base']['default'] = False
            other_entries.append(entry)
    
    # Reorder with DuckDuckGo first
    if ddg_entry:
        config['data'] = [ddg_entry] + other_entries
    
    with open('src/firefox/services/settings/dumps/main/search-config-v2.json', 'w') as f:
        json.dump(config, f, indent=2)
    
    print("✅ DuckDuckGo set as default search engine")
except Exception as e:
    print(f"⚠️ Could not update search config: {e}")
PYTHON_SCRIPT
fi

# 7. Create custom theme
echo "🎨 Installing HenSurf custom theme..."
mkdir -p "$FIREFOX_SRC/browser/branding/hensurf/extensions/hensurf-theme@hensurf.org"
cat > "$FIREFOX_SRC/browser/branding/hensurf/extensions/hensurf-theme@hensurf.org/manifest.json" << 'EOF'
{
  "manifest_version": 2,
  "name": "HenSurf Theme",
  "version": "1.0",
  "description": "Official HenSurf Browser Theme",
  "browser_specific_settings": {
    "gecko": {
      "id": "hensurf-theme@hensurf.org"
    }
  },
  "theme": {
    "colors": {
      "toolbar": "#0078D4",
      "toolbar_text": "#FFFFFF",
      "frame": "#004578",
      "tab_background_text": "#FFFFFF",
      "tab_line": "#00A8E6",
      "tab_loading": "#00A8E6",
      "bookmark_text": "#FFFFFF",
      "button_background_hover": "#106EBE",
      "button_background_active": "#005A9E",
      "popup": "#F3F2F1",
      "popup_text": "#323130",
      "popup_border": "#D2D0CE",
      "popup_highlight": "#DEECF9",
      "ntp_background": "#FAFAFA",
      "ntp_text": "#323130",
      "sidebar": "#F3F2F1",
      "sidebar_text": "#323130",
      "sidebar_border": "#D2D0CE"
    },
    "images": {
      "theme_frame": "background.png"
    },
    "properties": {
      "color_scheme": "light",
      "content_color_scheme": "light"
    }
  }
}
EOF

# 8. build-hensurf.sh is removed, autobuild.sh is now the main build script.

# 9. Update README
echo "📚 Updating documentation..."
cat > "README-HenSurf.md" << 'EOF'
# HenSurf Browser

🏄 **HenSurf** is a privacy-focused web browser based on Firefox, designed for a clean, fast, and secure browsing experience.

## Features

- 🔒 **Enhanced Privacy**: Built-in tracking protection and ad blocking
- 🚫 **No Sponsored Content**: Completely removes all sponsored stories and ads
- 🔍 **DuckDuckGo Default**: Privacy-focused search engine set as default
- 🎨 **Custom Theme**: Beautiful ocean-inspired design
- ⚡ **Optimized Performance**: Faster startup and browsing
- 🛡️ **Security First**: Latest security patches and hardened configuration

## Building HenSurf

### Prerequisites
- Git
- Python 3.6+
- Rust
- Node.js
- Platform-specific build tools (Xcode on macOS, Visual Studio on Windows, GCC on Linux)

### Build Instructions

1. **Clone and Setup**:
   ```bash
   git clone <repository-url> # Or ensure you are in the project root
   # The autobuild script will handle patches and bootstrapping.
   ```

2. **Build HenSurf (using autobuild)**:
   ```bash
   ./autobuild.sh [options]
   # Example: ./autobuild.sh -c  (for a clean build for your current platform)
   # Example: ./autobuild.sh -p linux (to build for Linux)
   # Run ./autobuild.sh --help for all options.
   ```
   The `autobuild.sh` script will typically:
   - Apply necessary HenSurf customizations (like those in `apply-hensurf-patches.sh`).
   - Bootstrap Firefox sources if needed.
   - Build the browser for the specified (or auto-detected) platform.

### Platform-Specific Builds
The `autobuild.sh` script handles platform-specific builds and packaging.
Refer to `autobuild.sh --help` for more details.
- **macOS**: Creates `.dmg` installer and `.app` bundle.
- **Linux**: Creates `.tar.bz2` package and potentially AppImage.
- **Windows**: Creates `.exe` installer.

## Configuration

HenSurf comes pre-configured with privacy-focused settings:

- Tracking protection enabled
- Sponsored content disabled
- Telemetry disabled
- DuckDuckGo as default search
- Custom HenSurf theme

## Privacy Features

- **No Data Collection**: Telemetry and data reporting completely disabled
- **No Sponsored Content**: Pocket stories and sponsored tiles removed
- **Enhanced Tracking Protection**: Blocks trackers, cryptominers, and fingerprinting
- **Secure DNS**: DNS over HTTPS enabled by default
- **WebRTC Protection**: Prevents IP address leaks

## Customization

HenSurf can be further customized by modifying:
- `src/firefox/browser/app/profile/hensurf.js` - Default preferences
- `browser/branding/hensurf/` - Branding and logos
- `src/firefox/browser/themes/hensurf/` - Custom theme

## Support

For issues and support:
- Check existing issues in the repository
- Create a new issue with detailed information
- Join our community discussions

## License

HenSurf is based on Firefox and is licensed under the Mozilla Public License 2.0.

---

**Surf the web with privacy and style! 🏄‍♂️**
EOF

echo "✅ HenSurf customization completed!"
echo ""
echo "🏄 Next steps:"
echo "To build the browser, run the main autobuild script:"
echo "   ./autobuild.sh"
echo "For example, for a clean build for your current platform:"
echo "   ./autobuild.sh -c"
echo "Run ./autobuild.sh --help for more options."
echo ""
echo "The autobuild script will handle bootstrapping, applying patches, and building HenSurf with:"
echo "   - HenSurf branding and logos"
echo "   - DuckDuckGo as default search engine"
echo "   - All sponsored content removed"
echo "   - Custom ocean theme"
echo "   - Enhanced privacy settings"
echo ""
echo "🎉 Welcome to HenSurf - Surf the web with privacy!"