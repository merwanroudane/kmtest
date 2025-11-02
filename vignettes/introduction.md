---
title: "Introduction to kmtest: Kobayashi-McAleer Tests"
author: "Dr. Merwan Roudane"
date: "2025-11-02"
output: rmarkdown::html_vignette
vignette: >
  %\VignetteIndexEntry{Introduction to kmtest}
  %\VignetteEngine{knitr::rmarkdown}
  %\VignetteEncoding{UTF-8}
---



## Introduction

The `kmtest` package implements the Kobayashi-McAleer (1999) tests for determining whether a time series should be modeled in levels (linear transformation) or logarithms. These tests are particularly useful for economic and financial time series that are suspected to be integrated processes.

## Theoretical Background

### The Problem

When working with integrated time series, an important question is whether to use the level of the series $y_t$ or its logarithm $\log y_t$. The choice affects:

- Interpretation of parameters
- Forecasting accuracy
- Model specification

### The Tests

Kobayashi and McAleer (1999) proposed four tests:

1. **V1 test**: Tests linear (with drift) vs. logarithmic
2. **V2 test**: Tests logarithmic (with drift) vs. linear
3. **U1 test**: Tests linear (no drift) vs. logarithmic
4. **U2 test**: Tests logarithmic (no drift) vs. linear

The V tests have asymptotic normal distributions, while the U tests have nonstandard distributions with tabulated critical values.

## Installation


``` r
# Install from CRAN (when available)
install.packages("kmtest")

# Or install development version
# devtools::install_github("merwanroudane/kmtest")
```


``` r
library(kmtest)
```

## Basic Usage

### Example 1: Linear Integrated Process

First, let's simulate a linear integrated process with drift:


``` r
set.seed(123)
n <- 200
mu <- 0.5
y_linear <- numeric(n)
y_linear[1] <- 100
epsilon <- rnorm(n, 0, 1)

for (t in 2:n) {
  y_linear[t] <- y_linear[t-1] + mu + epsilon[t]
}
```

Visualize the data:


``` r
# Save current par settings
oldpar <- par(no.readonly = TRUE)
par(mfrow = c(2, 2))

plot(y_linear, type = "l", main = "Linear Process (Level)", 
     ylab = "y", xlab = "Time")
plot(log(y_linear), type = "l", main = "Linear Process (Log)", 
     ylab = "log(y)", xlab = "Time")
plot(diff(y_linear), type = "l", main = "First Difference (Level)", 
     ylab = expression(Delta*y), xlab = "Time")
plot(diff(log(y_linear)), type = "l", main = "First Difference (Log)", 
     ylab = expression(Delta*log(y)), xlab = "Time")
```

![plot of chunk linear_plot](figure/linear_plot-1.png)

``` r

# Restore par settings
par(oldpar)
```

Run the test suite:


``` r
result_linear <- km_test_suite(y_linear, has_drift = TRUE)
#> 
#> === Kobayashi-McAleer Tests for Data Transformation ===
#> Testing: Linear (with drift) vs Logarithmic
#> V1 statistic: 0.4767 (p-value: 0.6336)
#> Reject linear null: NO
#> Testing: Logarithmic (with drift) vs Linear
#> V2 statistic: 2.7962 (p-value: 0.0052)
#> Reject logarithmic null: YES
#> === Interpretation ===
#> Conclusion: Data should be modeled in LEVELS
```

### Example 2: Logarithmic Integrated Process

Now simulate a logarithmic integrated process:


``` r
set.seed(456)
n <- 200
eta <- 0.002
log_y <- numeric(n)
log_y[1] <- log(100)
u <- rnorm(n, 0, 0.01)

for (t in 2:n) {
  log_y[t] <- log_y[t-1] + eta + u[t]
}

y_log <- exp(log_y)
```

Visualize:


``` r
# Save current par settings
oldpar <- par(no.readonly = TRUE)
par(mfrow = c(2, 2))

plot(y_log, type = "l", main = "Log Process (Level)", 
     ylab = "y", xlab = "Time")
plot(log(y_log), type = "l", main = "Log Process (Log)", 
     ylab = "log(y)", xlab = "Time")
plot(diff(y_log), type = "l", main = "First Difference (Level)", 
     ylab = expression(Delta*y), xlab = "Time")
plot(diff(log(y_log)), type = "l", main = "First Difference (Log)", 
     ylab = expression(Delta*log(y)), xlab = "Time")
```

![plot of chunk log_plot](figure/log_plot-1.png)

``` r

# Restore par settings
par(oldpar)
```

Run tests:


