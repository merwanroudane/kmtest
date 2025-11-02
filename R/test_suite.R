#' Comprehensive Kobayashi-McAleer Test Suite
#' 
#' Runs appropriate tests (with or without drift) and provides interpretation
#' 
#' @param y Numeric vector of time series data
#' @param has_drift Logical, whether to test for processes with drift (default: TRUE)
#' @param p Integer, lag order (NULL for automatic selection)
#' @param max_p Integer, maximum lag to consider for automatic selection
#' @param verbose Logical, whether to print detailed output (default: TRUE)
#' 
#' @return A list of class "kmtest_suite" containing:
#' \item{tests}{List of individual test results}
#' \item{conclusion}{Character string with interpretation}
#' \item{has_drift}{Logical indicating drift assumption}
#' 
#' @details
#' This function runs the appropriate pair of tests based on whether the series
#' is assumed to have drift:
#' \itemize{
#'   \item With drift: Runs V1 and V2 tests
#'   \item Without drift: Runs U1 and U2 tests
#' }
#' 
#' The interpretation follows the logic:
#' \itemize{
#'   \item If only the linear null is rejected: use logarithmic transformation
#'   \item If only the logarithmic null is rejected: use level (linear) transformation
#'   \item If both or neither are rejected: inconclusive
#' }
#' 
#' @examples
#' # Example with drift
#' set.seed(123)
#' n <- 200
#' y_linear <- cumsum(rnorm(n, mean = 0.5, sd = 1)) + 100
#' results <- km_test_suite(y_linear, has_drift = TRUE)
#' 
#' @export
km_test_suite <- function(y, has_drift = TRUE, p = NULL, max_p = 12, verbose = TRUE) {
  
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
  
  if (verbose) {
    message("\n=== Kobayashi-McAleer Tests for Data Transformation ===\n")
  }
  
  results <- list()
  
  # Run appropriate tests based on drift assumption
  if (has_drift) {
    # Tests with drift
    if (verbose) {
      message("Testing: Linear (with drift) vs Logarithmic")
    }
    results$v1 <- km_v1_test(y, p, max_p)
    
    if (verbose) {
      message(sprintf("V1 statistic: %.4f (p-value: %.4f)", 
                    results$v1$statistic, results$v1$p_value))
      message(sprintf("Reject linear null: %s\n", 
                    ifelse(results$v1$reject_null, "YES", "NO")))
    }
    
    if (verbose) {
      message("Testing: Logarithmic (with drift) vs Linear")
    }
    results$v2 <- km_v2_test(y, p, max_p)
    
    if (verbose) {
      message(sprintf("V2 statistic: %.4f (p-value: %.4f)", 
                    results$v2$statistic, results$v2$p_value))
      message(sprintf("Reject logarithmic null: %s\n", 
                    ifelse(results$v2$reject_null, "YES", "NO")))
    }
    
  } else {
    # Tests without drift
    if (verbose) {
      message("Testing: Linear (no drift) vs Logarithmic")
    }
    results$u1 <- km_u1_test(y, p, max_p)
    
    if (verbose) {
      message(sprintf("U1 statistic: %.4f", results$u1$statistic))
      message(sprintf("Reject at 5%%: %s\n", 
                    ifelse(results$u1$reject_05, "YES", "NO")))
    }
    
    if (verbose) {
      message("Testing: Logarithmic (no drift) vs Linear")
    }
    results$u2 <- km_u2_test(y, p, max_p)
    
    if (verbose) {
      message(sprintf("U2 statistic: %.4f", results$u2$statistic))
      message(sprintf("Reject at 5%%: %s\n", 
                    ifelse(results$u2$reject_05, "YES", "NO")))
    }
  }
  
  # Generate interpretation
  conclusion <- interpret_results(results, has_drift)
  
  if (verbose) {
    message("=== Interpretation ===")
    message(conclusion)
  }
  
  output <- list(
    tests = results,
    conclusion = conclusion,
    has_drift = has_drift
  )
  
  class(output) <- "kmtest_suite"
  return(output)
}


