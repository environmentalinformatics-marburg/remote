asSpatRaster = function(x) {

  ## if applicable, convert `Raster*` input to `SpatRaster`
  if (inherits(x, what = "Raster")) {
    x = terra::rast(x)
  }

  return(x)
}