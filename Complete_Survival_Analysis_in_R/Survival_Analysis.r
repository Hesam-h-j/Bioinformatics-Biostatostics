#------------------------------------------------------------
# Script: onco_assess.r
# Purpose: Lung cancer survival analysis using KM, CIF, Cox
# Author: Seyed Mohammad Hesam Hosseini
# Data: onco_ds.csv
#------------------------------------------------------------
## data preparation
#------------------------------------------------------------
install.packages("tidyverse")
install.packages("survival")
install.packages("survminer")
install.packages("psych")
install.packages("cmprsk")
# loading packages
library(tidyverse)
library(survival)
library(survminer)
library(psych)
library(cmprsk) #cumulative incidence function (CIF)
library(grid)
# loading data.csv file
onco <- read_csv("onco_ds.csv") # or read.csv("d.csv")
# overview of the data
summary(onco)
# checking unique values in the columns
unique(onco$Obs)
unique(onco$Therapy)
unique(onco$Cell)
unique(onco$SurvTime)
unique(onco$Kps)
unique(onco$DiagTime)
unique(onco$Age)
unique(onco$Prior)
unique(onco$Treatment)
unique(onco$Censor)
unique(onco$Event)
# check for missing values
colSums(is.na(onco))
# missing values locations
na_locs <- which(is.na(onco), arr.ind = TRUE)
print(na_locs)
# All are in the same row, remove the row with missing values
onco1 <- onco[-na_locs[, 1], ]  # onco1 is the data.frame with no NAs
## adjusting the columns to the correct data types
# Convert Diag_Time (months) to Diag_Time_days (days)
# prior treatment to factor
# turn Event to Event_num for modeling and Event_fac for plotting
onco2 <- onco1 %>%
  mutate(
    Obs = as.integer(Obs),
    Therapy = as.factor(Therapy),
    Cell = factor(Cell),
    SurvTime = as.numeric(SurvTime),
    Kps = as.numeric(Kps),
    DiagTime = as.numeric(DiagTime),
    DiagTime_days = DiagTime * 30.44,
    # days (30 or 30.44/month) depending on the study
    Age = as.numeric(Age),
    Prior = ifelse(Prior == 0, 0, 1), #or Prior = ifelse(Prior > 0, 1, 0)
    Prior = as.factor(Prior), # 0 = no prior treatment, 1 = prior treatment
    Treatment = as.factor(Treatment), # 0 = standard, 1 = test
    # but this excess risk declines with age. In contrast,
    Censor = as.numeric(Censor),
    Event2 = ifelse(Censor == 1, 0, 1),
    Kps_cat = case_when( 
      Kps < 60            ~ "<60",
      Kps >= 60 & Kps <= 80 ~ "60-80",
      Kps > 80            ~ ">80"
    ), # Clinical performance classification
    Kps_cat = factor(Kps_cat, levels = c("<60","60-80",">80")),
    Event_num = as.numeric(Event), # for modeling
    Event_fac = factor(Event, levels = c(0, 1), labels = c("censored", "event"))
  )
onco2 <- as.data.frame(onco2) #data.frame instead of a tibble throughout
view(onco2) # having data frame in viewer
# to check data types of columns and general structure of the data
str(onco2)
#--------------------------------------------------------------------
## Exercise 1. what was the maximum survival time for the cell type adeno?
#--------------------------------------------------------------------
onco2 %>% 
  filter(Cell == "adeno") %>%
  summarise(max_survtime = max(SurvTime, na.rm = TRUE))
# or
max(onco2$SurvTime[onco2$Cell == "adeno"], na.rm = TRUE)
#or
with(onco2, max(SurvTime[Cell == "adeno"], na.rm = TRUE))
# survival time max for all cell type/ comparitive analysis are always better
tapply(onco2$SurvTime, onco2$Cell, max, na.rm = TRUE)
# Or
max_survival <- onco2 %>%
  group_by(Cell) %>%
  summarise(Max_Surv = max(SurvTime, na.rm = TRUE))
print(max_survival)
#---------------------------------------------------------------------
## Exercise 2. what is the average age of subjects in this study?
#---------------------------------------------------------------------
onco2 %>%
  summarise(AvgAge = mean(Age, na.rm = TRUE))
# or
mean(onco2$Age, na.rm = TRUE)
# average age for all cell types
tapply(onco2$Age, onco2$Cell, mean, na.rm = TRUE,)
#---------------------------------------------------------------------
## Exercise 3. which cell type appeared the most during this study?
#---------------------------------------------------------------------
onco2 %>%
  group_by(Cell) %>%
  summarise(Count = n()) %>%
  arrange(desc(Count)) %>%
  slice(1)
