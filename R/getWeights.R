#' Calculate weights from latitude
#' 
#' Calculate weights using the cosine of latitude to compensate for area 
#' distortion of non-projected lat/lon data
#' 
#' @param x a Raster* object
#' @return a numeric vector of weights
#' @examples 
#' data("australiaGPCP")
#' wghts <- getWeights(australiaGPCP)
#' wghts_rst <- australiaGPCP[[1]]
#' wghts_rst[] <- wghts
#' 
#' opar <- par(mfrow = c(1,2))
#' plot(australiaGPCP[[1]], main = "data")
#' plot(wghts_rst, main = "weights")
#' par(opar)
#' 
#' @export getWeights
getWeights <- function(x) {
  
  cos(deg2rad(coordinates(x)[, 2][!is.na(x[[1]][])]))

}