``` r
result_log <- km_test_suite(y_log, has_drift = TRUE)
#> 
#> === Kobayashi-McAleer Tests for Data Transformation ===
#> Testing: Linear (with drift) vs Logarithmic
#> V1 statistic: 1.4809 (p-value: 0.1386)
#> Reject linear null: NO
#> Testing: Logarithmic (with drift) vs Linear
#> V2 statistic: 0.5037 (p-value: 0.6145)
#> Reject logarithmic null: NO
#> === Interpretation ===
#> Conclusion: INCONCLUSIVE - neither null rejected
```

## Individual Tests

You can also run individual tests:

### V1 Test (Linear vs. Logarithmic with Drift)


``` r
v1_result <- km_v1_test(y_linear)
print(v1_result)
#> 
#> Kobayashi-McAleer Test Result
#> =============================
#> 
#> Test type: V1 
#> Null hypothesis: Linear integrated process (with drift) 
#> Alternative: Logarithmic integrated process 
#> 
#> Test statistic: 0.4767 
#> P-value: 0.6336 
#> Decision (5% level): Do not reject null 
#> 
#> Lag order: 0
```

### V2 Test (Logarithmic vs. Linear with Drift)


``` r
v2_result <- km_v2_test(y_log)
print(v2_result)
#> 
#> Kobayashi-McAleer Test Result
#> =============================
#> 
#> Test type: V2 
#> Null hypothesis: Logarithmic integrated process (with drift) 
#> Alternative: Linear integrated process 
#> 
#> Test statistic: 0.5037 
#> P-value: 0.6145 
#> Decision (5% level): Do not reject null 
#> 
#> Lag order: 0
```

## Tests Without Drift

For processes without drift (random walks), use the U tests:


``` r
set.seed(789)
n <- 200
y_rw <- cumsum(rnorm(n)) + 100
```


``` r
result_nodrift <- km_test_suite(y_rw, has_drift = FALSE)
#> 
#> === Kobayashi-McAleer Tests for Data Transformation ===
#> Testing: Linear (no drift) vs Logarithmic
#> Warning in y_lagged * (z_t^2 - s_squared): la taille d'un
#> objet plus long n'est pas multiple de la taille d'un objet
#> plus court
#> U1 statistic: -0.2033
#> Reject at 5%: NO
#> Testing: Logarithmic (no drift) vs Linear
#> U2 statistic: 0.1821
#> Reject at 5%: NO
#> === Interpretation ===
#> Conclusion: INCONCLUSIVE - neither null rejected
```

## Interpretation Guidelines

The test suite provides automatic interpretation:

- **"Use LOGARITHMS"**: When the linear null is rejected but logarithmic null is not
- **"Use LEVELS"**: When the logarithmic null is rejected but linear null is not
- **"INCONCLUSIVE"**: When both or neither nulls are rejected

In inconclusive cases, consider:

1. Different model specifications
2. Presence of structural breaks
3. Alternative unit root processes
4. Sample size issues

## Customization Options

### Lag Order Selection

By default, the lag order is selected automatically using AIC. You can specify it manually:


``` r
result_custom <- km_v1_test(y_linear, p = 2)
#> Warning in y_lagged * (z_t^2 - s_squared): la taille d'un
#> objet plus long n'est pas multiple de la taille d'un objet
#> plus court
```

### Maximum Lag Consideration


``` r
result_maxlag <- km_test_suite(y_linear, has_drift = TRUE, max_p = 8)
#> 
#> === Kobayashi-McAleer Tests for Data Transformation ===
#> Testing: Linear (with drift) vs Logarithmic
#> V1 statistic: 0.4767 (p-value: 0.6336)
#> Reject linear null: NO
#> Testing: Logarithmic (with drift) vs Linear
#> V2 statistic: 2.7962 (p-value: 0.0052)
#> Reject logarithmic null: YES
#> === Interpretation ===
#> Conclusion: Data should be modeled in LEVELS
```

### Verbose Control

Control output verbosity:


``` r
# Suppress output
result_quiet <- km_test_suite(y_linear, has_drift = TRUE, verbose = FALSE)

# The result is still returned
print(result_quiet$conclusion)
#> [1] "Conclusion: Data should be modeled in LEVELS"
```

## Practical Recommendations

1. **Always visualize your data** before testing
2. **Check for unit roots** using standard tests (ADF, PP)
3. **Consider the economic interpretation** of your choice
4. **Be aware of sample size requirements** (at least n > 50 recommended)
5. **Look for structural breaks** if tests are inconclusive

## References

Kobayashi, M. and McAleer, M. (1999). Tests of Linear and Logarithmic Transformations for Integrated Processes. *Journal of the American Statistical Association*, 94(447), 860-868.

## Citation

To cite this package in publications:


``` r
citation("kmtest")
```
