#' @export nmodes

if (!isGeneric('nmodes')) {
  setGeneric('nmodes', function(x, ...)
    standardGeneric('nmodes')) 
}

setMethod('nmodes', signature(x = 'EotStack'), 
          function(x) { 
            length(x@modes)
          }
)
