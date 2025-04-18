% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/writeEot.R
\name{writeEot}
\alias{writeEot}
\alias{writeEot,EotMode-method}
\alias{writeEot,EotStack-method}
\title{Write Eot* objects to disk}
\usage{
\S4method{writeEot}{EotMode}(x, path.out = ".", prefix = "remote", overwrite = TRUE, ...)

\S4method{writeEot}{EotStack}(x, path.out = ".", prefix, ...)
}
\arguments{
\item{x}{an Eot* object}

\item{path.out}{the path to the folder to write the files to}

\item{prefix}{a prefix to be added to the file names (see Details)}

\item{overwrite}{see \code{\link[raster:writeRaster]{raster::writeRaster()}}.
Defaults to \code{TRUE} in \code{\link[=writeEot]{writeEot()}}}

\item{...}{further arguments passed to \code{\link[raster:writeRaster]{raster::writeRaster()}}}
}
\description{
Write Eot* objects to disk. This is merely a wrapper around
\code{\link[raster:writeRaster]{raster::writeRaster()}} so see respective help section for details.
}
\details{
\code{\link[=writeEot]{writeEot()}} will write the results of either an EotMode or an EotStack
to disk. For each mode the following files will be written:

\itemize{
\item \emph{pred_r} - the \emph{RasterLayer} of the correlation coefficients
between the base point and each pixel of the predictor domain
\item \emph{pred_rsq} - as above but for the coefficient of determination
\item \emph{pred_rsq_sums} - as above but for the sums of coefficient of determination
\item \emph{pred_int} - the \emph{RasterLayer} of the intercept of the
regression equation for each pixel of the predictor domain
\item \emph{pred_slp} - same as above but for the slope of the
regression equation for each pixel of the predictor domain
\item \emph{pred_p} - the \emph{RasterLayer} of the significance (p-value)
of the the regression equation for each pixel of the predictor domain
\item \emph{pred_resid} - the \emph{RasterBrick} of the reduced data
for the predictor domain
}

Apart from \emph{pred_rsq_sums}, all these files are also created for
the response domain as \emph{resp_*}. These will be pasted together
with the prefix & the respective mode so that the file names will
look like, e.g.:

\emph{prefix_mode_n_pred_r.grd}

for the \emph{RasterLayer} of the predictor correlation coefficient
of mode n using the standard \emph{raster} file type (.grd).
}
\section{Methods (by class)}{
\itemize{
\item \code{writeEot(EotStack)}: EotStack

}}
\examples{
\dontrun{
data(vdendool)

nh_modes <- eot(x = vdendool, y = NULL, n = 2, 
                standardised = FALSE, 
                verbose = TRUE)

## write the complete EotStack
writeEot(nh_modes, prefix = "vdendool")

## write only one EotMode
writeEot(nh_modes[[2]], prefix = "vdendool")
}
}
\seealso{
\code{\link[raster:writeRaster]{raster::writeRaster()}}
}
