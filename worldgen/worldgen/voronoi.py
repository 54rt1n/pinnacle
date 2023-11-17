import numpy as np
import pandas as pd
import rasterio.features
from scipy.ndimage import gaussian_laplace, binary_dilation
from scipy.spatial import Voronoi
from shapely.affinity import scale
from shapely.geometry import Polygon
from typing import List

from .image import patch

def get_voronoi(n: int) -> tuple[np.ndarray, Voronoi]:
    """
    Generates a set of random points and computes the Voronoi diagram for these points.

    Args:
        n (int): The number of random points to generate.

    Returns:
        tuple[np.ndarray, Voronoi]: A tuple containing the generated points and the Voronoi diagram computed from these points.
    """
    points = np.random.rand(n, 2)
    vor = Voronoi(points)
    return points, vor

def voronoi_finite_polygons_2d(vor, radius=None) -> tuple[list, np.ndarray]:
    """
    Reconstructs a set of non-finite Voronoi regions from a given Voronoi diagram.

    Args:
        vor (Voronoi): The Voronoi diagram to reconstruct non-finite regions from.
        radius (float, optional): The radius of the bounding circle. Defaults to None.

    Returns:
        tuple[list, np.ndarray]: A tuple containing the reconstructed regions and vertices.
    """
    if vor.points.shape[1] != 2:
        raise ValueError("Requires 2D input")

    new_regions = []
    new_vertices = vor.vertices.tolist()

    center = vor.points.mean(axis=0)
    if radius is None:
        radius = vor.points.ptp().max()

    # Construct a map containing all ridges for a given point
    all_ridges = {}
    for (p1, p2), (v1, v2) in zip(vor.ridge_points, vor.ridge_vertices):
        all_ridges.setdefault(p1, []).append((p2, v1, v2))
        all_ridges.setdefault(p2, []).append((p1, v1, v2))

    # Reconstruct infinite regions
    for p1, region in enumerate(vor.point_region):
        vertices = vor.regions[region]

        if all(v >= 0 for v in vertices):
            # finite region
            new_regions.append(vertices)
            continue

        # reconstruct a non-finite region
        ridges = all_ridges[p1]
        new_region = [v for v in vertices if v >= 0]

        for p2, v1, v2 in ridges:
            if v2 < 0:
                v1, v2 = v2, v1
            if v1 >= 0:
                # finite ridge: already in the region
                continue

            # Compute the missing endpoint of an infinite ridge
            t = vor.points[p2] - vor.points[p1] # tangent
            t /= np.linalg.norm(t)
            n = np.array([-t[1], t[0]])  # normal

            midpoint = vor.points[[p1, p2]].mean(axis=0)
            direction = np.sign(np.dot(midpoint - center, n)) * n
            far_point = vor.vertices[v2] + direction * radius

            new_region.append(len(new_vertices))
            new_vertices.append(far_point.tolist())

        # Sort region counterclockwise.
        vs = np.asarray([new_vertices[v] for v in new_region])
        c = vs.mean(axis=0)
        angles = np.arctan2(vs[:,1] - c[1], vs[:,0] - c[0])
        new_region = np.array(new_region)[np.argsort(angles)]

        # Finish
        new_regions.append(new_region.tolist())

    return new_regions, np.asarray(new_vertices)

def clip_to_bounds(regions: list, vertices: np.ndarray, x_bounds : tuple[int, int], y_bounds : tuple[int, int]) -> List[Polygon]:
    """
    Clips a list of polygons to a bounding box defined by x and y bounds.

    Args:
    - regions (list): A list of regions to clip.
    - vertices (np.ndarray): An array of vertices.
    - x_bounds (tuple[int, int]): A tuple of x bounds.
    - y_bounds (tuple[int, int]): A tuple of y bounds.

    Returns:
    - clipped_polygons (List[Polygon]): A list of clipped polygons.
    """
    # bounding box
    bbox = Polygon([(x_bounds[0], y_bounds[0]), (x_bounds[0], y_bounds[1]), (x_bounds[1], y_bounds[1]), (x_bounds[1], y_bounds[0])])
    clipped_polygons = []
    for region in regions:
        polygon = vertices[region]
        # Clipping polygon
        poly = Polygon(polygon)
        poly = poly.intersection(bbox)
        clipped_polygons.append(poly)

    return clipped_polygons

