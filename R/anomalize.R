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
#' @param ... If `reference = NULL`, additional arguments passed to 
#'   [terra::app()] when calculating the overall mean (except for 'fun').
#' 
#' @return An anomaly `SpatRaster` series.
#' 
#' @seealso
#' [deseason()], [denoise()]
#' 
#' @examples
#' pcp = terra::unwrap(australiaGPCP)
#' pcp_anom = anomalize(pcp)
#' 
#' opar = par(mfrow = c(1,2))
#' plot(pcp[[10]], main = "original")
#' plot(pcp_anom[[10]], main = "anomalized")
#' par(opar)
#' 
#' @export
anomalize = function(
  x
  , reference = NULL
  , ...
) {
  
  x = asSpatRaster(x)
  
  if (is.null(reference)) {
    reference = terra::app(
      x
      , fun = mean
      , ...
    )
  } else {
  
    ## early exit: 'reference' is neither `NULL` nor a raster
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
    
    reference = asSpatRaster(reference)
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
