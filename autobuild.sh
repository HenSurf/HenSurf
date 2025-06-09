#!/bin/bash

# HenSurf Autobuild Script
# Automated build system for HenSurf browser
# This script handles the complete build process from setup to packaging

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
BUILD_LOG="$LOG_DIR/autobuild_$DATE.log"
VERSION="1.0.0-$(date +"%Y%m%d")"

# Default configuration
BUILD_TYPE="release"  # release, debug, or nightly
TARGET_PLATFORM="auto"  # auto, linux, macos, windows, or all
CLEAN_BUILD=false
SKIP_BOOTSTRAP=false
SKIP_PATCHES=false
PARALLEL_JOBS=$(nproc 2>/dev/null || sysctl -n hw.ncpu 2>/dev/null || echo "4")
VERBOSE=false
DRY_RUN=false

# Function to print colored output
print_header() {
    echo -e "\n${PURPLE}=================================${NC}"
    echo -e "${PURPLE}🏄 $1${NC}"
    echo -e "${PURPLE}=================================${NC}\n"
}

print_status() {
    echo -e "${GREEN}[INFO]${NC} $1" | tee -a "$BUILD_LOG"
}

print_warning() {
    echo -e "${YELLOW}[WARN]${NC} $1" | tee -a "$BUILD_LOG"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1" | tee -a "$BUILD_LOG"
}

print_debug() {
    if [ "$VERBOSE" = true ]; then
        echo -e "${CYAN}[DEBUG]${NC} $1" | tee -a "$BUILD_LOG"
    fi
}

# Function to show usage
show_usage() {
    cat << EOF
HenSurf Autobuild Script

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
  
  Platform:
  -p, --platform PLAT     Target platform: auto, linux, macos, windows, all (default: auto)
  
  Skip Options:
  --skip-bootstrap        Skip Mozilla bootstrap process
  --skip-patches          Skip applying HenSurf patches
  
  Advanced:
  --build-dir DIR         Custom build directory
  --log-dir DIR           Custom log directory
  --version VER           Custom version string

Examples:
  $0                      # Quick release build for current platform
  $0 -c -v               # Clean verbose build
  $0 -d -p all           # Debug build for all platforms
  $0 --nightly -j 8      # Nightly build with 8 parallel jobs
  $0 -n                   # Dry run to see what would happen

EOF
}

# Function to detect platform
detect_platform() {
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        echo "linux"
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        echo "macos"
    elif [[ "$OSTYPE" == "msys" ]] || [[ "$OSTYPE" == "cygwin" ]]; then
        echo "windows"
    else
        echo "unknown"
    fi
}

