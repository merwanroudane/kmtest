#' Kobayashi-McAleer V1 Test
#' 
#' Tests the null hypothesis of a linear integrated process with positive drift
#' against the alternative of a logarithmic integrated process.
#' Based on Kobayashi & McAleer (1999) JASA.
#' 
#' @param y Numeric vector of time series data (must be positive)
#' @param p Integer, number of lags for AR process (default: automatically selected by AIC)
#' @param max_p Integer, maximum number of lags to consider for automatic selection
#' 
#' @return An object of class "kmtest" containing:
#' \item{statistic}{The V1 test statistic}
#' \item{p_value}{Two-sided p-value under asymptotic normality}
#' \item{reject_null}{Logical, whether to reject null at 5\% level}
#' \item{null_hypothesis}{Description of null hypothesis}
#' \item{alternative}{Description of alternative hypothesis}
#' \item{lag_order}{Selected lag order}
#' \item{mu_hat}{Estimated drift parameter}
#' \item{s_squared}{Estimated innovation variance}
#' \item{test_type}{Type of test performed}
#' 
#' @details
#' The V1 test is designed for integrated processes with positive drift. Under the null
#' hypothesis of a linear integrated process, the test statistic is asymptotically 
#' N(0,1). The test rejects the null when |V1| is large, suggesting the logarithmic
#' transformation is more appropriate.
#' 
#' The linear model is: \eqn{\Delta y_t = \mu + \sum_{j=1}^p a_j \Delta y_{t-j} + \epsilon_t}
#' 
#' @references
#' Kobayashi, M. and McAleer, M. (1999). Tests of Linear and Logarithmic 
#' Transformations for Integrated Processes. Journal of the American 
#' Statistical Association, 94(447), 860-868.
#' 
#' @examples
#' # Simulate a linear integrated process
#' set.seed(123)
#' n <- 200
#' y <- cumsum(rnorm(n, mean = 0.5, sd = 1)) + 100
#' 
#' # Run V1 test
#' result <- km_v1_test(y)
#' print(result)
#' 
#' @export
km_v1_test <- function(y, p = NULL, max_p = 12) {
  
  # Input validation
  if (!is.numeric(y)) {
    stop("y must be a numeric vector")
  }
  if (any(y <= 0)) {
    stop("y must contain only positive values")
  }
  if (length(y) < 10) {
    stop("y must have at least 10 observations")
  }
  
  n <- length(y)
  delta_y <- diff(y)
  
  # Select optimal lag if not specified
  if (is.null(p)) {
    p <- select_lag_order(delta_y, max_p, criterion = "AIC")
  }
  
  # Estimate the linear model
  if (p > 0) {
    X <- create_lags(delta_y, p)
    X <- cbind(1, X)
    y_reg <- delta_y[(p+1):length(delta_y)]
    
    fit <- lm(y_reg ~ X - 1)
    coefs <- coef(fit)
    z_t <- residuals(fit)
    
    a_sum <- sum(coefs[-1])
    mu_hat <- coefs[1] / (1 - a_sum)
    
  } else {
    fit <- lm(delta_y ~ 1)
    mu_hat <- coef(fit)
    z_t <- residuals(fit)
  }
  
  s_squared <- mean(z_t^2)
  y_lagged <- y[p:(n-1)]
  
  # Calculate V1 statistic
  numerator <- sum(y_lagged * (z_t^2 - s_squared))
  denominator <- sqrt(s_squared^2 * mu_hat^2 / 6)
  V1 <- numerator / (n^(3/2) * denominator)
  
  # P-value under asymptotic normality
  p_value <- 2 * (1 - pnorm(abs(V1)))
  reject <- abs(V1) > qnorm(0.975)
  
  result <- list(
    statistic = V1,
    p_value = p_value,
    reject_null = reject,
    null_hypothesis = "Linear integrated process (with drift)",
    alternative = "Logarithmic integrated process",
    lag_order = p,
    mu_hat = mu_hat,
    s_squared = s_squared,
    test_type = "V1"
  )
  
  class(result) <- "kmtest"
  return(result)
}


