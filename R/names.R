if (!isGeneric('names')) {
  setGeneric('names', function(x)
    standardGeneric('names')) 
}

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
#' @export
#' @name names
#' @rdname names
#' @aliases names,EotStack-method


setMethod('names', signature(x = 'EotStack'), 
          function(x) {
            ln <- sapply(seq(nmodes(x)), function(i) {
              paste("mode_", sprintf("%02.f", x[[i]]@mode), sep = "")
            })
            return(ln)
          }
)

#' @export
#' @name names
#' @rdname names
#' @aliases names,EotMode-method

setMethod('names', signature(x = 'EotMode'), 
          function(x) { 
            ln <- slotNames(x)
            return(ln)
          }
)



