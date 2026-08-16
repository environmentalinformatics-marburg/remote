#' Number of modes of an `EotStack`
#' 
#' @description
#' Retrieves the number of modes of an `EotStack`.
#' 
#' @param x An `EotStack`.
#' 
#' @return
#' The number of modes as `integer`.
#' 
#' @examples
#' gph = terra::unwrap(vdendool)
#' nh_modes = eot(gph, n = 2)
#' nmodes(nh_modes)
#' 
#' @export
nmodes = function(x) { 
  length(x@modes)
}
