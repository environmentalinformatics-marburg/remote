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

## `Raster*` input
expect_equal(
  deseason(as(pcp, "Raster"), cycle.window = 12L)
  , target = dsn
  , info = "returns same result as `Raster*` input"
)

## with cpp
dsn_cpp = deseason(pcp, cycle.window = 12L, use.cpp = TRUE)

expect_equal(
  dsn_cpp
  , target = dsn
  , info = "returns same result as non-cpp implementation"
)

## with file output
tmp = tempfile(fileext = ".tif")
jnk = deseason(pcp, cycle.window = 12L, filename = tmp)

expect_true(
  file.exists(tmp)
  , info = "creates a file if 'filename' is specified"
)
