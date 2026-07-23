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
#' @param reference An optional single-layer `SpatRaster` (or `RasterLayer`) to 
#'   be used as the reference. Uses the overall mean of the original series if 
#'   `NULL` (default).
#' @param ... Additional arguments passed to [terra::app()] (e.g. 'cores', 
#'   'filename') to calculate the overall mean if 'reference' is `NULL`, or to
#'   the underlying `SpatRaster` method for `Raster*` input.
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
    
    ## early exit: 'reference' is not a raster
    if (!inherits(reference, what = c("SpatRaster", "Raster"))) {
      stop(
        sprintf(
          "Expected 'reference' to inherit from [%s], but got [%s]."
          , paste0(c("SpatRaster", "Raster"), collapse = ", ")
          , class(reference)[1L]
        )
        , call. = FALSE
      )
    }

    ## if required, convert 'reference' to `SpatRaster`
    if (inherits(reference, what = "Raster")) {
      reference = terra::rast(reference)
    }
    
    ## if required, use only the first 'reference' layer
    if (terra::nlyr(reference) > 1L) {
      warning(
        sprintf(
          paste(
            "Expected 'reference' to have a single layer, but got [%s]."
            , "Using the first layer only."
          )
          , terra::nlyr(reference)
        )
        , call. = FALSE
      )
      reference = reference[[1L]]
    }
    
    return(x - reference)
  }
)