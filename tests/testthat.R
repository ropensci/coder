library(testthat)
library(classifyr)

test_check("classifyr")

# Run once more without suggested packages
trace("require", quote(value <- FALSE), at = 5)
test_check("classifyr")
untrace("require")
