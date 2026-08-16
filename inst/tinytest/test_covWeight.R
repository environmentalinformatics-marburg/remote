library("tinytest")
library("checkmate")
using("checkmate")

pcp = terra::unwrap(australiaGPCP)

cov_wghts = covWeight(
  terra::values(pcp)
  , weights = getWeights(pcp)
)

expect_list(
  cov_wghts
  , types = c(
    "matrix"
    , "numeric"
    , "integer"
  )
  , any.missing = FALSE
  , len = 5L
  , unique = TRUE
  , names = "named"
  , info = "returns a `list` of length 5 with named elements (see `?cov.wt`)"
)

expect_names(
  names(cov_wghts)
  , identical.to = c(
    "cov"
    , "center"
    , "n.obs"
    , "wt"
    , "cor"
  )
)

