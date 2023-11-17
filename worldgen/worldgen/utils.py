from PIL import Image
import numpy as np

def get_pixel_color(image: Image, x: int, y: int) -> tuple:
    """Retrieve the color of the pixel at the specified coordinates."""
    width, height = image.size
    # Make sure x and y are within the bounds of the image
    x = min(max(0, x), width - 1)
    y = min(max(0, y), height - 1)
    
    # PIL images have (0,0) at the top left so we might need to adjust y
    pixel = image.getpixel((x, y))
    return pixel

def get_coordinate_info(x: int, y: int) -> str:
    """Format the x, y coordinates as a string."""
    return f"({x}, {y})"

def load_image(path: str, scale: int) -> np.ndarray:
    """Load the image at the specified path."""
    image = Image.open(path)
    image = image.resize((scale, scale))
    img_array = np.array(image)
    return img_array