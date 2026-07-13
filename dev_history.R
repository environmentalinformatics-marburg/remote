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
devtools::document()
devtools::check()
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
