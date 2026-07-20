methods::setGeneric(
  "deseason"
  , function(x, ...) {
    standardGeneric("deseason")
  }
)

#' Create seasonal anomalies
#' 
#' @description The function calculates anomalies of a raster object by 
#'   supplying a suitable seasonal window. E.g. to create monthly anomalies of a 
#'   raster stack of 12 layers per year, use `cycle.window = 12`.
#' 
#' @param x A `SpatRaster` (or `Raster*`) object or, alternatively, a `numeric`
#'   time series.
#' @param cycle.window `integer`, defaults to `12`. The window for the creation 
#'   of the anomalies.
#' @param use.cpp `logical`, defaults to `FALSE`. Determines whether or not to 
#'   use **Rcpp** functionality. Only applies if `x` is a raster object.
#' @param filename `character`. Output filename (optional).
#' @param ... For `SpatRaster` input: additional arguments passed to
#'   [terra::writeRaster()], only considered if `filename` is specified.
#'   For `Raster*` input: arguments passed to the underlying `SpatRaster`
#'   method (e.g. `cycle.window`, `use.cpp`, `filename`).
#' 
#' @return If `x` is a raster object, a deseasoned `SpatRaster`; else a 
#'   deseasoned `numeric` vector.
#' 
#' @seealso
#' [anomalize()], [denoise()]
#' 
#' @export deseason
#' @name deseason
#' 
#' @examples 
#' pcp = terra::unwrap(australiaGPCP)
#' pcp_dsn = deseason(pcp, cycle.window = 12)
#' 
#' opar = par(mfrow = c(1, 2))
#' plot(pcp[[1]], main = "original")
#' plot(pcp_dsn[[1]], main = "deseasoned")
#' par(opar)


################################################################################
### function using 'RasterStack' or 'RasterBrick' ##############################
#' @aliases deseason,RasterStackBrick-method
#' @rdname deseason
setMethod(
  "deseason"
  , signature(x = "RasterStackBrick")
  , function(
    x
    , ...
  ) {
    deseason(
      terra::rast(x)
      , ...
    )
  }
)


################################################################################
### function using 'SpatRaster' ################################################
#' @aliases deseason,SpatRaster-method
#' @rdname deseason
setMethod("deseason",
          signature(x = "SpatRaster"),
          function(x, 
                   cycle.window = 12L,
                   use.cpp = FALSE,
                   filename = "", 
                   ...) {
            
            if (use.cpp) {
              ## raster to matrix
              mat <- terra::as.matrix(x)
              
              ## deseasoning
              mat_mv <- monthlyMeansC(mat, cycle.window)
              x_mv <- x[[1:cycle.window]]
              x_mv <- terra::setValues(x_mv, values = mat_mv)
            } else {
              # Calculate layer averages based on supplied seasonal window
              x_mv <- terra::rast(lapply(1:cycle.window, function(i) {
                terra::app(x[[seq(i, terra::nlyr(x), cycle.window)]], 
                             fun = mean, na.rm = TRUE)
              }))
            }
            
            # Subtract monthly averages from actually measured values
            x_dsn <- x - x_mv
            
            # Write to file (optional)
            if (filename != "")
              x_dsn <- terra::writeRaster(x_dsn, filename = filename, ...)
            
            # Return output
            return(x_dsn)
          })


################################################################################
### function using 'numeric' ###################################################
#' @aliases deseason,numeric-method
#' @rdname deseason
setMethod("deseason",
          signature(x = "numeric"),
          function(x, 
                   cycle.window = 12L) {
            
            ## calculate long-term mean values
            x_mv <- sapply(1:cycle.window, function(i) {
              val <- x[seq(i, length(x), cycle.window)]
              mean(val, na.rm = TRUE)
            })
            
            ## create anomalies
            x_dsn <- x - x_mv
            
            # Return output
            return(x_dsn)
          })
