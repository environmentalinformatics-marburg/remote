#' Class definitions for remote
#' 
#' @slot eot.series the EOT time series at the identified base point
#' @slot max.xy  the cell number of the indeified base point
#' @slot exp.var the (cumulative) explained variance of the considered EOT
#' @slot loc.eot  the location of the base point (in original coordinates)
#' @slot r.predictor the RasterLayer of the correlation coefficients between the base point and each pixel of the predictor domain
#' @slot rsq.predictor as above but for the coefficient of determination of the predictor domain
#' @slot rsq.sums.predictor as above but for the sums of coefficient of determination of the predictor domain
#' @slot int.predictor the RasterLayer of the intercept of the regression equation for each pixel of the predictor domain
#' @slot slp.predictor same as above but for the slope of the regression equation for each pixel of the predictor domain
#' @slot p.predictor the RasterLayer of the significance (p-value) of the the regression equation for each pixel of the predictor domain
#' @slot resid.predictor the RasterBrick of the reduced data for the predictor domain 
#' @slot r.response the RasterLayer of the correlation coefficients between the base point and each pixel of the response domain
#' @slot rsq.response as above but for the coefficient of determination of the response domain
#' @slot int.response the RasterLayer of the intercept of the regression equation for each pixel of the response domain
#' @slot slp.response as above but for the slope of the regression equation for each pixel of the response domain
#' @slot p.response same the RasterLayer of the significance (p-value) of the the regression equation for each pixel of the response domain
#' @slot resid.response the RasterBrick of the reduced data for the response domain 
#' 
#' @exportClass eot

setClass('eot',
         slots = c(eot.series = 'numeric',
                   max.xy = 'integer',
                   exp.var = 'numeric',
                   loc.eot = 'ANY',
                   r.predictor = 'ANY',
                   rsq.predictor = 'ANY',
                   rsq.sums.predictor = 'ANY',
                   int.predictor = 'ANY', 
                   slp.predictor = 'ANY',
                   p.predictor = 'ANY',
                   resid.predictor = 'ANY',
                   r.response = 'ANY',
                   rsq.response = 'ANY',
                   int.response = 'ANY', 
                   slp.response = 'ANY',
                   p.response = 'ANY',
                   resid.response = 'ANY'))

NULL

#' @slot EOT the eot object of the respective mode
#' 
#' @exportClass eotMode

setClass('eotModes',
         slots = c(modes = 'list'))

NULL