# or
onco2 %>%
  count(Cell, sort = TRUE)
# or
sort(summary(onco2$Cell), decreasing = TRUE)
#---------------------------------------------------------------------
## Exercise 4. Calculate descriptive statistics for all numeric variables
#---------------------------------------------------------------------
summary(onco2[, sapply(onco2, is.numeric)])
# more detailed (standard deviation, skewness, kurtosis, etc.):
psych::describe(onco2 [, sapply(onco2, is.numeric)])
# cell types group-wise summaries
onco2 %>% group_by(Cell) %>%
  summarise(across(where(is.numeric), ~mean(.x, na.rm = TRUE)))
#---------------------------------------------------------------------
## Exercise 5.Survival analysis/assess survival time (variable SurvTime)
## Based on the cancerous cells (var Cell)Consider applying survival functions
## kaplan meier quartiles
##cumulative incidence function
##cox regression
#----------------------------------------------------------------------
# Create survival object for reuse across multiple models
#----------------------------------------------------------------------
surv_obj <- Surv(time = onco2$SurvTime, event = onco2$Event_num)
head(surv_obj) # just to check if the object is created correctly
#----------------------------------------------------------------------
# Plotting the overall Kaplan-Meier survival curves
#---------------------------------------------------------------------
surv_all <- surv_fit(surv_obj ~ 1, data = onco2)
# plotting
km_all_plot <- ggsurvplot(
  fit = surv_all,              # your survfit object
  data = onco2,                 # your data frame
  xlab = "Days",                # x‐axis label
  ylab = "Overall survival",    # y‐axis label
  title = "Kaplan–Meier Curve (All Cell Type)",
  conf.int = TRUE,                  # add confidence band
  risk.table = TRUE,                  # add risk table underneath
  surv.median.line = "hv", # add horizontal+vertical median (50%) lines
  censor.shape = 124,                   # small tick marks for censored pts
  palette = "Dark2",               # same color palette you were using
  ggtheme = theme_minimal() +      # base theme
    theme(
      plot.title      = element_text(hjust = 0.5, face = "bold", size = 16),
      legend.position = "top"
    ) #+
  #xlim = c(0, 200), # main plot x‑axis limits
)
km_all_plot
# save the plot
jpeg("km_all_plot.jpeg", width = 8, height = 12, units = "in", res = 300)
print(km_all_plot)    # prints both plot & risk table
dev.off()
# overall KM quartiles (25%, 50%, 75%)
km_q <- survfit(Surv(SurvTime, Event_num) ~ 1, data = onco2)
quantile(km_q, probs = c(0.25, 0.5, 0.75))
#---------------------------------------------------------------------
# probability of overal surviving beyond a certain number of days
#---------------------------------------------------------------------
summary(surv_all, times = c(0, 50, 100, 200, 300))
#---------------------------------------------------------------------
# Plotting the Kaplan-Meier survival curves by cell type
#---------------------------------------------------------------------
km_by_cell <- survfit(surv_obj ~ Cell, data = onco2)
km_by_cell
names(km_by_cell$strata) <- levels(onco2$Cell)
# to make table for km_by_cell
km_by_cell
# drawing the plot
km_cell_plot <- ggsurvplot(
  fit = km_by_cell,
  data = onco2,
  xlab = "Days",
  ylab = "Overall survival",
  title = "Kaplan-Meier Curve For Each Cell Type",
  conf.int = TRUE,
  surv.median.line = "hv",
  pval = TRUE, # survdiff() function/ log-rank test p-value
  pval.method = TRUE, # show p-value for log-rank test
  risk.table = TRUE,
  palette = "Dark2",
  break.time.by = 100,
  ggtheme = theme_minimal() +
    theme(plot.title = element_text(hjust = 0.5, face  = "bold", size  = 16),
          legend.position = "top")
)
km_cell_plot
# save the plot
jpeg("km_cell_plot.jpeg", width = 8, height = 12, units = "in", res = 300)
print(km_cell_plot)    # prints both plot & risk table
dev.off()
#probability of surviving beyond a certain number of days in each cell type
km_summary <- summary(km_by_cell, times = c(50, 100))
km_summary
surv_median(km_by_cell)
#KM quartiles (25%, 50%, 75%)
km_by_cell <- survfit(Surv(SurvTime, Event_num) ~ Cell, data = onco2)
quantile(km_by_cell, probs = c(0.25, 0.5, 0.75))
#----------------------------------------------------------------------
###cumulative incidence function (CIF)###
# Fine–Gray's method (non-parametric cumulative incidence)
#critical in oncology, where multiple causes of death are common
#account competing risks while KM ignore competing risks.
#----------------------------------------------------------------------
#======================================================
# Cumulative Incidence Function Analysis by Cell Group
#======================================================
ci <- cuminc(ftime = onco2$SurvTime,
             fstatus = onco2$Event_num,
             # event status (0=censored, 1=event)
             group = onco2$Cell)

