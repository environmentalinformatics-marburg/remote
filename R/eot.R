#' EOT analysis of a predictor and (optionally) a response RasterStack
#' 
#' @description
#' Calculate a given number of EOT modes either internally or between 
#' RasterStacks.
#' 
#' @param pred a ratser stack used as predictor
#' @param resp a RasterStack used as response. If \code{resp} is \code{NULL},
#' \code{pred} is used as \code{resp}
#' @param n the number of EOT modes to calculate
#' @param standardised logical. If \code{FALSE} the calculated r-squared values 
#' will be multiplied by the variance
#' @param write.out logical. If \code{TRUE} results will be written to disk 
#' using \code{path.out}
#' @param path.out the file path for writing results if \code{write.out} is \code{TRUE}.
#' Defaults to current working directory
#' @param names.out optional prefix to be used for naming of results if 
#' \code{write.out} is \code{TRUE}
#' @param reduce.both logical. If \code{TRUE} both \code{pred} and \code{resp} 
#' are reduced after each iteration. If \code{FALSE} only \code{resp} is reduced
#' @param type the type of the link function. Defaults to \code{'rsq'} as in original
#' proposed method from \cite{Dool2000}. If set to \code{'ioa'} index of agreement is
#' used instead
#' @param verbose logical. If \code{TRUE} some details about the 
#' calculation process will be output to the console
#' @param ... not used at the moment
#' 
#' @details 
#' For a detailed description of the EOT algorithm and the mathematics behind it,
#' see the References section. In brief, the algorithm works as follows: 
#' First, the temporal profiles of each pixel \emph{xp} of the predictor domain 
#' are regressed against the profiles of all pixels \emph{xr} in the 
#' response domain (in case of only a single field \emph{xr} = \emph{xp} - 1). 
#' The calculated coefficients of determination are summed up and the pixel 
#' with the highest sum is identified as the 'base point' of the first/leading mode. 
#' The temporal profile at this base point is the first/leading EOT. 
#' Then, the residuals from the regression are taken to be the basis 
#' for the calculation of the next EOT, thus ensuring orthogonality 
#' of the identified teleconnections. This procedure is repeated until 
#' a predefined amount of \emph{n} EOTs is calculated. In general, 
#' \pkg{Reot} implements a 'brute force' spatial data mining approach to 
#' identify locations of enhanced potential to explain spatio-temporal 
#' variability within the same or another geographic field.
#' 
#' @return 
#' a list of \code{n} EOTs. Each EOT is also a list with the following components:
#' \itemize{
#' \item \emph{mode} - the number of the identified mode
#' \item \emph{eot} - the EOT (time series) at the identified base point. Note, this is a simple numeric vector
#' \item \emph{coords_bp} - the coordinates of the identified base point
#' \item \emph{cell_bp} - the cell number of the indeified base point
#' \item \emph{explained_variance} - the (cumulative) explained variance of the considered EOT
#' \item \emph{r_predictor} - the \emph{RasterLayer} of the correlation coefficients 
#' between the base point and each pixel of the predictor domain
#' \item \emph{rsq_predictor} - as above but for the coefficient of determination
#' \item \emph{rsq_sums_predictor} - as above but for the sums of coefficient of determination
#' \item \emph{int_predictor} - the \emph{RasterLayer} of the intercept of the 
#' regression equation for each pixel of the predictor domain
#' \item \emph{slp_predictor} - same as above but for the slope of the 
#' regression equation for each pixel of the predictor domain
#' \item \emph{p_predictor} - the \emph{RasterLayer} of the significance (p-value) 
#' of the the regression equation for each pixel of the predictor domain
#' \item \emph{resid_predictor} - the \emph{RasterBrick} of the reduced data 
#' for the predictor domain
#' }
#' 
#' All \emph{*_predictor} fields are also returned for the \emph{*_response} domain, 
#' even if predictor and response domain are equal. This is due to that fact, 
#' that if not both fields are reduced after the first EOT is found, 
#' these \emph{RasterLayers} will differ.
#' 
#' 
#' @references 
#' \bold{Empirical Orthogonal Teleconnections}\cr
#' H. M. van den Dool, S. Saha, A. Johansson (2000)\cr
#' Journal of Climate, Volume 13, Issue 8, pp. 1421-1435\cr
#' \url{http://journals.ametsoc.org/doi/abs/10.1175/1520-0442%282000%29013%3C1421%3AEOT%3E2.0.CO%3B2
#' }
#'  
#' \bold{Empirical methods in short-term climate prediction}\cr
#' H. M. van den Dool (2007)\cr
#' Oxford University Press, Oxford, New York\cr
#' \url{http://www.oup.com/uk/catalogue/?ci=9780199202782}
#' 
#' @examples
#' ### EXAMPLE I:
#' ### a single field
#' data(vdendool)
#' 
#' # claculate 2 leading modes
#' nh_modes <- eot(pred = vdendool, resp = NULL, n = 2, 
#'                 reduce.both = FALSE, standardised = FALSE, 
#'                 verbose = TRUE)
#' 
#' plot(nh_modes, mode = 1, show.bp = TRUE)
#' plot(nh_modes, mode = 2, show.bp = TRUE)
#' 
#' @export eot
#' @name eot

