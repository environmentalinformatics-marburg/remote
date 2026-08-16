#' Class EotMode
#' 
#' @slot mode the number of the identified mode
#' @slot name the name of the mode
#' @slot eot the EOT (time series) at the identified base point. Note, this is a simple numeric vector
#' @slot coords_bp the coordinates of the identified base point
#' @slot cell_bp the cell number of the indeified base point
#' @slot cum_exp_var the cumulative explained variance of the considered EOT mode
#' @slot r_predictor `SpatRaster` of the correlation coefficients between the base point and each pixel of the predictor domain
#' @slot rsq_predictor as above but for the coefficient of determination of the predictor domain
#' @slot rsq_sums_predictor as above but for the sums of coefficient of determination of the predictor domain
#' @slot int_predictor `SpatRaster` of the intercept of the regression equation for each pixel of the predictor domain
#' @slot slp_predictor as above but for the slope of the regression equation for each pixel of the predictor domain
#' @slot p_predictor `SpatRaster` of the significance (p-value) of the regression equation for each pixel of the predictor domain
#' @slot resid_predictor `SpatRaster` of the reduced data for the predictor domain
#' @slot r_response `SpatRaster` of the correlation coefficients between the base point and each pixel of the response domain
#' @slot rsq_response as above but for the coefficient of determination of the response domain
#' @slot int_response `SpatRaster` of the intercept of the regression equation for each pixel of the response domain
#' @slot slp_response as above but for the slope of the regression equation for each pixel of the response domain
#' @slot p_response `SpatRaster` of the significance (p-value) of the regression equation for each pixel of the response domain
#' @slot resid_response `SpatRaster` of the reduced data for the response domain
#' 
#' @exportClass EotMode
#' @rdname EotMode-class

methods::setClass(
  'EotMode'
  , slots = c(mode = 'integer'
    , name = 'character'
    , eot = 'numeric'
    , coords_bp = 'matrix'
    , cell_bp = 'integer'
    , cum_exp_var = 'numeric'
    , r_predictor = 'SpatRaster'
    , rsq_predictor = 'SpatRaster'
    , rsq_sums_predictor = 'SpatRaster'
    , int_predictor = 'SpatRaster'
    , slp_predictor = 'SpatRaster'
    , p_predictor = 'SpatRaster'
    , resid_predictor = 'SpatRaster'
    , r_response = 'SpatRaster'
    , rsq_response = 'SpatRaster'
    , int_response = 'SpatRaster'
    , slp_response = 'SpatRaster'
    , p_response = 'SpatRaster'
    , resid_response = 'SpatRaster'
  )
)

NULL

#' Class EotStack
#' 
#' @slot modes a list containing the individual 'EotMode's of the 'EotStack'
#' @slot names the names of the modes
#' 
#' @exportClass EotStack
#' @rdname EotStack-class

methods::setClass('EotStack',
         slots = c(modes = 'list',
                   names = 'character'))

NULL