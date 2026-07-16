methods::setGeneric(
  "denoise"
  , function(x, ...) {
    standardGeneric("denoise")
  }
)

#' Noise filtering through principal components
#' 
#' Filter noise from a RasterStack by decomposing into principal components 
#' and subsequent reconstruction using only a subset of components
#' 
#' @param x RasterStack to be filtered
#' @param k number of components to be kept for reconstruction 
#' (ignored if \code{expl.var} is supplied)
#' @param expl.var  minimum amount of variance to be kept after reconstruction
#' (should be set to NULL or omitted if \code{k} is supplied)
#' @param weighted logical. If `TRUE` the covariance matrix will be 
#' geographically weighted using the cosine of latitude during decomposition 
#' (only important for lat/lon data)
#' @param use.cpp logical. Determines whether to use \strong{Rcpp} 
#' functionality, defaults to `TRUE`.
#' @param verbose logical. If `TRUE` some details about the 
#' calculation process will be output to the console
#' @param ... additional arguments passed to [stats::princomp()]
#' 
#' @return a denoised RasterStack
#' 
#' @seealso
#' [anomalize()], [deseason()]
#' 
#' @export denoise
#' @name denoise
#' 
#' @examples
#' gph = terra::unwrap(vdendool)
#' gph_dns = denoise(gph, expl.var = 0.8)
#' 
#' opar = par(mfrow = c(1,2))
#' plot(gph[[1]], main = "original")
#' plot(gph_dns[[1]], main = "denoised")
#' par(opar)


################################################################################
### function using 'RasterStackBrick' ##########################################
#' @aliases denoise,RasterStackBrick-method
#' @rdname denoise
methods::setMethod(
  "denoise"
  , signature(x = "RasterStackBrick")
  , function(
    x
    , ...
  ) {
    denoise(
      terra::rast(x)
      , ...
    )
  }
)


################################################################################
### function using 'SpatRaster' ################################################
#' @aliases denoise,SpatRaster-method
#' @rdname denoise
methods::setMethod(
  "denoise"
  , signature(x = "SpatRaster")
  , function(
    x
    , k = NULL
    , expl.var = NULL
    , weighted = TRUE
    , use.cpp = TRUE
    , verbose = TRUE
    , ...
  ) {
    
    x.vals <- terra::values(x)
    #x.vals[is.na(x.vals)] <- 0
    
    # PCA
    if (weighted) { 
      pca <- stats::princomp(
        ~ x.vals
        , covmat = covWeight(
          x.vals
          , getWeights(x)
        )
        , scores = TRUE
        , na.action = stats::na.exclude
        , ...
      )
    } else {
      pca <- stats::princomp(
        ~ x.vals
        , scores = TRUE
        , na.action = stats::na.exclude
        , ...
      )
    }
    
    # declare reconstruction characteristics according to supplied values
    # TODO: `NULL` pointer in `else` if neither 'expl.var' nor 'k' are supplied
    if (!is.null(expl.var)) {
      k <- which(cumsum(pca$sdev^2 / sum(pca$sdev^2)) >= expl.var)[1]
    } else {
      expl.var <- cumsum(pca$sdev^2 / sum(pca$sdev^2))[k]
    }
    
    if (verbose) {
      paste(
        "\nUsing the first %s components (of %s) to reconstruct series..."
        , "these account for %s of variance in orig. series\n\n"
        , sep = "\n "
      ) |> 
        sprintf(
          k
          , terra::nlyr(x)
          , expl.var
        ) |> 
          cat()
    }
    
    # Reconstruction
    recons <- lapply(seq(terra::nlyr(x)), function(i) {
      rowSums(t(as.matrix(pca$loadings[, 1:k])[i, ] * 
      t(pca$scores[, 1:k]))) + pca$center[i]
    })
    
    # Insert reconstructed values in original data set 
    # TODO: discard 'use.cpp' option and always use {terra} for speed-up
    if (use.cpp) { 
      jnk <- insertReconsC(recons, x.vals)
      rst <- terra::setValues(x, jnk)
    } else {
      rst = terra::setValues(
        x
        , values = do.call(cbind, recons)
      )
    }
    
    # Return denoised data set
    return(rst)
    
  }
)