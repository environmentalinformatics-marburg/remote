gph = terra::unwrap(vdendool)
gph_wghts = geoWeight(gph)

expect_inherits(
  gph_wghts
  , class = "SpatRaster"
  , info = "returns a `SpatRaster` in case of `SpatRaster` input"
)

expect_identical(
  dim(gph_wghts)
  , target = dim(gph)
  , info = "returns a `SpatRaster` of the same dimensions as the input"
)

## different weighting function 'f'
gph_wghts_sqrt_cos = geoWeight(
  gph
  , f = \(x) sqrt(cos(x)) # downweights high latitudes less aggressively
)

expect_true(
  terra::global(
    gph_wghts_sqrt_cos[[1L]] != gph_wghts[[1L]]
    , fun = all
  )[[1L]]
  , info = "returns different results for different weighting function"
)

## `Raster*` input
expect_equal(
  geoWeight(as(gph, "Raster"))
  , target = gph_wghts
  , info = "returns same result as `Raster*` input"
)