# Checks for required tools, disk space, and RAM before starting the build process.
#
# Globals:
#
# * PROJECT_ROOT: Used to determine available disk space.
#
# Outputs:
#
# * Prints status, warning, or error messages to STDOUT and STDERR.
#
# Returns:
#
# * 0 if all prerequisites are met.
# * 1 if any required tools are missing.
#
# Example:
#
#   check_prerequisites
#   if [ $? -ne 0 ]; then
#       echo "Prerequisite check failed."
#       exit 1
#   fi
# 
# This function verifies that all necessary tools for the current platform are installed, checks for at least 10GB of free disk space, and warns if system RAM is below 8GB.
check_prerequisites() {
    print_status "Checking prerequisites..."
    
    local missing_tools=()
    local required_tools=("git" "python3" "curl")
    
    # Platform-specific tools
    case "$(detect_platform)" in
        "macos")
            required_tools+=("xcode-select")
            ;;
        "linux")
            required_tools+=("gcc" "make")
            ;;
        "windows")
            required_tools+=("x86_64-w64-mingw32-gcc")
            ;;
    esac
    
    for tool in "${required_tools[@]}"; do
        if ! command -v "$tool" &> /dev/null; then
            missing_tools+=("$tool")
        fi
    done
    
    if [ ${#missing_tools[@]} -ne 0 ]; then
        print_error "Missing required tools: ${missing_tools[*]}"
        print_error "Please install the missing tools and try again."
        return 1
    fi
    
    # Check disk space (need at least 10GB)
    local available_space
    if command -v df &> /dev/null; then
        available_space=$(df "$PROJECT_ROOT" | awk 'NR==2 {print $4}')
        if [ "$available_space" -lt 10485760 ]; then  # 10GB in KB
            print_warning "Low disk space detected. Firefox builds require at least 10GB free space."
        fi
    fi
    
    # Check RAM (recommend at least 8GB)
    local total_ram
    if command -v free &> /dev/null; then
        total_ram=$(free -m | awk 'NR==2{print $2}')
    elif command -v sysctl &> /dev/null; then
        total_ram=$(($(sysctl -n hw.memsize) / 1024 / 1024))
    fi
    
    if [ -n "$total_ram" ] && [ "$total_ram" -lt 8192 ]; then
        print_warning "Low RAM detected ($total_ram MB). Firefox builds work best with 8GB+ RAM."
    fi
    
    print_debug "Checking for Python Pillow library..."
    if ! python3 -c "from PIL import Image" &> /dev/null; then
        print_error "Python Pillow library (PIL) is not installed. This is required for icon conversion."
        print_error "Please install it using a command like: pip install Pillow"
        missing_tools+=("Python Pillow (PIL)")
    else
        print_debug "Python Pillow library found."
    fi

    if [ ${#missing_tools[@]} -ne 0 ]; then
        print_error "Missing required tools: ${missing_tools[*]}"
        print_error "Please install the missing tools and try again."
        return 1
    fi

    print_status "Prerequisites check passed!"
}

# Function to setup build environment
setup_environment() {
    print_status "Setting up build environment..."
    
    # Create necessary directories
    mkdir -p "$BUILD_DIR" "$LOG_DIR"
    
    # Initialize git submodules if needed
    if [ ! -d "$FFOX_SRC/.git" ]; then
        print_status "Initializing Firefox source..."
        if [ "$DRY_RUN" = false ]; then
            git submodule update --init --recursive
        else
            print_debug "Would run: git submodule update --init --recursive"
        fi
    fi
    
    # Set up environment variables
    export MOZ_OBJDIR="$FFOX_SRC/obj-hensurf"
    export MOZCONFIG="$FFOX_SRC/mozconfig-hensurf"
    
    print_debug "MOZ_OBJDIR: $MOZ_OBJDIR"
    print_debug "MOZCONFIG: $MOZCONFIG"
}

# Function to apply HenSurf customizations
apply_customizations() {
    if [ "$SKIP_PATCHES" = true ]; then
        print_status "Skipping HenSurf patches (--skip-patches specified)"
        return 0
    fi
    
    print_status "Applying HenSurf customizations..."
    
    # Convert icons if needed
    if [ -f "$PROJECT_ROOT/convert-icons.py" ] && [ -f "$PROJECT_ROOT/HenSurfLogo.png" ]; then
        print_status "Converting logo to various formats..."
        if [ "$DRY_RUN" = false ]; then
            cd "$PROJECT_ROOT"
            python3 convert-icons.py
        else
            print_debug "Would run: python3 convert-icons.py"
        fi
    fi
    
    # Apply main patches
    if [ -f "$PROJECT_ROOT/apply-hensurf-patches.sh" ]; then
        print_status "Applying HenSurf patches..."
        if [ "$DRY_RUN" = false ]; then
            bash "$PROJECT_ROOT/apply-hensurf-patches.sh"
        else
            print_debug "Would run: bash apply-hensurf-patches.sh"
        fi
    else
        print_warning "HenSurf patches script not found, skipping customizations"
    fi
}

# Generates a platform-specific mozconfig file with build options tailored to the selected build type and platform.
#
# Arguments:
#
# * Platform name (e.g., linux, macos, windows)
#
# Outputs:
#
# * Writes the generated mozconfig file to the path specified by the MOZCONFIG environment variable, unless in dry-run mode.
#
# Example:
#
# ```bash
# create_mozconfig_for_platform linux
# ```
create_mozconfig_for_platform() {
    local platform="$1"
    print_status "Creating build configuration for $platform..."
    
    local mozconfig_content
    mozconfig_content="# HenSurf Build Configuration - Generated $(date)
# Build type: $BUILD_TYPE
# Target platform: $platform

# Basic configuration
ac_add_options --enable-application=browser
ac_add_options --with-branding=browser/branding/hensurf
ac_add_options --with-app-name=hensurf
ac_add_options --with-app-basename=HenSurf
ac_add_options --with-distribution-id=org.hensurf

# Build type specific options"

    case "$BUILD_TYPE" in
        "release")
            mozconfig_content+="
ac_add_options --enable-optimize
ac_add_options --disable-debug
ac_add_options --disable-tests
ac_add_options --enable-strip
ac_add_options --enable-install-strip"
            ;;
        "debug")
            mozconfig_content+="
ac_add_options --enable-debug
ac_add_options --disable-optimize
ac_add_options --enable-tests"
            ;;
        "nightly")
            mozconfig_content+="
ac_add_options --enable-optimize
ac_add_options --disable-debug
ac_add_options --enable-nightly-build
ac_add_options --disable-tests"
            ;;
    esac
    
    # Platform-specific options
    case "$platform" in
        "linux")
            mozconfig_content+="

