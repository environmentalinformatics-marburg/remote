#' Noise filtering through principal components
#' 
#' @description
#' Filter noise from a raster series by decomposing into principal components 
#' and subsequent reconstruction using only a subset of components.
#' 
#' @param x A `SpatRaster` (or `Raster*`) series to be filtered.
#' @param k The number of components to be kept for reconstruction (ignored if 
#'   'expl.var' is supplied).
#' @param expl.var Minimum amount of variance to be kept after reconstruction
#' (should be set to `NULL` or omitted if 'k' is supplied).
#' @param weighted logical. If `TRUE` the covariance matrix will be 
#'   geographically weighted using the cosine of latitude during decomposition 
#'   (only important for lat/lon data).
#' @param use.cpp logical. Determines whether to use **Rcpp** functionality, 
#'   defaults to `TRUE`.
#' @param verbose logical. If `TRUE` some details about the calculation process 
#'   will be output to the console.
#' @param ... Additional arguments passed to [stats::princomp()].
#' 
#' @return A denoised `SpatRaster` series.
#' 
#' @note
#' Either 'k' or 'expl.var' must be specified. If both are supplied, 'k' will be
#'   ignored. If none are supplied, an error will be thrown.
#' 
#' @seealso
#' [anomalize()], [deseason()]
#' 
#' @examples
#' gph = terra::unwrap(vdendool)
#' gph_dns = denoise(gph, expl.var = 0.8)
#' 
#' opar = par(mfrow = c(1,2))
#' plot(gph[[1]], main = "original")
#' plot(gph_dns[[1]], main = "denoised")
#' par(opar)
#' 
#' @export
denoise = function(
  x
  , k = NULL
  , expl.var = NULL
  , weighted = TRUE
  , use.cpp = TRUE
  , verbose = TRUE
  , ...
) {
  
  x = asSpatRaster(x)
  
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
  stopifnot(
    "Either 'expl.var' or 'k' must be supplied." = 
    !is.null(expl.var) | !is.null(k)
  )
  
  if (!is.null(expl.var)) {
    k <- which(cumsum(pca$sdev^2 / sum(pca$sdev^2)) >= expl.var)[1]
  } else {
    expl.var <- cumsum(pca$sdev^2 / sum(pca$sdev^2))[k]
  }
  
  if (verbose) {
    fmt = paste(
      "\nUsing the first %s components (of %s) to reconstruct series..."
      , "these account for %s of variance in orig. series\n\n"
      , sep = "\n "
    )
    
    txt = sprintf(
      fmt
      , k
      , terra::nlyr(x)
      , expl.var
    )
    
    cat(txt)
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