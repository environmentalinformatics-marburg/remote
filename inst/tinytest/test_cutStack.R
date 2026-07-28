pcp = terra::unwrap(australiaGPCP)

## `n = NULL` (default)
cut_dpl = cutStack(pcp)

expect_equal(
  cut_dpl
  , target = pcp
  , info = "returns unmodified raster series if `n == NULL`"
)

## take away from end, e.g. if supplied series is predictor
n_nd = 8L
cut_nd = cutStack(pcp, tail = TRUE, n = n_nd)

expect_inherits(
  cut_nd
  , class = "SpatRaster"
  , info = "returns a 'SpatRaster' object"
)

expect_true(
  terra::nlyr(cut_nd) == (terra::nlyr(pcp) - n_nd)
  , info = "removes 'n' layers from input (tail)"
)

expect_equal(
  cut_nd[[terra::nlyr(cut_nd)]]
  , target = pcp[[terra::nlyr(pcp) - n_nd]]
  , info = "last layer of cut series is correct"
)

## take away from start, e.g. if supplied series is response
n_st = 6L
cut_st = cutStack(pcp, tail = FALSE, n = n_st)

expect_true(
  terra::nlyr(cut_st) == (terra::nlyr(pcp) - n_st)
  , info = "removes 'n' layers from input (head)"
)

expect_equal(
  cut_st[[1L]]
  , target = pcp[[n_st + 1L]]
  , info = "first layer of cut series is correct"
)
