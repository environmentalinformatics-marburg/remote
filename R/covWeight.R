#' Create a weighted covariance matrix
#' 
#' @param m A `matrix`, e.g. as returned by [terra::values()].
#' @param weights A `numeric` vector of weights. For lat/lon data this can be 
#'   produced with [getWeights()].
#' @param ... Additional arguments passed to [stats::cov.wt()]
#' 
#' @return
#' See [stats::cov.wt()].
#' 
#' @export
covWeight <- function(m, weights, ...) {
  
  # TODO: `SpatRaster` method
  stats::cov.wt(
    stats::na.exclude(m)
    , weights
    , cor = TRUE
    , ...
  )
  
}