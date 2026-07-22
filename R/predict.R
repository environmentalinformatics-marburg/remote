if ( !methods::isGeneric('predict') ) {
  methods::setGeneric(
    'predict'
    , function(object, ...) {
      standardGeneric('predict')
    }
  )
}

#' EOT based spatial prediction
#'
#' @description
#' Make spatial predictions using the fitted model returned by
#' [eot()]. A (user-defined) set of 'n' modes will be used to
#' model the outcome using the identified link functions of the respective modes
#' which are added together to produce the final prediction.
#'
#' @param object An `Eot*` object.
#' @param newdata The data to be used as predictor.
#' @param n The number of modes to be used for the prediction.
#' See [nXplain()] for calculating the number of modes based
#' on their explanatory power.
#' @param filename `character`, output filenames (optional). If specified,
#' this must be of the same length as `nlayers(newdata)`.
#' @param ... Further arguments passed to [terra::app()], and hence,
#' [terra::writeRaster()].
#'
#' @return
#' A `SpatRaster` of `nlayers(newdata)`.
#'
#' @seealso
#' [terra::app()], [terra::writeRaster()].
#'
#' @examples
#' ### not very useful, but highlights the workflow
#' \donttest{
#' sst = terra::unwrap(pacificSST)
#' pcp = terra::unwrap(australiaGPCP)
#'
#' ## train data using eot()
#' train <- eot(x = sst[[1:10]],
#'              y = pcp[[1:10]],
#'              n = 1)
#'
#' ## predict using identified model
#' pred <- predict(train,
#'                 newdata = sst[[11:20]],
#'                 n = 1)
#'
#' ## compare results
#' opar <- par(mfrow = c(1,2))
#' plot(pcp[[13]], main = "original", zlim = c(0, 10))
#' plot(pred[[3]], main = "predicted", zlim = c(0, 10))
#' par(opar)
#' }
#' @export
#' @name predict

# set methods -------------------------------------------------------------
#' @aliases predict,EotStack-method
#' @rdname predict
methods::setMethod(
  'predict'
  , signature(object = 'EotStack')
  , function(
    object
    , newdata
    , n = 1L
    , filename = ''
    , ...) {
      
      if (n == 1L) {
        return(
          predict(
            object[[1L]]
            , newdata = newdata
            , n = 1L
            , filename = filename
            , ...
          )
        )
      }
    
      ### extract identified EOT (@cell_bp)
      bps <- sapply(seq(n), function(i) object[[i]]@cell_bp)
      ts.modes <- t(terra::extract(newdata, bps))
      
      ### target files
      vld <- length(filename) == terra::nlyr(newdata)
      filename <- if (vld) filename else rep("", nrow(ts.modes))
      
      dots <- list(...)
      
      ### prediction using calculated intercept, slope and values
      terra::rast(
        lapply(seq(nrow(ts.modes)), function(i) {
          
          rst <- terra::rast(lapply(seq(ncol(ts.modes)), function(k) {
            object[[k]]@int_response +
            object[[k]]@slp_response * ts.modes[i, k]
          }))
          
          ### summate prediction for each mode at each time step
          dots_sub <- list(x = rst, fun = sum, filename = filename[i])
          dots_sub <- append(dots, dots_sub)
          
          do.call(terra::app, args = dots_sub)
        }
      )
    )
  }
)

#' @aliases predict,EotMode-method
#' @rdname predict
methods::setMethod(
  'predict'
  , signature(object = 'EotMode')
  , function(
    object
    , newdata
    , n = 1L
    , filename = ''
    , ...
  ) {
    
    ### extract identified EOT (@cell_bp)
    bps <- object@cell_bp
    ts.modes <- t(terra::extract(newdata, bps))
    
    ### target files
    vld <- length(filename) == terra::nlyr(newdata)
    filename <- if (vld) filename else rep("", nrow(ts.modes))
    
    dots <- list(...)
    
    ### prediction using claculated intercept, slope and values
    terra::rast(
      lapply(seq(nrow(ts.modes)), function(i) {
        
        rst <- terra::app(c(object@int_response, object@slp_response), 
        fun = function(x) x[[1L]] + x[[2L]] * ts.modes[i, ])
      })
    )
  }
)
