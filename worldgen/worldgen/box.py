import numpy as np
import pygame

# initialize pygame
pygame.init()

# define your tile size
tile_size = 2

# define your map as a numpy ndarray of uint8
from worldgen.image import load_image, extract_biomes

goal = 65536
base = 512
scale = base * 128
patches = 8
patch_window = int(base / patches)
biome_count = 10

world_image = load_image("./assets/pinnacle.png", base)
#tilemap = np.random.randint(0, 255, (100, 100)).astype(np.uint8)
tilemap = world_image.astype(np.uint8)
print(tilemap.shape[0])

# define your tiles
# in practice, you'd probably load these from images
tiles = [pygame.Surface((tile_size, tile_size)) for _ in range(256)]
tilen = len(tiles)
for i, tile in enumerate(tiles):
    # create a graident from black to white
    tile.fill((i,i,i))

# create a surface to draw your map on
map_surface = pygame.Surface((tilemap.shape[1]*tile_size, tilemap.shape[0]*tile_size))

# draw your map on the surface
for y in range(tilemap.shape[0]):
    for x in range(tilemap.shape[1]):
        map_surface.blit(tiles[tilemap[y, x, 0]], (x*tile_size, y*tile_size))

# create a window
win = pygame.display.set_mode((tilemap.shape[1]*tile_size, tilemap.shape[0]*tile_size))

# main game loop
running = True
while running:
    for event in pygame.event.get():
        if event.type == pygame.QUIT:
            running = False
        elif event.type == pygame.KEYDOWN:  # a key has been pressed
            if event.key == pygame.K_q:  # the key is 'q'
                running = False

    # draw the map
    win.blit(map_surface, (0, 0))
    pygame.display.flip()

pygame.quit()