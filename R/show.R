


methods::setMethod ('show' , 'EotMode', 
           function(object) {
             cat('class                :', class(object), '\n')
             cat('name                 :', names(object), '\n')
             cat('base point (x, y)    :', object@coords_bp, '\n')
             cat('cum. expl. variance  :', object@cum_exp_var, '\n')
             cat('dimensions           : ', 
                 terra::nrow(object@r_predictor), ', ', 
                 terra::ncol(object@r_predictor), ', ', 
                 terra::ncell(object@r_predictor),
                 '  (nrow, ncol, ncell)\n', sep="") 
             cat('resolution           : ', 
                 terra::xres(object@r_predictor), ', ', 
                 terra::yres(object@r_predictor), '  (x, y)\n', sep="")
             xtnt = as.vector(terra::ext(object@r_predictor))
             cat('extent               : ', xtnt['xmin'], 
                 ', ', xtnt['xmax'], ', ', 
                 xtnt['ymin'], ', ', xtnt['ymax'], 
                 '  (xmin, xmax, ymin, ymax)\n', sep="")
             cat('coord. ref.          :', 
                 terra::crs(object@r_predictor, proj = TRUE), '\n')
           }
)

methods::setMethod ('show' , 'EotStack', 
           function(object) {
             obj1 = object[[1L]]
             cat('class                :', class(object), '\n')
             cat('cum. expl. variance  :', 
                 object[[nmodes(object)]]@cum_exp_var, '\n')
             cat('names                :', names(object), '\n')
             cat('dimensions           : ', 
                 terra::nrow(obj1@r_predictor), ', ', 
                 terra::ncol(obj1@r_predictor), ', ', 
                 terra::ncell(obj1@r_predictor), ', ', 
                 nmodes(object), '  (nrow, ncol, ncell, nmodes)\n', sep="") 
             cat('resolution           : ', 
                 terra::xres(obj1@r_predictor), ', ', 
                 terra::yres(obj1@r_predictor), 
                 '  (x, y)\n', sep="")
             xtnt = as.vector(terra::ext(obj1@r_predictor))
             cat('extent               : ', 
                 xtnt['xmin'], ', ', 
                 xtnt['xmax'], ', ', 
                 xtnt['ymin'], ', ', 
                 xtnt['ymax'], 
                 '  (xmin, xmax, ymin, ymax)\n', sep="")
             cat('coord. ref.          :', 
                 terra::crs(obj1@r_predictor, proj = TRUE), '\n')
           }
)