def rasterize_voronoi(polygons: List[Polygon], labels: np.ndarray, output_scale : int) -> np.ndarray:
    """
    Rasterizes a list of polygons onto a numpy array.

    Args:
    - polygons (List[Polygon]): A list of polygons to rasterize.
    - labels (np.ndarray): A 2D numpy array representing the labels.
    - output_scale (int): The scale to bring our polygon to.

    Returns:
    - out_arr (np.ndarray): A 2D numpy array representing the rasterized polygons.
    """
    width, height = labels.shape[:2]
    out_arr = np.zeros((output_scale, output_scale), dtype=np.uint8)
    for polygon in polygons:
        x, y = polygon.boundary.xy
        center = (np.mean(x), np.mean(y)) * output_scale
        zone = labels[int(center[0] * (width - 1)), int(center[1] * (height - 1))]
        
        # Scale the polygon to raster coordinates
        raster_polygon = scale(polygon, xfact=output_scale, yfact=output_scale, origin=(0, 0))

        # Burn this polygon into the array
        rasterio.features.rasterize([(raster_polygon, zone)], out=out_arr)

    # It has to be flipped and rotated
    return out_arr.T[::-1, ::]

def binary_fill_holes(zones : np.ndarray, biomes : pd.DataFrame) -> np.ndarray:
    """
    Fills holes in a binary image.

    Args:
    - zone_map (np.ndarray): A 2D numpy array of floats representing the zone map.
    - biomes (pd.DataFrame): A pandas DataFrame representing the biomes.

    Returns:
    - zones (np.ndarray): A 2D numpy array representing the zone map with filled holes.
    """
    # Use binary dilation to fill holes, iterating from len(zones) to 0
    while np.isnan(zones).sum() > 0:
        for z in range(len(biomes), 0, -1):
            mask = zones == z
            dilated_mask = binary_dilation(mask) & np.isnan(zones)
            zones = np.where(dilated_mask, z, zones)
    return zones

def LoG_erode(zone_map : np.ndarray, biomes : pd.DataFrame, sigma : float = 1, threshold : float = 0, iterations : int = 4) -> np.ndarray:
    """
    Applies Laplacian of Gaussian (LoG) edge detection to a zone map and erodes the edges.

    Args:
    - zone_map (np.ndarray): A 2D numpy array representing the zone map.
    - sigma (float): The standard deviation of the Gaussian kernel used in the LoG filter.
    - threshold (float): The threshold value used to binarize the LoG image.
    - iterations (int): The number of times to apply the LoG filter and erosion.

    Returns:
    - zones (np.ndarray): A 2D numpy array representing the zone map with eroded edges.
    """
    zones = zone_map.copy().astype(float)
    for _ in range(iterations):
        # Compute the Laplacian of Gaussian (LoG)
        log = gaussian_laplace(zones, sigma=sigma)

        # Threshold the LoG image to get the edges
        edges = log > threshold
        zones[edges] = np.nan

        zones = binary_fill_holes(zones, biomes)

    return zones.astype(int)

def voronoi_array(labels : np.ndarray, voronoi_points : int, layer_window : int) -> np.ndarray:
    _, voronoi = get_voronoi(voronoi_points)
    regions, vertices = voronoi_finite_polygons_2d(voronoi)
    polygons = clip_to_bounds(regions, vertices, (0, 1), (0, 1))
    return rasterize_voronoi(polygons, labels, layer_window)

def super_resolution(zone_map : np.ndarray, base : int, patches: int) -> np.ndarray:
    result = np.zeros((base * patches, base * patches), dtype=np.uint8)
    for u in range(patches):
        for v in range(patches):
            patch_window = int(base / patches)
            x = u * patch_window * patches
            y = v * patch_window * patches
            layer_window = patch_window * patches
            print(f'({u}, {v}) -> ({x}, {y}) / {layer_window}')

            patch_map = patch(u, v, zone_map, patch_window)
            patch_map = np.flip(patch_map, 0)
            v_map = voronoi_array(patch_map, 6096, layer_window)
            #vzones = LoG_erode(vzones, biomes, 1, 0, 4)
            result[x:x+layer_window, y:y+layer_window] = v_map
    return result
