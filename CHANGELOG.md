# HenFire Browser Changelog

All notable changes to HenFire Browser will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- Initial HenFire browser fork setup
- Custom build system with HenFire-specific `mach` commands
- Comprehensive documentation (README, INSTALL, PRIVACY)
- Bootstrap script for automated setup on macOS

### Privacy & Security
- Complete removal of Mozilla telemetry system
- Disabled crash reporting by default
- Removed Pocket integration
- Disabled Firefox Accounts and sync services
- Enhanced tracking protection enabled by default
- Built-in ad blocking preparation (uBlock Origin integration planned)

### Memory Management
- Custom MemoryManager.jsm module for intelligent RAM limiting
- Configurable memory thresholds (warning: 75%, critical: 90%)
- Automatic tab suspension for inactive tabs during high memory usage
- Aggressive garbage collection during memory pressure
- Cache clearing mechanisms for memory optimization
- Memory usage monitoring and statistics
- Process count management for better resource control

### UI/UX Improvements
- Clean, minimalist UI theme (henfire-clean.css)
- Simplified toolbar with essential buttons only
- Streamlined address bar design
- Clean tab interface with suspension indicators
- Removed unnecessary UI elements and clutter
- Dark mode support with clean aesthetics
- Memory usage indicator in the interface
- Visual feedback for suspended tabs

### Build System
- Custom mozconfig template for optimized builds
- HenFire-specific branding and icons
- Automated patch application system
- Custom build scripts for macOS
- Distribution packaging system

### Developer Experience
- Comprehensive build documentation
- Troubleshooting guides for common issues
- Development environment setup instructions
- Custom mach commands for HenFire development

## [0.1.0-alpha] - 2025-01-XX (Planned)

### Initial Release Features

#### Core Browser
- Firefox-based engine with HenFire customizations
- Full web compatibility maintained
- Enhanced performance optimizations

#### Memory Management
- RAM limiting with user-configurable thresholds
- Intelligent tab suspension system
- Memory usage monitoring dashboard
- Automatic memory cleanup processes

#### Privacy Features
- Zero telemetry data collection
- Enhanced tracking protection
- Built-in ad blocking (uBlock Origin)
- Secure defaults for all privacy settings

#### Clean UI
- Minimalist interface design
- Distraction-free browsing experience
- Customizable toolbar
- Clean context menus

#### Platform Support
- macOS support (primary)
- Linux support (planned)
- Windows support (planned)

### Known Issues
- Build process requires significant disk space (~10GB)
- Initial build time can be lengthy (1-3 hours)
- Some Firefox extensions may need compatibility testing

## Development Roadmap

### Version 0.2.0 (Planned)
- [ ] Advanced memory management algorithms
- [ ] User-configurable UI themes
- [ ] Enhanced privacy dashboard
- [ ] Performance monitoring tools
- [ ] Extension compatibility improvements

### Version 0.3.0 (Planned)
- [ ] Cross-platform support (Linux, Windows)
- [ ] Advanced tab management features
- [ ] Custom search engine integration
- [ ] Enhanced security features

### Version 1.0.0 (Planned)
- [ ] Stable release with all core features
- [ ] Comprehensive testing and bug fixes
- [ ] Full documentation and user guides
- [ ] Community feedback integration

## Technical Changes

### Build System Modifications
- Custom `mozconfig` with HenFire-specific optimizations
- Disabled unnecessary Firefox features (Pocket, Sync, etc.)
- Enhanced privacy and security compile-time options
- Custom branding and application naming

### Code Modifications
- MemoryManager.jsm: Core memory management system
- henfire-clean.css: UI styling and cleanup
- Custom preferences in henfire.js
- Branding files and localization strings

### Removed Features
- Mozilla telemetry and data reporting
- Pocket integration
- Firefox Accounts and Sync
- Crash reporting (disabled by default)
- Various tracking and analytics components

### Enhanced Features
- Memory management beyond Firefox defaults
- Cleaner UI with reduced visual clutter
- Privacy-focused default settings
- Performance optimizations for lower-end hardware

## Installation & Compatibility

### System Requirements
- **macOS**: 10.15 (Catalina) or later
- **RAM**: 4GB minimum, 8GB recommended
- **Storage**: 15GB free space for build
- **Xcode**: Command Line Tools required

### Compatibility Notes
- Most Firefox extensions should work without modification
- Some privacy-invasive extensions may be blocked
- WebExtensions API fully supported
- Legacy add-ons not supported (following Firefox standards)

## Contributing

We welcome contributions! Please see our contributing guidelines for:
- Code style and standards
- Testing requirements
- Documentation updates
- Bug reporting procedures

## Security

Security updates follow Firefox's release schedule:
- Critical security fixes: Immediate release
- Regular security updates: Monthly
- Extended support releases: As needed

## Acknowledgments

### Based On
- **Mozilla Firefox**: Core browser engine and functionality
- **Gecko**: Rendering engine
- **SpiderMonkey**: JavaScript engine

### Inspiration
- Privacy-focused browser projects
- Minimalist UI design principles
- Community feedback and requests

### Tools & Libraries
- Mozilla build system (mach)
- Various open-source privacy and performance tools
- Community-contributed patches and improvements

---

## Legend

- 🆕 **Added**: New features
- 🔧 **Changed**: Changes in existing functionality
- 🗑️ **Deprecated**: Soon-to-be removed features
- ❌ **Removed**: Removed features
- 🐛 **Fixed**: Bug fixes
- 🔒 **Security**: Security improvements
- 🎨 **UI/UX**: User interface and experience improvements
- ⚡ **Performance**: Performance improvements
- 🧠 **Memory**: Memory management improvements

---

*For detailed technical changes and commit history, see the [Git repository](https://github.com/henryperzinski/henfire).*