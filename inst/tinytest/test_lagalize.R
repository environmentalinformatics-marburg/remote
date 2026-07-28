library("tinytest")
library("checkmate")
using("checkmate")

sst = terra::unwrap(pacificSST)
pcp = terra::unwrap(australiaGPCP)

lagged = lagalize(sst, pcp, lag = 4L, freq = 12L)

expect_list(
  lagged
  , types = "SpatRaster"
  , any.missing = FALSE
  , len = 2L
  , unique = TRUE
  , info = "returns a list of two `SpatRaster` objects"
)

expect_true(
  terra::nlyr(lagged[[1L]]) == terra::nlyr(lagged[[2L]]),
  info = "returns two `SpatRaster` objects of equal length"
)

expect_match(
  names(lagged)[[1L]][1L]
  , pattern = "_01"
  , info = "leaves the 1st layer in 'x' unchanged"
)

expect_match(
  names(lagged)[[2L]][1L]
  , pattern = "_05"
  , info = "shifts the original 'y' series by 4 lags"
)

## `Raster*` input
lagged_l0 = lagalize(sst, pcp, freq = 12L)

expect_equal(
  lagged_l0[[1L]]
  , target = sst
  , info = "returns the original 'x' series when 'lag' is `NULL`"
)

expect_equal(
  lagged_l0[[2L]]
  , target = pcp
  , info = "returns the original 'y' series when 'lag' is `NULL`"
)
