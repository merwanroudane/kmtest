#' kmtest: Kobayashi-McAleer Tests for Data Transformations
#'
#' @description
#' The kmtest package implements the Kobayashi-McAleer (1999) tests for
#' determining whether integrated time series should be modeled in levels
#' (linear transformation) or logarithms. These tests are essential for
#' proper specification of econometric models with I(1) processes.
#'
#' @details
#' The package provides four test statistics:
#' \itemize{
#'   \item \code{\link{km_v1_test}}: Tests linear (with drift) vs. logarithmic
#'   \item \code{\link{km_v2_test}}: Tests logarithmic (with drift) vs. linear
#'   \item \code{\link{km_u1_test}}: Tests linear (no drift) vs. logarithmic
#'   \item \code{\link{km_u2_test}}: Tests logarithmic (no drift) vs. linear
#' }
#'
#' The main interface is \code{\link{km_test_suite}}, which runs the appropriate
#' tests and provides automatic interpretation.
#'
#' @section Key Features:
#' \itemize{
#'   \item Automatic lag order selection using information criteria
#'   \item Clear interpretation of test results
#'   \item Handles both drift and no-drift cases
#'   \item S3 methods for convenient output
#'   \item Comprehensive documentation and examples
#' }
#'
#' @section Main Functions:
#' \itemize{
#'   \item \code{\link{km_test_suite}}: Complete test suite with interpretation
#'   \item \code{\link{km_v1_test}}: V1 test (linear vs. log, with drift)
#'   \item \code{\link{km_v2_test}}: V2 test (log vs. linear, with drift)
#'   \item \code{\link{km_u1_test}}: U1 test (linear vs. log, no drift)
#'   \item \code{\link{km_u2_test}}: U2 test (log vs. linear, no drift)
#' }
#'
#' @examples
#' # Simulate a linear integrated process
#' set.seed(123)
#' n <- 200
#' y <- cumsum(rnorm(n, mean = 0.5, sd = 1)) + 100
#'
#' # Run complete test suite
#' result <- km_test_suite(y, has_drift = TRUE)
#'
#' # Run individual test
#' v1 <- km_v1_test(y)
#' print(v1)
#'
#' @references
#' Kobayashi, M. and McAleer, M. (1999). Tests of Linear and Logarithmic
#' Transformations for Integrated Processes. Journal of the American
#' Statistical Association, 94(447), 860-868.
#' \doi{10.1080/01621459.1999.10474191}
#'
#' @author Dr. Merwan Roudane \email{merwanroudane920@@gmail.com}
#'
#' @docType package
#' @name kmtest-package
#' @aliases kmtest
#' @keywords package
#' @importFrom stats lm coef residuals pnorm qnorm
NULL