# set methods -------------------------------------------------------------
if ( !isGeneric('eot') ) {
  setGeneric('eot', function(pred, ...)
    standardGeneric('eot'))
}

setMethod('eot', signature(pred = 'RasterStack'), 
          function(pred, 
                   resp = NULL, 
                   n = 1, 
                   standardised = TRUE, 
                   write.out = FALSE,
                   path.out = ".", 
                   names.out = NULL,
                   reduce.both = FALSE, 
                   type = c("rsq", "ioa"),
                   verbose = TRUE,
                   ...) {
            
            # Duplicate predictor set in case predictor and response are identical
            if (is.null(resp)) {
              resp <- pred  
              resp.eq.pred <- TRUE
            } else {
              resp.eq.pred <- FALSE
            }
            
            orig.var <- calcVar(resp, standardised = standardised)
            
            ### EOT
            
            # Loop through number of desired EOTs
            for (z in seq(n)) {
              
              # Use initial response data set in case of first iteration
              if (z == 1) {
                
                pred.eot <- EotCycle(pred = pred, 
                                     resp = resp,
                                     resp.eq.pred = resp.eq.pred,
                                     n = z, 
                                     type = type,
                                     standardised = standardised, 
                                     orig.var = orig.var,
                                     write.out = write.out,
                                     path.out = path.out, 
                                     verbose = verbose,
                                     names.out = names.out)
                
                # Use last entry of slot 'residuals' otherwise  
              } else if (z > 1) {
                tmp.pred.eot <- EotCycle(
                  pred = if (!reduce.both) {
                    pred
                  } else {
                    if (z == 2) {
                      pred.eot@resid_predictor
                    } else {
                      pred.eot[[z-1]]@resid_predictor
                    }
                  }, 
                  resp = if (z == 2) {
                    pred.eot@resid_response 
                  } else {
                    pred.eot[[z-1]]@resid_response
                  }, 
                  resp.eq.pred = resp.eq.pred,
                  n = z, 
                  type = type,
                  standardised = standardised, 
                  orig.var = orig.var,
                  write.out = write.out,
                  path.out = path.out,  
                  verbose = verbose,
                  names.out = names.out)
                
                if (z == 2) {
                  pred.eot <- list(pred.eot, tmp.pred.eot)
                  names(pred.eot) <- c("mode_1", paste("mode", z, sep = "_"))
                } else {
                  tmp.names <- names(pred.eot)
                  pred.eot <- append(pred.eot, list(tmp.pred.eot))
                  names(pred.eot) <- c(tmp.names, paste("mode", z, sep = "_"))
                }
              }
            }
            
            if (length(pred.eot) == 1) {
              out <- pred.eot
            } else {
              out <- new('EotStack', modes = pred.eot)
            }
            return(out)
          }
)

setMethod('eot', signature(pred = 'RasterBrick'), 
          function(pred, 
                   resp = NULL, 
                   n = 1, 
                   standardised = TRUE, 
                   write.out = FALSE,
                   path.out = ".", 
                   names.out = NULL,
                   reduce.both = FALSE, 
                   type = c("rsq", "ioa"),
                   verbose = TRUE,
                   ...) {
            
            # Duplicate predictor set in case predictor and response are identical
            if (is.null(resp)) {
              resp <- pred  
              resp.eq.pred <- TRUE
            } else {
              resp.eq.pred <- FALSE
            }
            
            orig.var <- calcVar(resp, standardised = standardised)
            
            ### EOT
            
            # Loop through number of desired EOTs
            for (z in seq(n)) {
              
              # Use initial response data set in case of first iteration
              if (z == 1) {
                
                pred.eot <- EotCycle(pred = pred, 
                                     resp = resp,
                                     resp.eq.pred = resp.eq.pred,
                                     n = z, 
                                     type = type,
                                     standardised = standardised, 
                                     orig.var = orig.var,
                                     write.out = write.out,
                                     path.out = path.out, 
                                     verbose = verbose,
                                     names.out = names.out)
                
                # Use last entry of slot 'residuals' otherwise  
              } else if (z > 1) {
                tmp.pred.eot <- EotCycle(
                  pred = if (!reduce.both) {
                    pred
                  } else {
                    if (z == 2) {
                      pred.eot@resid_predictor
                    } else {
                      pred.eot[[z-1]]@resid_predictor
                    }
                  }, 
                  resp = if (z == 2) {
                    pred.eot@resid_response 
                  } else {
                    pred.eot[[z-1]]@resid_response
                  }, 
                  resp.eq.pred = resp.eq.pred,
                  n = z, 
                  type = type,
                  standardised = standardised, 
                  orig.var = orig.var,
                  write.out = write.out,
                  path.out = path.out,  
                  verbose = verbose,
                  names.out = names.out)
                
                if (z == 2) {
                  pred.eot <- list(pred.eot, tmp.pred.eot)
                  names(pred.eot) <- c("mode_1", paste("mode", z, sep = "_"))
                } else {
                  tmp.names <- names(pred.eot)
                  pred.eot <- append(pred.eot, list(tmp.pred.eot))
                  names(pred.eot) <- c(tmp.names, paste("mode", z, sep = "_"))
                }
              }
            }
            
            if (length(pred.eot) == 1) {
              out <- pred.eot
            } else {
              out <- new('EotStack', modes = pred.eot)
            }
            return(out)
          }
)


