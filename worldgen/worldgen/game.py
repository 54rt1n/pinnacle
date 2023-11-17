import arcade
import arcade.color as arcade_color
import arcade.gui as arcade_gui
import arcade.key as arcade_key
from PIL import Image
import numpy as np
from typing import Optional

from worldgen.engine import Engine

class Simulation(arcade.Window):
    engine : Engine
    world_scene : arcade.Scene
    world_texture : arcade.Texture
    world_camera : arcade.Camera
    gui_camera : arcade.Camera
    zoom_scene : arcade.Scene
    zoom_texture : Optional[arcade.Texture] = None
    zoom_camera : arcade.Camera
    zoom_level : float = 1.0
    view_left : float = 0
    view_bottom : float = 0
    view_width : float = 0
    view_height : float = 0
    drag_start_x : Optional[float] = None
    drag_start_y : Optional[float] = None
    scale : float = 1.0
    selected_tile : Optional[tuple] = None
    ui_manager : arcade_gui.UIManager
    speed : int
    sz : float
    viewport_dim : int

    @classmethod
    def from_file(cls, file_path : str):
        image = Image.open(file_path).resize((4096, 4096))
        engine = Engine(np.asarray(image))
        sim = cls(engine, 800, 830, "Simulation")
        return sim

    def __init__(self, engine : Engine, width : int, height : int, title : str):
        super().__init__(width, height, title)

        # load the image as texture
        self.engine = engine
        self.viewport_dim = 800
        self.sz = self.viewport_dim  / 4096
        self.world_scene = arcade.Scene()
        # Viewport left bottom width height
        self.world_camera = arcade.Camera(viewport=(0, 0, self.viewport_dim, self.viewport_dim))
        self.gui_camera = arcade.Camera(viewport=(0, 0, width, height))
        self.zoom_scene = arcade.Scene()
        #self.zoom_camera = arcade.Camera(viewport=(width - 90, height - 120, 90, 90))
        self.zoom_camera = arcade.Camera(viewport=(width - 180, height - 210, 180, 180))
        self.ui_manager = arcade_gui.UIManager(self)

        self.title_label = arcade_gui.UILabel(text="Pinnacle", x=10, y=self.height - 22)
        self.iteration_label = arcade_gui.UILabel(text=f"Iteration: {self.engine.iterations}", x=100, y=self.height - 22)
        self.speed_label = arcade_gui.UILabel(text="[Pause]", x=self.width - 60, y=self.height - 22)
        self.selected_label = arcade_gui.UILabel(text="(____, ____)", x=self.width - 200, y=self.height - 22)
        self.ui_manager.add(self.title_label)
        self.ui_manager.add(self.iteration_label)
        self.ui_manager.add(self.speed_label)
        self.ui_manager.add(self.selected_label)
        self.speed = 0

        arcade.set_background_color(arcade_color.ALMOND)

    def setup(self):
        # Add the anchor widget to the UIManager
        if self.world_scene._name_mapping.get('world_map', None) is not None:
            self.world_scene.remove_sprite_list_by_name('world_map')
            self.world_texture.remove_from_cache()
            self.world_texture.remove_from_atlases()
        self.world_texture = arcade.Texture(image=self.engine.getImage(), hash='world')
        self.scale = self.viewport_dim
        self.scale /= self.world_texture.size[0]
        world_map = arcade.Sprite(
            self.world_texture,
            center_x=self.viewport_dim // 2,
            center_y=self.viewport_dim // 2,
            scale=self.scale
            )
        self.world_scene.add_sprite('world_map', world_map)
        self.view_width = self.viewport_dim
        self.view_height = self.viewport_dim

    def set_zoom_window(self):
        """Add our texture to our scene"""
        if self.selected_tile is not None:
            if self.zoom_scene._name_mapping.get('zoom_map', None) is not None:
                self.zoom_scene.remove_sprite_list_by_name('zoom_map')
            zoom_image = self.engine.getZoomAt(*self.selected_tile, radius=32)
            if self.zoom_texture is not None:
                self.zoom_texture.remove_from_cache()
                self.zoom_texture.remove_from_atlases()
            self.zoom_texture = arcade.Texture(image=zoom_image)
            zoom_sprite = arcade.Sprite(
                self.zoom_texture,
                center_x=zoom_image.width // 2,
                center_y=zoom_image.height // 2,
                scale=4,
                )
            self.zoom_scene.add_sprite('zoom_map', zoom_sprite)
        else:
            self.zoom_scene.remove_sprite_list_by_name('zoom_map')

    def select_world_location(self, x : int, y : int):
        self.selected_tile = (x, y)
        self.set_zoom_window()

    def update_viewport(self):
        self.clamp_viewport()

        left = int(self.view_left)
        width = int(self.view_width)
        height = int(self.view_height)
        bottom = int(self.view_bottom)
        self.world_camera.set_viewport(viewport=(left, bottom, width, height))

    def on_draw(self):
        arcade.start_render()
        self.world_camera.use()
        self.world_scene.draw()
        if self.selected_tile is not None:
            cx, cy = self.selected_tile
            cx = cx * self.sz
            cy = cy * self.sz
            arcade.draw_lrbt_rectangle_outline(cx - 1, cx + 1, cy - 1, cy + 1, arcade.color.WHITE, 1)
        self.gui_camera.use()
        self.draw_overlay()
        if self.selected_tile is not None:
            self.zoom_camera.use()
            arcade.draw_lrbt_rectangle_filled(0, 90, 0, 90, arcade.color.WHITE)
            self.zoom_scene.draw()

    def on_mouse_press(self, x, y, button, modifiers):
        # start dragging
        if button == arcade.MOUSE_BUTTON_MIDDLE:
            self.drag_start_x = x
            self.drag_start_y = y
        else:
            # when mouse is clicked, select the tile at that position
            world_x = (x - self.view_left) * self.zoom_level // self.sz
            world_y = (y - self.view_bottom) * self.zoom_level // self.sz
            if world_y >= 4096 or world_x >= 4096:
                self.selected_tile = None
                self.set_zoom_window()
                return
            self.select_world_location(int(world_x), int(world_y))

    def on_mouse_release(self, x, y, button, modifiers):
        # stop dragging
        if button == arcade.MOUSE_BUTTON_MIDDLE:
            self.drag_start_x = None
            self.drag_start_y = None

    def on_mouse_motion(self, x, y, dx, dy):
        # if dragging, move the map
        if self.drag_start_x is not None and self.drag_start_y is not None:
            self.view_left -= dx / self.zoom_level
            self.view_bottom -= dy / self.zoom_level
            self.update_viewport()

    def on_key_press(self, symbol, modifiers):
        if symbol == arcade_key.Q:
            arcade.close_window()
        if symbol == arcade_key.SPACE:
            self.engine.tick()
            self.texture = arcade.Texture(image=self.engine.getImage())
        if symbol == arcade_key.UP and self.selected_tile is not None:
            self.select_world_location(self.selected_tile[0], self.selected_tile[1] + 1)
        if symbol == arcade_key.DOWN and self.selected_tile is not None:
            self.select_world_location(self.selected_tile[0], self.selected_tile[1] - 1)
        if symbol == arcade_key.LEFT and self.selected_tile is not None:
            self.select_world_location(self.selected_tile[0] - 1, self.selected_tile[1])
        if symbol == arcade_key.RIGHT and self.selected_tile is not None:
            self.select_world_location(self.selected_tile[0] + 1, self.selected_tile[1])
        if symbol == arcade_key.R:
            self.selected_tile = None
            self.setup()
            arcade.cleanup_texture_cache()

    def on_mouse_scroll(self, x: int, y: int, scroll_x: int, scroll_y: int):
        SCALE_FACTOR = 0.1  # determines the speed of zooming
        # This is our window size vs our map size

        # x, y is the mouse position. 
        vw = self.viewport_dim / self.zoom_level
        vh = self.viewport_dim / self.zoom_level

        # Our relative mouse positions
        px = (x / self.viewport_dim)
        py = (y / self.viewport_dim)

        if scroll_y > 0:
            self.zoom_level *= (1 - SCALE_FACTOR)
            if self.zoom_level < self.sz / 4:
                self.zoom_level = self.sz / 4
        elif scroll_y < 0:
            self.zoom_level *= (1 + SCALE_FACTOR)
            if self.zoom_level > 1:
                self.zoom_level = 1 

        self.view_width = self.viewport_dim / self.zoom_level
        self.view_height = self.viewport_dim / self.zoom_level

        # we need to update left/bottom so that the viewport scrolls towards the pointer
        self.view_left -= (self.view_width - vw) * px
        self.view_bottom -= (self.view_height - vh) * py

        self.update_viewport()
    
    def clamp_viewport(self):
        # clamp the viewport
        # two conditions, the left/bottom, and right/top
        # left/bottom, can't go below zero.
        # top/right, can't exceed the scaled viewport size (nh/nw) viewport width (900)
        self.view_left = min(0, self.view_left)
        self.view_bottom = min(0, self.view_bottom)
        self.view_left = max(self.view_left, self.viewport_dim - self.view_width)
        self.view_bottom = max(self.view_bottom, self.viewport_dim - self.view_height)

    def draw_overlay(self):
        # Draw the menu bar
        arcade.draw_xywh_rectangle_filled(0, self.height - 30, self.width, 30, arcade.color.GRAY)

        # Update the iteration counter and speed label
        self.iteration_label.text = f"Iteration: {self.engine.iterations}"
        speed_text = {
            0: "[Pause]",
            1: "[Play]",
            2: "[>>]"
        }.get(self.speed, "[Off]")
        self.speed_label.text = speed_text
        selected = self.selected_tile
        if selected is not None:
            self.selected_label.text = f"({selected[0]:.0f}, {selected[1]:.0f})"
        else:
            self.selected_label.text = "(____, ____)"

        # Draw the labels
        #self.title_label.draw()
        #self.iteration_label.draw()
        #self.speed_label.draw()
        self.ui_manager.draw()

if __name__ == "__main__":
    sim = Simulation.from_file("assets/world_4096_map.png")
    sim.setup()
    arcade.run()