import numpy as np
import pandas as pd
from PIL import Image
import scipy.ndimage as ndi
import skimage.color as color
from sklearn.cluster import KMeans

def load_image(path: str, scale: int) -> np.ndarray:
    """Load the image at the specified path."""
    image = Image.open(path)
    image = image.resize((scale, scale))
    img_array = np.array(image)
    return img_array

def patch(x, y, image, window):
    """
    Extracts a patch from an image.

    Parameters:
    x (int): The x-coordinate of the patch.
    y (int): The y-coordinate of the patch.
    image (np.ndarray): The original image as a numpy array.
    window (int): The size of the patch window.

    Returns:
    np.ndarray: A numpy array containing the extracted patch.
    """
    return image[x*window:(x+1)*window, y*window:(y+1)*window]

def extract_biomes(original_image : np.ndarray, biome_count : int = 10) -> tuple[pd.DataFrame, pd.DataFrame]:
    """
    Extracts biomes from an image using KMeans clustering.

    Parameters:
    original_image (np.ndarray): The original image as a numpy array.
    biome_count (int): The number of biomes to extract. Default is 10.

    Returns:
    pd.DataFrame: A pandas dataframe containing the extracted biomes.
    """
    width, height = original_image.shape[0:2]
    clip_labels = biome_count
    # We have an image with colors which represent biomes.  We need to extract the color bands

    # Convert the world to lab color, and then find our clusters across the a and b channels
    lab_image = color.rgb2lab(original_image[:,:,:3])[:, :, :3].reshape(-1, 3)

    maps = []
    cluster = KMeans(n_clusters=biome_count, random_state=0, n_init='auto')
    
    maps.append(cluster.fit(original_image[:,:,:3].reshape(-1, 3)))
    #maps.append(cluster.fit(lab_image))

    for c in (0, 1, 2):
        # Extract the a and b channels
        ab = lab_image[:, c].reshape(-1, 1)

        # Find the color clusters using KMeans
        #kmeans = KMeans(n_clusters=7, random_state=0, n_init='auto').fit(ab)
        #maps.append(kmeans)

    # We need to align our label values in coordinates across the four maps
    coordinates = np.stack([maps[i].labels_ for i in (0,)]).T
    sets = np.unique(coordinates, axis=0)

    # Create an empty dictionary to store the mappings
    label_mapping = {}
    label_counts = {}

    # Iterate over each unique combination
    for combination in sets:
        # Create a mask for the combination
        mask = np.all(coordinates == combination, axis=1)
        # Count the number of occurrences of the combination
        count = np.sum(mask)
        # Store the count in label_counts
        label_counts[tuple(combination)] = count

    # Sort the label_counts dictionary by the number of occurrences
    label_counts = sorted(label_counts.items(), key=lambda x: x[1], reverse=True)

    # Iterate over each unique combination
    for i, (combination, count) in enumerate(label_counts, 1):
        # Assign a unique label to each unique combination
        label_mapping[tuple(combination)] = i

    # Reorder the label_mapping dictionary by the number of occurrences
    label_mapping = {k: label_mapping[k] for k, _ in label_counts}

    # Now, apply the mapping to the coordinates
    aligned_coordinates = np.zeros((coordinates.shape[0], 1), dtype=np.uint8)

    for i, combination in enumerate(coordinates):
        new_label = label_mapping[tuple(combination)]
        aligned_coordinates[i] = new_label

    # The euclidian distance between two colors in the CIE-LAB color space is equal to the difference in their perceptual
    #  features, so we can use the euclidian distance to find the closest color to a given color, once we have translated
    #  the colors to euclidian coordinates.
    va = pd.DataFrame(lab_image.reshape(-1, 3), columns=['L', 'a', 'b'])
    va['x']= va.index % width
    va['y'] = va.index // width
    va['label'] = aligned_coordinates
    va['acos'] = np.cos(va['a'] * 2 * np.pi / 256.)
    va['asin'] = np.sin(va['a'] * 2 * np.pi / 256.)
    va['bcos'] = np.cos(va['b'] * 2 * np.pi / 256.)
    va['bsin'] = np.sin(va['b'] * 2 * np.pi / 256.)

    # Build our label color map
    vb = va.groupby('label').mean()
    vb['count'] = va[['label', 'L']].groupby('label').count()
    # Convert the euclidian coordinates back to LAB
    vb['a'] = np.arctan2(vb['asin'], vb['acos']) * 256 / (2 * np.pi)
    vb['b'] = np.arctan2(vb['bsin'], vb['bcos']) * 256 / (2 * np.pi)
    vb[['R', 'G', 'B']] = (color.lab2rgb(vb[['L', 'a', 'b']]) * 255).astype(np.uint8)
    vb.loc[0] = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]

    # Now we eliminate the labels above our label clip, since that is how many we are supposed to have
    va.loc[va['label'] > clip_labels, 'label'] = 0
    vb = vb.loc[vb.index <= clip_labels]

    # Convert va back into an image of labels, so we can use binary dilation to expand the labels
    label_image = va['label'].values.reshape(width, height)

    # Iterate from highest label to lowest (exclusive of 0)
    while (label_image == 0).sum() > 0:
        for i in range(clip_labels, 0, -1):
            # Create a binary mask of the current label
            mask = (label_image == i)

            # Use binary dilation to extend the current label to the neighboring pixels
            mask_dilated = ndi.binary_dilation(mask)

            # Use the dilated mask to update the label image, only changing the 0-label pixels
            label_image = np.where((label_image == 0) & mask_dilated, i, label_image)

    va['label'] = label_image.reshape(-1)

    # Apply RGB centroids back to the original image
    va = pd.merge(va, vb[['R', 'G', 'B']], left_on='label', right_index=True)
    va.sort_values(['y', 'x'], inplace=True)

    return va[['x', 'y', 'label', 'R', 'G', 'B']], vb[['R', 'G', 'B']]

