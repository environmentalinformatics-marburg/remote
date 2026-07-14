methods::setGeneric(
  "anomalize"
  , function(x, ...) {
    standardGeneric("anomalize")
  }
)

#' Create an anomaly raster series 
#' 
#' @description The function creates an anomaly raster series either based on 
#'   the overall mean of the original series, or a supplied reference raster. 
#'   For the creation of seasonal anomalies use [deseason()].
#' 
#' @param x A `SpatRaster` (or `Raster*`) series.
#' @param reference An optional `SpatRaster` (or `RasterLayer`) to be used as 
#'   the reference.
#' @param ... Additional arguments passed to [terra::app()] when 'reference' is 
#'   `NULL` (e.g. 'cores', 'filename'), or to the underlying `SpatRaster` method
#'   for `Raster*` input.
#' 
#' @return An anomaly `SpatRaster` series.
#' 
#' @seealso
#' [deseason()], [denoise()]
#' 
#' @export anomalize
#' @name anomalize
#' 
#' @examples
#' pcp = terra::unwrap(australiaGPCP)
#' pcp_anom = anomalize(pcp)
#' 
#' opar = par(mfrow = c(1,2))
#' plot(pcp[[10]], main = "original")
#' plot(pcp_anom[[10]], main = "anomalized")
#' par(opar)


################################################################################
### function using 'RasterStackBrick' ##########################################
#' @aliases anomalize,RasterStackBrick-method
#' @rdname anomalize
methods::setMethod(
  "anomalize"
  , signature(x = "RasterStackBrick")
  , function(
    x
    , ...
  ) {
    anomalize(
      terra::rast(x)
      , ...
    )
  }
)


################################################################################
### function using 'SpatRaster' ################################################
#' @aliases anomalize,SpatRaster-method
#' @rdname anomalize
methods::setMethod(
  "anomalize"
  , signature(x = "SpatRaster")
  , function(
    x
    , reference = NULL
    , ...
  ) {
    
    if (is.null(reference)) {
      reference = terra::app(
        x
        , fun = mean
        , ...
      )
    }
    
    return(x - reference)
  }
)