# Examine the structure of the result
print(ci)
# cuminc() adds a " 1" suffix to the names, we want to remove it
cause1_indices <- grep(" 1$", names(ci))
ci_cause1 <- ci[cause1_indices] # making a List Subset
# simplify names (remove the " 1" suffix for clarity)
names(ci_cause1) <- sub(" 1$", "", names(ci_cause1))

# Plot CIF curves for primary event by Cell group using base R
plot(ci_cause1, 
     xlab = "Time", ylab = "Cumulative Incidence",
     main = "CIF of Primary Event by Cell Type",
     lty = 1:length(ci_cause1), col = 1:length(ci_cause1))

# Save the base R CIF plot as a high-resolution JPEG
jpeg("CIF_by_Cell_baseR.jpeg", width = 12, height = 10, units = "in", res = 300)
plot(ci_cause1, 
     xlab = "Time", ylab = "Cumulative Incidence", 
     main = "CIF of Primary Event by Cell Type",
     lty = 1:length(ci_cause1), col = 1:length(ci_cause1))
dev.off()
# Extract time and CIF estimates for each Cell group
cif_list <- lapply(seq_along(ci_cause1), function(i) {
  data.frame(time = ci_cause1[[i]]$time,
             CIF  = ci_cause1[[i]]$est,
             Cell = names(ci_cause1)[i])
})
cif_df <- bind_rows(cif_list)

# Preview
head(cif_df)
# Remove duplicate time points per group
cif_df <- cif_df %>%
  group_by(Cell, time) %>%
  slice_tail(n = 1) %>%
  ungroup()

# Sort the data by group and time
cif_df <- arrange(cif_df, Cell, time)
# Plot CIF curves using ggplot2
cif_plot <- ggplot(cif_df, aes(x = time, y = CIF, color = Cell)) +
  geom_step(size = 1) +  # step function for CIF
  labs(title = "Cumulative Incidence of Primary Event by Cell Type",
       x = "Time",
       y = "Cumulative Incidence Probability") +
  theme_minimal() +
  theme(plot.title = element_text(hjust = 0.5))  # center the title

# Display the ggplot
print(cif_plot)
# Save the ggplot as a high-resolution JPEG
ggsave("CIF_by_Cell_ggplot.jpeg", plot = cif_plot, width = 12,
       height = 10, units = "in", dpi = 300)
# Export the CIF data to a CSV file
write.csv(cif_df, "CIF_estimates_by_Cell.csv", row.names = FALSE)
#======================================================================
# Analysis by Cell Group using Event2 as the competing event
#======================================================================
# 1- Making EventType coded: 1 = primary, 2 = competing, 0 = censored
onco2 <- onco2 %>%
  mutate(
    EventType = case_when(
      Event_num == 1 ~ 1,      # primary event
      Event2     == 1 ~ 2,      # competing event
      TRUE           ~ 0       # censored
    )
  )

# 2- adjusting multiple causes: cumulative incidence (both causes) by Cell group
ci_fit <- with(onco2, cuminc(ftime   = SurvTime,
                             fstatus = EventType,
                             group   = Cell,
                             cencode = 0) # 0 =censored
)

# Print the list names: each element is "<Cell> <cause>"
print(names(ci_fit))

# 3- Plot with base R (all causes & groups)
# drawing one curve per (Cell × cause)
jpeg("CIF_baseR_all_causes.jpeg", width = 6, height = 5, units = "in", res = 300)
plot(ci_fit,
     xlab = "Days",
     ylab = "Cumulative incidence",
     main = "CIF by Cell Type and Cause",
     lty = 1:length(ci_fit),
     col = rep(1:length(levels(onco2$Cell)), each = 2)  # same color per cell, two linetypes
)
# Adding legend
legend("bottomright",
       legend = names(ci_fit),
       lty    = 1:length(ci_fit),
       col    = rep(1:length(levels(onco2$Cell)), each = 2),
       cex    = 0.8
)
dev.off()
# 4a) pick only the elements whose names end in “ 1” or “ 2”
ci_names <- grep(" [12]$", names(ci_fit), value = TRUE)
# 4b) loop & row-bind each into a data.frame
cif_df <- data.frame(
  time  = numeric(0),
  cif   = numeric(0),
  Cell  = character(0),
  Cause = character(0),
  stringsAsFactors = FALSE
)

