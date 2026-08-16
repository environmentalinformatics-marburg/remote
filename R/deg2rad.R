#' Convert degrees to radians
#' 
#' @description Converts a series of degrees to radians.
#' 
#' @param deg A series of degrees to be converted to radians.
#' 
#' @return A vector of radians.
#' 
#' @examples
#' ## latitude in degrees
#' gph = terra::unwrap(vdendool)
#' 
#' degrees = terra::crds(gph)[, 2]
#' head(degrees)
#' 
#' ## latitude in radians
#' radians = deg2rad(degrees)
#' head(radians)
#' 
#' ## `SpatRaster` input, e.g. useful for topographic operations
#' tmp = gph[[1L]]
#' terra::values(tmp) = degrees
#' 
#' tmp_rad = deg2rad(tmp)
#' 
#' opar = par(mfrow = c(1, 2))
#' plot(tmp, main = "lat (degrees)")
#' plot(tmp_rad, main = "lat (radians)")
#' par(opar)
#' 
#' @export
deg2rad <- function(deg) {
  
  radians <- deg * pi / 180
  return(radians)
  
}