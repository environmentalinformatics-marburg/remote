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
