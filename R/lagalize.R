#' Create lagged RasterStacks
#' 
#' @description
#' The function is used to produce lagged RasterStacks. The second is cut
#' from the beginning, the first from the tail to ensure equal output lengths
#' (provided that input lengths were equal).
#' 
#' @param pred a RasterStack (to be cut from tail)
#' @param resp a RasterStack (to be cut from beginning)
#' @param lag the desired lag (in the native frequency of the stacks)
#' @param freq the frequency of the RasterStacks
#' @param ... currently not used
#' 
#' @return
#' a list with the two RasterStacks lagged by \code{lag}
#' 
#' @examples
#' data(pacificSST)
#' data(australiaGPCP)
#' 
#' # lag GPCP by 4 months
#' lagged <- lagalize(pacificSST, australiaGPCP, lag = 4, freq = 12)
#' lagged[[1]][[1]] #check names to see date of layer
#' lagged[[2]][[1]] #check names to see date of layer
#' 
#' @export lagalize
lagalize <- function(pred, 
                     resp, 
                     lag = NULL,
                     freq = 12,
                     ...) {
  
  # Return list of unmodified RasterStacks if lag == NULL
  if (is.null(lag)) {
    return(list(pred, resp))
  } else {
    rest <- freq - lag
    # Lagalize predictor stack
    pred.lag <- cutStack(data = pred, tail = TRUE, 
                              lag = lag)
    pred.lag.adj <- pred.lag[[1:(nlayers(pred.lag) - rest)]]
    # Lagalize response stack
    resp.lag <- cutStack(data = resp, tail = FALSE, 
                              lag = lag)
    resp.lag.adj <- resp.lag[[1:(nlayers(resp.lag) - rest)]]
    # Return list of lagalized stacks
    return(list(pred.lag, resp.lag))
  }
}