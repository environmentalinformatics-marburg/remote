#' R EMpirical Orthogonal TEleconnections
#' 
#' @description
#' A collection of functions to facilitate empirical orthogonal teleconnection 
#' analysis. Some handy functions for preprocessing, such as deseasoning, 
#' denoising, lagging are readily available for ease of usage.
#' 
#' @name remote-package
#' @aliases remote
#' @title R EMpirical Orthogonal TEleconnections
#' @author Tim Appelhans, Florian Detsch, Thomas Nauss\cr
#' \cr
#' \emph{Maintainer:} Tim Appelhans \email{tim.appelhans@@gmail.com}
#' 
#' @keywords package
#' @references 
#' Empirical Orthogonal Teleconnections\cr
#' H. M. van den Dool, S. Saha, A. Johansson (2000)\cr
#' Journal of Climate, Volume 13, Issue 8 (April 2000) pp. 1421 - 1435\cr
#' 
#' Empirical methods in short-term climate prediction\cr
#' H. M. van den Dool (2007)\cr
#' Oxford University Press, Oxford, New York (2007)\cr
#' 
#' @seealso \pkg{remote} is built upon the \pkg{terra} package, which is the 
#' direct successor of the \pkg{raster} package. The \pkg{terra} package is used
#' for raster data handling and processing, while \pkg{raster} is still 
#' supported but not actively developed anymore. For more information on raster 
#' data handling, please refer to the documentation of the \pkg{terra} package 
#' and its functions.
#' 
#' @import Rcpp gridExtra latticeExtra mapdata scales methods parallel terra
#' @importFrom grDevices colorRampPalette hcl 
#' @importFrom stats pt var cov.wt na.exclude princomp na.omit
#' @importFrom utils read.csv write.table
#' @useDynLib remote
#' 
"_PACKAGE"

#' 
#' @docType data 
#' @name vdendool
#' @aliases vdendool
#' @title Mean seasonal (DJF) 700 mb geopotential heights
#' @description NCEP/NCAR reanalysis data of mean seasonal (DJF) 700 mb geopotential heights from 1948 to 1998
#' @details NCEP/NCAR reanalysis data of mean seasonal (DJF) 700 mb geopotential heights from 1948 to 1998
#' @format A `PackedSpatRaster` with the following attributes:\cr
#' ```sh
#' size        : 14, 36, 50  (nrow, ncol, nlyr)
#' resolution  : 10, 5  (x, y)
#' extent      : -180, 180, 20, 90  (xmin, xmax, ymin, ymax)
#' coord. ref. : +proj=longlat +datum=WGS84 +no_defs
#' ```
#' @references
#' The NCEP/NCAR 40-year reanalysis project\cr
#' Kalnay et al. (1996)\cr
#' Bulletin of the American Meteorological Society, Volume 77, Issue 3, pp 437 - 471\cr
#' \doi{10.1175/1520-0477(1996)077<0437:TNYRP>2.0.CO;2}
#' @source
#' <https://psl.noaa.gov/data/gridded/data.ncep.reanalysis.derived.pressure.html>\cr
#' \emph{Original Source:} NOAA National Center for Environmental Prediction
#' 
#' @usage
#' vdendool
#' 
#' @examples
#' terra::unwrap(vdendool)
NULL

#' 
#' @docType data 
#' @name australiaGPCP
#' @aliases australiaGPCP
#' @title Monthly GPCP precipitation data for Australia
#' @description Monthly Gridded Precipitation Climatology Project precipitation data 
#' for Australia from 1982/01 to 2010/12
#' @details Monthly Gridded Precipitation Climatology Project precipitation data 
#' for Australia from 1982/01 to 2010/12
#' @format A `PackedSpatRaster` with the following attributes:\cr
#' ```sh
#' size        : 12, 20, 348  (nrow, ncol, nlyr)
#' resolution  : 2.5, 2.5  (x, y)
#' extent      : 110, 160, -40, -10  (xmin, xmax, ymin, ymax)
#' coord. ref. : +proj=longlat +ellps=WGS84 +towgs84=0,0,0,0,0,0,0 +no_defs
#' ```
#' @references
#' The Version-2 Global Precipitation Climatology Project (GPCP) Monthly Precipitation Analysis (1979 - Present)\cr
#' Adler et al. (2003)\cr
#' Journal of Hydrometeorology, Volume 4, Issue 6, pp. 1147 - 1167\cr
#' \doi{10.1175/1525-7541(2003)004<1147:TVGPCP>2.0.CO;2}
#' 
#' @usage
#' australiaGPCP
#' 
#' @examples
#' terra::unwrap(australiaGPCP)
NULL
#' 
#' @docType data 
#' @name pacificSST
#' @aliases pacificSST
#' @title Monthly SSTs for the tropical Pacific Ocean
#' @description Monthly NOAA sea surface temperatures for the tropical Pacific Ocean from 1982/01 to 2010/12
#' @details Monthly NOAA sea surface temperatures for the tropical Pacific Ocean from 1982/01 to 2010/12
#' @format A `PackedSpatRaster` with the following attributes:\cr
#' ```sh
#' size        : 30, 140, 348  (nrow, ncol, nlyr)
#' resolution  : 1, 1  (x, y)
#' extent      : 150, 290, -15, 15  (xmin, xmax, ymin, ymax)
#' coord. ref. : +proj=longlat +ellps=WGS84 +towgs84=0,0,0,0,0,0,0 +no_defs
#' ```
#' @references
#' Daily High-Resolution-Blended Analyses for Sea Surface Temperature\cr
#' Reynolds et al. (2007)\cr
#' Journal of Climate, Volume 20, Issue 22, pp. 5473 - 5496\cr
#' \doi{10.1175/2007JCLI1824.1}
#' 
#' @usage
#' pacificSST
#' 
#' @examples
#' terra::unwrap(pacificSST)
NULL
