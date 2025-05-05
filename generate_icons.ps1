# Download a sample icon
Invoke-WebRequest -Uri "https://upload.wikimedia.org/wikipedia/commons/7/73/Flat_tick_icon.png" -OutFile "icon.png"

# Python script to resize and copy icons
$pythonScript = @"
from PIL import Image
import os

sizes = {
    'mipmap-mdpi': 48,
    'mipmap-hdpi': 72,
    'mipmap-xhdpi': 96,
    'mipmap-xxhdpi': 144,
    'mipmap-xxxhdpi': 192
}

src = 'icon.png'
for folder, size in sizes.items():
    dst_dir = os.path.join('android', 'app', 'src', 'main', 'res', folder)
    os.makedirs(dst_dir, exist_ok=True)
    dst = os.path.join(dst_dir, 'app_icon.png')
    img = Image.open(src).convert('RGBA').resize((size, size), Image.LANCZOS)
    img.save(dst)
"@

Set-Content -Path "resize_icons.py" -Value $pythonScript

# Run the Python script
python resize_icons.py

# Clean up
Remove-Item "icon.png"
Remove-Item "resize_icons.py"
