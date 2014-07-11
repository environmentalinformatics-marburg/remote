#' Plot the results of eot
#' 
#' @description
#' This is the standard plotting routine for the results of \code{\link{eot}}.
#' Three panels will be drawn i) the predictor domain, ii) the response 
#' domain, iii) the time series at the identified base point
#' 
#' @param eot.obj an EOT object as returned by \code{\link{eot}}
#' @param mode numeric. the mode to be plotted
#' @param pred.prm the parameter of the predictor to be plotted.\cr
#' Can be any of "r", "rsq", "rsq.sums", "p", "int" or "slp"
#' @param resp.prm the parameter of the response to be plotted.\cr
#' Can be any of "r", "rsq", "rsq.sums", "p", "int" or "slp"
#' @param show.mode.loc logical. If \code{TRUE} a grey circle will be drawn 
#' in the predictor image to indicate the location of the mode
#' @param anomalies logical. If \code{TRUE} a reference line will be drawn
#' a 0 in the EOT time series
#' @param add.map logical. If \code{TRUE} country outlines will be added 
#' to the predictor and response images
#' @param times.vec an (optional) time series vector of the considered 
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
#' plotEot(modes)
#' 
#' # showing the loction of the mode
#' plotEot(modes, mode = 1, show.mode.loc = TRUE)
#' 
#' # changing parameters
#' plotEot(modes, mode = 1, show.mode.loc = TRUE,
#'         pred.prm = "r", resp.prm = "p")
#'         
#' # change plot arrangement
#' plotEot(modes, mode = 1, show.mode.loc = TRUE, arrange = "long") 
#' 
#' @export plotEot
plotEot <- function(eot.obj,
                    mode = 1,
                    pred.prm = "rsq",
                    resp.prm = "r",
                    show.mode.loc = FALSE,
                    anomalies = TRUE,
                    add.map = TRUE,
                    times.vec = NULL,
                    arrange = c("wide", "long"),
                    clr = colorRampPalette(
                      rev(brewer.pal(9, "Spectral")))(1000),
                    ...)
{
  
  library(latticeExtra)
  library(gridExtra)
  library(mapdata)
  
  p.prm <- paste(pred.prm, "predictor", sep = ".")
  r.prm <- paste(resp.prm, "response", sep = ".")
  
  if (is.null(times.vec)) 
    times.vec <- seq(nlayers(eot.obj[[1]]$resid.response))
  
  xy <- xyFromCell(eot.obj[[mode]]$rsq.predictor, 
                   cell = eot.obj[[mode]]$max.xy)
  
  mode.location.p <- xyplot(xy[1, 2] ~ xy[1, 1], cex = 2,
                           pch = 21, fill = "grey80", col = "black")
  
  if (isTRUE(add.map)) {
    mm180 <- map("world", plot = F, fill = T, col = "grey70")
    mm360 <- data.frame(map(plot = F, fill = T)[c("x","y")])
    mm360 <- within(mm360, {
      x <- ifelse(x < 0, x + 360, x)
      x <- ifelse((x < 1) | (x > 359), NA, x)
    })
    
    if (max(extent(eot.obj[[mode]][[p.prm]])@xmax) > 180) {
      mm.pred <- mm360
    } else {
      mm.pred <- mm180
    }
    
    if (max(extent(eot.obj[[mode]][[r.prm]])@xmax) > 180) {
      mm.resp <- mm360
    } else {
      mm.resp <- mm180
    }
  }
  
  px.pred <- ncell(eot.obj[[mode]][[p.prm]])
  px.resp <- ncell(eot.obj[[mode]][[r.prm]])
  
  pred.p <- spplot(eot.obj[[mode]][[p.prm]], 
                   mm = mm.pred, maxpixels = px.pred,
                   colorkey = list(space = "top",
                                   width = 0.7, height = 0.8), 
                   main = paste(p.prm, "mode", mode, sep = " "), 
                   col.regions = clr, panel = function(..., mm) {
                     panel.levelplot(...)
                     if (isTRUE(add.map)) {
                     panel.polygon(mm$x, mm$y, lwd = 0.5, 
                                   border = "grey20")
                     }
                     }, ...) 
  
  if (show.mode.loc) pred.p <- pred.p + as.layer(mode.location.p)
  
  resp.p <- spplot(eot.obj[[mode]][[r.prm]], 
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
  
  if (show.mode.loc) resp.p <- resp.p + as.layer(mode.location.p)
  
  ts.main <- paste("time series mode", mode, 
                   "- explained response domain variance:", 
                   round(if (mode > 1) {
                     eot.obj[[mode]]$exp.var * 100 -
                       eot.obj[[mode - 1]]$exp.var * 100
                     } else {
                       eot.obj[[mode]]$exp.var * 100
                       }, 2), "%", sep = " ")
  
  eot.ts <- xyplot(eot.obj[[mode]]$eot.series[1, ] ~ times.vec,
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
