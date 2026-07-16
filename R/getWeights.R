methods::setGeneric(
  "getWeights"
  , function(x, ...) {
    standardGeneric("getWeights")
  }
)

#' Calculate weights from latitude
#' 
#' @description Calculate weights using the cosine of latitude to compensate for
#'   area distortion of non-projected lat/lon data.
#' 
#' @param x A `SpatRaster` (or `Raster*`) object.
#' @param f A `function` applied to the latitude (in radians) to compute 
#'   weights. Defaults to `cos`.
#' @param ... Additional arguments passed to be passed to 'f', or to the 
#'   underlying `SpatRaster` method in general for `Raster*` input.
#' 
#' @return A `numeric` vector of weights for non-`NA` cells in 'x'.
#' 
#' @examples 
#' pcp = terra::unwrap(australiaGPCP)
#' 
#' wghts = getWeights(pcp)
#' utils::head(wghts)
#' 
#' wghts_rst = terra::setValues(pcp[[1]], wghts)
#' 
#' opar = par(mfrow = c(1,2))
#' plot(pcp[[1]], main = "data")
#' plot(wghts_rst, main = "weights")
#' par(opar)
#' 
#' @export getWeights
#' @name getWeights


################################################################################
### function using 'RasterStackBrick' ##########################################
#' @aliases getWeights,RasterStackBrick-method
#' @rdname getWeights
methods::setMethod(
  "getWeights"
  , signature(x = "RasterStackBrick")
  , function(
    x
    , ...
  ) {
    getWeights(
      terra::rast(x)
      , ...
    )
  }
)


################################################################################
### function using 'SpatRaster' ################################################
#' @aliases getWeights,SpatRaster-method
#' @rdname getWeights
methods::setMethod(
  "getWeights"
  , signature(x = "SpatRaster")
  , function(
    x
    , f = function(x) cos(x)
    , ...
  ) {
    
    # TODO: 
    # * what happens in the presence of `NA` values (length of weights vector is
    #   not a multiple of `ncell(x)`)? Use `na.all = TRUE` to account for all 
    #   layers in 'x', not just first?
    # * test for epsg:4326
    f(
      deg2rad(
        terra::crds(x, na.rm = TRUE)[, 2L]
      )
      , ...
    )
    
  }
)