# Linux-specific options
ac_add_options --enable-default-toolkit=cairo-gtk3
ac_add_options --enable-official-branding
ac_add_options --with-system-zlib
ac_add_options --with-system-bz2"
            ;;
        "macos")
            mozconfig_content+="

# macOS-specific options
ac_add_options --target=x86_64-apple-darwin
ac_add_options --enable-official-branding
local macos_sdk_path=\$(xcrun --sdk macosx --show-sdk-path 2>/dev/null || echo "/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk")
ac_add_options --with-macos-sdk=\${macos_sdk_path}"
            ;;
        "windows")
            mozconfig_content+="

# Windows-specific options
ac_add_options --target=x86_64-pc-mingw32
ac_add_options --enable-official-branding
ac_add_options --disable-maintenance-service
ac_add_options --disable-bits-download"
            ;;
    esac
    
    # Common options
    mozconfig_content+="

# Privacy and security
ac_add_options --disable-crashreporter
ac_add_options --disable-updater
ac_add_options --disable-maintenance-service
ac_add_options --disable-webrtc
ac_add_options --disable-eme
ac_add_options --disable-drm

# Additional privacy and feature disabling from HenSurf patches
ac_add_options --disable-default-browser-agent
ac_add_options --disable-normandy
ac_add_options --disable-pocket
ac_add_options --disable-telemetry
ac_add_options --disable-data-reporting
ac_add_options --disable-health-report

# Performance
ac_add_options --enable-lto
ac_add_options --enable-rust-simd

# Parallel build
mk_add_options MOZ_MAKE_FLAGS=\"-j$PARALLEL_JOBS\""
    
    if [ "$DRY_RUN" = true ] && [ "$VERBOSE" = true ]; then
        print_debug "--- START DRY RUN MOZCONFIG CONTENT (for $platform) ---"
        # Print with CYNC (actually CYAN) color, then reset. Ensure NC is properly defined.
        echo -e "${CYAN}"
        echo -e "$mozconfig_content"
        echo -e "${NC}"
        print_debug "--- END DRY RUN MOZCONFIG CONTENT (for $platform) ---"
    fi

    if [ "$DRY_RUN" = false ]; then
        echo "$mozconfig_content" > "$MOZCONFIG"
        print_debug "Created mozconfig for $platform at: $MOZCONFIG"
    else
        # MOZCONFIG here is the platform specific one e.g. /app/src/firefox/mozconfig-hensurf-linux
        print_debug "Would create mozconfig for $platform with $BUILD_TYPE configuration at $MOZCONFIG"
    fi
}

