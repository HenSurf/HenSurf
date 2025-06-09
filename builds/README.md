# HenSurf Builds Directory

This directory contains organized builds of HenSurf browser for different platforms and build types.

## Directory Structure

```
builds/
├── linux/
│   ├── release/
│   │   ├── latest/          # Latest release build
│   │   └── [version]/       # Versioned builds
│   ├── debug/
│   └── nightly/
├── macos/
│   ├── release/
│   │   ├── latest/          # Latest release build
│   │   └── [version]/       # Versioned builds
│   ├── debug/
│   └── nightly/
└── windows/
    ├── release/
    │   ├── latest/          # Latest release build
    │   └── [version]/       # Versioned builds
    ├── debug/
    └── nightly/
```

## Build Types

- **Release**: Optimized builds for production use
- **Debug**: Development builds with debugging symbols
- **Nightly**: Experimental builds with latest features

## Platform-Specific Files

### Linux
- `*.tar.bz2` - Compressed archive
- `*.tar.gz` - Alternative compressed format
- Extract and run `hensurf` or `hensurf-bin`

### macOS
- `HenSurf.app` - Application bundle
- `*.dmg` - Disk image for distribution
- Drag to Applications folder to install

### Windows
- `*.exe` - Installer executable
- `*.zip` - Portable version
- Run installer or extract portable version

## Build Information

Each build directory contains:
- `build-info.txt` - Detailed build information
- Platform-specific binaries
- Installation instructions

## Usage

1. Navigate to desired platform and build type
2. Use `latest/` for most recent build
3. Use versioned directories for specific releases
4. Check `build-info.txt` for build details

## HenSurf Features

- 🔒 Enhanced Privacy Protection
- 🦆 DuckDuckGo Default Search
- 🚫 No Sponsored Content
- 🌊 Custom Ocean Theme
- ⚡ Optimized Performance
- 🛡️ Advanced Security Settings

