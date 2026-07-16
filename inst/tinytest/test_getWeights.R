library("tinytest")
library("checkmate")
using("checkmate")

pcp = terra::unwrap(australiaGPCP)

wghts = getWeights(pcp)

expect_numeric(
  wghts
  , lower = 0
  , upper = 1
  , finite = TRUE
  , any.missing = FALSE
  , len = terra::ncell(pcp)
  , info = "returns a `numeric` vector of the same length as `ncell(x)`"
)

## with `NA`
n = 5L

set.seed(1899L)
idx = terra::spatSample(pcp, size = n, values = FALSE, cells = TRUE)

pcp1 = pcp
pcp1[idx] = NA_real_

wghts_na = getWeights(as(pcp1, "Raster"))

expect_true(
  length(wghts_na) == terra::ncell(pcp) - n
  , info = "returns a shorter weights vector in the presence of `NA` values"
)

expect_identical(
  wghts_na
  , target = wghts[-idx]
  , info = "returns the same weights as on original data, minus the `NA` values"
)