# Function to create mozconfig (backward compatibility)
create_mozconfig() {
    create_mozconfig_for_platform "$TARGET_PLATFORM"
}

# Bootstraps the Mozilla build system for the HenSurf browser.
#
# Initializes the Mozilla build environment by running the bootstrap process in the Firefox source directory, unless already completed or explicitly skipped. In dry-run mode, skips actual execution and prints intended actions.
#
# Globals:
#   SKIP_BOOTSTRAP: If true, skips the bootstrap process.
#   DRY_RUN: If true, simulates actions without executing them.
#   FFOX_SRC: Path to the Firefox source directory.
#
# Outputs:
#   Status and debug messages to STDOUT and the build log.
#
# Example:
#   bootstrap_mozilla
bootstrap_mozilla() {
    if [ "$SKIP_BOOTSTRAP" = true ]; then
        print_status "Skipping Mozilla bootstrap (--skip-bootstrap specified)"
        return 0
    fi
    
    print_status "Bootstrapping Mozilla build system..."
    
    if [ "$DRY_RUN" = true ] && [ ! -d "$FFOX_SRC" ]; then
        print_debug "DRY RUN: Would change to $FFOX_SRC, but it doesn't exist (submodules not initialized in dry run)."
        print_debug "DRY RUN: Skipping ./mach bootstrap steps."
        return 0
    fi
    cd "$FFOX_SRC"
    
    if [ ! -f ".mach_bootstrap_complete" ]; then
        print_status "Running Mozilla bootstrap (this may take a while)..."
        if [ "$DRY_RUN" = false ]; then
            ./mach bootstrap --no-interactive --application-choice browser
            touch .mach_bootstrap_complete
        else
            print_debug "Would run: ./mach bootstrap --no-interactive --application-choice browser"
        fi
    else
        print_status "Mozilla bootstrap already completed, skipping..."
    fi
}

# Builds the HenSurf browser for a specified platform, handling clean builds, logging, and packaging.
#
# Arguments:
#
# * platform: The target platform to build for (e.g., linux, macos, windows).
#
# Returns:
#
# * 0 on successful build and packaging, 1 if the build fails.
#
# The function creates a platform-specific mozconfig, optionally cleans previous build artifacts, runs the build process with logging, and packages the resulting build. In dry-run mode, it skips actual build and packaging steps, printing debug messages instead.
build_for_platform() {
    local platform="$1"
    local original_mozconfig="$MOZCONFIG"
    
    print_status "Building HenSurf for $platform..."
    
    # Create platform-specific mozconfig
    MOZCONFIG="$FFOX_SRC/mozconfig-hensurf-$platform"
    create_mozconfig_for_platform "$platform"
    
    if [ "$DRY_RUN" = true ] && [ ! -d "$FFOX_SRC" ]; then
        print_debug "DRY RUN: Would change to $FFOX_SRC for $platform build, but it doesn't exist."
        print_debug "DRY RUN: Skipping ./mach clobber and ./mach build steps for $platform."
        return 0 # Skip build and subsequent packaging for this platform in dry run
    fi
    cd "$FFOX_SRC"
    
    # Set platform-specific object directory
    export MOZ_OBJDIR="$FFOX_SRC/obj-hensurf-$platform"
    
    # Clean build if requested
    if [ "$CLEAN_BUILD" = true ]; then
        print_status "Cleaning previous build for $platform..."
        if [ "$DRY_RUN" = false ]; then
            ./mach clobber || true
            rm -rf "$MOZ_OBJDIR"
        else
            print_debug "Would run: ./mach clobber && rm -rf $MOZ_OBJDIR"
        fi
    fi
    
    # Start build
    local build_start_time=$(date +%s)
    print_status "Starting $platform build process (this will take 30-60 minutes)..."
    
    if [ "$DRY_RUN" = false ]; then
        local platform_log="$LOG_DIR/autobuild_${platform}_$DATE.log"
        if [ "$VERBOSE" = true ]; then
            ./mach build 2>&1 | tee "$platform_log"
        else
            ./mach build > "$platform_log" 2>&1
        fi
        
        local build_exit_code=$?
        local build_end_time=$(date +%s)
        local build_duration=$((build_end_time - build_start_time))
        
        if [ $build_exit_code -eq 0 ]; then
            print_status "$platform build completed successfully in $((build_duration / 60)) minutes and $((build_duration % 60)) seconds!"
            package_build_for_platform "$platform"
        else
            print_error "$platform build failed after $((build_duration / 60)) minutes and $((build_duration % 60)) seconds"
            print_error "Check the build log at: $platform_log"
            return 1
        fi
    else
        print_debug "Would run: ./mach build for $platform"
    fi
    
    # Restore original mozconfig
    MOZCONFIG="$original_mozconfig"
}

