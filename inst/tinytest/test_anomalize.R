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
