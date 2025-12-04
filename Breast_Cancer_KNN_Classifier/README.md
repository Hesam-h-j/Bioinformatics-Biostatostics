## README: Breast Cancer Wisconsin (Diagnostic) Dataset Project

### Dataset Overview

This project utilizes the **Breast Cancer Wisconsin (Diagnostic) Dataset**, a widely used dataset for machine learning tasks, particularly in classification. It contains features computed from digitized images of fine needle aspirate (FNA) of breast masses. These features describe characteristics of the cell nuclei present in the image.

### Key Features

The dataset comprises 32 features, including:
*   `id`: A unique identification number for each sample.
*   `diagnosis`: The target variable, indicating whether the mass is Malignant (M) or Benign (B).
*   30 real-valued features, which are various measurements related to the cell nuclei, such as:
    *   `radius` (mean of distances from center to points on the perimeter)
    *   `texture` (standard deviation of gray-scale values)
    *   `perimeter`
    *   `area`
    *   `smoothness` (local variation in radius lengths)
    *   `compactness` (perimeter^2 / area - 1.0)
    *   `concavity` (severity of concave portions of the contour)
    *   `concave points` (number of concave portions of the contour)
    *   `symmetry`
    *   `fractal_dimension` ("coastline approximation" - 1)

For each of these features, three measures are provided: the mean, standard error (se), and "worst" or largest (mean of the three largest values) for each mass.

### Source

The dataset is publicly available on Kaggle:
[Breast Cancer Wisconsin (Diagnostic) Dataset on Kaggle](https://www.kaggle.com/datasets/uciml/breast-cancer-wisconsin-data)
