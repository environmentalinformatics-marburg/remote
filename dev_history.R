# 2023-06-02 ----

txt = utils::bibentry(
  bibtype = "Article"
  , title = "{remote}: Empirical Orthogonal Teleconnections in {R}"
  , author = c("Tim Appelhans", "Florian Detsch", "Thomas Nauss")
  , journal = "Journal of Statistical Software"
  , year = 2015
  , volume = 65
  , number = 10
  , pages = "1--19"
  , doi = "10.18637/jss.v065.i10"
  # , url = "https://www.jstatsoft.org/article/view/v065i10"
  , header = "To cite the {remote} package in publications use:"
  , textVersion = paste(
    "Appelhans T, Detsch F, Nauss T (2015)."
    , "remote: Empirical Orthogonal Teleconnections in R."
    , "Journal of Statistical Software, 65(10), 1-19,"
    , "doi:10.18637/jss.v065.i10 <https://doi.org/10.18637/jss.v065.i10>."
  )
)


# 2026-06-21 ====

## document, check and build package
devtools::check(
  document = TRUE # `devtools::document()`
  , build_args = "--resave-data=best"
  , manual = FALSE
  , cran = TRUE
  , run_dont_test = TRUE
)
pak::local_install(ask = FALSE)

## bump version
if (!requireNamespace("oiseasy", quietly = TRUE)) {
  remotes::install_git(
    "https://codeberg.org/tim-salabim/oiseasy.git"
    , Ncpus = 4L
  )
}

oiseasy::bumpDevVersion()


# 2026-07-07 ====

## BUILT-IN DATA ====

## if missing, create target folders
for (i in c("data-raw", "inst/extdata")) {
  dir.create(i, showWarnings = FALSE)
}

to_tif = FALSE
to_rda = TRUE

## process built-in datasets
for (rdata_name in c("australiaGPCP", "pacificSST", "vdendool")) {
  
  # # debug:
  # rdata_name = "australiaGPCP"

  # construct file names
  rdata_file = paste0(
    rdata_name
    , ".RData"
  )

  rdata_file_raw = file.path("data-raw", rdata_file)
  rdata_file_data = file.path("data", rdata_file)
  
  # if applicable, move existing `.RData` file to `data-raw/`
  if (file.exists(rdata_file_data)) {
    file.rename(
      rdata_file_data
      , rdata_file_raw
    )
  }
  
  # load built-in data into memory
  load(rdata_file_raw)
  
  get(rdata_name) |> 
    terra::rast() |> 
    assign(
      rdata_name
      , value = _
    )
  
  # write `.tif` to `inst/extdata`
  if (to_tif) {
    tif_file_ext = sprintf("inst/extdata/%s.tif", rdata_name)
    dir.create(dirname(tif_file_ext), showWarnings = FALSE, recursive = TRUE)

    terra::writeRaster(
      get(rdata_name)
      , filename = tif_file_ext
      , overwrite = TRUE
      , gdal = c("COMPRESS=LZW")
    )
  }
  
  # write `.rda` to `data/`
  if (to_rda) {
    rda_file_data = sprintf("data/%s.rda", rdata_name)
    dir.create(dirname(rda_file_data), showWarnings = FALSE)

    get(rdata_name) |> 
      terra::wrap() |> 
      assign(
        rdata_name
        , value = _
      )
  
    save(
      list = rdata_name
      , envir = environment()
      , file = rda_file_data
      , compress = "bzip2"
    )
  }
}

## verify new built-in data
load("data/australiaGPCP.rda")
terra::unwrap(australiaGPCP)


# 2026-07-13 ====

## {tinytest} SETUP ====

tinytest::setup_tinytest(pkgdir = ".")
tinytest::run_test_dir()

covr::report()


# 2026-07-14 ====

## `calcVar()` SPEED-UP ====

x = terra::unwrap(pacificSST)

## across time
microbenchmark::microbenchmark(
  ref = vls <- mean(apply(terra::values(x), 1, var, na.rm = TRUE))
  , new = clc <- mean(terra::values(terra::app(x, "sd", na.rm = TRUE)^2)[, 1L])
  , times = 25L
)
# Unit: milliseconds
#  expr       min        lq      mean    median        uq       max neval
#   ref 46.488107 53.404365 93.521187 59.092277 62.971696 367.62212    25
#   new  6.915151  7.785462  8.564513  8.633283  9.261476  10.22619    25

tinytest::expect_equal(
  clc
  , target = vls
)

## across space
microbenchmark::microbenchmark(
  ref = vls <- mean(apply(terra::values(x), 2, var, na.rm = TRUE), na.rm = TRUE)
  , new = glbl <- mean((terra::global(x, fun = "sd", na.rm = TRUE)[, 1L])^2)
  , times = 25L
)
# Unit: milliseconds
#  expr       min        lq     mean    median        uq      max neval
#   ref 21.047098 26.973126 67.45445 29.584694 36.766237 345.3942    25
#   new  5.703815  6.513882  7.13055  7.042239  7.507108  11.4029    25

tinytest::expect_equal(
  glbl
  , target = vls
)


# 2026-07-15 ====

## `denoise()` BENCHMARKING ====

gph = terra::unwrap(vdendool)

microbenchmark::microbenchmark(
  terra = gph_dns <- denoise(gph, expl.var = 0.8, use.cpp = FALSE, verbose = F)
  , rcpp = gph_dns_cpp <- denoise(gph, expl.var = 0.8, verbose = FALSE)
)
# Unit: milliseconds
#   expr      min       lq     mean   median       uq      max neval
#  terra 7.954648 8.832743 10.63336  9.91166 10.84664 19.66279   100
#   rcpp 8.732450 9.636186 11.87453 10.55196 11.59424 28.42883   100

tinytest::expect_equal(
  gph_dns
  , target = gph_dns_cpp
)


# 2026-07-16 ====

## `denoise()` / `covWeight()` WITH MISSING VALUES ====

pcp = terra::unwrap(australiaGPCP)

set.seed(1899L)
idx = terra::spatSample(pcp, size = n, values = FALSE, cells = TRUE)

pcp[idx] = NA_real_
rng = global(pcp[[1L]], fun = "range", na.rm = TRUE)

pcp_dns = denoise(pcp, expl.var = 0.8)

opar = par(mfrow = c(1,2))
plot(pcp[[1L]], main = "original")
plot(pcp_dns[[1L]], main = "denoised")
par(opar)

plot(pcp[[1L]] - pcp_dns[[1L]], main = "residuals")


# 2026-07-28 ====

## RESOLVE CHECK ISSUES ====

## eliminate "Compilation used the following non-portable flag(s): 
##   ‘-mno-omit-leaf-frame-pointer’" note
usethis::edit_r_makevars()

## add these lines:
## CFLAGS = -g -O2 -Wall -pedantic
## CXXFLAGS = -g -O2 -Wall -pedantic