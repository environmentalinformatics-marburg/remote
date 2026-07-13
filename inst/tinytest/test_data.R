### `australiaGPCP` ----

n = 348L
prj = "+proj=longlat +ellps=WGS84 +towgs84=0,0,0,0,0,0,0 +no_defs"

data(
  "australiaGPCP"
  , package = "remote"
)

expect_inherits(
  australiaGPCP
  , "PackedSpatRaster"
)

pcp = terra::unwrap(australiaGPCP)

expect_true(
  nrow(pcp) == 12L
)

expect_true(
  ncol(pcp) == 20L
)

expect_true(
  terra::nlyr(pcp) == n
)

expect_identical(
  terra::crs(pcp, proj = TRUE)
  , target = prj
)


### `pacificSST` ----

data(
  "pacificSST"
  , package = "remote"
)

expect_inherits(
  pacificSST
  , "PackedSpatRaster"
)

sst = terra::unwrap(pacificSST)

expect_true(
  nrow(sst) == 30L
)

expect_true(
  ncol(sst) == 140L
)

expect_true(
  terra::nlyr(sst) == n
)

expect_identical(
  terra::crs(sst, proj = TRUE)
  , target = prj
)


### `vdendool` ----

data(
  "vdendool"
  , package = "remote"
)

expect_inherits(
  vdendool
  , "PackedSpatRaster"
)

vdd = terra::unwrap(vdendool)

expect_true(
  nrow(vdd) == 14L
)

expect_true(
  ncol(vdd) == 36L
)

expect_true(
  terra::nlyr(vdd) == 50L
)

expect_identical(
  terra::crs(vdd, proj = TRUE)
  , target = "+proj=longlat +datum=WGS84 +no_defs"
)
