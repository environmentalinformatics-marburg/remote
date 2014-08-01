#' EOT based spatial prediction
#' 
#' @name predict
#' @aliases predict
#' @export predict
#' @rdname predict

# set methods -------------------------------------------------------------
if ( !isGeneric('predict') ) {
  setGeneric('predict', function(object, ...)
    standardGeneric('predict'))
}

setMethod('predict', signature(object = 'EotStack'), 
          function(object, newdata, n, ...) {
            
            ### extract identified EOT (@cell_bp) 
            ts.modes <- sapply(seq(n), function(i) {
              newdata[object[[i]]@cell_bp]
            })
            
            ### prediction using claculated intercept, slope and values
            pred.stck <- lapply(seq(nlayers(newdata)), function(i) {
              stack(lapply(seq(ncol(ts.modes)), function(k) {
                object[[k]]@int_response + 
                  object[[k]]@slp_response * ts.modes[i, k]
              }))
            })
            
            ### summate prediction for each mode at each time step
            pred <- stack(lapply(seq(nrow(ts.modes)), function(i) {
              calc(pred.stck[[i]], fun = sum, ...)
            }))
            
            return(pred)
          }
)