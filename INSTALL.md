# HenFire Browser Installation Guide

This guide will help you build and install HenFire, a Firefox fork with clean UI and intelligent RAM management.

## System Requirements

### macOS
- macOS 10.15 (Catalina) or later
- Xcode Command Line Tools
- Python 3.11 or later
- At least 8GB RAM (16GB recommended)
- 40GB+ free disk space
- Fast internet connection (for downloading Firefox source)

## Quick Start

### 1. Clone the Repository

```bash
git clone https://github.com/henryperzinski/henfire.git
cd henfire
```

### 2. Bootstrap the Environment

```bash
./scripts/bootstrap.sh
```

This script will:
- Check system prerequisites
- Download Firefox source code (~2GB)
- Install build dependencies
- Apply HenFire customizations
- Configure the build environment

**Note:** This process can take 30-60 minutes depending on your internet connection.

### 3. Build HenFire

```bash
./mach build
```

Building takes 20-45 minutes on most systems.

### 4. Run HenFire

```bash
./mach run
```

## Detailed Installation Steps

### Prerequisites Installation

#### Install Xcode Command Line Tools
```bash
xcode-select --install
```

#### Install Python 3.11+ (if not already installed)
Using Homebrew:
```bash
brew install python@3.11
```

Or download from [python.org](https://www.python.org/downloads/)

#### Verify Prerequisites
```bash
# Check Python version
python3 --version  # Should be 3.11+

# Check Git
git --version

# Check Xcode tools
xcode-select -p
```

### Build Configuration

HenFire uses a custom `mozconfig` file with optimizations:

```bash
# View current configuration
cat config/mozconfig.template
```

Key optimizations:
- Link-time optimization (LTO)
- Rust SIMD optimizations
- Disabled telemetry and crash reporting
- Custom branding
- Memory management features

### Build Options

#### Debug Build
For development with debugging symbols:
```bash
echo 'ac_add_options --enable-debug' >> src/firefox/mozconfig
./mach build
```

#### Release Build (Default)
Optimized for performance:
```bash
./mach build
```

#### Clean Build
Start fresh:
```bash
./mach henfire-clean
./mach henfire-setup
./mach build
```

## HenFire-Specific Commands

### Setup and Configuration
```bash
# Apply HenFire customizations
./mach henfire-setup

# Check build status
./mach henfire-status

# Clean customizations (reset to Firefox)
./mach henfire-clean

# Show HenFire help
./mach henfire-help
```

### Building and Running
```bash
# Build HenFire
./mach build

# Run HenFire
./mach run

# Run with specific profile
./mach run --profile /path/to/profile

# Run in safe mode
./mach run --safe-mode
```

### Packaging
```bash
# Create distribution package
./mach henfire-package

# Package will be in dist/ directory
ls dist/
```

## Configuration

### Memory Management Settings

After building, configure RAM limits in `about:config`:

1. Open HenFire
2. Navigate to `about:config`
3. Search for `henfire.memory`
4. Adjust these preferences:

```
henfire.memory.max_usage_mb = 2048          # Maximum RAM usage in MB
henfire.memory.tab_suspend_threshold = 1536  # Threshold for tab suspension
henfire.memory.auto_gc_enabled = true        # Enable automatic garbage collection
```

### UI Customization

Clean UI settings:
```
henfire.ui.clean_mode = true           # Enable clean interface
henfire.ui.minimal_toolbar = true      # Minimize toolbar
henfire.ui.hide_pocket = true          # Hide Pocket integration
```

## Troubleshooting

### Common Build Issues

#### "Command not found: python3"
```bash
# Install Python 3.11+
brew install python@3.11
# Or create symlink if Python 3 is installed as 'python'
ln -s /usr/bin/python3 /usr/local/bin/python3
```

#### "Xcode Command Line Tools not found"
```bash
xcode-select --install
# Follow the installation prompts
```

#### "No space left on device"
- Free up at least 40GB of disk space
- Consider using an external drive for the build

#### Build fails with "missing dependencies"
```bash
# Re-run bootstrap
./scripts/bootstrap.sh

# Or manually install missing dependencies
cd src/firefox
python3 bootstrap.py
```

### Memory Issues During Build

If build fails due to insufficient memory:

```bash
# Reduce parallel jobs
export MOZ_MAKE_FLAGS="-j2"  # Use only 2 cores
./mach build
```

### Runtime Issues

#### HenFire won't start
```bash
# Check for conflicting Firefox installations
./mach run --safe-mode

# Reset profile
rm -rf ~/Library/Application\ Support/HenFire/
./mach run
```

#### High memory usage despite limits
1. Check `about:config` settings
2. Restart HenFire
3. Check `about:memory` for detailed usage

## Development

### Making Changes

1. **UI Changes**: Edit files in `modules/ui-cleaner/`
2. **Memory Management**: Edit `modules/memory-manager/`
3. **Branding**: Edit files in `browser/branding/henfire/`

### Testing Changes
```bash
# Apply changes
./mach henfire-setup

# Rebuild
./mach build

# Test
./mach run
```

### Creating Patches
```bash
cd src/firefox

# Make changes to Firefox source
# ...

# Create patch
git diff > ../../patches/my-feature.patch
```

## Performance Tips

### Build Performance
- Use SSD storage
- Increase RAM if possible
- Use `ccache` for faster rebuilds:
  ```bash
  brew install ccache
  echo 'export CC="ccache clang"' >> ~/.bashrc
  echo 'export CXX="ccache clang++"' >> ~/.bashrc
  ```

### Runtime Performance
- Enable hardware acceleration in preferences
- Adjust memory limits based on your system
- Use fewer browser processes for lower memory usage

## Updating

### Update Firefox Base
```bash
cd src/firefox
git pull origin central
cd ../..
./mach henfire-setup
./mach build
```

### Update HenFire
```bash
git pull origin main
./mach henfire-setup
./mach build
```

## Uninstalling

### Remove Build Files
```bash
# Remove build artifacts
rm -rf src/firefox/obj-*

# Remove entire project
cd ..
rm -rf henfire
```

### Remove User Data
```bash
# Remove HenFire profile data
rm -rf ~/Library/Application\ Support/HenFire/
rm -rf ~/Library/Caches/HenFire/
```

## Getting Help

- **Issues**: [GitHub Issues](https://github.com/henryperzinski/henfire/issues)
- **Discussions**: [GitHub Discussions](https://github.com/henryperzinski/henfire/discussions)
- **Firefox Build Docs**: [Mozilla Build Documentation](https://firefox-source-docs.mozilla.org/)

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for development guidelines.