for(nm in ci_names) {
  obj   <- ci_fit[[nm]]
  parts <- strsplit(nm, " ")[[1]]
  tmp   <- data.frame(
    time  = obj$time,
    cif   = obj$est,
    Cell  = parts[1],
    Cause = parts[2],
    stringsAsFactors = FALSE
  )
  cif_df <- rbind(cif_df, tmp)
}

# 4c) label the causes
cif_df$Cause <- factor(
  cif_df$Cause,
  levels = c("1", "2"),
  labels = c("Primary event", "Competing event")
)

# 4d) remove duplicate (pre-jump) rows, keeping only the post-jump value
#     by reversing, dropping duplicates, then re-reversing
rev_df <- cif_df[nrow(cif_df):1, ]
key    <- paste(rev_df$Cell, rev_df$Cause, rev_df$time, sep = "_")
uniq_rev <- rev_df[!duplicated(key), ]
cif_clean <- uniq_rev[nrow(uniq_rev):1, ]

#── 5. Export the CIF estimates ───────────────────────────────────────────────
write.csv(
  cif_clean,
  file      = "CIF_estimates_Cell_Cause.csv",
  row.names = FALSE
)

#── 6. ggplot2 step‐plot, faceted by Cell ────────────────────────────────────
cif_plot <- ggplot(cif_clean, aes(x = time, y = cif, color = Cause)) +
  geom_step(size = 1) +
  facet_wrap(~ Cell) +
  labs(
    title    = "Cumulative Incidence by Cell Type",
    subtitle = "Primary vs. Competing Events",
    x        = "Time (days)",
    y        = "Cumulative incidence",
    color    = "Event type"
  ) +
  theme_minimal() +
  theme(
    plot.title    = element_text(hjust = 0.5, face = "bold"),
    plot.subtitle = element_text(hjust = 0.5)
  )

print(cif_plot)

# Save high-res JPEG
ggsave(
  filename = "CIF_by_Cell_facet_ggplot.jpeg",
  plot     = cif_plot,
  width    = 8, height = 6,
  units    = "in", dpi = 300
)
#----------------------------------------------------------------------
#*** since we have a single event type (no true competing risk)
#*** => can't apply multiple cause-specific deaths/events tests
#----------------------------------------------------------------------
# Pairwise log‑rank tests (multiple‑comparison adjustment)
#---------------------------------------------------------------------
# Pairwise log-rank test: Cell types
pairwise_res_cell <- pairwise_survdiff(
  Surv(SurvTime, Event_num) ~ Cell, # or Kps
  data            = onco2,
  p.adjust.method = "bonferroni"   # or "BH", "fdr", etc.
)
# View the matrix of chi‑square stats and adjusted p‑values:
pairwise_res_cell$TABLE    # chi‑square statistics
pairwise_res_cell$p.value    # adjusted p‑value matrix
# If you want a compact table of pairwise p’s:
print(pairwise_res_cell$p.value)
# Save the pairwise comparison results to a CSV file
write.csv(pairwise_res_cell$p.value,
          "pairwise_comparisons_cells.csv", row.names = TRUE)
#----------------------------------------------------------------------
# perform pairwise log-rank tests for KPS categories
pairwise_res_kps <- pairwise_survdiff(
  Surv(SurvTime, Event_num) ~ Kps_cat,
  data            = onco2,
  p.adjust.method = "bonferroni" # or "BH", "holm", etc.
)
pairwise_res_kps$p.value  # chi‑square statistics
pairwise_res_kps$TABLE    # adjusted p‑value matrix
print(pairwise_res_kps$p.value) # compact table of pairwise p’s
# Save the pairwise comparison results to a CSV file
write.csv(pairwise_res_kps$p.value,
          "pairwise_comparisons_kps.csv", row.names = TRUE)