# Function to build HenSurf
build_hensurf() {
    if [ "$TARGET_PLATFORM" = "all" ]; then
        print_status "Building HenSurf for all platforms..."
        local platforms=("linux" "macos" "windows")
        local failed_platforms=()
        
        for platform in "${platforms[@]}"; do
            print_header "Building for $platform"
            if ! build_for_platform "$platform"; then
                failed_platforms+=("$platform")
                print_error "Failed to build for $platform"
            fi
        done
        
        if [ ${#failed_platforms[@]} -gt 0 ]; then
            print_error "Build failed for platforms: ${failed_platforms[*]}"
            return 1
        else
            print_status "Successfully built for all platforms!"
        fi
    else
        build_for_platform "$TARGET_PLATFORM"
    fi
}

# Packages HenSurf build artifacts for a specified platform.
#
# Packages the build output for the given platform by running the Mozilla packaging process,
# organizing the resulting artifacts into versioned and "latest" directories, and generating
# a build information file with metadata. In dry-run mode, skips actual packaging and copying.
#
# Arguments:
#
# * Platform name (e.g., "linux", "macos", "windows")
#
# Outputs:
#
# * Packaged build artifacts and a build-info.txt file in the build directory structure.
#
# Example:
#
# ```bash
# package_build_for_platform linux
# ```
package_build_for_platform() {
    local platform="$1"
    print_status "Packaging HenSurf for $platform..."
    
    if [ "$DRY_RUN" = true ] && [ ! -d "$FFOX_SRC" ]; then
        print_debug "DRY RUN: Would change to $FFOX_SRC for packaging $platform, but it doesn't exist."
        print_debug "DRY RUN: Skipping ./mach package and artifact copying for $platform."
        return 0
    fi
    cd "$FFOX_SRC"
    
    if [ "$DRY_RUN" = false ]; then
        ./mach package
        
        # Create organized directory structure
        local platform_dir="$BUILD_DIR/$platform/$BUILD_TYPE/$VERSION"
        local latest_dir="$BUILD_DIR/$platform/$BUILD_TYPE/latest"
        mkdir -p "$platform_dir" "$latest_dir"
        
        # Copy based on platform
        case "$platform" in
            "macos")
                if [ -d "$MOZ_OBJDIR/dist/HenSurf.app" ]; then
                    cp -r "$MOZ_OBJDIR/dist/HenSurf.app" "$platform_dir/"
                    cp -r "$MOZ_OBJDIR/dist/HenSurf.app" "$latest_dir/"
                fi
                cp "$MOZ_OBJDIR/dist/"*.dmg "$platform_dir/" 2>/dev/null || true
                cp "$MOZ_OBJDIR/dist/"*.dmg "$latest_dir/" 2>/dev/null || true
                ;;
            "linux")
                cp "$MOZ_OBJDIR/dist/"*.tar.bz2 "$platform_dir/" 2>/dev/null || true
                cp "$MOZ_OBJDIR/dist/"*.tar.gz "$platform_dir/" 2>/dev/null || true
                cp "$MOZ_OBJDIR/dist/"*.tar.bz2 "$latest_dir/" 2>/dev/null || true
                cp "$MOZ_OBJDIR/dist/"*.tar.gz "$latest_dir/" 2>/dev/null || true
                ;;
            "windows")
                cp "$MOZ_OBJDIR/dist/install/sea/"*.exe "$platform_dir/" 2>/dev/null || true
                cp "$MOZ_OBJDIR/dist/"*.zip "$platform_dir/" 2>/dev/null || true
                cp "$MOZ_OBJDIR/dist/install/sea/"*.exe "$latest_dir/" 2>/dev/null || true
                cp "$MOZ_OBJDIR/dist/"*.zip "$latest_dir/" 2>/dev/null || true
                ;;
        esac
        
        # Create build info file
        cat > "$platform_dir/build-info.txt" << EOF
