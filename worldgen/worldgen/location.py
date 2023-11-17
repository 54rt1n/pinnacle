# worldgen/location.py

import noise
import numpy as np
from scipy.spatial import Voronoi
import random
from scipy.ndimage import gaussian_filter
from scipy.signal import convolve
from scipy.spatial import distance

from scipy.ndimage import label, generate_binary_structure

def level_set_leveling(heightmap, num_levels, scale):
    """Apply leveling using level sets (contour lines of constant height)"""
    width, height = heightmap.shape
    leveled_heightmap = np.copy(heightmap)

    # Create a histogram of the heightmap values
    histogram, bin_edges = np.histogram(heightmap, bins=num_levels)
    
    # Create level sets by labeling each bin
    for i in range(1, num_levels):
        lower, upper = bin_edges[i-1], bin_edges[i]
        level_mask = (lower <= heightmap) & (heightmap < upper)

        # Label each contiguous area within the level set
        structure = generate_binary_structure(2, 2)  # 2D connectivity
        labeled, num_features = label(level_mask, structure=structure)
        
        # Adjust each point in the labeled area towards the mean
        for feature in range(1, num_features+1):
            feature_mask = labeled == feature
            feature_values = heightmap[feature_mask]
            mean = np.mean(feature_values)

            # Adjust each point in the feature towards the mean
            for j in range(width):
                for k in range(height):
                    if feature_mask[j][k]:
                        difference = heightmap[j][k] - mean
                        leveled_heightmap[j][k] -= difference * scale

    return leveled_heightmap


def generate_voronoi_noise_map(width, height, num_cells):
    """Generate a Voronoi-based noise map."""
    # Generate a set of random points within the map
    points = np.random.rand(num_cells, 2) * [width, height]
    
    # Create an empty array for the noise map
    noise_map = np.zeros((width, height))
    
    # For each pixel in the map, calculate its distance to the nearest Voronoi point
    for i in range(width):
        for j in range(height):
            distances = distance.cdist([(i, j)], points, 'euclidean')
            noise_map[i][j] = np.min(distances)
            
    # Normalize the noise map to the range [0, 1]
    noise_map = (noise_map - np.min(noise_map)) / (np.max(noise_map) - np.min(noise_map))
    
    return noise_map

def gaussian_smooth(noise_map, sigma=1):
    """Apply Gaussian smoothing to the noise map."""
    return gaussian_filter(noise_map, sigma=sigma)

def average_smooth(noise_map, kernel_size=3):
    """Apply average smoothing to the noise map."""
    kernel = np.full((kernel_size, kernel_size), 1.0 / (kernel_size**2))
    return convolve(noise_map, kernel, mode='same')

def apply_leveling(heightmap, clusters, scale):
    """Use the clusters to level the heightmap in each cluster towards the median"""
    width, height = heightmap.shape
    leveled_heightmap = np.copy(heightmap)

    for cluster_idx in np.unique(clusters):
        cluster_mask = clusters == cluster_idx
        cluster_values = heightmap[cluster_mask]
        median = np.median(cluster_values)

        # Adjust each point in the cluster towards the median
        for i in range(width):
            for j in range(height):
                if cluster_mask[i][j]:
                    difference = heightmap[i][j] - median
                    leveled_heightmap[i][j] -= difference * scale

    return leveled_heightmap

def apply_fractal_noise(heightmap, scale, octaves, persistence, lacunarity, noise_map):
    """Apply fractal noise to the heightmap."""
    width, height = heightmap.shape
    
    for i in range(width):
        for j in range(height):
            # Apply fractal noise by adding more perlin noise
            heightmap[i][j] += noise.pnoise2(i, j, 
                                            octaves=octaves, 
                                            persistence=persistence, 
                                            lacunarity=lacunarity) * scale
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

class Location:
    DEFAULT_CONFIG = {
        'size': (128, 128),
        'noise_scale': 1,
        'octaves': 6,
        'persistence': 0.5,
        'lacunarity': 2.0,
        'num_biomes': 5,
        'num_towns': 10,
        'num_buildings': 50,
        'smoothing_factor': 1.0,
        'temperature': 76,
        'humidity': .40,
        'seed': 42,
    }

    def __init__(self, width, height, **kwargs):
        self.width = width
        self.height = height

        # Assign all additional parameters from the config
        for param, default in self.DEFAULT_CONFIG.items():
            setattr(self, param, kwargs.get(param, default))

        print(f'Generating location with size {self.width}x{self.height}.  Seed: {self.seed}')
        # Set the seed for random functions
        np.random.seed(self.seed)
        random.seed(self.seed)

    @classmethod
    def from_config(cls, config):
        # Merge the given config with the default one
        merged_config = {**cls.DEFAULT_CONFIG, **config}
        u, v = merged_config['size']
        return cls(u, v, **merged_config)

    def generate(self, smoothing_func=gaussian_smooth, variability=.5):
        # Generate a Voronoi-based noise map
        num_voronoi_cells = int((self.width ** 2 + self.height ** 2) // 8)
        print(f'Generating Voronoi noise map with {num_voronoi_cells} cells')
        heightmap = generate_voronoi_noise_map(self.width, self.height, num_voronoi_cells)
        #heightmap = average_smooth(heightmap)

        # Apply smoothing
        noise_map = np.random.rand(self.width, self.height)
        #noise_map = np.zeros((self.width, self.height))
        noise_map = gaussian_smooth(noise_map)

        #heightmap = self.generate_heightmap(self.width, self.height, self.scale, self.octaves, self.persistence, self.lacunarity, smoothed_noise_map)
        clusters = self.generate_voronoi(heightmap, 5)

        #heightmap = level_set_leveling(heightmap, 2, .7)
        #heightmap = gaussian_smooth(heightmap)
        #heightmap = level_set_leveling(heightmap, 5, 1)
        heightmap = apply_fractal_noise(heightmap, self.noise_scale, self.octaves, self.persistence, self.lacunarity, 1- heightmap)
        #heightmap = gaussian_smooth(heightmap)

        biomes = generate_biomes(heightmap, self.num_biomes)

        return { 'heightmap': heightmap, 'biomes': biomes }


    def generate_voronoi(self, heightmap, num_biomes):
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
