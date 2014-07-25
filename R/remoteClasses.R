#' Class EotMode
#' 
#' @slot eot the EOT (time series) at the identified base point. Note, this is a simple numeric vector
#' @slot coords_bp the coordinates of the identified base point
#' @slot cell_bp the cell number of the indeified base point
#' @slot explained_variance the (cumulative) explained variance of the considered EOT mode
#' @slot r_predictor the RasterLayer of the correlation coefficients between the base point and each pixel of the predictor domain
#' @slot rsq_predictor as above but for the coefficient of determination of the predictor domain
#' @slot rsq_sums_predictor as above but for the sums of coefficient of determination of the predictor domain
#' @slot int_predictor the RasterLayer of the intercept of the regression equation for each pixel of the predictor domain
#' @slot slp_predictor same as above but for the slope of the regression equation for each pixel of the predictor domain
#' @slot p_predictor the RasterLayer of the significance (p-value) of the the regression equation for each pixel of the predictor domain
#' @slot resid_predictor the RasterBrick of the reduced data for the predictor domain 
#' @slot r_response the RasterLayer of the correlation coefficients between the base point and each pixel of the response domain
#' @slot rsq_response as above but for the coefficient of determination of the response domain
#' @slot int_response the RasterLayer of the intercept of the regression equation for each pixel of the response domain
#' @slot slp_response as above but for the slope of the regression equation for each pixel of the response domain
#' @slot p_response same the RasterLayer of the significance (p-value) of the the regression equation for each pixel of the response domain
#' @slot resid_response the RasterBrick of the reduced data for the response domain 
#' 
#' @exportClass EotMode
#' @rdname EotMode-class

setClass('EotMode',
         slots = c(eot = 'ANY',
                   coords_bp = 'ANY',
                   cell_bp = 'integer',
                   explained_variance = 'numeric',
                   r_predictor = 'ANY',
                   rsq_predictor = 'ANY',
                   rsq_sums_predictor = 'ANY',
                   int_predictor = 'ANY', 
                   slp_predictor = 'ANY',
                   p_predictor = 'ANY',
                   resid_predictor = 'ANY',
                   r_response = 'ANY',
                   rsq_response = 'ANY',
                   int_response = 'ANY', 
                   slp_response = 'ANY',
                   p_response = 'ANY',
                   resid_response = 'ANY'))

NULL

#' Class EotStack
#' @slot modes a list containing the individual 'EotMode's of the 'EotStack'
#' 
#' @exportClass EotStack
#' @rdname EotStack-class

setClass('EotStack',
         slots = c(modes = 'list'))

NULL