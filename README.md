# Regression Modelling: Wine Price Analysis

A comprehensive statistical analysis of Bordeaux wine prices using generalized linear regression models in R. This project examines how various geographical and contextual variables impact wine prices from 1952 to 1998.

## Table of Contents

- [Overview](#overview)
- [Research Question](#research-question)
- [Dataset](#dataset)
- [Analysis Methodology](#analysis-methodology)
- [Key Findings](#key-findings)
- [Model Specifications](#model-specifications)
- [Project Structure](#project-structure)
- [Installation & Usage](#installation--usage)
- [Requirements](#requirements)
- [Results & Interpretation](#results--interpretation)
- [Limitations & Future Work](#limitations--future-work)

## Overview

This project analyzes the effect of various explanatory variables on the average price of 25 Bordeaux wines spanning from 1952 to 1998. The analysis employs statistical regression techniques including:

- **Linear Regression** - Baseline model with log-transformed response variable
- **Poisson Generalized Linear Model (GLM)** - For count/rate data
- **Gamma GLM** - For positive, continuous response variables

The final model uses a **Gamma GLM with log link function**, which provides the best fit for the wine price data.

## Research Question

**What is the effect of geographical and contextual variables on the average price of Bordeaux wines?**

Specifically, the analysis investigates how the following factors influence wine prices:
- Production year
- Harvest month rainfall
- Summer temperature before harvest
- Winter rainfall before harvest
- Harvest temperature
- Wine quality rating (Parker score)

## Dataset

### Data Description

The dataset contains 47 observations (years) with information on 25 Bordeaux wines from 1952-1998.

### Variables

| Variable | Definition | Measurement | Notes |
|----------|-----------|-------------|-------|
| `year` | Year of production | Year | Predictor |
| `price` | Average price relative to 1961 | Percentage | **Response Variable** |
| `h.rain` | Rain during harvest month | Millimetres (mm) | Predictor |
| `s.temp` | Average summer temperature before harvest | Celsius (°C) | Predictor |
| `w.rain` | Winter rainfall before harvest | Millimetres (mm) | Predictor |
| `h.temp` | Average temperature at harvest | Celsius (°C) | Excluded due to multicollinearity |
| `parker` | Wine quality rating | 100-point scale | Excluded (18 missing values) |

### Data Cleaning

- **Missing Values**: 9 missing price values and 18 missing Parker scores
- **Action Taken**: Deleted rows with missing `price` values; removed `parker` variable due to excessive missing data
- **Final Sample Size**: 38 observations after cleaning

## Analysis Methodology

### 1. Exploratory Data Analysis

**Distribution Analysis:**
- Examined summary statistics of all variables
- Identified right-skewed distribution in `price`
- Applied log-transformation to normalize the response variable

**Correlation Analysis:**
- Assessed multicollinearity using correlation matrices
- Identified high correlation between `h.temp` and other variables
- Excluded `h.temp` from final models to avoid multicollinearity issues

**Visual Analysis:**
- Scatter plots of explanatory variables against price
- Distribution plots of price and log(price)
- Trend visualization over time

### 2. Collinearity Assessment

**Correlation Matrix (with h.temp):**
```
         year  h.rain  s.temp  w.rain  h.temp
year    1.00  -0.24   0.27    0.16    0.22
h.rain -0.24   1.00  -0.17   -0.27   -0.49
s.temp  0.27  -0.17   1.00   -0.10    0.47
w.rain  0.16  -0.27  -0.10    1.00    0.10
h.temp  0.22  -0.49   0.47    0.10    1.00
```

**Decision**: `h.temp` removed due to high correlations with `h.rain` (-0.49) and `s.temp` (0.47)

### 3. Model Building & Selection

#### Model 1: Linear Regression (OLS)
- Formula: `lm(log(price) ~ year + h.rain + s.temp + w.rain)`
- All variables significant at 1% level
- Adjusted R² = 0.66
- **Limitation**: Assumes normally distributed errors; residual plots show deviation

#### Model 2: Poisson GLM
- Formula: `glm(price ~ year + h.rain + s.temp + w.rain, family=poisson)`
- All variables significant
- **Issue**: Overdispersion detected (Var(yi) > μi)
- AIC: 288.26
- Better normality in Q-Q plot but higher AIC

#### Model 3: Gamma GLM (Final Model) ✓
- Formula: `glm(price ~ year + h.rain + s.temp + w.rain, family=Gamma(link="log"))`
- All variables significant across all levels
- **Advantages**: Better fit for positive, continuous data; lower AIC
- AIC: 266.09 (lower than Poisson)
- Dispersion parameter: 0.1229

### 4. Model Diagnostics

**Residual Analysis:**
- Residuals vs Fitted Values: Linear trend, minimal heteroscedasticity
- Q-Q Plot: Residuals follow normal distribution well with minor outliers
- Chi-squared Goodness of Fit Test: χ² = (13.5749 - 3.7626) / df = 0.96 (p > 0.05, model significant)

## Model Specifications

### Final Model: Gamma GLM

```r
glm_g <- glm(price ~ year + h.rain + s.temp + w.rain, 
             family = Gamma(link = "log"), 
             data = wine)
```

### Model Equation

**Log Scale:**
```
log(E(yi)) = 53.60 - 0.030(year) - 0.0028(h.rain) + 0.51(s.temp) + 0.0010(w.rain)
```

### Coefficients & Interpretation

| Variable | Coefficient | Std. Error | t-value | p-value | Significance | % Change per Unit |
|----------|-------------|-----------|---------|---------|--------------|------------------|
| Intercept | 53.60 | 10.67 | 5.03 | 1.71e-05 | *** | - |
| year | -0.030 | 0.0056 | -5.41 | 5.46e-06 | *** | -2.96% |
| h.rain | -0.0028 | 0.00092 | -3.05 | 0.00444 | ** | -0.28% |
| s.temp | 0.51 | 0.083 | 6.14 | 6.36e-07 | *** | +66.53% |
| w.rain | 0.0010 | 0.0004 | 2.31 | 0.02722 | * | +0.10% |

**Significance Codes:** *** p<0.001, ** p<0.01, * p<0.05

### Model Performance Metrics

- **Null Deviance**: 13.5749 (df = 37)
- **Residual Deviance**: 3.7626 (df = 33)
- **AIC**: 266.09
- **Dispersion Parameter**: 0.1229
- **Fisher Scoring Iterations**: 6

## Key Findings

### Interpretation of Coefficients (Percentage Change)

1. **Year (-2.96% per year)**
   - **Effect**: Older wines have lower average prices
   - **Interpretation**: Counter-intuitive result; general consensus is that older wines appreciate
   - **Explanation**: Average prices across 25 wines may mask individual wine appreciation; price increase in some wines offset by decreases in others

2. **Harvest Rainfall, h.rain (-0.28% per mm)**
   - **Effect**: Rain during harvest reduces price
   - **Interpretation**: Negative impact on grape quality
   - **Explanation**: Excessive rainfall during harvest dilutes grape sugars and increases fungal disease risk
   - **Magnitude**: Small effect size

3. **Summer Temperature, s.temp (+66.53% per °C)**
   - **Effect**: Warmer summers dramatically increase wine price
   - **Interpretation**: Most influential variable (largest coefficient)
   - **Explanation**: Higher temperatures promote grape ripening, sugar accumulation, and optimal flavor development
   - **Practical Significance**: 1°C increase → ~67% price increase

4. **Winter Rainfall, w.rain (+0.10% per mm)**
   - **Effect**: Winter rain before harvest increases price slightly
   - **Interpretation**: Positive but minimal impact
   - **Explanation**: Winter rainfall provides soil moisture for optimal vine growth during dormancy
   - **Magnitude**: Very small effect size

### Overall Model Insights

- **Most Important Variable**: Summer temperature (`s.temp`) - dramatic positive effect
- **Least Important Variables**: Rainfall variables have small but significant effects
- **Data Quality Impact**: Limited sample size (38 observations) and missing Parker ratings reduce model robustness
- **Model Fit**: Gamma GLM explains residual deviance well; significant chi-squared test confirms model validity

## Project Structure

```
regression_modelling_wine/
├── README.md                    # This file
├── SMM634_adch391_vF.R         # Main R analysis script
├── wine.txt                     # Wine dataset (tab-separated)
└── [Analysis Output Files]      # Generated plots and diagnostics
```

### File Descriptions

- **SMM634_adch391_vF.R**: Complete R script including:
  - Data loading and exploration
  - Distribution and correlation analysis
  - Model fitting (Linear, Poisson, Gamma GLM)
  - Residual diagnostics
  - Model comparison and selection

- **wine.txt**: Dataset with 47 rows and 6 columns
  - Format: Tab-separated values
  - Contains raw data before cleaning

## Installation & Usage

### Requirements

- **R** (version 3.6.0 or higher)
- **RStudio** (recommended)

### Required R Packages

```r
# Core packages (usually pre-installed)
# stats, graphics, base
```

No additional packages required beyond base R functionality.
