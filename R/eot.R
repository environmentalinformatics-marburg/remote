methods::setGeneric(
  "eot"
  , function(x, ...) {
    standardGeneric("eot")
  }
)

#' EOT analysis of a predictor and (optionally) a response raster series
#' 
#' @description
#' Calculate a given number of EOT modes either internally or between raster 
#' series.
#' 
#' @param x A `SpatRaster` (or `Raster*`) object used as predictor.
#' @param y A `SpatRaster` (or `Raster*`) object used as response. If 'y' is 
#'   `NULL` (default), 'x' is used as response.
#' @param n The number of EOT modes to calculate as `integer`, defaults to `1`.
#' @param standardised `logical`, default `TRUE`. If `FALSE` the calculated 
#'   r-squared values will be multiplied by the variance.
#' @param write.out `logical`, default `FALSE`. If `TRUE` results will be 
#'   written to disk using 'path.out'.
#' @param path.out The file path for writing results if 'write.out' is `TRUE`. 
#'   Defaults to current working directory.
#' @param prefix optional prefix to be used for naming of results if 'write.out'
#'   is `TRUE`.
#' @param reduce.both `logical`, default `FALSE`. If `TRUE` both 'x' and 'y' are
#'   reduced after each iteration. If `FALSE` only 'y' is reduced.
#' @param type The type of the link function. Defaults to `"rsq"` as in original
#'   proposed method from \cite{van den Dool 2000}. If set to `"ioa"` index of 
#'   agreement is used instead.
#' @param verbose `logical`, default `FALSE`. If `TRUE` some details about the 
#'   calculation process will be output to the console.
#' @param ... Currently not used.
#' 
#' @details 
#' For a detailed description of the EOT algorithm and the mathematics behind it,
#' see the References section. In brief, the algorithm works as follows: 
#' First, the temporal profiles of each pixel _xp_ of the predictor domain 
#' are regressed against the profiles of all pixels _xr_ in the 
#' response domain. 
#' The calculated coefficients of determination are summed up and the pixel 
#' with the highest sum is identified as the 'base point' of the first/leading mode. 
#' The temporal profile at this base point is the first/leading EOT. 
#' Then, the residuals from the regression are taken to be the basis 
#' for the calculation of the next EOT, thus ensuring orthogonality 
#' of the identified teleconnections. This procedure is repeated until 
#' a predefined amount of _n_ EOTs is calculated. In general, 
#' \pkg{remote} implements a 'brute force' spatial data mining approach to 
#' identify locations of enhanced potential to explain spatio-temporal 
#' variability within the same or another geographic field.
#' 
#' @return 
#' If `n = 1`` an `EotMode`, if n > 1 an `EotStack` of 'n' `EotMode`s. Each 
#' `EotMode` has the following components:
#' 
#' \itemize{
#' \item \emph{mode} - the number of the identified mode (1 - n)
#' \item \emph{eot} - the EOT (time series) at the identified base point. 
#' Note, this is a simple numeric vector, not of class `ts`
#' \item \emph{coords_bp} - the coordinates of the identified base point
#' \item \emph{cell_bp} - the cell number of the indeified base point
#' \item \emph{cum_exp_var} - the (cumulative) explained variance of the considered EOT
#' \item \emph{r_predictor} - the `SpatRaster` of the correlation coefficients 
#' between the base point and each pixel of the predictor domain
#' \item \emph{rsq_predictor} - as above but for the coefficient of determination
#' \item \emph{rsq_sums_predictor} - as above but for the sums of coefficient of determination
#' \item \emph{int_predictor} - the `SpatRaster` of the intercept of the 
#' regression equation for each pixel of the predictor domain
#' \item \emph{slp_predictor} - same as above but for the slope of the 
#' regression equation for each pixel of the predictor domain
#' \item \emph{p_predictor} - the `SpatRaster` of the significance (p-value) 
#' of the the regression equation for each pixel of the predictor domain
#' \item \emph{resid_predictor} - the `SpatRaster` of the reduced data 
#' for the predictor domain
#' }
#' 
#' Apart from *rsq_sums_predictor*, all *&ast;_predictor* fields are 
#' also returned for the \emph{*_response} domain, 
#' even if predictor and response domain are equal. This is due to that fact, 
#' that if not both fields are reduced after the first EOT is found, 
#' these `SpatRaster`s will differ.
#' 
#' @references 
#' \bold{Empirical Orthogonal Teleconnections}\cr
#' H. M. van den Dool, S. Saha, A. Johansson (2000)\cr
#' Journal of Climate, Volume 13, Issue 8, pp. 1421-1435\cr
#' \doi{10.1175/1520-0442(2000)013<1421:EOT>2.0.CO;2}
#'  
#' \bold{Empirical Methods in Short-Term Climate Prediction}\cr
#' H. M. van den Dool (2007)\cr
#' Oxford University Press, Oxford, New York\cr
#' \doi{https://doi.org/10.1093/oso/9780199202782.001.0001}
#' 
#' @examples
#' ### EXAMPLE I
#' ### a single field
#' \donttest{
#' gph = terra::unwrap(vdendool)
#' 
#' ## calculate 2 leading modes
#' nh_modes <- eot(x = gph, y = NULL, n = 2, 
#'                 standardised = FALSE, 
#'                 verbose = TRUE)
#' 
#' plot(nh_modes, y = 1, show.bp = TRUE)
#' plot(nh_modes, y = 2, show.bp = TRUE)
#' }
#' 
#' @export
#' @name eot


