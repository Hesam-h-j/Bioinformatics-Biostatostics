Microarray Colorectal Cancer ML Pipeline (R)

This repository contains an R script that runs an end-to-end machine learning workflow for microarray gene expression data, focused on classifying colorectal cancer vs. normal samples.
​
It covers preprocessing, feature selection, and model training/evaluation so the most informative genes and best-performing classifier can be identified.
​

Workflow overview
Data preparation
The script loads raw microarray expression data and applies typical ML-ready preprocessing steps: log transformation, transposing to a samples × genes matrix, removing near-zero-variance genes, centering/scaling, and imputing missing values.
​

Feature selection
To reduce dimensionality and prioritize biologically informative signals, the workflow selects predictive genes using:
​

Boruta: an “all-relevant” wrapper method (commonly using Random Forest importance) that compares real features to randomized “shadow” features.
​

RFE (Recursive Feature Elimination) via caret: iteratively removes the least important features and evaluates performance across subset sizes.
​

Model training & evaluation
The script trains and evaluates multiple classifiers—Random Forest, SVM, and ANN—using gene sets from Boruta and RFE, enabling a side-by-side comparison of predictive performance.
​

Outputs (what you get)
Running the script produces:
​

Candidate gene biomarkers (e.g., boruta_features, rfe_features, and common_features) that best separate cancer vs. normal samples.
​

Performance metrics (e.g., Accuracy, Sensitivity, Specificity, and ROC/AUC) to compare Random Forest, SVM, and ANN under each feature-selection strategy.
​

A practical view of how feature selection choice (Boruta vs. RFE) impacts robustness and classification quality on this dataset.
​

Notes
Boruta is designed to identify all relevant predictors rather than only a minimal subset, which is useful for exploratory biomarker discovery.
​
RFE in caret is a backward-selection approach that can help balance model performance with feature set size (parsimony).
