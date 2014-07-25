#' Calculate a single EOT
#' 
#' @description
#' EotCycle() calculates a single EOT and is controlled by the main eot() function
#' 
#' @param pred a ratser stack used as predictor
#' @param resp a RasterStack used as response. If \code{resp} is \code{NULL},
#' \code{pred} is used as \code{resp}
#' @param resp.eq.pred logical. Whether predictor and response stack are the same
#' @param n the number of EOT modes to calculate
#' @param standardised logical. If \code{FALSE} the calculated r-squared values 
#' will be multiplied by the variance
#' @param orig.var original variance of the response domain
#' @param write.out logical. If \code{TRUE} results will be written to disk 
#' using \code{path.out}
#' @param path.out the file path for writing results if \code{write.out} is \code{TRUE}.
#' Defaults to current working directory
#' @param names.out optional prefix to be used for naming of results if 
#' \code{write.out} is \code{TRUE}
#' @param type the type of the link function. Defaults to \code{'rsq'} as in original
#' proposed method from \cite{Dool2000}. If set to \code{'ioa'} index of agreement is
#' used instead
#' @param print.console logical. If \code{TRUE} some details about the 
#' calculation process will be output to the console
#' @param ... not used at the moment
#' 
#' @export EotCycle
EotCycle <- function(pred, 
                     resp, 
                     resp.eq.pred = F,
                     n = 1,
                     standardised, 
                     orig.var,
                     write.out,
                     path.out,
                     names.out,
                     type,
                     print.console,
                     ...) {
  
    ### Identification of the most explanatory pred pixel
  
  # Extract pixel entries from RasterStack objects
  pred.vals <- getValues(pred)
  resp.vals <- getValues(resp)
  type <- type[1]
  
  # Calculate and summarize R-squared per pred pixel
  if (print.console) {
    cat("\nCalculating linear model ...", "\n")
  }
  
  type <- type[1]
  if (type == "rsq") {
    x <- predRsquaredSum(pred_vals = pred.vals, resp_vals = resp.vals, 
                         standardised = standardised)
  } else {
    x <- iodaSumC(pred_vals = pred.vals, resp_vals = resp.vals)
  }
  
  # Identify pred pixel with highest sum of r.squared
  if (print.console) {
    cat("Locating ", n, ". EOT ...", "\n", sep = "")
  }
  
  maxxy.all <- which(x == max(x, na.rm = TRUE))
  maxxy <- maxxy.all[1]

  if (length(maxxy.all) != 1) {
    if (print.console) {
      cat("WARNING:", "\n",
          "LOCATION OF EOT AMBIGUOUS! MULTIPLE POSSIBLE LOCATIONS DETECTED, 
        USING ONLY THE FIRST!\n\n")
    }
  }

  if (print.console) {
    cat("Location:", xyFromCell(pred, maxxy), "\n", sep = " ")
  }
  
  ### Regression of most explanatory pred pixel with resp pixels
    
  ## Fit lm
  
  # lm(resp.vals[i, ] ~ pred.vals[maxxy, ]) with T statistics
  resp.lm.param.t <- respLmParam(pred.vals, resp.vals, maxxy - 1) # C++ starts at 0!
  # Calculate p value from T statistics
  resp.lm.param.p <- lapply(resp.lm.param.t, function(i) {
    tmp <- i
    tmp[[5]] <- 2 * pt(-abs(tmp[[5]]), df = tmp[[6]])
    
    return(tmp)
  })  
  
  
  ## Rasterize lm parameters
  
  # RasterLayer template for R-squared, slope and p value
  rst.resp.template <- raster(nrows = nrow(resp), ncols = ncol(resp), 
                         xmn = xmin(resp), xmx = xmax(resp), 
                         ymn = ymin(resp), ymx = ymax(resp))
  
  rst.resp.r <- rst.resp.rsq <- rst.resp.intercept <- 
    rst.resp.slp <- rst.resp.p <- rst.resp.template

  # RasterBrick template for residuals
  brck.resp.resids <- brick(nrows = nrow(resp), ncols = ncol(resp), 
                            xmn = xmin(resp), xmx = xmax(resp), 
                            ymn = ymin(resp), ymx = ymax(resp), 
                            nl = nlayers(resp))
  
  # R
  rst.resp.r[] <- sapply(resp.lm.param.p, "[[", 1)
  # R-squared
  rst.resp.rsq[] <- sapply(resp.lm.param.p, "[[", 1) ^ 2
  # Intercept
  rst.resp.intercept[] <- sapply(resp.lm.param.p, "[[", 2)
  # Slope
  rst.resp.slp[] <- sapply(resp.lm.param.p, "[[", 3)
  # P value
  rst.resp.p[] <- sapply(resp.lm.param.p, "[[", 5)
  # Residuals
  brck.resp.resids[] <- matrix(sapply(resp.lm.param.p, "[[", 4), 
                               ncol = nlayers(pred), byrow = TRUE)
  # EOT over time
  eot.ts <- raster::extract(pred, maxxy)
  
  ### Regression of most explanatory pred pixel with pred pixels
  
  # Following code is only executed when pred and resp are not equal
  #if (!resp.eq.pred) {
    
    ## Fit lm
    
    # lm(pred.vals[i, ] ~ pred.vals[maxxy, ]) with T statistics
    pred.lm.param.t <- respLmParam(pred.vals, pred.vals, maxxy - 1) # C++ starts at 0!
    # Calculate p value from T statistics
    pred.lm.param.p <- lapply(pred.lm.param.t, function(i) {
      tmp <- i
      tmp[[5]] <- 2 * pt(-abs(tmp[[5]]), df = tmp[[6]])
      
      return(tmp)
    })  
    
    
    ## Rasterize lm parameters
    
    # RasterLayer template for R-squared, slope and p value
    rst.pred.template <- raster(nrows = nrow(pred), ncols = ncol(pred), 
                                xmn = xmin(pred), xmx = xmax(pred), 
                                ymn = ymin(pred), ymx = ymax(pred))
    
    rst.pred.r <- rst.pred.rsq <- rst.pred.rsq.sums <- rst.pred.intercept <- 
      rst.pred.slp <- rst.pred.p <- rst.pred.template
    
    # RasterBrick template for residuals
    brck.pred.resids <- brick(nrows = nrow(pred), ncols = ncol(pred), 
                              xmn = xmin(pred), xmx = xmax(pred), 
                              ymn = ymin(pred), ymx = ymax(pred), 
                              nl = nlayers(pred))
    
    # R
    rst.pred.r[] <- sapply(pred.lm.param.p, "[[", 1)
    # R-squared
    rst.pred.rsq[] <- sapply(pred.lm.param.p, "[[", 1) ^ 2
    # R-squared sums
    rst.pred.rsq.sums[] <- x
    # Intercept
    rst.pred.intercept[] <- sapply(pred.lm.param.p, "[[", 2)
    # Slope
    rst.pred.slp[] <- sapply(pred.lm.param.p, "[[", 3)
    # P value
    rst.pred.p[] <- sapply(pred.lm.param.p, "[[", 5)
    # Residuals
    brck.pred.resids[] <- matrix(sapply(pred.lm.param.p, "[[", 4), 
                                 ncol = nlayers(pred), byrow = TRUE)
  
    #expl.var <- x[maxxy] / orig.var
  if (!standardised) {
    t <- mean(apply(getValues(brck.resp.resids), 1, var, na.rm = TRUE), 
              na.rm = TRUE)
    s <- mean(apply(getValues(brck.resp.resids), 2, var, na.rm = TRUE), 
              na.rm = TRUE)
    resid.var <- t + s
  } else {
    resid.var <- var(as.vector(getValues(brck.resp.resids)), na.rm = TRUE)
  }
  
  expl.var <- (orig.var - resid.var) / orig.var
  
  if (print.console) {
    cat("Cum. expl. variance (%):", expl.var * 100, "\n", sep = " ")
  }
  
  xy <- xyFromCell(pred, maxxy)
  location.df <- as.data.frame(cbind(xy, paste("EOT", 
                                               sprintf("%02.f", n), 
                                               sep = "_"),
                                     expl.var,
                                     if (length(maxxy.all) != 1) 
                                       "ambiguous" else "ok"),
                               stringsAsFactors = FALSE)
  names(location.df) <- c("x", "y", "EOT", "cum_expl_var", "comment")
  mode(location.df$x) <- "numeric"
  mode(location.df$y) <- "numeric"
  mode(location.df$cum_expl_var) <- "numeric"
    
    ### Output
    
    # Output returned by function
  out <- new('EotMode',
             eot = eot.ts,
             coords_bp = location.df,
             cell_bp = maxxy,
             explained_variance = expl.var,
             r_predictor = rst.pred.r,
             rsq_predictor = rst.pred.rsq,
             rsq_sums_predictor = rst.pred.rsq.sums,
             int_predictor = rst.pred.intercept, 
             slp_predictor = rst.pred.slp,
             p_predictor = rst.pred.p,
             resid_predictor = brck.pred.resids,
             r_response = rst.resp.r,
             rsq_response = rst.resp.rsq,
             int_response = rst.resp.intercept, 
             slp_response = rst.resp.slp,
             p_response = rst.resp.p,
             resid_response = brck.resp.resids)
  
    # Output storage (optional)
    if (write.out) {
      out.name <- lapply(c("pred_r", "pred_rsq", "pred_rsq_sums", 
                           "pred_int", "pred_slp", "pred_p", "pred_resids", 
                           "resp_r", "resp_rsq", "resp_int", "resp_slp", 
                           "resp_p", "resp_resids"), 
                         function(i) {
                           paste(names.out, "eot", sprintf("%02.f", n), 
                                 i, sep = "_")
                         })
      
      df.name <- paste(names.out, "eot_locations.csv", sep = "_")
      
      write.table(location.df, col.names = FALSE,
                  paste(path.out, df.name, sep = "/"), 
                  row.names = FALSE, append = TRUE, sep = ",")
      
      a <- b <- NULL
      
      foreach(a = c(rst.pred.r, rst.pred.rsq, rst.pred.rsq.sums, 
                    rst.pred.intercept, rst.pred.slp, rst.pred.p, 
                    brck.pred.resids, rst.resp.r, rst.resp.rsq, 
                    rst.resp.intercept, rst.resp.slp, rst.resp.p, 
                    brck.resp.resids), 
              b = unlist(out.name)) %do% { 
                writeRaster(a, paste(path.out, b, sep = "/"), 
                            format = "raster", overwrite = TRUE, ...)
              }
      
      rm(list = c("eot.ts",
                  "maxxy",
                  "location.df",
                  "expl.var",
                  "rst.pred.r",
                  "rst.pred.rsq",
                  "rst.pred.rsq.sums",
                  "rst.pred.intercept", 
                  "rst.pred.slp",
                  "rst.pred.p",
                  "brck.pred.resids",
                  "rst.resp.r",
                  "rst.resp.rsq",
                  "rst.resp.intercept", 
                  "rst.resp.slp",
                  "rst.resp.p",
                  "brck.resp.resids"))
      gc()
      
    }

  return(out)
  
}