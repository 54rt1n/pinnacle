import dearpygui.dearpygui as dpg
import numpy as np
from PIL import Image
from typing import Any

# Function to load and process the image
def load_image(sender: str, app_data: Any) -> None:
    file_path = dpg.get_value("file_path")
    image = Image.open(file_path)
    image = image.resize((4096, 4096))
    image = np.array(image)
    dpg.set_value("image", image)
    dpg.draw_image("drawing", pmin=[0, 0], pmax=[4096, 4096])

# Function to handle click events
def click_handler(sender: str, app_data: Any) -> None:
    mouse_pos = dpg.get_mouse_pos()
    image = dpg.get_value("image")
    x, y = int(mouse_pos[0]), int(mouse_pos[1])
    if 0 <= x < image.shape[1] and 0 <= y < image.shape[0]:
        color = image[y, x]
        print(f"Clicked at ({x}, {y}), color: {color}")

dpg.create_context()
dpg.create_viewport(title='Custom Title', width=600, height=300)

with dpg.window(label="Example Window"):
    dpg.add_text("Hello, world")
    dpg.add_button(label="Save")
    dpg.add_input_text(label="string", default_value="Quick brown fox")
    dpg.add_slider_float(label="float", default_value=0.273, max_value=1)

dpg.setup_dearpygui()
dpg.show_viewport()
dpg.start_dearpygui()
dpg.destroy_context()