#======================================================================
##################### adjusted survival model #########################
#======================================================================
# Estimating the effect of one variable While controlling for others
#---------------------------------------------------------------------
### Proportional Hazards Model (Cox Model) ###
#---------------------------------------------------------------------
multi_cox <- coxph(
  Surv(SurvTime, Event_num) ~
    Cell + Therapy + Prior + Age + DiagTime_days + Kps_cat,
  data = onco2,
  # kept "adeno" as the reference - most clinically common
  #data = transform(onco2,
  #Cell = relevel(Cell, ref = "large"))
)
summary(multi_cox) #shows coefficients, HRs, CIs, p‑values
# cox model plots
ph_test <- cox.zph(multi_cox) # test proportional hazards assumption
# Save the forest plot with specified dimensions and resolution
jpeg("Cox Model.jpeg", width = 10, height = 14, units = "in", res = 500)
par(mfrow = c(3, 2))
plot(ph_test)
dev.off()

# Create and save a forest plot of adjusted HRs
forplot <- ggforest(
  multi_cox,
  data       = onco2,
  main       = "Cox Proportional Hazards Model for Survival Analysis",
  cpositions = c(0.02, 0.15, 0.35),
  fontsize   = 1.0,
  noDigits   = 3
)
print(forplot)
ggsave(
  filename = "multi_cox_forest_plot.jpeg",
  plot     = forplot,
  width    = 10,    # inches
  height   = 12,    # inches
  dpi      = 300
)
#----------------------------------------------------------------------
# Proportional‑Hazards (PH) Assumption :
# Grambsch-Therneau test (using Schoenfeld residuals)
#---------------------------------------------------------------------
# Perform Schoenfeld residuals test
p_schoen <- ggcoxzph(ph_test)
p_schoen

# plot Schoenfeld residuals for each covariate
jpeg("schoenfeld_residuals.jpeg",
     width = 10, height = 16, units = "in", res = 500)
print(p_schoen)
dev.off()
#----------------------------------------------------------------------
# Interpretation of the global test:
# - Null hypothesis: all covariate effects remain constant over time.
# - p < 0.05 indicates violation of the PH assumption.
# - In results, Cell and Kps_cat, don't show significant proportionality.
# we have 3 aproaches in PH Violation Handling :
# 1- Including Time-Dependent Covariates (assess effect modification)
# 2- Using Alternative Survival Analysis Models (eg. accelerated failure time)
# 3- Stratified Models
#----------------------------------------------------------------------
# I chose Stratified Models because Cell and Kps_cat variables are categorical
#----------------------------------------------------------------------
# Fit a Cox model stratified by Cell and Kps_cat (no HR estimated for those)
# Stratified Cox model
# 1. Run stratified Cox model
strat_cox <- coxph(
  Surv(SurvTime, Event_num) ~
    Therapy + Prior + Age + DiagTime_days + strata(Kps_cat) + strata(Cell),
  data = onco2
)
summary(strat_cox)

# Check PH again for non‑stratified terms only
ph_strat_test <- cox.zph(strat_cox)
print(ph_strat_test)
plot(ph_strat_test)              # base‑R Schoenfeld plots

# Save the stratified model’s Schoenfeld plots
jpeg(
  filename = "schoenfeld_residuals_stratified.jpeg",
  width    = 10,
  height   = 10,
  units    = "in",
  res      = 500,
)
par(mfrow = c(2, 2))  # Adjust based on number of covariates
plot(ph_strat_test)
mtext(
  text = "Schoenfeld Residuals Test for Stratified Cox Model", 
  side = 3,
  line =  -2,
  outer = TRUE,
  cex  = 1.5
)
p_glob <- signif(ph_strat_test$table["GLOBAL", "p"], 3)
mtext(
  text = paste0("Global p_value: ", p_glob),
  side = 3,
  line = -4,
  outer = TRUE,
  cex  = 1.2
)
dev.off()
#----------------------------------------------------------------------
# Risk-Adjusted Survival Curves by cell
#----------------------------------------------------------------------
#continuous variables (their averages),  overall proportion (for factors)
cox_adj <- coxph(
  Surv(SurvTime, Event_num) ~
    Cell + Therapy + Prior + Age + DiagTime_days + Kps_cat,
  data = onco2
)
# Drawing risk‑adjusted survival curves for 'Cell'
ggadj <- ggadjustedcurves(
  fit      = cox_adj,
  data     = onco2,
  variable = "Cell",
  method   = "average", # average over all other covariates
  palette  = "Dark2",
  xlab     = "Days",
  ylab     = "Adjusted Survival",
  title    = "Risk‑Adjusted Survival by Cell Type"
)
# 5) Inspect the result
print(ggadj)
# 6) Save it to disk
ggsave(
  filename = "risk_adjusted_survival.jpeg",
  plot     = ggadj,
  width    = 8,
  height   = 6,
  dpi      = 300
)
#-----------------------------------------------------------
# Fit Cox model testing whether Age modifies the Cell effect
#-----------------------------------------------------------
cox_int <- coxph( # intraction
  Surv(SurvTime, Event_num) ~
    Cell * Age +    # main effects + interaction
    Therapy + Prior + DiagTime_days + Kps_cat,
  data = onco2
)
# we can chage the reference:
# onco2$Cell <- relevel(onco2$Cell, ref = "small")
# cox_int2 <- coxph(....)
# Summarize interaction model
summary(cox_int)
# Test overall significance of the interaction
anova_res <- anova(coxph(
  Surv(SurvTime, Event_num) ~
    Cell + Age + Therapy + Prior + DiagTime_days + Kps_cat,
  data = onco2
), cox_int)
print(anova_res)
# 1) Create a fine grid of ages
ages <- seq(
  from = min(onco2$Age),
  to   = max(onco2$Age),
  length.out = 100
)
# 2) Build newdata for each Cell × age, others at reference
newdata2 <- expand.grid(
  Cell           = levels(onco2$Cell),
  Age            = ages,
  Therapy        = levels(onco2$Therapy)[1],
  Prior          = levels(onco2$Prior)[1],
  DiagTime_days  = mean(onco2$DiagTime_days),
  Kps_cat        = levels(onco2$Kps_cat)[1]
)

