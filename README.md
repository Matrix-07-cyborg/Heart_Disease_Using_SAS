# Heart Disease Analysis Using SAS

## Project Overview

This project presents a statistical analysis of heart disease data using **SAS programming**. The objective is to explore demographic, lifestyle, and clinical characteristics and identify factors associated with heart disease using hypothesis testing and multivariable logistic regression.

**Workflow:** Data Import → Data Cleaning → Descriptive Statistics → Hypothesis Testing → Multicollinearity Assessment → Logistic Regression → Model Evaluation → ROC/AUC → Interpretation

## Objectives

1. Import and inspect the heart disease dataset.
2. Clean and prepare the data for statistical analysis.
3. Handle missing values represented as `NA`.
4. Create a binary heart disease outcome.
5. Perform descriptive statistics.
6. Compare clinical measurements between heart disease groups.
7. Perform bivariate association testing.
8. Assess multicollinearity.
9. Develop a multivariable logistic regression model.
10. Interpret odds ratios and 95% confidence intervals.
11. Assess model goodness of fit.
12. Evaluate discrimination using ROC/AUC.

## Dataset

The dataset contains demographic, lifestyle, medical-history, and clinical variables.

### Main Variables

| Variable | Description |
|---|---|
| `Gender` | Participant gender |
| `age` | Age in years |
| `education` | Education category |
| `currentSmoker` | Current smoking status |
| `cigsPerDay` | Cigarettes smoked per day |
| `BPMeds` | Blood-pressure medication |
| `prevalentStroke` | History of stroke |
| `prevalentHyp` | Prevalent hypertension |
| `diabetes` | Diabetes status |
| `totChol` | Total cholesterol |
| `sysBP` | Systolic blood pressure |
| `diaBP` | Diastolic blood pressure |
| `BMI` | Body mass index |
| `heartRate` | Heart rate |
| `glucose` | Glucose level |
| `Heart_stroke` | Original outcome field |
| `heart_disease` | Derived binary outcome |

### Outcome Coding

- `0` = No heart disease
- `1` = Heart disease

The logistic regression modeled the probability of `heart_disease = 1`.

## SAS Procedures Used

- `PROC IMPORT` – Import CSV data
- `PROC CONTENTS` – Inspect dataset structure
- `PROC PRINT` – Inspect observations
- `PROC FREQ` – Frequency tables and categorical tests
- `PROC MEANS` – Descriptive statistics
- `PROC CORR` – Pearson correlation
- `PROC REG` – VIF/tolerance diagnostics
- `PROC LOGISTIC` – Logistic regression, model fit and ROC analysis

## Analysis

### 1. Data Import and Inspection

The dataset was imported into SAS and checked using `PROC CONTENTS` and `PROC PRINT` to verify variable names, types, structure, and sample observations.

### 2. Data Cleaning

Some numeric variables contained `"NA"` as character values. These included:

- `cigsPerDay`
- `totChol`
- `BMI`
- `glucose`

They were converted to numeric variables using the SAS `INPUT` function, with `"NA"` treated as missing.

### 3. Creation of Heart Disease Outcome

A binary variable `heart_disease` was created from `Heart_stroke`:

```sas
if upcase(strip(Heart_stroke)) = "YES" then heart_disease = 1;
else if upcase(strip(Heart_stroke)) = "NO" then heart_disease = 0;
else heart_disease = .;
```

### 4. Descriptive Statistics

`PROC FREQ` was used for categorical variables and `PROC MEANS` for continuous variables.

Selected frequency results from the dataset:

- Female: 210 (60.17%)
- Male: 139 (39.83%)
- Current smokers: 166 (47.56%)
- Non-smokers: 183 (52.44%)
- Hypertension present: 104 (29.80%)
- Diabetes present: 11 (3.15%)
- Heart disease = 0: 283 (81.09%)
- Heart disease = 1: 66 (18.91%)

### 5. Independent Samples t-test

An independent two-sample t-test was used to compare systolic blood pressure between participants with and without heart disease.

| Heart Disease | N | Mean sysBP | SD |
|---|---:|---:|---:|
| No | 246 | 130.50 | 21.68 |
| Yes | 56 | 143.50 | 24.51 |

Participants with heart disease had a mean systolic blood pressure approximately **13 mmHg higher** than those without heart disease. The t-test was used to determine whether this difference was statistically significant.

### 6. Bivariate Analysis

Categorical associations with heart disease were assessed using Pearson chi-square tests. Fisher's exact test was also used when cell counts were small.

One reported test had:

- Chi-square = 0.1717
- DF = 1
- p = 0.6786

The corresponding two-sided Fisher's exact p-value was 0.8130.

### 7. Multicollinearity

Multicollinearity was assessed using Pearson correlation, VIF, and tolerance.

Systolic and diastolic blood pressure showed the strongest correlation, approximately **r = 0.78**. The VIF values were below 5, indicating no severe multicollinearity among the assessed continuous predictors.

### 8. Multivariable Logistic Regression

The final candidate model included:

