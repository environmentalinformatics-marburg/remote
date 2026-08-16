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
longtermMeans = function(x, cycle.window = 12L) {
  
  x = asSpatRaster(x)
  
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
