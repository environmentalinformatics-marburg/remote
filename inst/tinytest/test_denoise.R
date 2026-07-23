pcp = terra::unwrap(australiaGPCP)
dns = denoise(pcp, expl.var = 0.8, verbose = FALSE)

expect_inherits(
  dns
  , class = "SpatRaster"
  , info = "returns a `SpatRaster` in case of `SpatRaster` input"
)

expect_identical(
  dim(dns)
  , target = dim(pcp)
  , info = "returns a `SpatRaster` of the same dimensions as the input"
)

expect_stdout(
  dns_rst <- denoise(as(pcp, "Raster"), expl.var = 0.8, use.cpp = FALSE)
  , pattern = paste(
    "Using the first \\d+ components .* to reconstruct series"
    , "these account for .* of variance in orig. series"
    , sep = ".*"
  )
  , info = "prints a message about the # of components and explained variance"
)

expect_equal(
  dns_rst
  , target = dns
  , info = "returns same result with `Raster*` input and `use.cpp = FALSE`"
)

## unweighted, with 'k' instead of 'expl.var'
sst = terra::unwrap(pacificSST)

expect_stdout(
  dns_no_wghts <- denoise(sst, k = 5L, weighted = FALSE)
  , pattern = "Using the first 5 components"
  , info = "prints a message about the specified # of components"
)

expect_inherits(
  dns_no_wghts
  , class = "SpatRaster"
  , info = "returns a `SpatRaster` in case of `SpatRaster` input (unweighted)"
)

expect_identical(
  dim(dns_no_wghts)
  , target = dim(sst)
  , info = "returns a `SpatRaster` of the same dimensions (unweighted)"
)

## errors
expect_error(
  denoise(pcp)
  , pattern = "^Either 'expl.var' or 'k' must be supplied\\.$"
)
