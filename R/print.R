



setMethod ('print', 'EotMode', 
           function(x, ...) {
             if (inherits(x, 'EotMode')) {
               show(x)
             }
           }
)