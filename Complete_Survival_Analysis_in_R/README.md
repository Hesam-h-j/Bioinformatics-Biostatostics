📊 Lung Cancer Survival Analysis (Survival_Analysis.r)
This script conducts a comprehensive survival analysis on lung cancer patient data using various statistical models and visualization techniques in R. It is designed for researchers, students, and analysts working in oncology, epidemiology, or biostatistics.

📁 Data
Input file: onco_ds.csv

The dataset includes demographic and clinical features such as:

Cancer cell type
Survival time
Censoring status
Prior treatment
Performance scores (KPS)
Diagnosis time
Therapy type

🧪 Main Objectives
Prepare and clean clinical data for survival analysis.

Summarize and visualize descriptive statistics (age, survival time, etc.).

Estimate and compare survival functions across cancer cell types using:
Kaplan-Meier curves
Cumulative Incidence Functions (CIF) for competing risks
Cox Proportional Hazards Models, including:
Adjusted models
Stratified models for PH assumption violations
Interaction models (e.g., age × cell type)

🛠 Methods and Tools Used
R packages: tidyverse, survival, survminer, psych, cmprsk

Survival techniques:
Kaplan-Meier estimation and log-rank tests
Cumulative incidence with competing risks (Fine & Gray)
Cox proportional hazards models with PH diagnostics
Stratified and interaction Cox models

Visualization:

High-resolution plots using ggplot2 and survminer
CIF plots for both primary and competing events

📈 Outputs
Plots:

Kaplan-Meier survival curves (overall and by cell type)
Cumulative incidence plots (base R and ggplot2)
Cox model forest plots
Age-dependent hazard ratio plots
Schoenfeld residual plots for PH assumption testing

Data exports:

Cleaned dataset without missing values
CIF estimates as CSV files
Pairwise log-rank p-value tables for cell types and KPS categories
Age-dependent hazard ratio summaries at key ages

🔍 Key Insights Enabled
Compare survival outcomes across different lung cancer cell types.
Visualize the impact of clinical covariates on survival.
Account for competing risks often present in oncology studies.
Examine interaction effects (e.g., does the hazard differ by age?).
Check and address violations of the proportional hazards assumption.

📌 Notes
This script assumes a single primary event type (e.g., death) but includes handling for a secondary competing event.
Designed to support clinical decision-making by identifying high-risk subgroups and potential treatment modifiers (e.g., performance status, cell type).
