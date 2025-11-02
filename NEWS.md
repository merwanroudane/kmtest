# kmtest 1.0.0

## Initial Release

* Implemented Kobayashi-McAleer V1, V2, U1, and U2 tests
* Added comprehensive test suite function `km_test_suite()`
* Automatic lag order selection using AIC
* S3 methods for print and summary
* Complete documentation and vignettes
* Unit tests with testthat
* Proper handling of output messages (using message() instead of cat())
* Correct restoration of par() settings in vignettes

## Features

* `km_v1_test()`: Test linear vs. logarithmic (with drift)
* `km_v2_test()`: Test logarithmic vs. linear (with drift)
* `km_u1_test()`: Test linear vs. logarithmic (no drift)
* `km_u2_test()`: Test logarithmic vs. linear (no drift)
* `km_test_suite()`: Run complete test suite with interpretation

## References

Based on: Kobayashi, M. and McAleer, M. (1999). Tests of Linear and 
Logarithmic Transformations for Integrated Processes. Journal of the 
American Statistical Association, 94(447), 860-868.
