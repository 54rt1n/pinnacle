# worldgen/visualization.py

import matplotlib.pyplot as plt
import matplotlib.colors as mcolors
from matplotlib.ticker import MultipleLocator
import numpy as np
import pandas as pd

def visualize_heightmap(heightmap):
    pass

def visualize_towns(town_locations):
    pass

def visualize_structures(building_locations):
    pass

def colormap_biomes(biomes : pd.DataFrame) -> mcolors.ListedColormap:
    """
    Creates a colormap using the RGB values of the biomes.

    Args:
    - biomes (pandas.DataFrame): A DataFrame containing the RGB values of each biome.

    Returns:
    - cmap (matplotlib.colors.ListedColormap): A colormap created using the RGB values of the biomes.
    """
    num_labels = len(biomes)
    num_colors = 3

    colors = np.zeros((num_labels, num_colors))
    colors = biomes[biomes.index != 0][['R', 'G', 'B']].values / 255.0

    # Create a colormap using the RGB values
    return mcolors.ListedColormap(colors)

def visualize_biomes(world, biomes, base):
    cmap = colormap_biomes(biomes)
    plt.imshow(world['label'].values.reshape(base, base, 1), cmap=cmap)
    plt.colorbar()

def visualize_voronoi(polygons : list, zone_map : np.ndarray, biomes : pd.DataFrame, window_size : int):
    fig, ax = plt.subplots(figsize=(16, 16))
    for i, polygon in enumerate(polygons):
        x, y = polygon.boundary.xy
        center = (np.mean(x), np.mean(y))

        # for each boundary point, get the color of the pixel at that point
        #boundary_zone = [zone_map[int(x[i] * (window_size - 1)), int(y[i] * (window_size - 1))] for i in range(len(x))]
        # get the color of the pixel at the center of the polygon
        center_zone = zone_map[int(center[0] * (window_size - 1)), int(center[1] * (window_size - 1))]

        #zones = [center_zone] + boundary_zone
        #zones = np.array(zones)
        # find the most common zone type
        #zone = np.bincount(zones.ravel()).argmax()

        # This works better than the above
        color = biomes.loc[center_zone].values / 255
        
        # Fill the polygon
        ax.fill(y, x, alpha=0.5, fc=color, ec='none')

    #ax.axis('off')
    ax.set_xlim(0, 1)
    ax.set_ylim(0, 1)
    ax.set_aspect('equal')

    # Set the major and minor ticks for the x and y axes
    major_locator = MultipleLocator(1 / window_size * 8)
    minor_locator = MultipleLocator(1 / window_size)
    ax.xaxis.set_major_locator(major_locator)
    ax.xaxis.set_minor_locator(minor_locator)
    ax.yaxis.set_major_locator(major_locator)
    ax.yaxis.set_minor_locator(minor_locator)

    # Set the gridlines for the x and y axes
    ax.grid(which='major', color='black', linestyle='-', linewidth=1)
    ax.grid(which='minor', color='black', linestyle='--', linewidth=0.5)

    # plt.savefig("test2.png", bbox_inches='tight', pad_inches=0, dpi=300)
    ax.grid(True, color='black', linestyle='-', linewidth=1)

    fig.show()

def visualize_zones(zone_map : np.ndarray, biomes : pd.DataFrame, window_size : int, figsize=(16, 16)):
    my_map = zone_map.copy()[::-1, ::]
    fig, ax = plt.subplots(figsize=figsize)
    biome_count = len(biomes) - 1
    cmap = colormap_biomes(biomes)
    my_map[-1, -biome_count-1:-1] = biomes.index.values[:-1]

    ax.imshow(my_map, cmap=cmap)
    u, v, = my_map.shape

    #ax.axis('off')
    ax.set_xlim(0, u)
    ax.set_ylim(0, v)
    ax.set_aspect('equal')

    # Set the major and minor ticks for the x and y axes
    major_locator = MultipleLocator(u / window_size * 8)
    minor_locator = MultipleLocator(u / window_size)
    ax.xaxis.set_major_locator(major_locator)
    ax.xaxis.set_minor_locator(minor_locator)
    ax.yaxis.set_major_locator(major_locator)
    ax.yaxis.set_minor_locator(minor_locator)

    # Set the gridlines for the x and y axes
    ax.grid(which='major', color='black', linestyle='-', linewidth=1)
    ax.grid(which='minor', color='black', linestyle='--', linewidth=0.5)

    # plt.savefig("test2.png", bbox_inches='tight', pad_inches=0, dpi=300)
    ax.grid(True, color='black', linestyle='-', linewidth=1)

    fig.show()