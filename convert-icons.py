#!/usr/bin/env python3

import os
from PIL import Image
import subprocess
import platform # For OS detection
import sys # For exit status

def convert_png_to_icns(png_path, icns_path):
    """Convert PNG to ICNS format for macOS, conditionally runs iconutil."""
    iconset_dir = icns_path.replace('.icns', '.iconset')
    created_iconset_dir = False  # Flag to track if directory was created

    try:
        # Create iconset directory
        os.makedirs(iconset_dir, exist_ok=True)
        created_iconset_dir = True
        
        # Load the original image
        img = Image.open(png_path)
        
        # Define the required sizes for macOS icons
        sizes = [
            (16, 'icon_16x16.png'),
            (32, 'icon_16x16@2x.png'),
            (32, 'icon_32x32.png'),
            (64, 'icon_32x32@2x.png'),
            (128, 'icon_128x128.png'),
            (256, 'icon_128x128@2x.png'),
            (256, 'icon_256x256.png'),
            (512, 'icon_256x256@2x.png'),
            (512, 'icon_512x512.png'),
            (1024, 'icon_512x512@2x.png')
        ]
        
        # Generate all required sizes
        for size, filename in sizes:
            resized_img = img.resize((size, size), Image.Resampling.LANCZOS)
            resized_img.save(os.path.join(iconset_dir, filename))
            print(f"Generated {filename} ({size}x{size})")
        
        if platform.system() == 'Darwin':
            # Convert iconset to icns using iconutil
            subprocess.run(['iconutil', '-c', 'icns', iconset_dir, '-o', icns_path], check=True)
            print(f"Created {icns_path}")
        else:
            print(f"Skipping ICNS generation for {icns_path} (iconutil requires macOS).")
            # Still considered a success if PNGs were generated
        
        return True # PNGs generated, and iconutil (if run) succeeded or was skipped
        
    except Exception as e:
        print(f"Error during ICNS preparation or generation: {e}")
        return False # Error in creating .iconset or PNGs within it
    finally:
        if created_iconset_dir:
            import shutil
            shutil.rmtree(iconset_dir)
            print(f"Cleaned up {iconset_dir}")

def convert_png_to_ico(png_path, ico_path):
    """Convert PNG to ICO format for Windows"""
    try:
        img = Image.open(png_path)
        # Create multiple sizes for ICO
        sizes = [(16, 16), (32, 32), (48, 48), (64, 64), (128, 128), (256, 256)]
        icons = []
        
        for size in sizes:
            resized_img = img.resize(size, Image.Resampling.LANCZOS)
            icons.append(resized_img)
        
        # Save as ICO with multiple sizes
        icons[0].save(ico_path, format='ICO', sizes=[(icon.width, icon.height) for icon in icons])
        print(f"Created {ico_path}")
        return True
    except Exception as e:
        print(f"Error converting to ICO: {e}")
        return False

def update_branding_icons():
    """Update branding directory with new icons"""
    png_path = 'HenSurfLogo.png' # Relative path
    branding_dir = 'browser/branding/hensurf' # Relative path

    # Ensure branding directory exists
    os.makedirs(branding_dir, exist_ok=True)
    
    if not os.path.exists(png_path):
        print(f"Error: {png_path} not found in {os.getcwd()}")
        return False
    
    # Load original image
    try:
        img = Image.open(png_path)
    except Exception as e:
        print(f"Error opening source image {png_path}: {e}")
        return False
    
    # Create 16x16 and 32x32 SVG-style icons (actually PNG for now)
    sizes = [16, 32, 48, 64, 128, 256]
    
    try:
        for size in sizes:
            resized_img = img.resize((size, size), Image.Resampling.LANCZOS)
            output_path = os.path.join(branding_dir, f'default{size}.png')
            resized_img.save(output_path)
            print(f"Created {output_path}")
    except Exception as e:
        print(f"Error generating PNG files: {e}")
        return False
    
    # Create macOS app icon
    icns_path = os.path.join(branding_dir, 'hensurf.icns')
    if not convert_png_to_icns(png_path, icns_path):
        # This function now returns True even if iconutil is skipped,
        # so False here means a more critical error in PNG generation for ICNS.
        print(f"Failed to create or prepare ICNS resources from {png_path}")
        # Depending on strictness, you might return False here.
        # For now, we'll let it continue if base PNGs were made,
        # as per "not necessarily return False if only the optional ICNS step prints a 'skipped' message".
        # However, if convert_png_to_icns returns False, it means PNGs for iconset failed.
        return False


    # Create Windows icon
    ico_path = os.path.join(branding_dir, 'hensurf.ico')
    if not convert_png_to_ico(png_path, ico_path):
        print(f"Failed to create ICO {ico_path} from {png_path}")
        return False # ICO generation is generally expected to work if Pillow is present
    
    return True

if __name__ == '__main__':
    print("Converting HenSurf logo to various icon formats...")
    if not update_branding_icons():
        print("Icon conversion failed.")
        sys.exit(1)
    print("Icon conversion completed!")