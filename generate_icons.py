from PIL import Image, ImageDraw
import os

def create_app_icon(size, color='#3498db'):  # Flat blue color
    image = Image.new('RGBA', (size, size), color)
    draw = ImageDraw.Draw(image)
    
    # Optional: Add a subtle border or design
    border_width = max(1, size // 20)
    draw.rectangle([0, 0, size-1, size-1], outline='white', width=border_width)
    
    return image

def generate_icons():
    sizes = {
        'mipmap-mdpi': 48,
        'mipmap-hdpi': 72,
        'mipmap-xhdpi': 96,
        'mipmap-xxhdpi': 144,
        'mipmap-xxxhdpi': 192
    }

    base_path = os.path.join('android', 'app', 'src', 'main', 'res')
    
    for folder, size in sizes.items():
        folder_path = os.path.join(base_path, folder)
        os.makedirs(folder_path, exist_ok=True)
        
        icon_path = os.path.join(folder_path, 'app_icon.png')
        icon = create_app_icon(size)
        icon.save(icon_path)
        print(f"Generated {icon_path}")

if __name__ == '__main__':
    generate_icons()