#' Kobayashi-McAleer U1 Test
#' 
#' Tests the null hypothesis of a linear integrated process without drift
#' against the alternative of a logarithmic integrated process.
#' 
#' @param y Numeric vector of time series data (must be positive)
#' @param p Integer, number of lags for AR process (default: automatically selected)
#' @param max_p Integer, maximum number of lags to consider
#' 
#' @return An object of class "kmtest" containing:
#' \item{statistic}{The U1 test statistic}
#' \item{critical_values}{List of critical values at 10\%, 5\%, and 1\% levels}
#' \item{reject_10}{Logical, reject null at 10\% level}
#' \item{reject_05}{Logical, reject null at 5\% level}
#' \item{reject_01}{Logical, reject null at 1\% level}
#' \item{null_hypothesis}{Description of null hypothesis}
#' \item{alternative}{Description of alternative hypothesis}
#' \item{lag_order}{Selected lag order}
#' \item{alpha_1}{Estimated alpha(1) parameter}
#' \item{s_squared}{Estimated innovation variance}
#' \item{test_type}{Type of test performed}
#' 
#' @details
#' The U1 test is designed for integrated processes without drift. Unlike V1, this
#' test has a nonstandard asymptotic distribution. Critical values are based on 
#' simulations from Kobayashi & McAleer (1999).
#' 
#' @references
#' Kobayashi, M. and McAleer, M. (1999). Tests of Linear and Logarithmic 
#' Transformations for Integrated Processes. Journal of the American 
#' Statistical Association, 94(447), 860-868.
#' 
#' @examples
#' # Simulate a linear random walk (no drift)
#' set.seed(456)
#' n <- 200
#' y <- cumsum(rnorm(n)) + 100
#' 
#' # Run U1 test
#' result <- km_u1_test(y)
#' print(result)
#' 
#' @export
km_u1_test <- function(y, p = NULL, max_p = 12) {
  
  # Input validation
  if (!is.numeric(y)) {
    stop("y must be a numeric vector")
  }
  if (any(y <= 0)) {
    stop("y must contain only positive values")
  }
  if (length(y) < 10) {
    stop("y must have at least 10 observations")
  }
  
  n <- length(y)
  delta_y <- diff(y)
  
  if (is.null(p)) {
    p <- select_lag_order(delta_y, max_p, criterion = "AIC")
  }
  
  # Estimate AR model without constant
  if (p > 0) {
    X <- create_lags(delta_y, p)
    y_reg <- delta_y[(p+1):length(delta_y)]
    fit <- lm(y_reg ~ X - 1)
    z_t <- residuals(fit)
    coefs <- coef(fit)
    alpha_1 <- 1 - sum(coefs)
  } else {
    z_t <- delta_y
    alpha_1 <- 1
  }
  
  s_squared <- mean(z_t^2)
  y_lagged <- y[p:(n-1)]
  
  # Calculate U1 statistic
  numerator <- sum(y_lagged * (z_t^2 - s_squared))
  denominator <- sqrt(2 * s_squared^3 / alpha_1)
  U1 <- numerator / (n * denominator)
  
  critical_values <- get_u1_critical_values()
  
  result <- list(
    statistic = U1,
    critical_values = critical_values,
    reject_10 = abs(U1) > critical_values$cv_10,
    reject_05 = abs(U1) > critical_values$cv_05,
    reject_01 = abs(U1) > critical_values$cv_01,
    null_hypothesis = "Linear integrated process (no drift)",
    alternative = "Logarithmic integrated process",
    lag_order = p,
    alpha_1 = alpha_1,
    s_squared = s_squared,
    test_type = "U1"
  )
  
  class(result) <- "kmtest"
  return(result)
}


