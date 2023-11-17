# Welcome To WorldGen

Worldgen is a tool, which will take a png image, and use it to seed the landscape for a world simulation.

## Specifications
- Python 3.9
- pygame
- noise
- numpy
- scipy
- scikit-learn
- scikit-image
- pandas
- matplotlib

## Application
Render all nodes of the world based on their current state, ability to zoom in and move the viewport, ability to click on a square and see it's various map values.  A top bar, with an iteration counter and speed controls on the right side.  The left side will have the world name 'Pinnacle', and a drop down menu to load an image.

## Algorithm

The goal of the algorithm being a world system, the outputs of the algorithm consists of:
- A biome map
- A heightmap
- A temperature map
- A humidity map
- A water depth map
- A water flow map
- A surface water map
- A vegetation map

The process of the algorithm is as follows:
- Read the image
- Create a biome map from the image using voronoi cells
- Use the biome map to seed the heightmap
- Apply perlin noise to the heightmap to create a more natural look
- Apply spectral synthesis to the heightmap to create a more natural look
- Use the biome map to seed the temperature, humidity and water depth maps
- Calculating the water flow from the height, temperature, humidity and water depth maps, iteratively apply erosion to the heightmap (for N iterations)
- Using water flow, find basins and fill to create the surface water map
- Fix the biome map to account for the new heightmap and surface water map
- Using the biome map, temperature, humidity and surface water maps, seed the vegetation map
- Simulate the vegetation map growth for N iterations
- Simulate the entire world for N iterations, until the world is stable

## Resources
https://en.wikipedia.org/wiki/Procedural_generation

https://huemint.com/