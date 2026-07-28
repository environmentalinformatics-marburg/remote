#' Create lagged raster series
#' 
#' @description
#' The function is used to produce two lagged raster series. The second is cut
#' from the beginning, the first from the tail to ensure equal output lengths
#' (provided that input lengths were equal).
#' 
#' @param x A `SpatRaster` (or `Raster*`) series to be cut from tail.
#' @param y A `SpatRaster` (or `Raster*`) series to be cut from beginning.
#' @param lag The desired lag in the native frequency of the series passed to 
#'   [cutStack()].
#' @param freq The frequency of the raster series as `integer`.
#' @param ... Currently not used.
#' 
#' @return
#' A `list` with the two raster series lagged by 'lag'.
#' 
#' @examples
#' sst = terra::unwrap(pacificSST)
#' pcp = terra::unwrap(australiaGPCP)
#' 
#' # lag GPCP by 4 months
#' lagged = lagalize(sst, pcp, lag = 4, freq = 12)
#' lagged[[1]][[1]] # check names to see date of layer
#' lagged[[2]][[1]] # -"-
#' 
#' @export
lagalize = function(
  x
  , y
  , lag = NULL
  , freq = 12L
  , ...
) {
  
  x = asSpatRaster(x)
  y = asSpatRaster(y)

  # Return list of unmodified raster series if lag == NULL
  if (is.null(lag)) {
    return(list(x, y))
  }
  
  rest <- freq - lag
  
  # Lagalize predictor stack
  x.lag <- cutStack(x = x, tail = TRUE, n = lag)
  x.lag.adj <- x.lag[[1:(terra::nlyr(x.lag) - rest)]]
  
  # Lagalize response stack
  y.lag <- cutStack(x = y, tail = FALSE, n = lag)
  y.lag.adj <- y.lag[[1:(terra::nlyr(y.lag) - rest)]]
  
  # Return list of lagalized stacks
  return(list(x.lag, y.lag))
  
}
