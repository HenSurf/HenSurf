#!/bin/bash

# HenSurf Multi-Platform Build Script
# Enhanced version for building HenSurf on all platforms with organized output

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Configuration
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
FFOX_SRC="$PROJECT_ROOT/src/firefox"
BUILD_DIR="$PROJECT_ROOT/builds"
LOG_DIR="$PROJECT_ROOT/logs"
DATE=$(date +"%Y%m%d_%H%M%S")
VERSION="1.0.0-$(date +"%Y%m%d")"

# Build configuration
BUILD_TYPE="release"  # Can be: release, debug, nightly
PARALLEL_JOBS=$(nproc 2>/dev/null || sysctl -n hw.ncpu 2>/dev/null || echo "4")
CLEAN_BUILD=false
VERBOSE=false
DRY_RUN=false

# Function to print colored output
print_header() {
    echo -e "\n${PURPLE}=================================${NC}"
    echo -e "${PURPLE}🏄 $1${NC}"
    echo -e "${PURPLE}=================================${NC}\n"
}

print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_debug() {
    if [ "$VERBOSE" = true ]; then
        echo -e "${CYAN}[DEBUG]${NC} $1"
    fi
}

# Function to show usage
show_usage() {
    cat << EOF
HenSurf Multi-Platform Build Script

Usage: $0 [OPTIONS]

Options:
  -h, --help              Show this help message
  -v, --verbose           Enable verbose output
  -n, --dry-run           Show what would be done without executing
  -c, --clean             Clean build directories before building
  -j, --jobs NUM          Number of parallel build jobs (default: $PARALLEL_JOBS)
  
  Build Type:
  -r, --release           Build release version (default)
  -d, --debug             Build debug version
  --nightly               Build nightly version
  
  Platform Options:
  --linux                 Build for Linux only
  --macos                 Build for macOS only
  --windows               Build for Windows only
  --all                   Build for all platforms (default)

Examples:
  $0                      # Build for all platforms (release)
  $0 --linux -v          # Build for Linux with verbose output
  $0 --debug --all        # Build debug version for all platforms
  $0 -c -j 8              # Clean build with 8 parallel jobs
  $0 -n                   # Dry run to see what would happen

EOF
}

# Function to setup build environment
setup_environment() {
    print_status "Setting up build environment..."
    
    # Create necessary directories with organized structure
    mkdir -p "$BUILD_DIR" "$LOG_DIR"
    
    # Create platform-specific directories
    for platform in linux macos windows; do
        for build_type in release debug nightly; do
            mkdir -p "$BUILD_DIR/$platform/$build_type/latest"
        done
    done
    
    print_status "Created organized build directory structure:"
    print_status "  $BUILD_DIR/"
    print_status "  ├── linux/"
    print_status "  │   ├── release/"
    print_status "  │   ├── debug/"
    print_status "  │   └── nightly/"
    print_status "  ├── macos/"
    print_status "  │   ├── release/"
    print_status "  │   ├── debug/"
    print_status "  │   └── nightly/"
    print_status "  └── windows/"
    print_status "      ├── release/"
    print_status "      ├── debug/"
    print_status "      └── nightly/"
}

# Function to create build info template
create_build_info() {
    local platform="$1"
    local build_type="$2"
    local output_dir="$3"
    
    cat > "$output_dir/build-info.txt" << EOF
HenSurf Build Information
========================

Platform: $platform
Build Type: $build_type
Version: $VERSION
Build Date: $(date)
Build Host: $(uname -a)
Git Commit: $(git rev-parse HEAD 2>/dev/null || echo 'N/A')

Build Configuration:
- Parallel Jobs: $PARALLEL_JOBS
- Clean Build: $CLEAN_BUILD
- Project Root: $PROJECT_ROOT
- Firefox Source: $FFOX_SRC

Directory Structure:
- Build Output: $output_dir
- Logs: $LOG_DIR

Build Features:
- Custom HenSurf Branding
- DuckDuckGo Default Search
- Privacy Enhancements
- Sponsored Content Removed
- Custom Ocean Theme
- Enhanced Security Settings

Installation Notes:
$(case "$platform" in
    "linux")
        echo "- Extract .tar.bz2 or .tar.gz file"
        echo "- Run: ./hensurf or ./hensurf-bin"
        echo "- Optional: Create desktop shortcut"
        ;;
    "macos")
        echo "- Mount .dmg file"
        echo "- Drag HenSurf.app to Applications folder"
        echo "- First run: Right-click > Open (bypass Gatekeeper)"
        ;;
    "windows")
        echo "- Run .exe installer"
        echo "- Follow installation wizard"
        echo "- Launch from Start Menu or Desktop"
        ;;
