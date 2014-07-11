#' Create seasonal anomalies
#' 
#' @description
#' The function calculates anomalies of a RasterStack by supplying a 
#' suitable seasonal window. E. g. to create monthly anomalies of a 
#' raster stack of 12 layers per year, use \code{cycle.window = 12}.
#' 
#' @param x a RasterStack
#' @param cycle.window the window for the creation of the anomalies
#' @param ... currently not used
#' 
#' @return a deseasoned RasterStack
#' 
#' @seealso
#' \code{\link{anomalize}}, \code{\link{denoise}}
#' 
#' @export deseason
#' 
#' @examples 
#' data("australiaGPCP")
#' 
#' aus_dsn <- deseason(australiaGPCP, 12)
#' 
#' opar <- par(mfrow = c(1,2))
#' plot(australiaGPCP[[1]], main = "original")
#' plot(aus_dsn[[1]], main = "deseasoned")
#' par(opar)
deseason <- function(x, 
                     cycle.window = 12,
                     ...) {
  
  # Calculate layer averages based on supplied seasonal window
  x.mv <- stack(rep(lapply(1:cycle.window, function(i) {
    calc(x[[seq(i, nlayers(x), cycle.window)]], fun = mean)
  }), nlayers(x) / cycle.window))
  
  # Subtract monthly averages from actually measured values
  x.dsn <- x - x.mv
    
  # Return output
  return(x.dsn)
}