# 3) Get linear predictor + SE from the interaction model
lp <- predict(cox_int, newdata2, type = "lp", se.fit = TRUE)

# 4) Compute hazard ratios vs. reference Cell = "adeno" at each age
newdata2$HR      <- exp(lp$fit)
newdata2$HR_lo   <- exp(lp$fit - 1.96*lp$se.fit)
newdata2$HR_hi   <- exp(lp$fit + 1.96*lp$se.fit)

# 5) Normalize so that at each age the adeno HR = 1
newdata2 <- newdata2 %>%
  group_by(Age) %>%
  mutate(
    refHR = HR[Cell == "adeno"],
    HR_rel = HR / refHR,
    HR_lo_rel = HR_lo / refHR,
    HR_hi_rel = HR_hi / refHR
  )

# 6) Plot
age_hr <- ggplot(newdata2, aes(x = Age, y = HR_rel, color = Cell, fill = Cell)) +
  geom_line() +
  geom_ribbon(aes(ymin = HR_lo_rel, ymax = HR_hi_rel), alpha = 0.2, color = NA) +
  labs(
    title = "Age‑Dependent Hazard Ratio by Cell Type\n(reference = adeno)",
    x     = "Age",
    y     = "Hazard Ratio",
    color = "Cell Type",
    fill  = "Cell Type"
  ) +
  theme_minimal()
print(age_hr)

ggsave(
  filename = "age_dependent_hazard_ratio.jpeg",
  plot     = last_plot(),
  width    = 8,
  height   = 6,
  dpi      = 300
)
# Extract values at a few ages :
# ages of interest
ages <- c(40, 50, 60, 70, 80)

# extract and round Age to match exactly those values
hr_trend <- newdata2 %>%
  # Round Age to nearest integer so it matches exactly 40,50,...
  mutate(Age = round(Age)) %>%
  # keep only the rows for those ages
  filter(Age %in% ages) %>%
  select(Cell, Age, HR_rel) %>%
  # for safety, if there are duplicates take the first
  group_by(Cell, Age) %>%
  slice(1) %>%
  ungroup() %>%
  # pivot so each age is its own column
  pivot_wider(
    names_from  = Age,
    values_from = HR_rel,
    names_prefix = "HR@"
  ) %>%
  arrange(Cell)

print(hr_trend)
#***no evidence that the effect of cell type on hazard changes with patient age
#***I chose Cox PH because it allows us to model time-to-event flexibly,
# without specifying a parametric form,
# and is widely interpretable in clinical settings.
# where to put ???
# “An HR of 2 for small cell carcinoma vs adeno means patients with small cell,
# have twice the hazard of death at any point, adjusting for other covariates.
# This can inform prioritizing aggressive treatment for those subtypes.”
# "Small cell carcinoma shows a notably higher hazard than adeno in younger patients.
# but this excess risk declines with age. In contrast,
# large cell carcinoma appears safer in younger patients but risk increases with age.
# This interaction implies age modifies the effect of cell type on survival,
# and treatment decisions might need to be age-adjusted."