#' Kobayashi-McAleer V2 Test
#' 
#' Tests the null hypothesis of a logarithmic integrated process with drift
#' against the alternative of a linear integrated process.
#' 
#' @param y Numeric vector of time series data (must be positive)
#' @param p Integer, number of lags (default: automatically selected)
#' @param max_p Integer, maximum number of lags to consider
#' 
#' @return An object of class "kmtest" containing:
#' \item{statistic}{The V2 test statistic}
#' \item{p_value}{Two-sided p-value under asymptotic normality}
#' \item{reject_null}{Logical, whether to reject null at 5\% level}
#' \item{null_hypothesis}{Description of null hypothesis}
#' \item{alternative}{Description of alternative hypothesis}
#' \item{lag_order}{Selected lag order}
#' \item{eta_hat}{Estimated drift parameter in log scale}
#' \item{w_squared}{Estimated innovation variance}
#' \item{test_type}{Type of test performed}
#' 
#' @details
#' The V2 test is designed for logarithmic integrated processes with drift. 
#' The test statistic is asymptotically N(0,1) under the null hypothesis.
#' 
#' The logarithmic model is: \eqn{\Delta \log y_t = \eta + \sum_{j=1}^p b_j \Delta \log y_{t-j} + u_t}
#' 
#' @references
#' Kobayashi, M. and McAleer, M. (1999). Tests of Linear and Logarithmic 
#' Transformations for Integrated Processes. Journal of the American 
#' Statistical Association, 94(447), 860-868.
#' 
#' @examples
#' # Simulate a logarithmic integrated process
#' set.seed(789)
#' n <- 200
#' log_y <- cumsum(rnorm(n, mean = 0.01, sd = 0.05)) + log(100)
#' y <- exp(log_y)
#' 
#' # Run V2 test
#' result <- km_v2_test(y)
#' print(result)
#' 
#' @export
km_v2_test <- function(y, p = NULL, max_p = 12) {
  
  # Input validation
  if (!is.numeric(y)) {
    stop("y must be a numeric vector")
  }
  if (any(y <= 0)) {
    stop("y must contain only positive values")
  }
  if (length(y) < 10) {
    stop("y must have at least 10 observations")
  }
  
  log_y <- log(y)
  n <- length(log_y)
  delta_log_y <- diff(log_y)
  
  if (is.null(p)) {
    p <- select_lag_order(delta_log_y, max_p, criterion = "AIC")
  }
  
  # Estimate logarithmic model
  if (p > 0) {
    X <- create_lags(delta_log_y, p)
    X <- cbind(1, X)
    y_reg <- delta_log_y[(p+1):length(delta_log_y)]
    
    fit <- lm(y_reg ~ X - 1)
    v_t <- residuals(fit)
    coefs <- coef(fit)
    
    b_sum <- sum(coefs[-1])
    eta_hat <- coefs[1] / (1 - b_sum)
  } else {
    fit <- lm(delta_log_y ~ 1)
    eta_hat <- coef(fit)
    v_t <- residuals(fit)
  }
  
  w_squared <- mean(v_t^2)
  n_eff <- length(v_t)
  log_y_lagged <- log_y[(p+1):(p+n_eff)]
  
  # Calculate V2 statistic
  numerator <- sum((-log_y_lagged) * (v_t^2 - w_squared))
  denominator <- sqrt(w_squared^2 * eta_hat^2 / 6)
  V2 <- numerator / (n^(3/2) * denominator)
  
  p_value <- 2 * (1 - pnorm(abs(V2)))
  reject <- abs(V2) > qnorm(0.975)
  
  result <- list(
    statistic = V2,
    p_value = p_value,
    reject_null = reject,
    null_hypothesis = "Logarithmic integrated process (with drift)",
    alternative = "Linear integrated process",
    lag_order = p,
    eta_hat = eta_hat,
    w_squared = w_squared,
    test_type = "V2"
  )
  
  class(result) <- "kmtest"
  return(result)
}


