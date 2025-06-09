# HenSurf Browser 🏄

A privacy-focused web browser based on Firefox, designed for enhanced security and user control. Surf the web with complete privacy!

## Features

- **🔒 Enhanced Privacy**: Built-in tracking protection and privacy-focused defaults
- **🎨 Custom Ocean Theme**: Beautiful custom theme with ocean-inspired design
- **🛡️ Security First**: Hardened security settings and reduced attack surface
- **🚫 No Telemetry**: Complete removal of data collection and telemetry
- **🦆 DuckDuckGo Default**: Privacy-focused search engine set as default
- **🧹 No Sponsored Content**: Removed all sponsored bookmarks and "thought-provoking stories"
- **🚀 Lightweight**: Optimized build with unnecessary components removed
- **🌊 Custom Branding**: Beautiful HenSurf logos and branding throughout

## Quick Start

### Prerequisites
- Git
- Python 3.6+
- Node.js 16+
- Rust (latest stable)
- Platform-specific build tools:
  - **Linux**: `build-essential`, `libgtk-3-dev`, `libdbus-glib-1-dev`
  - **macOS**: Xcode Command Line Tools
  - **Windows**: Visual Studio 2019+ with C++ tools

### Build Instructions

#### 🚀 Quick Start (Automated)

HenSurf provides multiple automated build options:

##### Option 1: Enhanced Multi-Platform Builder (Recommended)

1. **Clone the repository**:
   ```bash
   git clone https://github.com/yourusername/henfire.git
   cd henfire
   ```

2. **Run the enhanced builder**:
   ```bash
   # Build for all platforms with organized output
   ./build-all-platforms-enhanced.sh
   
   # Build for specific platforms
   ./build-all-platforms-enhanced.sh --linux --macos
   ./build-all-platforms-enhanced.sh --windows
   
   # Different build types
   ./build-all-platforms-enhanced.sh --debug --all
   ./build-all-platforms-enhanced.sh --nightly --verbose
   
   # Clean build with custom job count
   ./build-all-platforms-enhanced.sh --clean --jobs 8
   
   # Dry run to preview actions
   ./build-all-platforms-enhanced.sh --dry-run
   ```

##### Option 2: Standard Autobuild Script

1. **Run the autobuild script**:
   ```bash
   # Automated build (recommended)
   ./autobuild.sh
   
   # Or with options
   ./autobuild.sh --clean --verbose
   ./autobuild.sh --debug --jobs 8
   ./autobuild.sh --dry-run  # See what would happen
   ```

#### 🔧 Manual Build Process

1. **Initialize submodules**:
   ```bash
   git submodule update --init --recursive
   ```

2. **Apply HenSurf customizations**:
   ```bash
   ./apply-hensurf-patches.sh
   ```

3. **Build for your platform**:
   ```bash
   # Quick build for current platform
   ./build-hensurf.sh
   
   # Or build for all platforms
   ./build-all-platforms.sh
   
   # Or build for specific platforms
   ./build-all-platforms.sh linux macos
   ```

4. **Run HenSurf**:
   ```bash
   cd src/firefox
   ./mach run
   ```

### Multi-Platform Building

HenSurf supports building for multiple platforms:

- **Linux (x86_64)**: `./build-all-platforms.sh linux`
- **macOS (x86_64)**: `./build-all-platforms.sh macos`
- **Windows (x86_64)**: `./build-all-platforms.sh windows`
- **All platforms**: `./build-all-platforms.sh all`

Build artifacts will be available in the `builds/` directory.

### 🤖 Build Script Features

#### Enhanced Multi-Platform Builder (`build-all-platforms-enhanced.sh`)

**Advanced Features:**
- **Organized Output Structure**: Creates structured `builds/` directory with platform/type/version organization
- **Latest Build Links**: Maintains `latest/` directories for easy access to most recent builds
- **Comprehensive Documentation**: Auto-generates README and build info files
- **Platform-Specific Optimization**: Tailored build configurations for each platform
- **Build Artifact Management**: Organized storage with version tracking
- **Multi-Platform Coordination**: Efficient handling of cross-platform builds

**Directory Structure Created:**
```
builds/
├── linux/release/latest/     # Latest Linux release
├── macos/release/latest/     # Latest macOS release
├── windows/release/latest/   # Latest Windows release
└── [platform]/[type]/[version]/  # Versioned builds
```

#### Standard Autobuild Script (`autobuild.sh`)

