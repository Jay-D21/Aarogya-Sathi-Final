from PIL import Image
import numpy as np
import sys

def make_transparent(img_path, out_path):
    print(f"Loading {img_path}...")
    img = Image.open(img_path).convert('RGB')
    data = np.array(img, dtype=np.float32)
    
    # Subtract base background (8, 13, 26)
    bg = np.array([8.0, 13.0, 26.0])
    data = np.maximum(0, data - bg)
    
    # Calculate alpha based on luminance of the "glow"
    alpha = np.max(data, axis=2)
    
    # Create output array with shape (H, W, 4)
    out_data = np.zeros((data.shape[0], data.shape[1], 4), dtype=np.uint8)
    
    # Where alpha is > 0, unmultiply RGB
    mask = alpha > 0
    
    # We do (data * 255 / alpha)
    # Using np.divide with out and where to handle division by zero
    rgb_unmultiplied = np.zeros_like(data)
    np.divide(data * 255.0, np.expand_dims(alpha, axis=-1), out=rgb_unmultiplied, where=np.expand_dims(mask, axis=-1))
    rgb_unmultiplied = np.clip(rgb_unmultiplied, 0, 255)
    
    out_data[:, :, :3] = rgb_unmultiplied
    out_data[:, :, 3] = np.clip(alpha, 0, 255)
    
    print(f"Saving transparent image to {out_path}...")
    Image.fromarray(out_data, 'RGBA').save(out_path)
    print("Done!")

if __name__ == "__main__":
    src = r"c:\Users\Abhijit\Desktop\Aarogya-Sathi-Final\frontend\assets\images\icon.png"
    dst = r"c:\Users\Abhijit\Desktop\Aarogya-Sathi-Final\frontend\assets\images\icon.png"
    make_transparent(src, dst)
