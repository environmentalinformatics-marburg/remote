
### `SpatRaster` ----

pcp = terra::unwrap(australiaGPCP)
dsn = deseason(pcp, cycle.window = 12L)

expect_inherits(
  dsn
  , class = "SpatRaster"
  , info = "returns a `SpatRaster` in case of `SpatRaster` input"
)

expect_identical(
  dim(dsn)
  , target = dim(pcp)
  , info = "returns a `SpatRaster` of the same dimensions as the input"
)

## with cpp
dsn_cpp = deseason(pcp, cycle.window = 12L, use.cpp = TRUE)

expect_equal(
  dsn_cpp
  , target = dsn
  , info = "returns same result as non-cpp implementation"
)
