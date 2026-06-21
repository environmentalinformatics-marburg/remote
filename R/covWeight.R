#' Create a weighted covariance matrix
#' 
#' @param m a matrix (e.g. as returned by [raster::getValues()])
#' @param weights a numeric vector of weights. For lat/lon data this 
#' can be produced with [getWeights()]
#' @param ... additional arguments passed to [stats::cov.wt()]
#' 
#' @return
#' see [stats::cov.wt()]
#' 
#' @seealso
#' [stats::cov.wt()]
#' 
#' @export covWeight
covWeight <- function(m, weights, ...) {
  
  cov.wt(na.exclude(m), weights, cor = TRUE, ...)
  
}