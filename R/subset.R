if (!isGeneric('subset')) {
  setGeneric('subset', function(x, ...)
    standardGeneric('subset')) 
}

#' Subset modes in an `EotStack`
#' 
#' @description
#' Extract a set of modes from an `EotStack`.
#' 
#' @param x `EotStack` to be subset
#' @param subset `integer` or `character`. The modes to extract (either by
#'   their indexes or names).
#' @param drop If `TRUE`, a single selected mode is returned as an `EotMode`. 
#'   Defaults to `FALSE`, which always returns an `EotStack`.
#' @param ... Currently not used.
#' 
#' @return
#' An `EotMode` if a single mode is selected and `drop = TRUE`, otherwise an 
#'   `EotStack`.
#' 
#' @examples
#' gph <- terra::unwrap(vdendool)
#' 
#' nh_modes <- eot(x = gph, y = NULL, n = 3, 
#'                 standardised = FALSE, 
#'                 verbose = TRUE)
#'                 
#' subs <- subset(nh_modes, 2:3) # is the same as
#' subs <- nh_modes[[2:3]]
#' 
#' ## effect of 'drop=FALSE' when selecting a single layer
#' subs <- subset(nh_modes, 2)
#' class(subs)
#' subs <- subset(nh_modes, 2, drop = TRUE)
#' class(subs)
#' 
#' ## similarly to `drop = TRUE` above:
#' nh_modes[[2L]]
#' nh_modes[["mode_02"]]
#' 
#' @export subset
#' @name subset

################################################################################
### function using 'EotStack' ##################################################
#' @rdname subset
#' @aliases subset,EotStack-method
setMethod('subset', signature(x = 'EotStack'), 
          function(x, subset, drop = FALSE, ...) {
            if (is.character(subset)) {
              i <- na.omit(match(subset, names(x)))
              if (length(i) == 0) {
                stop('invalid mode names')
              } else if (length(i) < length(subset)) {
                warning('invalid mode names omitted')
              }
              subset <- i
            }
            # TODO: inconsistent behavior: invalid mode names are omitted in the
            #   presence of valid names, but invalid indexes are not
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

#' @rdname subset
#' @param i Index(es) or name(s) to be subset, delegated to [remote::subset()].

setMethod("[[", signature(x = "EotStack"), 
          function(x, i) {
            subset(x, i, drop = TRUE)
          }
)
