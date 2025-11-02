# Helper functions for Kobayashi-McAleer tests

#' Create lagged variables matrix
#' 
#' @param x Time series vector
#' @param p Number of lags
#' @return Matrix of lagged variables
#' @keywords internal
create_lags <- function(x, p) {
  n <- length(x)
  X <- matrix(NA, n - p, p)
  
  for (i in 1:p) {
    X[, i] <- x[(p - i + 1):(n - i)]
  }
  
  return(X)
}


#' Select optimal lag order using information criteria
#' 
#' @param x Time series vector
#' @param max_p Maximum lag order to consider
#' @param criterion Information criterion: "AIC" or "SIC"
#' @return Optimal lag order
#' @keywords internal
select_lag_order <- function(x, max_p, criterion = "AIC") {
  
  n <- length(x)
  ic_values <- numeric(max_p + 1)
  
  for (p in 0:max_p) {
    if (p == 0) {
      fit <- lm(x ~ 1)
      sigma2 <- sum(residuals(fit)^2) / n
      k <- 1
    } else {
      X <- create_lags(x, p)
      X <- cbind(1, X)
      y_reg <- x[(p+1):n]
      fit <- lm(y_reg ~ X - 1)
      sigma2 <- sum(residuals(fit)^2) / (n - p)
      k <- p + 1
    }
    
    if (criterion == "AIC") {
      ic_values[p + 1] <- log(sigma2) + 2 * k / n
    } else if (criterion == "SIC" || criterion == "BIC") {
      ic_values[p + 1] <- log(sigma2) + k * log(n) / n
    }
  }
  
  optimal_p <- which.min(ic_values) - 1
  return(optimal_p)
}


#' Get critical values for U1 test
#' 
#' Critical values from Kobayashi & McAleer (1999), Table 1.
#' Based on simulation with 20,000 iterations.
#' 
#' @return List containing critical values at 1\%, 5\%, and 10\% significance levels
#' @keywords internal
get_u1_critical_values <- function() {
  list(
    cv_01 = 1.116,
    cv_05 = 0.664,
    cv_10 = 0.477
  )
}


#' Get critical values for U2 test
#' 
#' Critical values from Kobayashi & McAleer (1999), Table 1.
#' Due to symmetry, U2 has the same critical values as U1.
#' 
#' @return List containing critical values at 1\%, 5\%, and 10\% significance levels
#' @keywords internal
get_u2_critical_values <- function() {
  # Due to symmetry of the distribution
  get_u1_critical_values()
}
