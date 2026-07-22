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

## single-mode output with `write.out = TRUE`
nh_mode = eot(
  x = gph
  , y = NULL
  , n = 1L
  , standardised = FALSE
  , write.out = TRUE
  , path.out = tempdir()
  , prefix = "dooln1"
  , verbose = FALSE
)

expect_equal(
  nh_mode
  , target = nh_modes[[1L]]
  , info = "returns the same result for single-mode output"
)

## `reduce.both = TRUE` with `write.out = TRUE`
nh_modes_rb <- eot(
  x = gph
  , y = NULL
  , n = n
  , standardised = FALSE
  , write.out = TRUE
  , path.out = tempdir()
  , prefix = "dool"
  , reduce.both = TRUE
  , verbose = FALSE
)

expect_true(
  nh_modes_rb[[n]]@cum_exp_var != nh_modes[[n]]@cum_exp_var
  , info = "returns different results for `reduce.both = TRUE`"
)

nh_modes_rb_fls = list.files(
  tempdir()
  , pattern = "^dool_.*\\.grd$"
)

expect_true(
  length(nh_modes_rb_fls) > 0L &&
    length(nh_modes_rb_fls) %% n == 0L
  , info = "writes EOT results to disk intrinsically if `write.out = TRUE`"
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


### `readEot()` ----

nh_modes_rb_reimport = readEot(
  x = tempdir()
  , prefix = "dool"
  , suffix = ".grd"
)

expect_inherits(
  nh_modes_rb_reimport
  , class = "EotStack"
  , info = "reimports EOT results with 2+ leading modes as `EotStack`"
)

expect_equivalent(
  nh_modes_rb_reimport
  , target = nh_modes_rb
  , info = "reimports EOT results from disk"
)

## single leading mode
nh_mode_reimport = readEot(
  x = tempdir()
  , prefix = "dooln1"
)

expect_inherits(
  nh_mode_reimport
  , class = "EotMode"
  , info = "reimports EOT results with a single leading mode as `EotMode`"
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


### `nmodes()` ----

expect_identical(
  nmodes(nh_modes)
  , target = n
  , info = "returns the correct number of modes"
)


### `nXplain()` ----

expect_number(
  nXplain(nh_modes, 0.25)
  , lower = 1L
  , upper = 3L
  , finite = TRUE
  , info = "returns a number between 1 (min. EOTs) and 3 ('n')"
)

expect_error(
  nXplain(nh_modes, 0.8)
  , pattern = "explained variance of EotStack is lower than"
  , info = "throws an error if the explained variance is lower than 'var'"
)


### `plot()` ----

expect_null(
  plot(nh_modes, show.bp = TRUE)
  , info = "returns `NULL` invisibly"
)

expect_null(
  plot(nh_modes, show.bp = TRUE, locations = TRUE)
  , info = "returns `NULL` invisibly for plot of mode locations"
)


### `print()` ----

## `EotStack`
expect_stdout(
  print(nh_modes)
  , pattern = paste(
    "^class .* EotStack"
    , "cum. expl. variance"
    , "names"
    , "dimensions"
    , "resolution"
    , "extent"
    , "coord. ref"
    , sep = ".*"
  )
  , info = "prints a summary of the `EotStack` object to console"
)

## `EotMode`
expect_stdout(
  print(nh_mode)
  , pattern = "^class .* EotMode"
  , info = "prints a summary of the `EotMode` object to console"
)


### `writeEot()` ----

## `filetype = "RRASTER"`
writeEot(
  nh_modes
  , prefix = "vdendool"
  , path.out = tempdir()
)

ofl = list.files(
  tempdir()
  , pattern = "^vdendool_mode_\\d+_.*_(predictor|response)\\.(grd|gri)$"
  , full.names = TRUE
)

expect_true(
  length(ofl) > 0L &&
    length(ofl) %% n == 0L
  , info = "writes EOT results to disk (default `.grd`)"
)

## other 'filetype'
writeEot(
  nh_modes
  , prefix = "vdendool1"
  , path.out = tempdir()
  , filetype = "GTIFF"
)

ofl1 = list.files(
  tempdir()
  , pattern = "^vdendool1_mode_\\d+_.*_(predictor|response)$" # no extension
  , full.names = TRUE
)

expect_true(
  length(ofl1) > 0L &&
    length(ofl1) %% n == 0L
  , info = "writes EOT results to disk (custom 'filetype')"
)


### `subset()` ----

## indexes
nh_modes_s2 = subset(
  nh_modes
  , subset = 2:3
)

expect_inherits(
  nh_modes_s2
  , class = "EotStack"
  , info = "returns a subset `EotStack`"
)

expect_true(
  remote::nmodes(nh_modes_s2) == 2L
  , info = "returns a subset `EotStack` with the specified # of modes"
)

## names
nh_modes_s1 = subset(
  nh_modes
  , subset = names(nh_modes)[3L]
  , drop = TRUE
)

expect_inherits(
  nh_modes_s1
  , class = "EotMode"
  , info = "returns a single subset `EotMode`"
)

## errors and warnings
expect_error(
  subset(
    nh_modes
    , subset = "flying_waters"
  )
  , pattern = "invalid mode names"
)

expect_warning(
  subset(
    nh_modes
    , subset = c(names(nh_modes)[1L], "flying_waters")
  )
  , pattern = "invalid mode names omitted"
)

expect_error(
  subset(
    nh_modes
    , subset = n:(n + 1L)
  )
  , pattern = "not a valid subset"
)
