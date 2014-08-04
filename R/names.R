#' Names of Eot* objects
#' 
#' @param x a EotMode or EotStack
#' 
#' @details
#' retrieves the names of Eot* objects
#' 
#' @return
#' if \code{x} is a EotStack, the names of the modes, 
#' if \code{x} is a EotMode, the names of the slots
#' 
#' @examples
#' data(vdendool)
#' 
#' nh_modes <- eot(vdendool, n = 2)
#' 
#' ## mode names
#' names(nh_modes)
#' 
#' ## slot names
#' names(nh_modes[[2]])
#' 
#' @export names
#' @name names
#' 

if (!isGeneric('names')) {
  setGeneric('names', function(x, ...)
    standardGeneric('names')) 
}

setMethod('names', signature(x = 'EotStack'), 
          function(x) { 
            ln <- names(x@modes)
            return(ln)
          }
)


setMethod('names', signature(x = 'EotMode'), 
          function(x) { 
            ln <- c("mode", "eot", "coords_bp", "cell_bp", "cum_exp_var",
                    "r_predictor", "rsq_predictor", "rsq_sums_predictor", 
                    "int_predictor", "slp_predictor", "p_predictor", 
                    "resid_predictor", "r_response", "rsq_response", 
                    "int_response", "slp_response", 
                    "p_response", "resid_response")
            return(ln)
          }
)
