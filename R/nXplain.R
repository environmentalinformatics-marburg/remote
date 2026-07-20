methods::setGeneric(
  'nXplain'
  , function(x, ...) {
    standardGeneric('nXplain')
  }
)

#' Number of EOTs needed for variance explanation
#' 
#' @description 
#' The function identifies the number of modes needed to explain a certain 
#'   amount of variance within the response field.
#' 
#' @param x An `EotStack`.
#' @param var The minimum amount of variance to be explained by the modes as 
#'   `numeric`, defaults to `0.9`.
#' 
#' @note This is a post-hoc function. It needs an `EotStack` created as returned
#'   by [eot()]. Depending on the potency of the identified EOTs, it may be 
#'   necessary to compute a high number of modes in order to be able to explain 
#'   a large enough part of the variance.
#' 
#' @return The number of EOTs needed to explain 'var'.
#' 
#' @examples
#' gph <- terra::unwrap(vdendool)
#' 
#' nh_modes <- eot(x = gph, y = NULL, n = 3, 
#'                 standardised = FALSE, 
#'                 verbose = TRUE)
#'              
#' ### How many modes are needed to explain 25% of variance?              
#' nXplain(nh_modes, 0.25)
#' 
#' @export 
#' @name nXplain
#' @rdname nXplain
#' @aliases nXplain,EotStack-method

setMethod('nXplain', signature(x = 'EotStack'),
          function(x, var = 0.9) {
            expl.var <- sapply(seq(nmodes(x)), function(i) {
              x[[i]]@cum_exp_var
            })
            
            idx = var - expl.var <= 0

            if (!any(idx)) {
              paste(
                "explained variance of EotStack is lower than: %s"
                , "maximum explained variance of this EotStack is: %s"
                , sep = "\n"
              ) |> 
                sprintf(
                  var
                  , x[[nmodes(x)]]@cum_exp_var
                ) |> 
                stop(
                  call. = FALSE
                )
            }

            n <- min(which(idx), na.rm = TRUE)
            
            return(n)
          }
)