#' Interpret test results
#' 
#' @param results List of test results
#' @param has_drift Logical indicating if drift tests were used
#' @return Character string with interpretation
#' @keywords internal
interpret_results <- function(results, has_drift) {
  
  if (has_drift) {
    linear_rejected <- results$v1$reject_null
    log_rejected <- results$v2$reject_null
    
    if (linear_rejected && !log_rejected) {
      conclusion <- "Conclusion: Data should be modeled in LOGARITHMS"
    } else if (!linear_rejected && log_rejected) {
      conclusion <- "Conclusion: Data should be modeled in LEVELS"
    } else if (linear_rejected && log_rejected) {
      conclusion <- paste(
        "Conclusion: INCONCLUSIVE - both nulls rejected",
        "Consider: (1) Different model specification, or",
        "          (2) Presence of structural breaks, or",
        "          (3) Stochastic unit root process",
        sep = "\n"
      )
    } else {
      conclusion <- "Conclusion: INCONCLUSIVE - neither null rejected"
    }
    
  } else {
    linear_rejected <- results$u1$reject_05
    log_rejected <- results$u2$reject_05
    
    if (linear_rejected && !log_rejected) {
      conclusion <- "Conclusion: Data should be modeled in LOGARITHMS"
    } else if (!linear_rejected && log_rejected) {
      conclusion <- "Conclusion: Data should be modeled in LEVELS"
    } else if (linear_rejected && log_rejected) {
      conclusion <- "Conclusion: INCONCLUSIVE - both nulls rejected"
    } else {
      conclusion <- "Conclusion: INCONCLUSIVE - neither null rejected"
    }
  }
  
  return(conclusion)
}


#' Print method for kmtest objects
#' 
#' @param x An object of class "kmtest"
#' @param ... Additional arguments (not used)
#' 
#' @return Invisibly returns the input object
#' 
#' @export
print.kmtest <- function(x, ...) {
  cat("\nKobayashi-McAleer Test Result\n")
  cat("=============================\n\n")
  cat("Test type:", x$test_type, "\n")
  cat("Null hypothesis:", x$null_hypothesis, "\n")
  cat("Alternative:", x$alternative, "\n\n")
  
  cat("Test statistic:", sprintf("%.4f", x$statistic), "\n")
  
  if (!is.null(x$p_value)) {
    # V1 or V2 test
    cat("P-value:", sprintf("%.4f", x$p_value), "\n")
    cat("Decision (5% level):", ifelse(x$reject_null, "Reject null", "Do not reject null"), "\n")
  } else {
    # U1 or U2 test
    cat("\nCritical values:\n")
    cat("  10% level:", sprintf("%.3f", x$critical_values$cv_10), 
        ifelse(x$reject_10, " [REJECTED]", ""), "\n")
    cat("   5% level:", sprintf("%.3f", x$critical_values$cv_05), 
        ifelse(x$reject_05, " [REJECTED]", ""), "\n")
    cat("   1% level:", sprintf("%.3f", x$critical_values$cv_01), 
        ifelse(x$reject_01, " [REJECTED]", ""), "\n")
  }
  
  cat("\nLag order:", x$lag_order, "\n")
  
  invisible(x)
}


#' Print method for kmtest_suite objects
#' 
#' @param x An object of class "kmtest_suite"
#' @param ... Additional arguments (not used)
#' 
#' @return Invisibly returns the input object
#' 
#' @export
print.kmtest_suite <- function(x, ...) {
  cat("\nKobayashi-McAleer Test Suite Results\n")
  cat("====================================\n\n")
  
  if (x$has_drift) {
    cat("Tests performed: V1 and V2 (with drift)\n\n")
    print(x$tests$v1)
    cat("\n")
    print(x$tests$v2)
  } else {
    cat("Tests performed: U1 and U2 (without drift)\n\n")
    print(x$tests$u1)
    cat("\n")
    print(x$tests$u2)
  }
  
  cat("\n")
  cat(x$conclusion, "\n")
  
  invisible(x)
}


#' Summary method for kmtest objects
#' 
#' @param object An object of class "kmtest"
#' @param ... Additional arguments (not used)
#' 
#' @return A data frame with test summary
#' 
#' @export
summary.kmtest <- function(object, ...) {
  print(object)
  invisible(object)
}


#' Summary method for kmtest_suite objects
#' 
#' @param object An object of class "kmtest_suite"
#' @param ... Additional arguments (not used)
#' 
#' @return The input object invisibly
#' 
#' @export
summary.kmtest_suite <- function(object, ...) {
  print(object)
  invisible(object)
}
