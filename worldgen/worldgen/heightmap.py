# worldgen/heightmap.py

import math
import noise
import numpy as np
import random

def init_heightmap(size, **kwargs):
    """Initializes a 2D numpy array of a given size with zeros."""
    world = np.zeros(size)
    
    return world

# Some notes on fractal noise
# Perlin noise is very interesting.  It is a fractal, so we shift around in that space
# to capture smooth forms.  You navigate using the xoffset and yoffset.
# The relationship between scale and octaves is interesting.  The scale is the zoom, and
# octaves is the perturbation.  The higher the octaves, the more detail you get,
# but it requires you zoom in or the noise level is too high.

def create_perlin(shape : tuple, center : tuple,
                  octaves : int, scale : float, persistence : float, lacunarity : float,
                  ioffset : int = 0, joffset : int = 0, **kwargs):
    """Applies Perlin noise to a given heightmap."""
    width, height = shape
    heightmap = np.zeros(shape, dtype=np.float32)

    for i in range(width):
        for j in range(height):
            # Apply fractal noise by adding more perlin noise
            heightmap[i][j] += noise.pnoise2((i - width // 2 + ioffset) * scale + center[0], 
                                             (j - height // 2 + joffset) * scale + center[1], 
                                             octaves=octaves, 
                                             persistence=persistence, 
                                             lacunarity=lacunarity)
    return heightmap

def apply_fractal_noise(heightmap : np.ndarray, center : tuple,
                        octaves : int, scale : float, persistence : float, lacunarity : float,
                        weight : float = 1.0,
                        ioffset : int = 0, joffset : int = 0,
                        **kwargs):
    """Applies Perlin noise to a given heightmap."""
    width, height = heightmap.shape

    for i in range(width):
        for j in range(height):
            # Apply fractal noise by adding more perlin noise
            heightmap[i][j] += noise.pnoise2((i - width // 2 + ioffset) * scale + center[0], 
                                             (j - height // 2 + joffset) * scale + center[1], 
                                             octaves=octaves, 
                                             persistence=persistence, 
                                             lacunarity=lacunarity) * weight
    return heightmap

def gradient_mask(size, radius = 48, **kwargs):
    """Generates a 2D mask that applies a gradient from the center to the edges of the given size."""
    # Create a 2D array with zeros
    arr = np.zeros(size)
    width, height = size

    # Create a meshgrid of x and y coordinates
    x, y = np.meshgrid(np.arange(width), np.arange(height))

    # Calculate the distance from the center of the array
    dist = np.sqrt((x - width // 2)**2 + (y - height // 2)**2)

    # Set the values inside the circle to 1
    arr[dist < radius] = 1

    # Set the values outside the circle to 0
    arr[dist >= radius] = 0
    return arr

def center(octaves=1, **kwargs):
    """Finds the center of a given heightmap by using the peak of the weighted heightmap."""
    width, height = kwargs['size']
    scale = kwargs['scale']
    xoffset, yoffset = kwargs['center']
    heightscan = init_heightmap(**kwargs)
    heightscan = apply_fractal_noise(heightscan, octaves=octaves, **kwargs)

    # Create a 2D Gaussian weight mask
    weight_mask = gradient_mask(**kwargs)

    # Apply the weight mask to the heightmap
    maskscan = heightscan * weight_mask

    # Find the indices of the maximum and minimum values
    max_index = np.unravel_index(maskscan.argmax(), maskscan.shape)
    #min_index = np.unravel_index(maskscan.argmin(), maskscan.shape)

    target = max_index
    # Update the xoffset and yoffset based on the maximum value
    xoffset -= (width // 2 - target[0]) * scale
    yoffset -= (height // 2 - target[1]) * scale

    return [(xoffset, yoffset), (target[0], target[1])]

def get_stats(heightmap, **kwargs):
    """Returns the statistics of a given heightmap, including the percentage of positive values, min, max, mean, and standard deviation."""
    hmv_x = heightmap > .025
    ratio = hmv_x.sum() / hmv_x.size * 100
    return ratio, heightmap.min(), heightmap.max(), heightmap.mean(), heightmap.std()

def zoom_center(**kwargs):
    """Zooms into the center of a given heightmap until it reaches a certain threshold."""
    threshold = 2
    octaves = 2
    radius = 96
    xoffset, yoffset = kwargs['xoffset'], kwargs['yoffset']
    kwargs['center'] = (xoffset, yoffset)
    while True:
        (xoffset, yoffset), (xpeak, ypeak) = center(octaves=octaves, **kwargs)
        width, height = kwargs['size']
        d = ((xpeak - width // 2)**2 + (ypeak - height // 2)**2)**.5
        if d < threshold:
            break
        kwargs['center'] = (xoffset, yoffset)
        threshold += 1
        radius /= 1.3
    return kwargs

def generate_thresholds(heightmap, lam, num_bins):
    """Generates an array of threshold values based on the heightmap values using an exponential distribution."""
    # Flatten the heightmap values into 1D array
    flat_heightmap = heightmap.flatten()

    # Sort the heightmap values
    sorted_heightmap = np.sort(flat_heightmap)
    sorted_heightmap = sorted_heightmap[::-1]

    # Calculate the threshold values using an exponential distribution
    thresholds = [sorted_heightmap[int(np.ceil(len(sorted_heightmap) * (1 - np.exp(-i / lam))))] for i in range(num_bins)]
    # Calculate the threshold values using a standard normal distribution
    #thresholds = [sorted_heightmap[int(np.ceil(len(sorted_heightmap) * (1 - norm.cdf(i, scale=lam))))] for i in range(num_bins)]
    thresholds = thresholds[::-1]
    thresholds.append(np.inf)

    return thresholds

def for_direction(heightmap : np.ndarray, d : str, w : int, **kwargs):
    """Applies noise to a heightmap in a given direction."""
    windows = [
        [1, .012, 2, .5],
        [1, .010, 3, .5],
        [1, .008, 4, .5],
        [1, .007, 4, .6],

        [2, .005, 3, .4],
        [2, .004, 4, .5],
        [2, .004, 5, .7],
        [2, .003, 6, .8],
        
        [3, .0035, 4, .5],
        [3, .003, 4, .5],
        [3, .0025, 4, .5],
        [3, .002, 4.5, .6],
        
        [4, .003, 3, .7],
        [4, .001, 4.5, .7],
        [4, .001, 4.5, .7],
        [5, .0111, 2, .4],
    ]
    directions = {
        'NW': (-1, -1),
        'N': (0, -1),
        'NE': (1, -1),
        'W': (-1, 0),
        'C': (0, 0),
        'E': (1, 0),
        'SW': (-1, 1),
        'S': (0, 1),
        'SE': (1, 1),
    }
    a, b = directions[d]
    window = windows[w]
    config = kwargs
    octaves, scale, lacunarity, persistence = window
    config['octaves'] = octaves
    config['scale'] = scale
    config['lacunarity'] = lacunarity
    config['persistence'] = persistence
    width, height = kwargs['size']
    ioffset = -a * width // 2
    joffset = -b * height // 2

    return apply_fractal_noise(heightmap, ioffset = ioffset, joffset = joffset, **config)

def apply_gaussian_noise(heightmap, center_a, center_b,
                         octaves, scale, persistence, lacunarity,
                         ioffset=0, joffset=0,
                         **kwargs):
    """Apply Gaussian noise to the heightmap."""
    width, height = heightmap.shape
    offset = 1e-7

    for i in range(width):
        for j in range(height):
            # Generate two independent layers of Perlin noise
            u1 = noise.pnoise2((i - width // 2 + ioffset) * scale + center_a[0], 
                               (j - height // 2 + joffset) * scale + center_a[1], 
                               octaves=octaves, 
                               persistence=persistence, 
                               lacunarity=lacunarity)
            u2 = noise.pnoise2((i - width // 2 + ioffset) * scale + center_b[0], 
                               (j - height // 2 + joffset) * scale + center_b[1],
                               octaves=octaves, 
                               persistence=persistence, 
                               lacunarity=lacunarity)

            # Remap the Perlin noise output to the range (0, 1)
            u1 = (u1 + 1) / 2.0
            u2 = (u2 + 1) / 2.0
            
            # Apply a small offset to ensure that u1 and u2 are within the range (0, 1)
            u1 = np.clip(u1, offset, 1 - offset)
            u2 = np.clip(u2, offset, 1 - offset)

            # Apply the Box-Muller transform to generate Gaussian noise
            gaussian_noise = math.sqrt(-2 * math.log(u1)) * math.cos(2 * math.pi * u2)

            # Apply the Gaussian noise to the heightmap
            heightmap[i][j] += gaussian_noise

    return heightmap

def generate_tiers_alt(heightmap, num_tiers, **kwargs):
    """Generate tiers based on the heightmap."""
    tier_thresholds = generate_thresholds(heightmap, kwargs.get('tier_lambda', 0.5), kwargs.get('num_tiers', 5))
    tier_thresholds.append(np.inf)

    # Assign each point in the heightmap to a tier based on its height
    tiers = np.zeros(heightmap.shape)
    for i in range(heightmap.shape[0]):
        for j in range(heightmap.shape[1]):
            set = False
            for b in range(num_tiers):
                if heightmap[i][j] <= tier_thresholds[b]:
                    tiers[i][j] = b
                    set = True
                    break
            if not set:
                tiers[i][j] = num_tiers

    return tiers

def generate_tiers(heightmap, **kwargs):
    hmv_d = heightmap > -1
    hmv_e = heightmap > -.7
    hmv_f = heightmap > -.6
    hmv_g = heightmap > -.5
    hmv_h = heightmap > -.4
    hmv_i = heightmap > -.3
    hmv_j = heightmap > -.2
    hmv_k = heightmap > -.1
    hmv_l = heightmap > -.025
    hmv_m = heightmap > 0
    hmv_n = heightmap > .025
    hmv_o = heightmap > .1
    hmv_p = heightmap > .2
    hmv_q = heightmap > .3
    hmv_r = heightmap > .4
    hmv_s = heightmap > .5
    hmv_t = heightmap > .6
    hmv_u = heightmap > .7
    hmv_v = heightmap > 1
    
    hmx = np.zeros_like(heightmap, dtype=np.int32)
    
    for i, mask in enumerate([
        hmv_d,
        hmv_e, hmv_f, hmv_g, hmv_h, hmv_i, hmv_j, hmv_k, hmv_l,
        hmv_m,
        hmv_n, hmv_o, hmv_p, hmv_q, hmv_r, hmv_s, hmv_t, hmv_u,
        hmv_v
        ]):
        hmx[mask] = i

    return hmx

def config_gen(seed=None, **kwargs):
    if seed is None:
        seed = random.randint(0, 2**32)

    np.random.seed(seed)
    random.seed(seed)

    cfg = {
        'size': (256, 256),
        'noise_scale': 1,
        'persistence': 0.5,
        'lacunarity': 4.0,
        'num_tiers': 5,
        'tier_lambda': 5,
        #'num_towns': 1,
        #'num_buildings': 50,
        'smoothing_factor': 1.0,
        #'temperature': 76,
        #'humidity': .40,
        'seed': seed,
        'scale': .03,
        'xoffset': random.randint(0, 100000),
        'yoffset': random.randint(0, 100000),
        **kwargs
    }

    cfg = zoom_center(**cfg)
    return cfg