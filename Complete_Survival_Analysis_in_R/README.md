📊 Lung Cancer Survival Analysis (Survival_Analysis.r)
This project conducts a comprehensive survival analysis on lung cancer patient data using various statistical models and visualization techniques in R. It is designed for researchers, students, and analysts working in oncology, epidemiology, or biostatistics.

📁 Data
Input file: onco_ds.csv

The dataset includes:

Cancer cell type

Survival time

Censoring status

Prior treatment

Performance scores (KPS)

Diagnosis time

Therapy type

🧪 Main Objectives
Prepare and clean clinical data for survival analysis.

Summarize and visualize descriptive statistics (e.g., age, survival time).

Estimate and compare survival functions across cancer cell types using:

Kaplan-Meier curves

Cumulative Incidence Functions (CIF) for competing risks

Cox Proportional Hazards Models, including:

Adjusted models

Stratified models for PH assumption violations

Interaction models (e.g., age × cell type)

🛠 Methods and Tools Used
R Packages:

tidyverse, survival, survminer, psych, cmprsk

Survival Techniques:

Kaplan-Meier estimation and log-rank tests

Cumulative incidence with competing risks (Fine & Gray)

Cox proportional hazards models with PH diagnostics

Stratified and interaction Cox models

Visualization:

High-resolution plots with ggplot2 and survminer

CIF plots for both primary and competing events

📈 Outputs
🔹 Plots:
Kaplan-Meier survival curves (overall and by cell type)

Cumulative incidence plots (base R and ggplot2)

Cox model forest plots

Age-dependent hazard ratio plots

Schoenfeld residual plots for PH assumption testing

🔹 Data Exports:
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

🚀 Get Started
To run the analysis:

# Install required packages
install.packages(c("tidyverse", "survival", "survminer", "psych", "cmprsk"))

# Run the script
source('Survival_Analysis.r')

🤝 Contributing
Contributions are welcome! If you would like to improve or expand the analysis, feel free to open a pull request.

📜 License
This project is licensed under the MIT License.
