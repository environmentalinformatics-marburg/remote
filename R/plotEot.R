#' Plot the results of eot
#' 
#' @description
#' This is the standard plotting routine for the results of \code{\link{eot}}.
#' Three panels will be drawn i) the predictor domain, ii) the response 
#' domain, iii) the time series at the identified base point
#' 
#' @param x an EotMode object as returned by \code{\link{eot}}
#' @param mode numeric. the mode to be plotted
#' @param pred.prm the parameter of the predictor to be plotted.\cr
#' Can be any of "r", "rsq", "rsq.sums", "p", "int" or "slp"
#' @param resp.prm the parameter of the response to be plotted.\cr
#' Can be any of "r", "rsq", "rsq.sums", "p", "int" or "slp"
#' @param show.bp logical. If \code{TRUE} a grey circle will be drawn 
#' in the predictor image to indicate the location of the base point
#' @param anomalies logical. If \code{TRUE} a reference line will be drawn
#' a 0 in the EOT time series
#' @param add.map logical. If \code{TRUE} country outlines will be added 
#' to the predictor and response images
#' @param ts.vec an (optional) time series vector of the considered 
#' EOT calculation to be shown as the x-axis in the time series plot
#' @param arrange whether the final plot should be arranged in "wide" or
#' "long" format
#' @param clr an (optional) color palette for displaying of the 
#' predictor and response fields
#' @param ... further arguments to be passed to \code{\link[raster]{spplot}}
#' 
#' @examples
#' data(vdendool)
#' 
#' # claculate 2 leading modes
#' modes <- eot(pred = vdendool, resp = NULL, n = 2, reduce.both = FALSE,
#'              standardised = FALSE, print.console = TRUE)
#'
#' # default settings 
#' plot(modes)
#' 
#' # showing the loction of the mode
#' plot(modes, mode = 1, show.bp = TRUE)
#' 
#' # changing parameters
#' plot(modes, mode = 1, show.bp = TRUE,
#'         pred.prm = "r", resp.prm = "p")
#'         
#' # change plot arrangement
#' plot(modes, mode = 1, show.bp = TRUE, arrange = "long") 
#' 
#' @export plotEot


# define function ---------------------------------------------------------
plotEot <- function(x,
                    mode = 1,
                    pred.prm = "rsq",
                    resp.prm = "r",
                    show.bp = FALSE,
                    anomalies = TRUE,
                    add.map = TRUE,
                    ts.vec = NULL,
                    arrange = c("wide", "long"),
                    clr = colorRampPalette(
                      rev(brewer.pal(9, "Spectral")))(1000),
                    ...)
{
  
  library(latticeExtra)
  library(gridExtra)
  library(mapdata)
  
  p.prm <- paste(pred.prm, "predictor", sep = "_")
  r.prm <- paste(resp.prm, "response", sep = "_")
  
  ps <- slot(x, p.prm)
  rs <- slot(x, r.prm)
  
  if (is.null(ts.vec)) 
    times.vec <- seq(nlayers(x@resid_response))
  
  xy <- xyFromCell(x@rsq_predictor, 
                   cell = x@cell_bp)
  
  mode.location.p <- xyplot(xy[1, 2] ~ xy[1, 1], cex = 2,
                           pch = 21, fill = "grey80", col = "black")
  
  if (isTRUE(add.map)) {
    mm180 <- map("world", plot = F, fill = T, col = "grey70")
    mm360 <- data.frame(map(plot = F, fill = T)[c("x","y")])
    mm360 <- within(mm360, {
      x <- ifelse(x < 0, x + 360, x)
      x <- ifelse((x < 1) | (x > 359), NA, x)
    })
    
    if (max(extent(ps)@xmax) > 180) {
      mm.pred <- mm360
    } else {
      mm.pred <- mm180
    }
    
    if (max(extent(rs)@xmax) > 180) {
      mm.resp <- mm360
    } else {
      mm.resp <- mm180
    }
  }
  
  px.pred <- ncell(ps)
  px.resp <- ncell(rs)
  
  pred.p <- spplot(ps, 
                   mm = mm.pred, maxpixels = px.pred,
                   colorkey = list(space = "top",
                                   width = 0.7, height = 0.8), 
                   main = x@mode, 
                   col.regions = clr, panel = function(..., mm) {
                     panel.levelplot(...)
                     if (isTRUE(add.map)) {
                       panel.polygon(mm$x, mm$y, lwd = 0.5, 
                                     border = "grey20")
                     }
                   }, ...) 
  
  if (show.bp) pred.p <- pred.p + as.layer(mode.location.p)
  
  resp.p <- spplot(rs, 
                   mm = mm.resp, maxpixels = px.resp,
                   colorkey = list(space = "top",
                                   width = 0.7, height = 0.8), 
                   main = paste(r.prm, "mode", mode, sep = " "), 
                   col.regions = clr, panel = function(..., mm) {
                     panel.levelplot(...)
                     if (isTRUE(add.map)) {
                       panel.polygon(mm$x, mm$y, lwd = 0.5, 
                                     border = "grey20")
                     }
                   }, ...) 
  
  if (show.bp) resp.p <- resp.p + as.layer(mode.location.p)
  
  md <- x@mode
  
  ts.main <- paste("time series mode", x@mode, 
                   "- explained response domain variance:", 
                   round(if (x@mode > 1) {
                     x@explained_variance * 100 
                     } else {
                       x@explained_variance * 100
                     }, 2), "%", sep = " ")
  
  eot.ts <- xyplot(x@eot ~ ts.vec,
                   type = "b", pch = 20, col = "black", 
                   ylab = "", xlab = "",
                   scales = list(tck = c(0.5, 0), x = list(axs = "i")), 
                   main = ts.main)
  
  if (anomalies) {
    eot.ts <- eot.ts + layer(panel.abline(h = 0, col = "grey40", lty = 3), 
                             under = TRUE)
  }

  ### set layout to wide or long
  arrange <- arrange[1]
  if (arrange == "wide") ncls <- 2 else ncls <- 1
  
  ### amalgamate pred.p and resp.p according to layout
  c.pred.resp <- arrangeGrob(pred.p, resp.p, ncol = ncls)
  
  ### clear plot area
  grid.newpage()
  
  ### combine c.pred.resp and eot time series and plot
  grid.arrange(c.pred.resp, eot.ts, heights = c(1, 0.5), ncol = 1)
  
}


# set methods -------------------------------------------------------------
if ( !isGeneric('plot') ) {
  setGeneric('plot', function(x, ...)
    standardGeneric('plot'))
}

setMethod('plot', signature(x = 'EotMode'), 
          plotEot)