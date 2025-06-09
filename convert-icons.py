#!/usr/bin/env python3

import os
from PIL import Image
import subprocess

def convert_png_to_icns(png_path, icns_path):
    """Convert PNG to ICNS format for macOS"""
    try:
        # Create iconset directory
        iconset_dir = icns_path.replace('.icns', '.iconset')
        os.makedirs(iconset_dir, exist_ok=True)
        
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
        
        # Convert iconset to icns using iconutil
        subprocess.run(['iconutil', '-c', 'icns', iconset_dir, '-o', icns_path], check=True)
        print(f"Created {icns_path}")
        
        # Clean up iconset directory
        import shutil
        shutil.rmtree(iconset_dir)
        
        return True
    except Exception as e:
        print(f"Error converting to ICNS: {e}")
        return False

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
    png_path = '/Users/henryperzinski/Developer/HenFire/HenSurfLogo.png'
    branding_dir = '/Users/henryperzinski/Developer/HenFire/browser/branding/hensurf'
    
    if not os.path.exists(png_path):
        print(f"Error: {png_path} not found")
        return False
    
    # Load original image
    img = Image.open(png_path)
    
    # Create 16x16 and 32x32 SVG-style icons (actually PNG for now)
    sizes = [16, 32, 48, 64, 128, 256]
    
    for size in sizes:
        resized_img = img.resize((size, size), Image.Resampling.LANCZOS)
        output_path = os.path.join(branding_dir, f'default{size}.png')
        resized_img.save(output_path)
        print(f"Created {output_path}")
    
    # Create macOS app icon
    icns_path = os.path.join(branding_dir, 'hensurf.icns')
    convert_png_to_icns(png_path, icns_path)
    
    # Create Windows icon
    ico_path = os.path.join(branding_dir, 'hensurf.ico')
    convert_png_to_ico(png_path, ico_path)
    
    return True

if __name__ == '__main__':
    print("Converting HenSurf logo to various icon formats...")
    update_branding_icons()
    print("Icon conversion completed!")