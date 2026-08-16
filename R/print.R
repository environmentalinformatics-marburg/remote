

methods::setMethod ('print', 'EotMode', 
           function(x, ...) {
             show(x)
           }
)


methods::setMethod ('print', 'EotStack', 
           function(x, ...) {
             show(x)
           }
)