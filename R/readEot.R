#' Read \code{Eot}* files from disk
#' 
#' @description 
#' Read \code{Eot}* related files from disk, e.g. for further use with 
#' \code{\link[remote]{predict}}. 
#' 
#' @param x \code{character}, search path for \code{Eot}* related files passed 
#' to \code{\link{list.files}}. 
#' @param prefix \code{character}, see \code{\link{writeEot}} for details.
#' @param suffix \code{character}, file extension depending on the output file 
#' type of locally stored \code{Eot}* files, see \code{\link{writeRaster}}.
#' 
#' @return An \code{Eot}* object.
#' 
#' @seealso \code{\link{eot}}, \code{\link{writeEot}}, 
#' \code{\link{writeRaster}}.
#' 
#' @author Florian Detsch
#' 
#' @examples 
#' \dontrun{
#' ## calculate 3 leading modes
#' data(vdendool)
#' nh_modes <- eot(x = vdendool, n = 3, standardised = FALSE, 
#'                 write.out = TRUE, path.out = "~/data")
#'                 
#' ## reimport related files
#' rm(nh_modes)
#' nh_modes <- readEot("~/data")
#' nh_modes
#' }
#' 
#' @export readEot
#' @name readEot
readEot <- function(x, prefix = "remote", suffix = "grd") {
  
  fls_mds <- list.files(x, pattern = paste0(prefix, "_mode.*", suffix), 
                        full.names = TRUE)
  mds <- unique(sapply(strsplit(fls_mds, "_"), "[[", 3))
  
  dat_mds <- list.files(x, paste0(prefix, "_eot_locations.csv"), 
                        full.names = TRUE)
  dat_mds <- read.csv(dat_mds)
  
  ## patterns of required raster* files
  pttrn <- c(paste("", c("r", "rsq", "rsq_sums", "int", "slp", "p", "resid"), "predictor", sep = "_"), 
             paste("", c("r", "rsq", "int", "slp", "p", "resid"), "response", sep = "_"))
  
  lst_eot <- lapply(mds, function(n) {
    fls <- fls_mds[grep(n, fls_mds)]
    
    ids <- sapply(eotLayerNames(), function(j) grep(j, fls))
    fls <- fls[ids]
    
    lst <- lapply(1:length(fls), function(j) {
      if (j %in% c(7, 13)) raster::brick(fls[j]) else raster::raster(fls[j])
    })
    
    new('EotMode',
        mode = as.integer(n),
        name = paste("mode", n, sep = "_"),
        eot = numeric(),
        coords_bp = t(as.matrix(c("x" = dat_mds$x[as.integer(n)], 
                                  "y" = dat_mds$y[as.integer(n)]), 
                                ncol = 2)),
        cell_bp = dat_mds$cell_bp[as.integer(n)],
        cum_exp_var = dat_mds$cum_expl_var[as.integer(n)],
        r_predictor = lst[[1]],
        rsq_predictor = lst[[2]],
        rsq_sums_predictor = lst[[3]],
        int_predictor = lst[[4]], 
        slp_predictor = lst[[5]],
        p_predictor = lst[[6]],
        resid_predictor = lst[[7]],
        r_response = lst[[8]],
        rsq_response = lst[[9]],
        int_response = lst[[10]], 
        slp_response = lst[[11]],
        p_response = lst[[12]],
        resid_response = lst[[13]])
  })
  
  names(lst_eot) <- sapply(lst_eot, function(i) i@name)
  
  new('EotStack', modes = lst_eot, names = names(lst_eot))
}

# function to create patterns of required raster* files
eotLayerNames <- function() {
  c(paste("", c("r", "rsq", "rsq_sums", "int", "slp", "p", "resid"), "predictor", sep = "_"), 
    paste("", c("r", "rsq", "int", "slp", "p", "resid"), "response", sep = "_"))
}