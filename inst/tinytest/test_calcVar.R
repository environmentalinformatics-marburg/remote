library("tinytest")
library("checkmate")
using("checkmate")

sst = terra::unwrap(pacificSST)

## non-standardized
var_ns = calcVar(sst)

expect_number(
  var_ns
  , lower = 0
  , finite = TRUE
  , info = "returns a single `numeric` value"
)

## standardized
var_st = calcVar(sst, standardised = TRUE)

expect_number(
  var_st
  , lower = 0
  , finite = TRUE
  , info = "returns a single `numeric` value"
)

expect_true(
  var_st != var_ns
)
