# worldgen/terrain.py

import noise
import numpy as np
from scipy.spatial import Voronoi

def generate_heightmap(size, scale, octaves, persistence, lacunarity):
    """Generate a heightmap using Perlin noise."""
    width, height = size
    world = np.zeros(size)
    
    for i in range(width):
        for j in range(height):
            world[i][j] = noise.pnoise2(i/scale, 
                                        j/scale, 
                                        octaves=octaves, 
                                        persistence=persistence, 
                                        lacunarity=lacunarity)
    return world

def apply_fractal_noise(heightmap, scale, octaves, persistence, lacunarity):
    """Apply fractal noise to the heightmap."""
    width, height = heightmap.shape
    
    for i in range(width):
        for j in range(height):
            # Apply fractal noise by adding more perlin noise
            heightmap[i][j] += noise.pnoise2(i/scale, 
                                             j/scale, 
                                             octaves=octaves, 
                                             persistence=persistence, 
                                             lacunarity=lacunarity)
    return heightmap

def generate_biomes(heightmap, num_biomes):
    """Generate biomes based on the heightmap."""
    # Flatten the heightmap values into 1D array
    flat_heightmap = heightmap.flatten()

    # Sort the heightmap values and split into equal parts
    sorted_heightmap = np.sort(flat_heightmap)
    biome_thresholds = np.array_split(sorted_heightmap, num_biomes)
    
    # Assign each point in the heightmap to a biome based on its height
    biomes = np.zeros(heightmap.shape)
    for i in range(heightmap.shape[0]):
        for j in range(heightmap.shape[1]):
            for b in range(num_biomes):
                if heightmap[i][j] <= biome_thresholds[b][-1]:
                    biomes[i][j] = b
                    break
                    
    return biomes

def generate_biomes_voronoi(heightmap, num_biomes):
    """Generate biomes based on Voronoi cells."""
    width, height = heightmap.shape

    # Generate a set of random points within the map
    points = np.random.rand(num_biomes, 2) * [width, height]

    # Create Voronoi diagram from points
    vor = Voronoi(points)

    # Create an empty array for biomes
    biomes = np.zeros((width, height))

    # Assign each pixel to the biome of the nearest Voronoi point
    for i in range(width):
        for j in range(height):
            # Calculate distances to Voronoi points
            distances = np.linalg.norm(points - [i, j], axis=1)

            # Assign pixel to biome of nearest Voronoi point
            biomes[i, j] = np.argmin(distances)

    return biomes