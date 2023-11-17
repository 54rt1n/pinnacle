# world.py

import numpy as np
from scipy.spatial import Voronoi, voronoi_plot_2d
from locationed import apply_fractal_noise, get_stats, generate_biomes2
import noise
import math
from scipy.ndimage import convolve
import random
from PIL import Image

def flood_fill(vor):
    """Function to flood fill regions using Voronoi diagram's ridge information. 

    This function iterates over all ridges, checks if one of the neighbouring regions is empty 
    and the other one is not. If this is the case, it fills the empty region with the non-empty 
    neighbour's biome.
    
    Parameters:
    vor (scipy.spatial.Voronoi object): Voronoi object for which the regions will be flood filled.
    
    Returns:
    filled_biomes (list): List containing filled biome data for each region.
    """

    # Assume vor is your Voronoi object
    filled_biomes = [-1]*len(vor.point_region) # Initialize as empty
    
    # Assume biomes is your initial list of biome data
    biomes = [...]
    
    for region_index in vor.point_region:
        if biomes[region_index] != -1: # Check if the region is not empty
            filled_biomes[region_index] = biomes[region_index] # If not empty, set the filled biome data to be the initial biome data
    
    # Iteratively spread biomes to neighboring regions
    change_occurred = True
    while change_occurred:
        change_occurred = False
        for (p1, p2) in vor.ridge_points:
            r1 = vor.point_region[p1]
            r2 = vor.point_region[p2]
            
            # Check if one region is empty and the other is not
            if filled_biomes[r1] == -1 and filled_biomes[r2] != -1:
                filled_biomes[r1] = filled_biomes[r2]
                change_occurred = True
            elif filled_biomes[r2] == -1 and filled_biomes[r1] != -1:
                filled_biomes[r2] = filled_biomes[r1]
                change_occurred = True
    
    return filled_biomes

"""
#### Overworld
- 512x512 grid
* Contains various types of `World Terrain` - Plains, Forest, Hills, Mountains, Jungle, Swamp, Desert, Ocean.
* There can also be variations on the terrain like light/medium/heavy
* A location might have a road (and it's direction).  (Oceans can't have roads.)
* A location might have a river (and it's direction).  (Oceans can't have rivers.)
* This makes 24 different terrain types.  (Heavy mountains are impassable.)
* Some locations are `Interactive`s, a Location may be entered.  A Settlement may be explored or used.  
Examples - Road, Farm, Mine, etc.
* NPCs- caravans, travellers, military companies, animals, monsters, and other groups will travel the overworld, and be
interactive.  When entering the square of a NPC, you can optionally engage - parley, attack, block.
"""

class World:
    def __init__(self, size=(65536, 65536)):
        """Initializes a World instance."""
        self.size = size
        self.heightmap = np.zeros(size)
        self.regions = None
        self.biomes = None

    def generate_regions(self, num_points=500):
        """Generates Voronoi regions for the world map."""
        # Generate random points for the Voronoi diagramw
        points = np.random.rand(num_points, 2) * self.size
        
        # Generate Voronoi regions
        self.regions = Voronoi(points)
        
        # ToDo: Add logic to calculate terrain depth and length values
        # ...

    def apply_perlin_noise(self, scale=1.0, octaves=1, persistence=0.5, lacunarity=2.0):
        """Applies Perlin noise to the world heightmap."""
        self.heightmap = apply_fractal_noise(self.heightmap, scale, (0, 0), octaves, persistence, lacunarity)

    def place_elements(self):
        """Places terrain elements on the world map."""
        # ToDo: Implement logic to place terrain elements based on heightmap, terrain depth, and length
        # ...

    def load_png_colors(self, png_file):
        """Loads a PNG file and assigns colors to each Voronoi region."""
        # Load the image
        img = Image.open(png_file)
        
        # Resize image to match world size
        img = img.resize(self.size)

        # Convert image to a numpy array
        img_data = np.array(img)
        
        # For each Voronoi region
        for region in self.regions:
            # Convert region centroid to integer pixel coordinates
            coordinates = tuple(map(int, region.centroid))
            
            # Assign color from the corresponding pixel in the image
            region.color = img_data[coordinates]

    def fill_empty_regions(self, burn_rate):
        """Fills empty regions by iteratively edge bleeding colors at the color's burn rate."""
        # Iterate over each Voronoi region
        for region in self.regions:
            # If the region is empty
            if region.color is None:
                # Get neighboring regions
                neighbors = get_neighbors(region)
                
                # Iterate over each neighbor
                for neighbor in neighbors:
                    # If the neighbor has a color, bleed it into the current region
                    if neighbor.color is not None:
                        region.color = neighbor.color * burn_rate
                        break


    def fill_empty_regions(self, burn_rate):
        """Fills empty regions by performing eight direction passes in random order."""
        # Define eight direction kernels
        kernels = [
            [[0, 0, 0], [0, 0, 1], [0, 0, 0]],  # Right
            [[0, 0, 0], [1, 0, 0], [0, 0, 0]],  # Left
            [[0, 0, 0], [0, 0, 0], [0, 1, 0]],  # Down
            [[0, 1, 0], [0, 0, 0], [0, 0, 0]],  # Up
            [[0, 0, 1], [0, 0, 0], [0, 0, 0]],  # Diagonal Top Right
            [[1, 0, 0], [0, 0, 0], [0, 0, 0]],  # Diagonal Bottom Left
            [[0, 0, 0], [0, 0, 0], [1, 0, 0]],  # Diagonal Bottom Right
            [[0, 0, 0], [0, 0, 1], [0, 0, 0]]   # Diagonal Top Left
        ]

        # Perform passes in random order
        random.shuffle(kernels)

        for kernel in kernels:
            # Perform a convolution with the current kernel
            convolved = convolve(self.region_colors, kernel)

            # Create a mask where the original region color is None
            mask = np.isnan(self.region_colors)

            # Apply the convolution result to the original color array, using the mask
            self.region_colors[mask] = convolved[mask]

            # Blend other areas according to the burn rate
            self.region_colors[~mask] = (
                burn_rate * self.region_colors[~mask] 
                + (1 - burn_rate) * convolved[~mask]
            )

        # Normalize color values to ensure they stay in range
        self.region_colors = np.clip(self.region_colors, 0, 1)


def generate_world(world_size=(65536, 65536), num_points=500):
    """Generates a world map."""
    world = World(world_size)
    world.generate_regions(num_points)
    world.apply_perlin_noise()
    world.place_elements()
    return world
