# WorldGen
Worldgen is an application, and worshipped by the Cult of Order.

## Algorithm
Our terrain generation algorithm involves two major steps: creation of a base heightmap and adding various features to this heightmap.

### Heightmap
We begin by creating a base heightmap for our terrain using Perlin noise. This is a type of gradient noise that produces natural-looking terrain shapes. We scale the Perlin noise according to the size of our world image and apply it to a grid that represents our terrain. We repeat this process with different parameters to create a fractal landscape, adding together several layers of Perlin noise with different wavelengths and amplitudes.

We will use a 512x512 pixel image of our world as the base. Each pixel in this image represents a 128x128 area in our actual world, resulting in a final world size of 65536x65536.

### Features
To add diversity and realism to our terrain, we overlay different features onto our base heightmap. This includes bodies of water, forests, mountains, etc. These features are determined by analyzing the colors in the world image. We will use Voronoi diagrams to create softer transitions between different terrain types and features.

To manage the vast number of patches that need to be transformed, we could employ a patch management strategy. One way could be to only load and generate terrain for the area currently visible or interacted with (chunk system). This way, we can handle a virtually infinite world while only keeping a small portion of it in memory at any given time.

Another strategy could be the use of procedural generation, where we generate the terrain on the fly as needed, rather than storing an entire pre-generated world. This allows us to have a potentially infinite world with a small memory footprint.

### Climate
We simulate our climate to grow forests and fields. For each patch of terrain, we calculate the average temperature based on the terrain type, height, and latitude.

### Conclusion
The combination of Perlin noise for base terrain generation, Voronoi diagrams for feature boundaries, and climate simulations for feature growth, along with the use of procedural generation techniques and patch management, allows us to create a diverse, rich, and virtually infinite world for our game. We hope that this document provides a comprehensive overview of the world generation algorithm and its implementation.

# Updated Algorithm
The terrain generation algorithm for our world-building application involves three key steps:

- Generating Voronoi diagram for 65536x65536 world map, and applying the world image to create regional areas, and boundary areas.
  - Each region will have a terrain depth value, which represents how close the closest non-same terrain type is to the region.
  - Each region will have a terrain length value, which represents the furthest consecutive same terrain type to the region.
  - These measures will be used to determine the terrain density of the region, and applied to shape the heightmap and determine what type of patches to use to share the features.
  - Particular terrain types of large or small length and depth will be used to determine the center of features, such as the location of riverheads, shoreline, forest centers, and mountaintops.
- Applying Perlin noise to add more detail and features.
  - Various layers of perlin noise will be used to transform the landscape.
  - Large height-centered noise patches will be applied to center of features such as mountians, at a scale large enough to encompass the entire feature is used to shape the features, weighted by the density.
  - Small, height-aligned to the change in elevation, noise patches will be applied to boundary areas to create the edge of the biomes.
  - Noise will be applied in smaller patches to shape features in the terrain.  There may be various methods for doing this, such as random walk, or a more complex method that uses the terrain depth and length to determine the shape and weight of the feature.
- Terrain elements
  - From the heightmap, biome type, terrain depth, and terrain length will be used to determine the roughness of the terrain, and various rules will be applied to place terrain elements such as trees, rocks, and grass.


The terrain generation algorithm for our world-building application involves three key steps:

- Generating Voronoi diagram for 65536x65536 world map, and applying the world image to create regional areas, and boundary areas.
  - Each region will have a terrain depth value, which represents how close the closest non-same terrain type is to the region.
  - Each region will have a terrain length value, which represents the furthest consecutive same terrain type to the region.
  - These measures will be used to determine the terrain density of the region, and applied to shape the heightmap and determine what type of patches to use to share the features.
  - Particular terrain types of large or small length and depth will be used to determine the center of features, such as the location of riverheads, shoreline, forest centers, and mountaintops.
- Applying Perlin noise to add more detail and features.
  - Various layers of perlin noise will be used to transform the landscape.
  - Large height-centered noise patches will be applied to center of features such as mountians, at a scale large enough to encompass the entire feature is used to shape the features, weighted by the density.
  - Small, height-aligned to the change in elevation, noise patches will be applied to boundary areas to create the edge of the biomes.
  - Noise will be applied in smaller patches to shape features in the terrain.  There may be various methods for doing this, such as random walk, or a more complex method that uses the terrain depth and length to determine the shape and weight of the feature.
- Terrain elements
  - From the heightmap, biome type, terrain depth, and terrain length will be used to determine the roughness of the terrain, and various rules will be applied to place terrain elements such as trees, rocks, and grass.
  
## Considerations
  - The result will be an 65536x65536 Int grid.  That is 4,294,967,296 Ints.  At 4 bytes per Int, that is 16,777,215,744 bytes, or 15.6 GB.  This is too large to store in memory, so we will need to use a patch management strategy to only load and generate terrain for the area currently visible or interacted with (chunk system).

  # Updated Algorithm

The terrain generation algorithm for our world-building application involves three key steps:

## Generating Voronoi Diagram

Our algorithm begins with generating a Voronoi diagram for a 65536x65536 world map and mapping the world image to create defined regional and boundary areas. For each region, we compute two key properties:

- **Terrain Depth**: A value indicating the proximity of the closest different terrain type.
- **Terrain Length**: A value reflecting the furthest stretch of similar terrain type.

These properties contribute to the determination of terrain density, which is instrumental in shaping the heightmap and deciding the type of patches used to add features. Certain terrain types, particularly those with long or short lengths and depths, are crucial in defining the center of unique features, including the origin of rivers, shorelines, forest centers, and mountain peaks.

## Applying Perlin Noise

Next, we use various scales of Perlin noise to transform the landscape and create more detail.

- **Large-scale Noise**: We apply broad, height-centered noise patches to central features, such as mountains. The scale is sufficiently large to encompass the entire feature, and the noise is weighted by the terrain density.
- **Small-scale Noise**: We introduce smaller, height-aligned noise patches along boundary areas to create biome edges.
- **Fine-detail Noise**: We use smaller patches of noise to add texture to the terrain, creating a more naturalistic feel. This process can involve a simple random walk or a more complex method factoring in terrain depth and length to determine feature shape and weight.

## Terrain Elements Placement

From the created heightmap, biome type, terrain depth, and terrain length, we derive a roughness value for the terrain. With this, we apply various rules to place terrain elements such as trees, rocks, and grass. These elements add realism and complexity to the landscape, enhancing the player's experience in the world.

In conclusion, through intelligent use of Voronoi diagrams, Perlin noise, and element placement rules, we can create diverse, intriguing landscapes that promote immersive exploration and interaction.
