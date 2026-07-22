sst = terra::unwrap(pacificSST)
pcp = terra::unwrap(australiaGPCP)

trn_idx = 1:10
tst_idx = 11:20
n = 3L

trn = eot(
  x = sst[[trn_idx]]
  , y = pcp[[trn_idx]]
  , n = n
  , verbose = FALSE
)

## `EotStack` input
prd_st = predict(
  trn
  , newdata = sst[[tst_idx]]
  , n = n
)

expect_inherits(
  prd_st
  , class = "SpatRaster"
  , info = "returns a `SpatRaster` (`EotStack` input)"
)

expect_identical(
  dim(prd_st)
  , target = dim(pcp[[tst_idx]])
  , info = "returns same dimensions as ground truth data (`EotStack` input)"
)

## `EotMode` input
prd_md = predict(
  trn[[1L]]
  , newdata = sst[[tst_idx]]
)

expect_inherits(
  prd_md
  , class = "SpatRaster"
  , info = "returns a `SpatRaster` (`EotMode` input)"
)

expect_identical(
  dim(prd_md)
  , target = dim(pcp[[tst_idx]])
  , info = "returns same dimensions as ground truth data (`EotMode` input)"
)

prd_n1 = predict(
  trn
  , newdata = sst[[tst_idx]]
  , n = 1L
)

expect_equal(
  prd_n1
  , target = prd_md
  , info = "returns the same result with `EotStack` input and `n = 1L`"
)

expect_true(
  terra::global(
    prd_md[[1L]] != prd_st[[1L]]
    , fun = "min"
  ) == 1L
  , info = "returns different results for `n = 3L` vs. `n = 1L`"
)
