#!/bin/bash

# HenSurf Multi-Platform Build Script
# Builds HenSurf browser for all supported platforms

set -e

echo "🏄 HenSurf Multi-Platform Builder"
echo "================================="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
PROJECT_ROOT="$(pwd)"
FFOX_SRC="$PROJECT_ROOT/src/firefox"
BRANDING_DIR="$PROJECT_ROOT/browser/branding/hensurf"
BUILD_DIR="$PROJECT_ROOT/builds"
DATE=$(date +"%Y%m%d")
VERSION="1.0.0-$DATE"

# Platform detection
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    HOST_OS="linux"
elif [[ "$OSTYPE" == "darwin"* ]]; then
    HOST_OS="macos"
elif [[ "$OSTYPE" == "msys" ]] || [[ "$OSTYPE" == "cygwin" ]]; then
    HOST_OS="windows"
else
    HOST_OS="unknown"
fi

echo -e "${BLUE}Host OS detected: $HOST_OS${NC}"
echo -e "${BLUE}Build version: $VERSION${NC}"
echo ""

# Function to print status
print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to check prerequisites
check_prerequisites() {
    print_status "Checking prerequisites..."
    
    if [ ! -d "$FFOX_SRC" ]; then
        print_error "Firefox source not found at $FFOX_SRC"
        print_error "Please run: git submodule update --init --recursive"
        exit 1
    fi
    
    if [ ! -f "$PROJECT_ROOT/HenSurfLogo.png" ]; then
        print_warning "HenSurfLogo.png not found, using default branding"
    fi
    
    if [ ! -f "$PROJECT_ROOT/HenSurfEmblem.svg" ]; then
        print_warning "HenSurfEmblem.svg not found, using default branding"
    fi
    
    # Check for required tools
    local missing_tools=()
    
    if ! command -v python3 &> /dev/null; then
        missing_tools+=("python3")
    fi
    
    if [[ "$HOST_OS" == "macos" ]] && ! command -v iconutil &> /dev/null; then
        missing_tools+=("iconutil (Xcode Command Line Tools)")
    fi
    
    if [ ${#missing_tools[@]} -ne 0 ]; then
        print_error "Missing required tools: ${missing_tools[*]}"
        exit 1
    fi
    
    print_status "Prerequisites check passed!"
}

# Function to setup build environment
setup_build_env() {
    print_status "Setting up build environment..."
    
    # Create build directory
    mkdir -p "$BUILD_DIR"
    
    # Setup branding
    if [ -f "$PROJECT_ROOT/convert-icons.py" ]; then
        print_status "Converting icons..."
        cd "$PROJECT_ROOT"
        python3 convert-icons.py
    fi
    
    # Apply HenSurf patches
    if [ -f "$PROJECT_ROOT/apply-hensurf-patches.sh" ]; then
        print_status "Applying HenSurf customizations..."
        bash "$PROJECT_ROOT/apply-hensurf-patches.sh"
    fi
}

# Function to build for a specific platform
build_platform() {
    local platform=$1
    local target_os=$2
    local target_arch=$3
    
    print_status "Building HenSurf for $platform ($target_arch)..."
    
    cd "$FFOX_SRC"
    
    # Create platform-specific mozconfig
    local mozconfig_file="mozconfig-$platform"
    cat > "$mozconfig_file" << EOF
# HenSurf Build Configuration for $platform

# Basic configuration
ac_add_options --enable-application=browser
ac_add_options --enable-optimize
ac_add_options --disable-debug
ac_add_options --disable-tests
ac_add_options --disable-crashreporter
ac_add_options --disable-updater
ac_add_options --disable-maintenance-service

# Privacy and security
ac_add_options --disable-webrtc
ac_add_options --disable-eme
ac_add_options --disable-drm
ac_add_options --enable-privacy

# Branding
ac_add_options --with-branding=browser/branding/hensurf
ac_add_options --with-app-name=hensurf
ac_add_options --with-app-basename=HenSurf

# Distribution
ac_add_options --with-distribution-id=org.hensurf

EOF

    # Platform-specific options
    case $target_os in
        "linux")
            cat >> "$mozconfig_file" << EOF
# Linux-specific options
ac_add_options --target=x86_64-pc-linux-gnu
ac_add_options --enable-default-toolkit=cairo-gtk3
ac_add_options --enable-official-branding
EOF
            ;;
        "macos")
            cat >> "$mozconfig_file" << EOF
# macOS-specific options
ac_add_options --target=x86_64-apple-darwin
ac_add_options --enable-official-branding
ac_add_options --with-macos-sdk=/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk
EOF
            ;;
        "windows")
            cat >> "$mozconfig_file" << EOF
