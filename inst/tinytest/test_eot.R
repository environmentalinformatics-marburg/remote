library("tinytest")
library("checkmate")
using("checkmate")

gph = terra::unwrap(vdendool)
n = 3L


### `eot()` ----

expect_stdout(
  nh_modes <- eot(
    x = gph
    , y = NULL
    , n = n
    , standardised = FALSE
    , verbose = TRUE
  )
  , pattern = paste(
    "Calculating linear model"
    , "Locating \\d+\\. EOT"
    , "Location"
    , "Cum\\. expl\\. variance \\(\\%\\)"
    , sep = ".*"
  )
  , info = "prints progress messages to console"
)

expect_inherits(
  nh_modes
  , class = "EotStack"
  , info = "returns an `EotStack` object"
)

expect_inherits(
  nh_modes[[1L]]
  , class = "EotMode"
  , info = "returns an `EotMode` object per mode"
)

## single-mode output
nh_mode = eot(
  x = gph
  , y = NULL
  , n = 1L
  , standardised = FALSE
  , verbose = FALSE
)

expect_equal(
  nh_mode
  , target = nh_modes[[1L]]
  , info = "returns the same result for single-mode output"
)

## `reduce.both = TRUE`
nh_modes_rb <- eot(
  x = gph
  , y = NULL
  , n = n
  , standardised = FALSE
  , reduce.both = TRUE
  , verbose = FALSE
)

expect_true(
  nh_modes_rb[[n]]@cum_exp_var != nh_modes[[n]]@cum_exp_var
  , info = "returns different results for `reduce.both = TRUE`"
)

## `Raster*` input
nh_modes_rst = eot(
  x = as(gph, "Raster")
  , y = NULL
  , n = n
  , standardised = FALSE
  , verbose = FALSE
)

expect_equal(
  nh_modes_rst
  , target = nh_modes
  , info = "returns the same result for `Raster*` input"
)


### `names()` ----

## `EotStack` method
expect_character(
  names(nh_modes)
  , pattern = "^mode_\\d+$"
  , any.missing = FALSE
  , len = n
  , unique = TRUE
  , sorted = TRUE
  , info = "sets default mode names"
)

## `EotMode` method
expect_identical(
  names(nh_modes[[1L]])
  , target = names(nh_modes)[1L]
  , info = "returns the name of the respective mode"
)

## discard mode names, i.e. set ''
names(nh_modes) = NULL

expect_true(
  all(
    !nzchar(names(nh_modes))
  )
  , info = "accepts `NULL` to set empty mode names, i.e. ''"
)

## set custom mode names
names(nh_modes) = paste0(
  "vdendool"
  , seq(n)
)

expect_character(
  names(nh_modes)
  , pattern = "^vdendool\\d+$"
  , any.missing = FALSE
  , len = n
  , unique = TRUE
  , sorted = TRUE
  , info = "accepts custom mode names"
)

## error: lengths don't match
expect_error(
  names(nh_modes) <- paste0(
    "vdendool"
    , seq(n + 1L)
  )
  , pattern = "incorrect number of mode names"
  , info = "throws an error if the number of mode names and modes don't match"
)