#' Kobayashi-McAleer U2 Test
#' 
#' Tests the null hypothesis of a logarithmic integrated process without drift
#' against the alternative of a linear integrated process.
#' 
#' @param y Numeric vector of time series data (must be positive)
#' @param p Integer, number of lags (default: automatically selected)
#' @param max_p Integer, maximum number of lags to consider
#' 
#' @return An object of class "kmtest" containing:
#' \item{statistic}{The U2 test statistic}
#' \item{critical_values}{List of critical values at 10\%, 5\%, and 1\% levels}
#' \item{reject_10}{Logical, reject null at 10\% level}
#' \item{reject_05}{Logical, reject null at 5\% level}
#' \item{reject_01}{Logical, reject null at 1\% level}
#' \item{null_hypothesis}{Description of null hypothesis}
#' \item{alternative}{Description of alternative hypothesis}
#' \item{lag_order}{Selected lag order}
#' \item{beta_1}{Estimated beta(1) parameter}
#' \item{w_squared}{Estimated innovation variance}
#' \item{test_type}{Type of test performed}
#' 
#' @details
#' The U2 test is for logarithmic processes without drift. Like U1, this test has
#' a nonstandard asymptotic distribution. Critical values from Kobayashi & McAleer (1999).
#' 
#' @references
#' Kobayashi, M. and McAleer, M. (1999). Tests of Linear and Logarithmic 
#' Transformations for Integrated Processes. Journal of the American 
#' Statistical Association, 94(447), 860-868.
#' 
#' @examples
#' # Simulate a logarithmic random walk (no drift)
#' set.seed(321)
#' n <- 200
#' log_y <- cumsum(rnorm(n, mean = 0, sd = 0.05)) + log(100)
#' y <- exp(log_y)
#' 
#' # Run U2 test
#' result <- km_u2_test(y)
#' print(result)
#' 
#' @export
km_u2_test <- function(y, p = NULL, max_p = 12) {
  
  # Input validation
  if (!is.numeric(y)) {
    stop("y must be a numeric vector")
  }
  if (any(y <= 0)) {
    stop("y must contain only positive values")
  }
  if (length(y) < 10) {
    stop("y must have at least 10 observations")
  }
  
  log_y <- log(y)
  n <- length(log_y)
  delta_log_y <- diff(log_y)
  
  if (is.null(p)) {
    p <- select_lag_order(delta_log_y, max_p, criterion = "AIC")
  }
  
  # Estimate AR model without constant
  if (p > 0) {
    X <- create_lags(delta_log_y, p)
    y_reg <- delta_log_y[(p+1):length(delta_log_y)]
    fit <- lm(y_reg ~ X - 1)
    v_t <- residuals(fit)
    coefs <- coef(fit)
    beta_1 <- 1 - sum(coefs)
  } else {
    v_t <- delta_log_y
    beta_1 <- 1
  }
  
  w_squared <- mean(v_t^2)
  n_eff <- length(v_t)
  log_y_lagged <- log_y[(p+1):(p+n_eff)]
  
  # Calculate U2 statistic
  numerator <- sum((-log_y_lagged) * (v_t^2 - w_squared))
  denominator <- sqrt(2 * w_squared^3 / beta_1)
  U2 <- numerator / (n * denominator)
  
  critical_values <- get_u2_critical_values()
  
  result <- list(
    statistic = U2,
    critical_values = critical_values,
    reject_10 = abs(U2) > critical_values$cv_10,
    reject_05 = abs(U2) > critical_values$cv_05,
    reject_01 = abs(U2) > critical_values$cv_01,
    null_hypothesis = "Logarithmic integrated process (no drift)",
    alternative = "Linear integrated process",
    lag_order = p,
    beta_1 = beta_1,
    w_squared = w_squared,
    test_type = "U2"
  )
  
  class(result) <- "kmtest"
  return(result)
}