esac)

EOF
}

# Function to create README for builds directory
create_builds_readme() {
    cat > "$BUILD_DIR/README.md" << 'EOF'
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

EOF
}

# Function to run autobuild for specific platforms
run_autobuild() {
    local platforms=("$@")
    
    if [ ${#platforms[@]} -eq 0 ]; then
        platforms=("all")
    fi
    
    for platform in "${platforms[@]}"; do
        print_header "Building HenSurf for $platform"
        
        local autobuild_args=()
        
        # Add build type
        case "$BUILD_TYPE" in
            "release") autobuild_args+=("--release") ;;
            "debug") autobuild_args+=("--debug") ;;
            "nightly") autobuild_args+=("--nightly") ;;
        esac
        
        # Add platform
        autobuild_args+=("--platform" "$platform")
        
        # Add other options
        if [ "$CLEAN_BUILD" = true ]; then
            autobuild_args+=("--clean")
        fi
        
        if [ "$VERBOSE" = true ]; then
            autobuild_args+=("--verbose")
        fi
        
        if [ "$DRY_RUN" = true ]; then
            autobuild_args+=("--dry-run")
        fi
        
        autobuild_args+=("--jobs" "$PARALLEL_JOBS")
        
        print_status "Running: ./autobuild.sh ${autobuild_args[*]}"
        
        if [ "$DRY_RUN" = false ]; then
            ./autobuild.sh "${autobuild_args[@]}"
        else
            print_debug "Would run: ./autobuild.sh ${autobuild_args[*]}"
        fi
    done
}

# Parse command line arguments
PLATFORMS=()

while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            show_usage
            exit 0
            ;;
        -v|--verbose)
            VERBOSE=true
            shift
            ;;
        -n|--dry-run)
            DRY_RUN=true
            shift
            ;;
        -c|--clean)
            CLEAN_BUILD=true
            shift
            ;;
        -j|--jobs)
            PARALLEL_JOBS="$2"
            shift 2
            ;;
        -r|--release)
            BUILD_TYPE="release"
            shift
            ;;
        -d|--debug)
            BUILD_TYPE="debug"
            shift
            ;;
        --nightly)
            BUILD_TYPE="nightly"
            shift
            ;;
        --linux)
            PLATFORMS+=("linux")
            shift
            ;;
        --macos)
            PLATFORMS+=("macos")
            shift
            ;;
        --windows)
            PLATFORMS+=("windows")
            shift
            ;;
        --all)
            PLATFORMS=("all")
            shift
            ;;
        *)
            print_error "Unknown option: $1"
            show_usage
            exit 1
            ;;
    esac
done

# Default to all platforms if none specified
if [ ${#PLATFORMS[@]} -eq 0 ]; then
    PLATFORMS=("all")
fi

# Main execution
main() {
    print_header "HenSurf Multi-Platform Builder v$VERSION"
    
    print_status "Build configuration:"
    print_status "  Build Type: $BUILD_TYPE"
    print_status "  Target Platforms: ${PLATFORMS[*]}"
    print_status "  Parallel Jobs: $PARALLEL_JOBS"
    print_status "  Clean Build: $CLEAN_BUILD"
    print_status "  Verbose: $VERBOSE"
    print_status "  Dry Run: $DRY_RUN"
    
    if [ "$DRY_RUN" = true ]; then
        print_warning "DRY RUN MODE - No actual changes will be made"
    fi
    
    # Setup environment
    setup_environment
    create_builds_readme
    
    # Run builds
    run_autobuild "${PLATFORMS[@]}"
    
    print_header "Multi-Platform Build Complete!"
    print_status "HenSurf builds completed successfully!"
    print_status "Build artifacts organized in: $BUILD_DIR"
    print_status "Check individual platform directories for binaries"
    print_status "Latest builds available in respective 'latest' directories"
    
    if [ "$DRY_RUN" = false ]; then
        echo -e "\n${GREEN}🏄 Ready to surf the web with privacy on all platforms!${NC}\n"
    else
        echo -e "\n${YELLOW}🏄 Dry run completed - no actual builds were performed${NC}\n"
    fi
}

# Run main function
main "$@"