HenSurf Build Information
========================

Platform: $platform
Build Type: $BUILD_TYPE
Version: $VERSION
Build Date: $(date)
Build Host: $(uname -a)
Git Commit: $(git rev-parse HEAD 2>/dev/null || echo 'N/A')

Build Configuration:
- Parallel Jobs: $PARALLEL_JOBS
- Clean Build: $CLEAN_BUILD
- Skip Bootstrap: $SKIP_BOOTSTRAP
- Skip Patches: $SKIP_PATCHES
EOF
        
        # Copy build info to latest as well
        cp "$platform_dir/build-info.txt" "$latest_dir/"
        
        print_status "$platform build artifacts saved to: $platform_dir"
        print_status "$platform latest build linked to: $latest_dir"
    else
        print_debug "Would run: ./mach package for $platform"
        print_debug "Would copy artifacts to: $BUILD_DIR/$platform/$BUILD_TYPE/$VERSION"
    fi
}

# Function to package the build (backward compatibility)
package_build() {
    if [ "$TARGET_PLATFORM" = "all" ]; then
        # Packaging is handled per-platform in build_hensurf
        return 0
    else
        package_build_for_platform "$TARGET_PLATFORM"
    fi
}

# Runs a minimal test suite if the build type is debug.
#
# Only executes tests when in debug mode. Skips test execution in dry-run mode or if the Firefox source directory does not exist.
#
# Globals:
# * BUILD_TYPE: Determines if tests should run (must be "debug").
# * DRY_RUN: If true, skips actual test execution.
# * FFOX_SRC: Path to the Firefox source directory.
#
# Outputs:
# * Status and debug messages to STDOUT.
# * Warnings if tests fail.
#
# Example:
#
#   run_tests
run_tests() {
    if [ "$BUILD_TYPE" = "debug" ]; then
        print_status "Running basic tests..."
        
        if [ "$DRY_RUN" = true ] && [ ! -d "$FFOX_SRC" ]; then
            print_debug "DRY RUN: Would change to $FFOX_SRC for running tests, but it doesn't exist."
            print_debug "DRY RUN: Skipping ./mach test."
            return 0
        fi
        cd "$FFOX_SRC"
        
        if [ "$DRY_RUN" = false ]; then
            # Run a minimal test suite
            ./mach test browser/base/content/test/general/browser_test_new_window_from.js || print_warning "Some tests failed"
        else
            print_debug "Would run: ./mach test browser/base/content/test/general/browser_test_new_window_from.js"
        fi
    fi
}

# Function to generate build report
generate_report() {
    local report_file="$BUILD_DIR/build_report_$DATE.txt"
    
    cat > "$report_file" << EOF
HenSurf Build Report
===================

Build Date: $(date)
Build Type: $BUILD_TYPE
Target Platform: $TARGET_PLATFORM
Host Platform: $(detect_platform)
Version: $VERSION
Parallel Jobs: $PARALLEL_JOBS

Build Configuration:
- Clean Build: $CLEAN_BUILD
- Skip Bootstrap: $SKIP_BOOTSTRAP
- Skip Patches: $SKIP_PATCHES
- Verbose: $VERBOSE
- Dry Run: $DRY_RUN

Build Log: $BUILD_LOG
Build Artifacts: $BUILD_DIR

System Information:
- OS: $OSTYPE
- User: $(whoami)
- Working Directory: $PROJECT_ROOT

EOF

    if command -v uname &> /dev/null; then
        echo "System: $(uname -a)" >> "$report_file"
    fi
    
    if command -v git &> /dev/null; then
        echo "Git Commit: $(git rev-parse HEAD 2>/dev/null || echo 'N/A')" >> "$report_file"
    fi
    
    print_status "Build report saved to: $report_file"
}