- Age
- Total cholesterol
- Prevalent hypertension
- Systolic blood pressure
- Diastolic blood pressure

The final model used 302 observations:

- Heart disease = 1: 56
- Heart disease = 0: 246

#### Overall Model Significance

| Test | Chi-Square | DF | p-value |
|---|---:|---:|---:|
| Likelihood Ratio | 34.8888 | 5 | <0.0001 |
| Score | 33.9603 | 5 | <0.0001 |
| Wald | 29.4705 | 5 | <0.0001 |

The overall model was statistically significant.

### 9. Logistic Regression Results

| Predictor | Odds Ratio | 95% CI | p-value |
|---|---:|---|---:|
| Age | 1.068 | 1.025–1.113 | 0.0017 |
| Total cholesterol | 1.008 | 1.001–1.015 | 0.0354 |
| Prevalent hypertension | 2.143 | 0.909–5.048 | 0.0814 |
| Systolic BP | 0.992 | 0.969–1.016 | 0.5293 |
| Diastolic BP | 1.024 | 0.981–1.069 | 0.2804 |

#### Interpretation

**Age:** OR = 1.068. Each one-year increase in age was associated with approximately a **6.8% increase in the odds** of heart disease, holding other predictors constant. Age was statistically significant.

**Total cholesterol:** OR = 1.008. Each one-unit increase in total cholesterol was associated with approximately a **0.8% increase in the odds** of heart disease, adjusting for other predictors. It was statistically significant.

**Prevalent hypertension:** OR = 2.143 suggested higher odds, but the 95% CI included 1 and p = 0.0814; therefore, it was not statistically significant at the 5% level.

**Systolic BP:** OR = 0.992, p = 0.5293. No statistically significant independent association was observed in the adjusted model.

**Diastolic BP:** OR = 1.024, p = 0.2804. No statistically significant independent association was observed in the adjusted model.

### 10. Model Fit

The Hosmer–Lemeshow goodness-of-fit test produced:

- Chi-square = 9.2021
- DF = 8
- p = 0.3255

Since p > 0.05, there was no evidence of lack of fit based on this test.

### 11. ROC Curve and AUC

The model's discriminatory performance was evaluated using an ROC curve.

- **AUC = 0.7476**
- **95% CI = 0.6837–0.8115**

An AUC of approximately 0.75 indicates **moderate discriminatory ability** to distinguish participants with and without heart disease.

## Model Fit Statistics

- AIC = 266.747
- SC = 289.009
- -2 Log Likelihood = 254.747
- R-square = 0.1091
- Max-rescaled R-square = 0.1769

## Key Findings

1. The final logistic regression used 302 observations.
2. There were 56 heart disease cases and 246 non-cases in that model.
3. The overall logistic regression model was statistically significant (`p < 0.0001`).
4. Age and total cholesterol were statistically significant predictors.
5. Prevalent hypertension had an elevated point estimate but was not statistically significant at the 5% level.
6. Systolic and diastolic BP were not statistically significant independent predictors in the final adjusted model.
7. No severe multicollinearity was identified based on VIF diagnostics.
8. The Hosmer–Lemeshow test indicated acceptable fit (`p = 0.3255`).
9. The ROC AUC of 0.7476 indicated moderate discrimination.

## Conclusion

This project demonstrates a complete SAS-based statistical workflow for heart disease data. The analysis identified **age and total cholesterol as statistically significant predictors** in the final multivariable logistic regression model. The overall model was significant and showed acceptable goodness of fit. The ROC AUC of approximately 0.75 indicated moderate discriminatory ability.

Because the analysis is observational, these findings should be interpreted as **associations rather than causal effects**.

## Limitations

- The dataset contains missing values.
- Some variables required conversion from character to numeric form because of `NA` entries.
- The number of heart disease cases was smaller than the number of non-cases.
- The observational design does not establish causality.
- Independent external validation was not performed.
- Additional assessment of nonlinear effects, interactions, calibration, and internal validation could strengthen the analysis.

## Project Skills Demonstrated

### SAS

- DATA step
- Data cleaning and transformation
- Missing-value handling
- `PROC IMPORT`
- `PROC CONTENTS`
- `PROC PRINT`
- `PROC FREQ`
- `PROC MEANS`
- `PROC CORR`
- `PROC REG`
- `PROC LOGISTIC`

### Statistics

- Descriptive statistics
- Independent samples t-test
- Chi-square test
- Fisher's exact test
- Pearson correlation
- Multicollinearity/VIF
- Logistic regression
- Odds ratios
- Confidence intervals
- Hosmer–Lemeshow goodness-of-fit
- ROC curve
- AUC

## Recommended Repository Structure

```text
Heart-Disease-SAS-Analysis/
│
├── README.md
├── data/
│   └── heart_disease.csv
├── sas/
│   └── heart_disease_analysis.sas
├── output/
│   └── SAS_output.pdf
└── documentation/
    └── project_report.pdf
```

If the dataset has redistribution restrictions, do not upload the raw dataset; instead provide instructions for obtaining it.

## Author

**Rakesh Shaw**