################################################################################
### function using 'RasterStackBrick' ##########################################
#' @aliases eot,RasterStackBrick-method
#' @rdname eot
methods::setMethod(
  "eot"
  , signature(x = "RasterStackBrick")
  , function(
    x
    , ...
  ) {
    eot(
      terra::rast(x)
      , ...
    )
  }
)


################################################################################
### function using 'SpatRaster' ################################################
#' @aliases eot,SpatRaster-method
#' @rdname eot
methods::setMethod(
  "eot"
  , signature(x = "SpatRaster")
  , function(
    x
    , y = NULL
    , n = 1
    , standardised = TRUE
    , write.out = FALSE
    , path.out = "."
    , prefix = "remote"
    , reduce.both = FALSE
    , type = c("rsq", "ioa")
    , verbose = TRUE
    , ... # TODO: pass to `writeEot()` (via `EotCycle()`), e.g. 'filetype'
  ) {
    
    type = match.arg(type)
    
    ## duplicate predictor set in case predictor and response are identical
    if (is.null(y)) {
      y <- x  
    }
    
    orig.var <- calcVar(y, standardised = standardised)
    
    ## loop through number of desired eots
    for (z in 1:n) {
      
      # use initial response data set in case of first iteration
      if (z == 1) {
        
        x.eot <- EotCycle(
          x = x
          , y = y
          , n = z
          , type = type
          , standardised = standardised
          , orig.var = orig.var
          , write.out = write.out
          , path.out = path.out
          , verbose = verbose
          , prefix = prefix
        )
        
        names(x.eot) <- sprintf("mode_%02d", z)
        next
        
      }
      
      # use last entry of slot 'residuals' otherwise
      tmp.x.eot <- EotCycle(
        x = if (!reduce.both) {
          x
        } else {
          if (z == 2) {
            x.eot@resid_predictor
          } else {
            x.eot[[z-1]]@resid_predictor
          }
        }, 
        y = if (z == 2) {
          x.eot@resid_response 
        } else {
          x.eot[[z-1]]@resid_response
        }, 
        # y.eq.x = y.eq.x,
        n = z, 
        type = type,
        standardised = standardised, 
        orig.var = orig.var,
        write.out = write.out,
        path.out = path.out,  
        verbose = verbose,
        prefix = prefix
      )
      
      if (z == 2) {
        x.eot <- list(x.eot, tmp.x.eot)
        names(x.eot) <- sprintf("mode_%02d", c(1, z))
      } else {
        tmp.names <- names(x.eot)
        x.eot <- append(x.eot, list(tmp.x.eot))
        names(x.eot) <- c(
          tmp.names
          , sprintf("mode_%02d", z)
        )
      }
    }
    
    if (length(x.eot) == 1) {
      out <- x.eot
    } else {
      out <- new('EotStack', modes = x.eot, names = names(x.eot))
    }
    return(out)
  }
)