# Windows-specific options
ac_add_options --target=x86_64-pc-mingw32
ac_add_options --enable-official-branding
EOF
            ;;
    esac
    
    # Set MOZCONFIG environment variable
    export MOZCONFIG="$PWD/$mozconfig_file"
    
    # Bootstrap if needed
    if [ ! -f ".mach_bootstrap_complete" ]; then
        print_status "Bootstrapping build environment..."
        ./mach bootstrap --no-interactive
        touch .mach_bootstrap_complete
    fi
    
    # Build
    print_status "Starting build process..."
    ./mach build
    
    # Package
    print_status "Creating package..."
    ./mach package
    
    # Copy build artifacts
    local build_output_dir="$BUILD_DIR/$platform"
    mkdir -p "$build_output_dir"
    
    case $target_os in
        "linux")
            cp obj-*/dist/hensurf-*.tar.bz2 "$build_output_dir/" 2>/dev/null || true
            cp obj-*/dist/hensurf-*.tar.gz "$build_output_dir/" 2>/dev/null || true
            ;;
        "macos")
            cp obj-*/dist/HenSurf.dmg "$build_output_dir/" 2>/dev/null || true
            cp -r obj-*/dist/HenSurf.app "$build_output_dir/" 2>/dev/null || true
            ;;
        "windows")
            cp obj-*/dist/install/sea/hensurf-*.exe "$build_output_dir/" 2>/dev/null || true
            cp obj-*/dist/hensurf-*.zip "$build_output_dir/" 2>/dev/null || true
            ;;
    esac
    
    print_status "Build completed for $platform!"
}

# Function to show usage
show_usage() {
    echo "Usage: $0 [OPTIONS] [PLATFORMS]"
    echo ""
    echo "Options:"
    echo "  -h, --help     Show this help message"
    echo "  -v, --version  Show version information"
    echo "  --clean        Clean build directories before building"
    echo ""
    echo "Platforms:"
    echo "  linux          Build for Linux (x86_64)"
    echo "  macos          Build for macOS (x86_64)"
    echo "  windows        Build for Windows (x86_64)"
    echo "  all            Build for all platforms (default)"
    echo ""
    echo "Examples:"
    echo "  $0                    # Build for all platforms"
    echo "  $0 linux macos       # Build for Linux and macOS only"
    echo "  $0 --clean all       # Clean and build for all platforms"
}

# Parse command line arguments
CLEAN_BUILD=false
PLATFORMS=()

while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            show_usage
            exit 0
            ;;
        -v|--version)
            echo "HenSurf Multi-Platform Builder v$VERSION"
            exit 0
            ;;
        --clean)
            CLEAN_BUILD=true
            shift
            ;;
        linux|macos|windows|all)
            PLATFORMS+=("$1")
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

# Expand 'all' to specific platforms
if [[ " ${PLATFORMS[*]} " =~ " all " ]]; then
    PLATFORMS=("linux" "macos" "windows")
fi

# Clean build directories if requested
if [ "$CLEAN_BUILD" = true ]; then
    print_status "Cleaning build directories..."
    rm -rf "$BUILD_DIR"
    rm -rf "$FFOX_SRC/obj-*"
fi

# Main build process
print_status "Starting HenSurf multi-platform build..."
print_status "Platforms to build: ${PLATFORMS[*]}"
echo ""

# Check prerequisites
check_prerequisites

# Setup build environment
setup_build_env

# Build for each platform
for platform in "${PLATFORMS[@]}"; do
    case $platform in
        "linux")
            if [[ "$HOST_OS" == "linux" ]] || command -v docker &> /dev/null; then
                build_platform "linux" "linux" "x86_64"
            else
                print_warning "Skipping Linux build (not on Linux and Docker not available)"
            fi
            ;;
        "macos")
            if [[ "$HOST_OS" == "macos" ]]; then
                build_platform "macos" "macos" "x86_64"
            else
                print_warning "Skipping macOS build (not on macOS)"
            fi
            ;;
        "windows")
            if [[ "$HOST_OS" == "windows" ]] || command -v wine &> /dev/null; then
                build_platform "windows" "windows" "x86_64"
            else
                print_warning "Skipping Windows build (not on Windows and Wine not available)"
            fi
            ;;
    esac
done

# Summary
echo ""
print_status "Build process completed!"
print_status "Build artifacts are available in: $BUILD_DIR"
echo ""
echo -e "${GREEN}🏄 HenSurf builds ready! Surf the web with privacy!${NC}"