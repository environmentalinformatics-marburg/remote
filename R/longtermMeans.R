methods::setGeneric(
  "longtermMeans"
  , function(x, ...) {
    standardGeneric("longtermMeans")
  }
)

#' Calculate long-term means from a raster series
#' 
#' @description 
#' Calculate long-term means from an input raster series. Ideally, the number of
#' input layers should be divisable by the supplied 'cycle.window'. For 
#' instance, if 'x' consists of monthly layers, 'cycle.window' should be a 
#' multiple of `12`.
#' 
#' @param x A `SpatRaster` (or `Raster*`) series.
#' @param cycle.window `integer`, defaults to `12`. See [deseason()].
#' @param ... For `Raster*` input, arguments passed to the underlying 
#'   `SpatRaster` method.
#' 
#' @return
#' A `SpatRaster` with 'cycle.window' layers, each containing the mean across 
#' all corresponding time steps.
#' 
#' @author 
#' Florian Detsch
#' 
#' @seealso 
#' [deseason()]. 
#' 
#' @examples 
#' pcp = terra::unwrap(australiaGPCP)
#' 
#' longtermMeans(pcp)
#' 
#' @export
#' @name longtermMeans


################################################################################
### function using 'RasterStackBrick' ##########################################
#' @aliases longtermMeans,RasterStackBrick-method
#' @rdname longtermMeans
methods::setMethod(
  "longtermMeans"
  , signature(x = "RasterStackBrick")
  , function(
    x
    , ...
  ) {
    longtermMeans(
      x = terra::rast(x)
      , ...
    )
  }
)


################################################################################
### function using 'SpatRaster' ################################################
#' @aliases longtermMeans,SpatRaster-method
#' @rdname longtermMeans
methods::setMethod(
  "longtermMeans"
  , signature(x = "SpatRaster")
  , function(x, cycle.window = 12L) {
    
    ## insert values
    idx = rep(
      1:cycle.window
      , times = terra::nlyr(x) / cycle.window
    )
    
    rst_ltm = terra::tapp(
      x
      , index = idx
      , fun = mean
      , na.rm = TRUE
    )
    
    return(rst_ltm)
  }
)