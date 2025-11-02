test_that("km_v1_test works correctly", {
  set.seed(123)
  n <- 100
  y <- cumsum(rnorm(n, mean = 0.5, sd = 1)) + 100
  
  result <- km_v1_test(y, p = 1)
  
  expect_s3_class(result, "kmtest")
  expect_true("statistic" %in% names(result))
  expect_true("p_value" %in% names(result))
  expect_type(result$statistic, "double")
  expect_true(result$p_value >= 0 && result$p_value <= 1)
})

test_that("km_v2_test works correctly", {
  set.seed(456)
  n <- 100
  log_y <- cumsum(rnorm(n, mean = 0.01, sd = 0.05)) + log(100)
  y <- exp(log_y)
  
  result <- km_v2_test(y, p = 1)
  
  expect_s3_class(result, "kmtest")
  expect_true("statistic" %in% names(result))
  expect_true("p_value" %in% names(result))
  expect_type(result$statistic, "double")
})

test_that("km_u1_test works correctly", {
  set.seed(789)
  n <- 100
  y <- cumsum(rnorm(n)) + 100
  
  result <- km_u1_test(y, p = 0)
  
  expect_s3_class(result, "kmtest")
  expect_true("statistic" %in% names(result))
  expect_true("critical_values" %in% names(result))
  expect_true("reject_05" %in% names(result))
})

test_that("km_u2_test works correctly", {
  set.seed(321)
  n <- 100
  log_y <- cumsum(rnorm(n, sd = 0.05)) + log(100)
  y <- exp(log_y)
  
  result <- km_u2_test(y, p = 0)
  
  expect_s3_class(result, "kmtest")
  expect_true("statistic" %in% names(result))
  expect_true("critical_values" %in% names(result))
})

test_that("Input validation works", {
  expect_error(km_v1_test(c("a", "b", "c")), "numeric")
  expect_error(km_v1_test(c(-1, 2, 3)), "positive")
  expect_error(km_v1_test(c(1, 2)), "at least 10")
})

test_that("km_test_suite works", {
  set.seed(111)
  n <- 100
  y <- cumsum(rnorm(n, mean = 0.5, sd = 1)) + 100
  
  result <- km_test_suite(y, has_drift = TRUE, verbose = FALSE)
  
  expect_s3_class(result, "kmtest_suite")
  expect_true("tests" %in% names(result))
  expect_true("conclusion" %in% names(result))
  expect_true("has_drift" %in% names(result))
})

test_that("Print methods work without errors", {
  set.seed(222)
  n <- 100
  y <- cumsum(rnorm(n, mean = 0.5, sd = 1)) + 100
  
  result_v1 <- km_v1_test(y, p = 1)
  expect_output(print(result_v1), "Kobayashi-McAleer")
  
  result_suite <- km_test_suite(y, has_drift = TRUE, verbose = FALSE)
  expect_output(print(result_suite), "Test Suite")
})

test_that("Lag order selection works", {
  set.seed(333)
  n <- 100
  y <- cumsum(rnorm(n, mean = 0.5, sd = 1)) + 100
  
  # With automatic lag selection
  result_auto <- km_v1_test(y, p = NULL, max_p = 5)
  expect_true(result_auto$lag_order >= 0 && result_auto$lag_order <= 5)
  
  # With specified lag
  result_fixed <- km_v1_test(y, p = 2)
  expect_equal(result_fixed$lag_order, 2)
})
