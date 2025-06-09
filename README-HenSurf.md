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
   git clone <repository-url>
   cd HenFire
   ./apply-hensurf-patches.sh
   ```

2. **Bootstrap Firefox**:
   ```bash
   cd src/firefox
   ./mach bootstrap
   ```

3. **Build HenSurf**:
   ```bash
   cd ../..
   ./build-hensurf.sh
   ```

### Platform-Specific Builds

- **macOS**: Creates `.dmg` installer
- **Linux**: Creates `.tar.bz2` package and AppImage (if available)
- **Windows**: Creates `.exe` installer

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
