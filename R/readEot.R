#' Read `Eot*` files from disk
#' 
#' @description 
#' Read `Eot*` related files from disk, e.g. for further use with 
#' [remote::predict()] or [remote::plot()]. 
#' 
#' @param x `character`, search path for `Eot*` related files passed 
#' to [list.files()]. 
#' @param prefix `character`, see [writeEot()] for details. Should be the same 
#'   'prefix' as used during file creation in [eot()] or [writeEot()].
#' @param suffix `character`, default `.grd` for native `"RRASTER"` format. File
#'   extension depending on the output file type of locally stored `Eot*` files.
#' 
#' @return An `EotMode` if a single mode is found on disk, or an `EotStack` 
#'   otherwise.
#' 
#' @seealso [writeEot()]
#' 
#' @author Florian Detsch
#' 
#' @examples 
#' \dontrun{
#' ## calculate 3 leading modes
#' gph <- terra::unwrap(vdendool)
#' nh_modes <- eot(x = gph, n = 3, standardised = FALSE, 
#'                 write.out = TRUE, path.out = tempdir())
#'                 
#' ## reimport related files
#' rm(nh_modes)
#' nh_modes <- readEot(tempdir())
#' nh_modes
#' }
#' 
#' @export
readEot <- function(x, prefix = "remote", suffix = ".grd") {
  
  ## identify available files and modes
  fls_mds = list.files(
    x
    , pattern = sprintf(
      "^%s_mode_\\d+_.*_(predictor|response)%s$"
      , prefix
      , suffix
    )
    , full.names = TRUE
  )

  mds = regmatches(
    fls_mds
    , m = regexpr(
      "(?<=mode_)\\d+"
      , fls_mds
      , perl = TRUE
    )
  ) |> 
    unique()

  ## import locations and explained variance related to leading modes
  # TODO: `.csv` file is only created in `eot()`, not in `writeEot()`
  dat_mds = list.files(
    x
    , sprintf(
      "^%s_eot_locations\\.csv$"
      , prefix
    )
    , full.names = TRUE
  ) |> 
    utils::read.csv()

  ## loop over modes, creating 'EotMode' objects for each mode available
  lst_eot <- lapply(mds, function(n) {
    
    # track and reorder files related to current mode
    fls <- fls_mds[grep(paste0("mode_", n), basename(fls_mds))]
    ids <- sapply(eotLayerNames(), function(j) grep(j, fls))
    fls <- fls[ids]
    
    # import files
    lst <- lapply(1:length(fls), function(j) {
      terra::rast(fls[j])
    })
    
    # create 'EotMode' object
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

  ## for a single leading mode, return `EotMode`
  if (length(mds) == 1L) {
    return(lst_eot[[1L]])
  }
  
  ## else create an `EotStack` if more than one leading mode is available
  names(lst_eot) <- sapply(lst_eot, function(i) i@name)
  new('EotStack', modes = lst_eot, names = names(lst_eot))
}

# function to create patterns of required raster* files
eotLayerNames <- function() {
  c(paste("", c("r", "rsq", "rsq_sums", "int", "slp", "p", "resid"), "predictor", sep = "_"), 
    paste("", c("r", "rsq", "int", "slp", "p", "resid"), "response", sep = "_"))
}
