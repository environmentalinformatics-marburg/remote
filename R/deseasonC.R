#' Create seasonal anomalies (based on \strong{Rcpp})
#' 
#' @description
#' The function calculates seasonal anomalies from a 'RasterStack' object by 
#' supplying a suitable seasonal window. To create monthly anomalies of a 
#' 'RasterStack' encompassing 12 layers per year, for instance, use 
#' \code{cycle.window = 12}.
#' 
#' @param x a RasterStack
#' @param cycle.window the window for the creation of the anomalies
#' @param ... currently not used
#' 
#' @return A deseasoned 'RasterStack'.
#' 
#' @author Florian Detsch, \link{florian.detsch@staff.uni-marburg.de}
#' 
#' @seealso
#' \code{\link{anomalize}}, \code{\link{denoise}}
#' 
#' @export deseasonC
#' 
#' @examples 
#' data("australiaGPCP")
#' 
#' aus_dsnC <- deseasonC(australiaGPCP, 12)
#' 
#' opar <- par(mfrow = c(1,2))
#' plot(australiaGPCP[[1]], main = "original")
#' plot(aus_dsnC[[1]], main = "deseasoned")
#' par(opar)
deseasonC <- function(x, cycle.window = 12, ...) {
  
  ## raster to matrix
  mat <- as.matrix(x)
  
  ## deseasoning
  mat_mv <- monthlyMeansC(mat, cycle.window)
  rst_mv <- x[[1:cycle.window]]
  rst_mv <- setValues(rst_mv, values = mat_mv)
  
  rst_dsn <- x - rst_mv
  return(rst_dsn)
}