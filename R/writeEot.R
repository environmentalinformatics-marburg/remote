methods::setGeneric(
  'writeEot'
  , function(x, ...) {
    standardGeneric('writeEot')
  }
)

#' Write `Eot*` objects to disk
#'  
#' @description
#' Write `Eot*` objects to disk. This is merely a wrapper around 
#' [terra::writeRaster()] so see respective help section for details.
#' 
#' @param x An `Eot*` object.
#' @param path.out The path to the folder to write the files to.
#' @param prefix A prefix to be added to the file names (see Details).
#' @param overwrite See [terra::writeRaster()]. In [writeEot()], this defaults 
#'   to `TRUE`.
#' @param ... Further arguments passed to [terra::writeRaster()] for `EotMode` 
#'   input, or to the underlying `EotMode` method for `EotStack` input. If 
#'   'filetype' is not specified, the default `"RRASTER"` format (`.grd`) is 
#'   used.
#' 
#' @details 
#' [writeEot()] will write the results of either an `EotMode` or an `EotStack`
#'   to disk. For each mode the following files will be written:
#' 
#' \itemize{
#' \item \emph{pred_r} - the `SpatRaster` of the correlation coefficients 
#'   between the base point and each pixel of the predictor domain
#' \item \emph{pred_rsq} - as above but for the coefficient of determination
#' \item \emph{pred_rsq_sums} - as above but for the sums of coefficient of 
#'   determination
#' \item \emph{pred_int} - the `SpatRaster` of the intercept of the 
#'   regression equation for each pixel of the predictor domain
#' \item \emph{pred_slp} - same as above but for the slope of the 
#'   regression equation for each pixel of the predictor domain
#' \item \emph{pred_p} - the `SpatRaster` of the significance (p-value) 
#'   of the the regression equation for each pixel of the predictor domain
#' \item \emph{pred_resid} - the `SpatRaster` of the reduced data 
#'   for the predictor domain
#' }
#' 
#' Apart from \emph{pred_rsq_sums}, all these files are also created for 
#' the response domain as \emph{resp_*}. These will be pasted together
#' with the prefix & the respective mode so that the file names will 
#' look like, e.g.:
#' 
#' \emph{prefix_mode_n_pred_r.grd}
#' 
#' for the `SpatRaster` of the predictor correlation coefficient 
#' of mode n using the standard \pkg{raster} file type (`.grd`).
#' 
#' @seealso [terra::writeRaster()]
#' 
#' @examples
#' \dontrun{
#' gph <- terra::unwrap(vdendool)
#' 
#' nh_modes <- eot(x = gph, y = NULL, n = 2, 
#'                 standardised = FALSE, 
#'                 verbose = TRUE)
#' 
#' ## write the complete EotStack
#' writeEot(nh_modes, prefix = "vdendool")
#' 
#' ## write only one EotMode
#' writeEot(nh_modes[[2]], prefix = "vdendool")
#' }
#' @export 
#' @name writeEot
#' @rdname writeEot 
#' @aliases writeEot,EotMode-method

# set methods -------------------------------------------------------------

methods::setMethod(
  'writeEot'
  , signature(x = 'EotMode')
  , function(
    x
    , path.out = "."
    , prefix = "remote"
    , overwrite = TRUE
    , ...
  ) { 
    
    ## get slots of interest
    slots = grep(
      "^(r|rsq|int|slp|p|resid).*_(predictor|response)$"
      , slotNames(x)
      , value = TRUE
    )

    ## imitate `raster::writeRaster()` default behavior for file type and 
    ## extension if 'filetype' is not specified
    dots = list(...)
    fext = ""

    if (!"filetype" %in% names(dots)) {
      dots$filetype = "RRASTER"
      fext = ".grd"
    }

    ## construct file names
    out.name = sprintf(
      "%s_mode_%02.f_%s%s"
      , prefix
      , x@mode
      , slots
      , fext
    )

    ## get objects to write
    out.object = lapply(slots, slot, object = x)
    
    ## write objects to disk
    Map(
      \(oo, on) {
        do.call(
          terra::writeRaster
          , args = c(
            list(
              x = oo
              , filename = file.path(path.out, on)
              , overwrite = overwrite
            )
            , dots
          )
        )
      }
      , out.object
      , out.name
    )
  }
)

#' @describeIn writeEot EotStack
#' @aliases writeEot,EotStack-method

methods::setMethod(
  'writeEot'
  , signature(x = 'EotStack')
  , function(
    x
    , ...
  ) {
    
    for (i in seq(nmodes(x))) {
      writeEot(
        x[[i]]
        , ...
      )
    }
  }
)