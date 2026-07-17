methods::setGeneric(
  "geoWeight"
  , function(x, ...) {
    standardGeneric("geoWeight")
  }
)

#' Geographic weighting
#' 
#' @description 
#' The function performs geographic weighting of non-projected long/lat data. By
#' default it uses the cosine of latitude (in radians) to compensate for the 
#' area distortion, though the user can supply other weighting functions.
#' 
#' @param x,f,... See [getWeights()]. In case of `Raster*` input, '...' funnels 
#'   additional arguments (i.e. 'f') to the underlying `SpatRaster` method.
#' 
#' @return A weighted `SpatRaster`.
#' 
#' @export geoWeight
#' @name geoWeight
#' 
#' @examples
#' gph <- terra::unwrap(vdendool)
#' wgtd <- geoWeight(gph)
#' 
#' opar <- par(mfrow = c(1,2))
#' plot(gph[[1]], main = "original")
#' plot(wgtd[[1]], main = "weighted")
#' par(opar)


################################################################################
### function using 'RasterStackBrick' ##########################################
#' @aliases geoWeight,RasterStackBrick-method
#' @rdname geoWeight
methods::setMethod(
  "geoWeight"
  , signature(x = "RasterStackBrick")
  , function(
    x
    , ...
  ) {
    geoWeight(
      terra::rast(x)
      , ...
    )
  }
)


################################################################################
### function using 'SpatRaster' ################################################
#' @aliases geoWeight,SpatRaster-method
#' @rdname geoWeight
methods::setMethod(
  "geoWeight"
  , signature(x = "SpatRaster")
  , function(
    x
    , f = cos
    , ...
  ) {
    
    # TODO: test for epsg:4326
    # NOTE: can't use `getWeights()` hereafter because of `na.rm = TRUE` 
    #   (required for compatibility with `princomp()`) therein

    x.vals <- x[]
    rads <- deg2rad(terra::crds(x)[, 2L])
    x.weightd <- x.vals * f(rads, ...)
    x[] <- x.weightd
    return(x)
    
  }
)