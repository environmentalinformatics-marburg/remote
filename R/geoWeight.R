#' Geographic weighting
#' 
#' @description
#' The function performs geographic weighting using the cosine of latitude 
#' to compensate for area distortion of non-projected lat/lon data
#' 
#' @param x a Raster* object
#' 
#' @return a weighted Raster* object
#' 
#' @export geoWeight
#' 
#' @examples
#' data(vdendool)
#' 
#' wgtd <- geoWeight(vdendool)
#' 
#' opar <- par(mfrow = c(1,2))
#' plot(vdendool[[1]], main = "original")
#' plot(wgtd[[1]], main = "weighted")
#' par(opar)
geoWeight <- function(x) {
  
  x.vals <- x[]
  rads <- deg2rad(coordinates(x)[, 2])
  x.weightd <- x.vals * cos(rads)
  x[] <- x.weightd
  return(x)
  
}