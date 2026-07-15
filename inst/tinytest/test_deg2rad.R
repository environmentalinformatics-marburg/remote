library("tinytest")
library("checkmate")
using("checkmate")

gph = terra::unwrap(vdendool)

## `numeric` input
degrees = terra::crds(gph)[, 2L]
radians = deg2rad(degrees)

expect_numeric(
  radians
  , lower = -pi / 2
  , upper = pi / 2
  , finite = TRUE
  , any.missing = FALSE
  , len = length(degrees)
  , info = "returns a `numeric` vector in case of `numeric` input"
)

## `SpatRaster` input
tmp = gph[[1L]]
terra::values(tmp) = degrees

tmp_rad = deg2rad(tmp)

expect_inherits(
  tmp_rad
  , class = "SpatRaster"
  , info = "returns a `SpatRaster` in case of `SpatRaster` input"
)

expect_identical(
  dim(tmp_rad)
  , target = dim(tmp)
  , info = "returns a `SpatRaster` with the same dimensions as the input"
)

expect_identical(
  terra::values(tmp_rad)[, 1L]
  , target = radians
  , info = "returns same values as `numeric` input"
)
