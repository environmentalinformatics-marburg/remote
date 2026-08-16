### `asSpatRaster()` -----

## `Raster*` input
r = system.file(
  "external/rlogo.grd"
  , package = "raster"
) |> 
  raster::brick() 

s = remote:::asSpatRaster(r)

expect_inherits(
  s
  , class = "SpatRaster"
  , info = "converts `Raster*` to `SpatRaster`"
)

expect_equal(
  dim(s)
  , dim(r)
  , info = "preserves dimensions when converting `Raster*` to `SpatRaster`"
)

## `SpatRaster` input
s1 = system.file(
  "ex/elev.tif"
  , package = "terra"
) |> 
  terra::rast()

expect_identical(
  remote:::asSpatRaster(s1)
  , target = s1
  , info = "returns `SpatRaster` input unchanged"
)

## `NULL` input
expect_null(
  remote:::asSpatRaster(NULL)
  , info = "returns `NULL` input unchanged"
)
