#' Shorten a raster series
#' 
#' @description The function cuts a specified number of layers off a raster 
#'   series in order to create a lagged stack.
#' 
#' @param x A `SpatRaster` (or `Raster*`) series.
#' @param tail `logical`. If `TRUE` (default) the layers will be taken off
#' the end of the stack. If `FALSE` layers will be taken off
#' the beginning.
#' @param n The number of layers to take away as `integer`. If `NULL` (default), 
#'   'x' is returned unchanged.
#' 
#' @return A `SpatRaster` series shortened by 'n' layers either from the 
#' beginning or the end, depending on the specification of 'tail'.
#' 
#' @examples
#' pcp = terra::unwrap(australiaGPCP)
#' 
#' # 6 layers from the beginning
#' cutStack(pcp, tail = FALSE, n = 6)
#' # 8 layers from the end
#' cutStack(pcp, tail = TRUE, n = 8)
#' 
#' @export
cutStack = function(
  x
  , tail = TRUE
  , n = NULL
) {
  
  x = asSpatRaster(x)
  
  ## return unmodified raster series if `n == NULL`
  if (is.null(n)) {
    return(x)
  }
  
  ## take away layers from the end, e.g. if supplied series is predictor
  idx = if (tail) {
    1:(terra::nlyr(x) - n)
    ## take away layers from the start, e.g. if supplied series is response
  } else {
    seq.int(n + 1L, terra::nlyr(x))
  }
  
  return(x[[idx]])
}