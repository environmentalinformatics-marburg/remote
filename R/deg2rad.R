#' Convert degrees to radians
#' 
#' @export deg2rad
#' 
#' @param deg vector of degrees to be converted to radians.
#' 
deg2rad <- function(deg) {
  
  radians <- deg * pi / 180
  return(radians)
  
}