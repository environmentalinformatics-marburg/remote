# set methods -------------------------------------------------------------
if ( !isGeneric('predict') ) {
  setGeneric('predict', function(object, ...)
    standardGeneric('predict'))
}

#' EOT based spatial prediction
#'
#' @description
#' Make spatial predictions using the fitted model returned by
#' [eot()]. A (user-defined) set of \emph{n} modes will be used to
#' model the outcome using the identified link functions of the respective modes
#' which are added together to produce the final prediction.
#'
#' @param object an \code{Eot*} object
#' @param newdata the data to be used as predictor
#' @param n the number of modes to be used for the prediction.
#' See [nXplain()] for calculating the number of modes based
#' on their explanatory power.
#' @param filename `character`, output filenames (optional). If specified,
#' this must be of the same length as \code{nlayers(newdata)}.
#' @param cores `integer`. Number of cores for parallel processing.
#' @param ... further arguments passed to [raster::calc()], and hence,
#' [raster::writeRaster()].
#'
#' @return
#' a \emph{RasterStack} of \code{nlayers(newdata)}
#'
#' @seealso
#' [raster::calc()], [raster::writeRaster()].
#'
#' @examples
#' ### not very useful, but highlights the workflow
#' \donttest{
#' data(pacificSST)
#' data(australiaGPCP)
#'
#' ## train data using eot()
#' train <- eot(x = pacificSST[[1:10]],
#'              y = australiaGPCP[[1:10]],
#'              n = 1)
#'
#' ## predict using identified model
#' pred <- predict(train,
#'                 newdata = pacificSST[[11:20]],
#'                 n = 1)
#'
#' ## compare results
#' opar <- par(mfrow = c(1,2))
#' plot(australiaGPCP[[13]], main = "original", zlim = c(0, 10))
#' plot(pred[[3]], main = "predicted", zlim = c(0, 10))
#' par(opar)
#' }
#' @export
#' @name predict
#' @rdname predict
#' @aliases predict,EotStack-method

setMethod('predict', signature(object = 'EotStack'),
          function(object,
                   newdata,
                   n = 1,
                   cores = 1L,
                   filename = '',
                   ...) {

            ### extract identified EOT (@cell_bp)
            bps <- sapply(seq(n), function(i) object[[i]]@cell_bp)
            ts.modes <- t(raster::extract(newdata, bps))

            ### target files and parallelization
            vld <- length(filename) == raster::nlayers(newdata)
            filename <- if (vld) filename else rep("", nrow(ts.modes))
            
            dots <- list(...)
            
            cl <- parallel::makePSOCKcluster(cores)
            on.exit(parallel::stopCluster(cl))
            parallel::clusterExport(cl, c("ts.modes", "object", "filename", 
                                          "dots"), envir = environment())

            ### prediction using calculated intercept, slope and values
            raster::stack(
              parallel::parLapply(cl, seq(nrow(ts.modes)), function(i) {

                rst <- raster::stack(lapply(seq(ncol(ts.modes)), function(k) {
                  object[[k]]@int_response +
                    object[[k]]@slp_response * ts.modes[i, k]
                }))
                
                ### summate prediction for each mode at each time step
                dots_sub <- list(x = rst, fun = sum, filename = filename[i])
                dots_sub <- append(dots, dots_sub)
                
                do.call(raster::calc, args = dots_sub)
              })
            )
          }
)

#' @aliases predict,EotMode-method
#' @rdname predict
setMethod('predict', signature(object = 'EotMode'),
          function(object,
                   newdata,
                   n = 1,
                   cores = 1L,
                   filename = '',
                   ...) {

            ### extract identified EOT (@cell_bp)
            bps <- object@cell_bp
            ts.modes <- t(raster::extract(newdata, bps))
            
            ### target files and parallelization
            vld <- length(filename) == raster::nlayers(newdata)
            filename <- if (vld) filename else rep("", nrow(ts.modes))
            
            dots <- list(...)

            cl <- parallel::makePSOCKcluster(cores)
            on.exit(parallel::stopCluster(cl))
            parallel::clusterExport(cl, c("ts.modes", "object", "filename", 
                                          "dots"), envir = environment())

            ### prediction using claculated intercept, slope and values
            raster::stack(
              parallel::parLapply(cl, seq(nrow(ts.modes)), function(i) {
                
                rst <- raster::overlay(object@int_response, object@slp_response, 
                                       fun = function(x, y) x + y * ts.modes[i, ])

                ### summate prediction for each mode at each time step
                dots_sub <- list(x = rst, fun = sum, filename = filename[i])
                dots_sub <- append(dots, dots_sub)
                
                do.call(raster::calc, args = dots_sub)
              })
            )
          }
)
