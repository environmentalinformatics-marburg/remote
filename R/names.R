#' @export names

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
