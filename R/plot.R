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

### some helper functions especially for the grid layout
### resizingTextGrob from 
### http://ryouready.wordpress.com/2012/08/01/
resizingTextGrob <- function(..., scale.fact = 1) {
  
  grob(tg = textGrob(...), cl = "resizingTextGrob", 
       scale.fact = scale.fact)
  
}

drawDetails.resizingTextGrob <- function(x, scale.fact, recording = TRUE) {
  
  grid.draw(x$tg)
  
}

preDrawDetails.resizingTextGrob <- function(x, ...) {
  
  library(scales)
  
  h <- convertHeight(unit(1, "npc"), "mm", valueOnly = TRUE)
  fs <- rescale(h, to = c(80, 15), from = c(120, 20)) * x$scale.fact
  pushViewport(viewport(gp = gpar(fontsize = fs)))
  
}

postDrawDetails.resizingTextGrob <- function(x) popViewport()
###


# definde function --------------------------------------------------------
plotLocations <- function(x, ...) {
  
  library(latticeExtra)
  library(gridExtra)
  library(mapdata)
  
  ### plot function
  loc.df <- as.data.frame(do.call("rbind", 
                                  lapply(seq(nmodes(x)), function(i) {
                                    xyFromCell(x[[i]]@rsq_predictor, 
                                               cell = x[[i]]@cell_bp)
                                  })))
  
  loc.df$eot <- paste("EOT", sprintf("%02.f", seq(x)), 
                      sep = "_")
  
  mm <- map("world", plot = FALSE, fill = TRUE)
  px.pred <- ncell(x[[1]]@r_predictor)
  
  pred.p <- spplot(x[[1]]@rsq_predictor, 
                   mm = mm, maxpixels = px.pred,
                   colorkey = FALSE, 
                   col.regions = "grey50", panel = function(..., mm) {
                     panel.levelplot(...)
                     panel.polygon(mm$x, mm$y, lwd = 0.5, 
                                   border = "grey20", col = "grey70")
                   }, ...) 
  
  clrs.hcl <- function(n) {
    hcl(h = seq(270, 0, length.out = n), 
        c = 70, l = 50, fixup = TRUE)
  }
  
  n <- nmodes(x)
  clrs <- clrs.hcl(n)
  
  points.p <- xyplot(y ~ x, data = loc.df, col = "black", 
                     fill = clrs, pch = 21,
                     cex = 2)
  
  out <- pred.p + as.layer(points.p)
  
  grid.newpage()
  
  map.vp <- viewport(x = 0, y = 0, 
                     height = 1, width = 0.85,
                     just = c("left", "bottom"))
  
  pushViewport(map.vp)
  
  print(out, newpage = FALSE)
  
  downViewport(trellis.vpname(name = "figure"))
  
  leg.vp <- viewport(x = 1, y = 0.5, 
                     height = n / 10, width = 0.15,
                     just = c("left", "centre"))
  
  pushViewport(leg.vp)  
  
  if(n == 1) ypos <- 0.5 else ypos <- seq(0.95, 0.05, length.out = n + 2)
  if(n == 1) ypos <- ypos else ypos <- ypos[-c(1, length(ypos))]
  xpos.pts <- unit(0.15, "npc")
  size.pts <- 1 / n
  
  for (i in 1:n) {
    
    vp <- viewport(x = xpos.pts, y = ypos[i], 
                   height = size.pts, width = 0.1,
                   just = c("left", "centre"))
    
    pushViewport(vp)
    
    grid.circle(gp = gpar(fill = clrs[i], 
                          col = "black"))
    
    upViewport()
    
  }
  
  xpos.txt <- unit(0.25, "npc")
  width.txt <- 0.7
  
  for (i in 1:n) {
    
    vp <- viewport(x = xpos.txt, y = ypos[i], 
                   height = size.pts, width = width.txt,
                   just = c("left", "centre"))
    
    pushViewport(vp)
    
    txt <- textGrob(x = 0.2, sort(names(x))[i],
                    just = "left")
    
    grid.draw(txt)
    
    popViewport()
    
  }
  
  upViewport(0)
  
}


# define function ---------------------------------------------------------
plotEotMode <- function(x,
                        locations = FALSE,
                        pred.prm = "rsq",
                        resp.prm = "r",
                        show.bp = FALSE,
                        anomalies = TRUE,
                        add.map = TRUE,
                        ts.vec = NULL,
                        arrange = c("wide", "long"),
                        clr = colorRampPalette(
                          rev(brewer.pal(9, "Spectral")))(1000),
                        ...) {
  
  library(latticeExtra)
  library(gridExtra)
  library(mapdata)
  
  p.prm <- paste(pred.prm, "predictor", sep = "_")
  r.prm <- paste(resp.prm, "response", sep = "_")
  
  ps <- slot(x, p.prm)
  rs <- slot(x, r.prm)
  
  if (is.null(ts.vec)) 
    ts.vec <- seq(nlayers(x@resid_response))
  
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
                   main = paste(p.prm, "mode", x@mode, sep = " "),
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
                   main = paste(r.prm, "mode", x@mode, sep = " "), 
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
                   round(x@cum_exp_var * 100 , 2), "%", sep = " ")
  
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



# define function ---------------------------------------------------------
plotEotStack <- function(x,
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
                         locations = FALSE,
                         ...) {
  
  if (!locations) {
    
    library(latticeExtra)
    library(gridExtra)
    library(mapdata)
    
    p.prm <- paste(pred.prm, "predictor", sep = "_")
    r.prm <- paste(resp.prm, "response", sep = "_")
    
    ps <- slot(x[[mode]], p.prm)
    rs <- slot(x[[mode]], r.prm)
    
    if (is.null(ts.vec)) 
      ts.vec <- seq(nlayers(x[[mode]]@resid_response))
    
    xy <- xyFromCell(x[[mode]]@rsq_predictor, 
                     cell = x[[mode]]@cell_bp)
    
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
                     main = paste(p.prm, "mode", mode, sep = " "), 
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
    
    md <- x[[mode]]@mode
    
    ts.main <- paste("time series mode", x[[mode]]@mode, 
                     "- explained response domain variance:", 
                     round(x[[mode]]@cum_exp_var * 100 , 2), "%", sep = " ")
    
    eot.ts <- xyplot(x[[mode]]@eot ~ ts.vec,
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
    
    
  } else {
    plotLocations(x, ...)
  }
}


# set methods -------------------------------------------------------------
if ( !isGeneric('plot') ) {
  setGeneric('plot', function(x, ...)
    standardGeneric('plot'))
}

setMethod('plot', signature(x = 'EotMode'), 
          plotEotMode)

setMethod('plot', signature(x = 'EotStack'), 
          plotEotStack)