# Parse command line arguments
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
        -p|--platform)
            TARGET_PLATFORM="$2"
            shift 2
            ;;
        --skip-bootstrap)
            SKIP_BOOTSTRAP=true
            shift
            ;;
        --skip-patches)
            SKIP_PATCHES=true
            shift
            ;;
        --build-dir)
            BUILD_DIR="$2"
            shift 2
            ;;
        --log-dir)
            LOG_DIR="$2"
            shift 2
            ;;
        --version)
            VERSION="$2"
            shift 2
            ;;
        *)
            print_error "Unknown option: $1"
            show_usage
            exit 1
            ;;
    esac
done

# Resolve target platform
if [ "$TARGET_PLATFORM" = "auto" ]; then
    TARGET_PLATFORM=$(detect_platform)
fi

# Orchestrates the full HenSurf browser build process, including setup, customization, building, testing, packaging, and reporting.
#
# Executes all major build steps in sequence, printing status updates and handling both normal and dry-run modes. Reports build artifact and log locations upon completion.
#
# Globals:
#   Uses and modifies global configuration variables such as BUILD_TYPE, TARGET_PLATFORM, PARALLEL_JOBS, CLEAN_BUILD, DRY_RUN, BUILD_DIR, LOG_DIR, and VERSION.
#
# Outputs:
#   Prints status, warnings, and completion messages to STDOUT. Writes logs and reports to the build log directory.
#
# Example:
#
#   main
#   # Runs the entire automated build process for HenSurf with current configuration.
main() {
    print_header "HenSurf Autobuild v$VERSION"
    
    print_status "Build configuration:"
    print_status "  Build Type: $BUILD_TYPE"
    print_status "  Target Platform: $TARGET_PLATFORM"
    print_status "  Parallel Jobs: $PARALLEL_JOBS"
    print_status "  Clean Build: $CLEAN_BUILD"
    print_status "  Dry Run: $DRY_RUN"
    print_status "  Builds Directory: $BUILD_DIR"
    
    if [ "$DRY_RUN" = true ]; then
        print_warning "DRY RUN MODE - No actual changes will be made"
    fi
    
    # Execute build steps
    check_prerequisites
    setup_environment
    apply_customizations
    bootstrap_mozilla
    build_hensurf
    run_tests
    generate_report
    
    print_header "Build Complete!"
    print_status "HenSurf $BUILD_TYPE build completed successfully!"
    if [ "$TARGET_PLATFORM" = "all" ]; then
        print_status "Build artifacts for all platforms are available in: $BUILD_DIR"
        print_status "Directory structure:"
        print_status "  $BUILD_DIR/linux/$BUILD_TYPE/$VERSION/"
        print_status "  $BUILD_DIR/macos/$BUILD_TYPE/$VERSION/"
        print_status "  $BUILD_DIR/windows/$BUILD_TYPE/$VERSION/"
        print_status "  Latest builds also available in respective 'latest' directories"
    else
        print_status "Build artifacts are available in: $BUILD_DIR/$TARGET_PLATFORM/$BUILD_TYPE/$VERSION/"
        print_status "Latest build also available in: $BUILD_DIR/$TARGET_PLATFORM/$BUILD_TYPE/latest/"
    fi
    print_status "Build logs: $LOG_DIR"
    
    if [ "$DRY_RUN" = false ]; then
        echo -e "\n${GREEN}🏄 Ready to surf the web with privacy!${NC}\n"
    else
        echo -e "\n${YELLOW}🏄 Dry run completed - no actual build was performed${NC}\n"
    fi
}

# Run main function
main "$@"