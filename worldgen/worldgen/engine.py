# worldgen/engine.py

import numpy as np
from PIL import Image

class Engine(object):
    def __init__(self, world : np.ndarray):
        self.world = world.copy()
        self.iterations = 0

    def tick(self):
        self.iterations += 1
        print(f'tick {self.iterations}')
        self.world = (self.world * .9).astype(np.uint8)

    def getImage(self) -> Image.Image:
        return Image.fromarray(self.world)

    def getZoomAt(self, x : int, y : int, radius : int) -> Image.Image:
        # We need to get our world, centered at x, y
        nx = x
        ny = 4096 - y
        wl = self.world[ny-radius:ny+radius, nx-radius:nx+radius]
        # now we need to expand the image 4x to get our world-level scale
        wl = wl.repeat(8, axis=0).repeat(4, axis=1)
        return Image.fromarray(wl).transpose(Image.FLIP_TOP_BOTTOM).transpose(Image.FLIP_LEFT_RIGHT)