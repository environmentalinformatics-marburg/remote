#' @export subset


if (!isGeneric('subset')) {
  setGeneric('subset', function(x, ...)
    standardGeneric('subset')) 
}

setMethod('subset', signature(x = 'EotStack'), 
          function(x, subset, drop = TRUE, ...) {
            if (is.character(subset)) {
              i <- na.omit(match(subset, names(x)))
              if (length(i) == 0) {
                stop('invalid mode names')
              } else if (length(i) < length(subset)) {
                warning('invalid mode names omitted')
              }
              subset <- i
            }
            subset <- as.integer(subset)
            if (! all(subset %in% 1:nmodes(x))) {
              stop('not a valid subset')
            }
            if (length(subset) == 1 & drop) {
              x <- x@modes[[subset]]
            } else {
              x@modes <- x@modes[subset]
            }
            return(x)
          }
)

setMethod("[[", signature(x = "EotStack"), 
          function(x, i) {
            subset(x, i)
          }
)
