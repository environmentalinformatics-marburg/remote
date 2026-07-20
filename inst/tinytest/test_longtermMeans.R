pcp = terra::unwrap(australiaGPCP)

pcp_mn = longtermMeans(pcp, cycle.window = 12L)

expect_inherits(
  pcp_mn
  , class = "SpatRaster"
  , info = "returns a `SpatRaster` object"
)

expect_true(
  terra::nlyr(pcp_mn) == 12L
  , info = "returns the correct number of layers"
)

expect_identical(
  dim(pcp_mn)[1:2]
  , target = dim(pcp)[1:2] # nrows, ncols
  , info = "returns the correct number of rows and columns"
)

pcp_mn1 = longtermMeans(as(pcp, "Raster"), cycle.window = 1L)

expect_true(
  terra::nlyr(pcp_mn1) == 1L
  , info = "returns the correct number of layers for overall mean"
)
