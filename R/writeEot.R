#' Write Eot* objects to disk
#' 
#' @export writeEot
#' 
#' @name writeEot
#' @aliases writeEot
#' @export writeEot
#' @rdname writeEot

if (!isGeneric('writeEot')) {
  setGeneric('writeEot', function(x, ...)
    standardGeneric('writeEot')) 
}

setMethod('writeEot', signature(x = 'EotMode'), 
          function(x, 
                   path.out,
                   prefix,
                   ...) { 
            
            out.name <- lapply(c("pred_r", "pred_rsq", "pred_rsq_sums", 
                                 "pred_int", "pred_slp", "pred_p", 
                                 "pred_resids", "resp_r", "resp_rsq", 
                                 "resp_int", "resp_slp", "resp_p", 
                                 "resp_resids"), 
                               function(i) {
                                 paste(prefix, "mode", sprintf("%02.f", 
                                                               x@mode), 
                                       i, sep = "_")
                               })
            
            out.object <- lapply(names(x)[6:18], function(j) {
              slot(x, j)
            })
            
            a <- b <- NULL
            
            foreach(a = unlist(out.object), 
                    b = unlist(out.name)) %do% { 
                      writeRaster(a, paste(path.out, b, sep = "/"), 
                                  overwrite = TRUE, ...)
                    }
          }
)


setMethod('writeEot', signature(x = 'EotStack'), 
          function(x, 
                   path.out,
                   prefix,
                   ...) {
            
            for (i in seq(nmodes(x))) {
              writeEot(x[[i]], 
                       path.out = path.out,
                       prefix = prefix,
                       ...)
            }
          }
)