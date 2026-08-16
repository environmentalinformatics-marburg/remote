#' Calculate space-time variance of a raster series
#' 
#' @description The function calculates the (optionally standardised) space-time 
#'   variance of a raster series. 
#' 
#' @param x A `SpatRaster` (or `Raster*`) series.
#' @param standardised `logical`, defaults to `FALSE`. 
#' @param ... Currently not used.
#' 
#' @return The mean (optionally standardised) space-time variance as `numeric`.
#' 
#' @examples
#' sst = terra::unwrap(pacificSST)
#' 
#' calcVar(sst) # default non-standardised
#' calcVar(sst, standardised = TRUE)
#' 
#' @export
calcVar = function(x, standardised = FALSE, ...) {
  
  x = asSpatRaster(x)
  
  if (!standardised) {
    # compute variance across time and space, leveraging c++ functions for 
    # speed (see `?terra::app` for details)
    t <- mean(terra::values(terra::app(x, "sd", na.rm = TRUE)^2)[, 1L])
    s <- mean((terra::global(x, fun = "sd", na.rm = TRUE)[, 1L])^2)
    vrnc <- t + s
  } else {
    vrnc <- var(as.vector(terra::values(x)), na.rm = TRUE)
  }
  
  return(vrnc)
}