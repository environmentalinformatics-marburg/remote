pcp = terra::unwrap(australiaGPCP)
anm = anomalize(pcp)

expect_inherits(
  anm
  , class = "SpatRaster"
  , info = "returns a `SpatRaster` in case of `SpatRaster` input"
)

expect_identical(
  dim(anm)
  , target = dim(pcp)
  , info = "returns a `SpatRaster` of the same dimensions as the input"
)

expect_equal(
  anomalize(as(pcp, "Raster"))
  , target = anm
  , info = "returns same result as `Raster*` input"
)

## errors
expect_error(
  anomalize(pcp, reference = "frozen_hearts")
  , pattern = "^Expected 'reference' to inherit from .* but got"
  , info = "throws error if 'reference' is not a raster"
)

## warnings
ref = terra::app(pcp, fun = mean, na.rm = TRUE)

expect_warning(
  anm1 <- anomalize(
    pcp
    , reference = as(terra::rast(replicate(2L, ref)), "Raster")
  )
  , pattern = "to have a single layer, but got .* Using the first layer only"
  , info = "throws warning if 'reference' has more than one layer"
)

expect_equal(
  anm1
  , target = anm
  , info = "returns same result as single-layer 'reference'"
)