**Core Features:**
- **Intelligent Prerequisites Check**: Automatically verifies all required tools and dependencies
- **Flexible Build Types**: Support for release, debug, and nightly builds
- **Multi-Platform Support**: Can build for Linux, macOS, Windows, or all platforms
- **Parallel Building**: Automatically detects optimal number of build jobs
- **Clean Builds**: Option to clean previous builds before starting
- **Comprehensive Logging**: Detailed build logs with timestamps
- **Dry Run Mode**: Preview what the script would do without making changes
- **Build Reports**: Generates detailed build reports with system information

**Usage Examples:**
```bash
# Enhanced builder - organized output
./build-all-platforms-enhanced.sh --all --verbose

# Standard builder - quick builds
./autobuild.sh --help                    # Show all options
./autobuild.sh --clean --verbose         # Clean verbose build
./autobuild.sh --debug --jobs 8          # Debug build with 8 parallel jobs
./autobuild.sh --platform all            # Build for all platforms
./autobuild.sh --dry-run                 # Preview without building
./autobuild.sh --skip-bootstrap          # Skip Mozilla bootstrap
```

## Privacy & Security Features

### Enhanced Privacy Protection
HenSurf includes comprehensive privacy features:

- **No Sponsored Content**: Completely removed sponsored bookmarks and "thought-provoking stories"
- **DuckDuckGo Default**: Privacy-focused search engine set as default
- **Tracking Protection**: Enhanced tracking protection enabled by default
- **No Telemetry**: All data collection and telemetry completely removed
- **Pocket Removal**: Pocket integration completely removed

### Custom Ocean Theme
Beautiful custom theme inspired by ocean waves:

- **Ocean Colors**: Blue and teal color scheme throughout the interface
- **Wave Animations**: Subtle wave-inspired animations
- **Custom Icons**: Beautiful HenSurf branding with surfboard logo
- **Clean Design**: Minimalist interface focused on content

### Configuration
HenSurf privacy settings are pre-configured, but can be customized through `about:config`:

```
// Default search engine (DuckDuckGo)
user_pref("browser.search.defaultenginename", "DuckDuckGo");

// Disable sponsored content
user_pref("browser.newtabpage.activity-stream.showSponsoredTopSites", false);

// Enhanced tracking protection
user_pref("privacy.trackingprotection.enabled", true);
```

## UI Customizations

### Ocean Theme
HenSurf features a beautiful ocean-inspired theme:

- **Wave Design**: Interface elements inspired by ocean waves
- **Blue Gradient**: Calming blue color scheme throughout
- **Custom Icons**: Surfboard-inspired icons and branding
- **Reduced Clutter**: Clean interface with unnecessary elements removed
- **Dark Mode**: Enhanced dark mode with ocean-inspired night colors

### Multi-Platform Support
HenSurf is designed to work seamlessly across platforms:

- **macOS**: Native-feeling macOS app with custom app icon
- **Linux**: GTK3 integration with system theme support
- **Windows**: Modern Windows interface with custom installer

### Customization Options
Additional UI customizations available in `about:config`:

```
// Enable compact mode
user_pref("browser.uidensity", 1);

// Use system accent colors with ocean theme
user_pref("browser.theme.colorway-retention", true);

// Enable smooth scrolling
user_pref("general.smoothScroll", true);
```

## Development

### Project Structure
```
henfire/
├── browser/                 # Browser-specific customizations
│   ├── themes/             # UI themes and CSS
│   ├── components/         # Custom UI components
│   └── locales/           # Localization files
├── modules/                # Core functionality modules
│   ├── memory-manager/    # RAM management system
│   ├── ui-cleaner/        # UI simplification
│   └── privacy-tools/     # Privacy enhancements
├── scripts/               # Build and utility scripts
├── patches/               # Firefox source patches
└── config/                # Build configuration
```

### Contributing

Contributions to HenSurf are welcome! Please feel free to submit pull requests or open issues to improve the browser.

## License

This project is licensed under the Mozilla Public License 2.0 - see the [LICENSE](LICENSE) file for details.

---

🏄 **HenSurf Browser** - *Surf the web with privacy!*

## Credits

- **Mozilla Firefox**: The foundation of HenSurf browser
- **DuckDuckGo**: Privacy-focused search engine integration
- **Community Contributors**: Thanks to all who help improve HenSurf
- **Privacy Advocates**: Inspired by the privacy-first movement

🌊 *Ride the waves of privacy with HenSurf!*