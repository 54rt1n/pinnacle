# This cell is used for imports and setup

%matplotlib inline
import matplotlib.pyplot as plt
from matplotlib.patches import Circle

import numpy as np
import random
import worldgen.heightmap as wh

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

def config_gen(seed=None):
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
        'num_towns': 1,
        'num_buildings': 50,
        'smoothing_factor': 1.0,
        'temperature': 76,
        'humidity': .40,
        'seed': seed,
        'scale': .03,
        'xoffset': random.randint(0, 100000),
        'yoffset': random.randint(0, 100000),
    }

    cfg = wh.zoom_center(**cfg)
    return cfg

config = config_gen()
# Nine cardinal directions
yc = 9
xc = len(windows) * 2
fig, ax = plt.subplots(xc, yc, figsize=(10, xc * 2))
width, height = config['size']
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
for i, (octaves, scale, lacunarity, persistence) in enumerate(windows):
    config['lacunarity'] = lacunarity
    config['persistence'] = persistence
    config['scale'] = scale
    config['octaves'] = octaves
    v = 0

    for d in directions.keys():
        a, b = directions[d]
        heightmap = wh.init_heightmap(**config)
        heightmap = wh.for_direction(heightmap, d, i, **config)
        tiermap = wh.generate_tiers(heightmap, **config)
        ratio, min, max, mean, std = wh.get_stats(heightmap, **config)
        #u = i // yc
        ax[i * 2, v].imshow(tiermap, cmap='terrain')
        ax[i * 2 + 1, v].imshow(heightmap, cmap='terrain')
        #ax[u * 2 + 1, v].imshow(tiers, cmap='terrain')
        ax[i * 2, v].set_title(f'({a}, {b}) {ratio:.0f}')
        #ax[i, v].set_title(f'({a}, {b}) {scale:.3f} {octaves} {ratio:.0f}')
        v += 1
    
plt.show()

