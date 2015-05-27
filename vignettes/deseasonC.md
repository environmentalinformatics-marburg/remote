---
title: "Enhanced `deseason()`-ing with **Rcpp**"
author: "Florian Detsch"
date: "26.05.2015"
output: html_document
---



The [`deseason`](https://github.com/environmentalinformatics-marburg/remote/blob/master/R/deseason.R) function included in the [R **remote** package](https://github.com/environmentalinformatics-marburg/remote) has recently been [reimplemented in **Rcpp**](https://github.com/environmentalinformatics-marburg/remote/blob/develop/R/deseasonC.R), resulting in a performance speed more than 15 times faster as compared to the initial, solely R-based version.   

### Speed test

#### Prerequisites


```r
## required packages
# devtools::install_github("environmentalinformatics-marburg/remote", 
#                          ref = "develop")
library(remote)
library(microbenchmark)

# devtools::install_github("hadley/lineprof")
library(lineprof)

## data
data("australiaGPCP")
```

#### Base-R deseasoning


```r
microbenchmark(
  dsn_r <- deseason(australiaGPCP)
, times = 20L)
```

```
## Unit: milliseconds
##                              expr      min       lq     mean   median       uq      max neval
##  dsn_r <- deseason(australiaGPCP) 519.2028 536.0497 563.2485 550.9001 563.9413 728.6707    20
```

#### **Rcpp**-based deseasoning


```r
microbenchmark(
  dsn_cpp <- deseasonC(australiaGPCP)
, times = 20L)
```

```
## Unit: milliseconds
##                                 expr      min       lq     mean   median       uq      max neval
##  dsn_cpp <- deseasonC(australiaGPCP) 25.55353 26.32604 28.01438 28.36833 28.69972 31.54996    20
```

#### Visual inspection

![plot of chunk vis_dsn](/media/permanent/programming/r/remote/documentation/figure/vis_dsn-1.png) 

### Line profiling

While the initial approach using `lapply` along with `raster::calc` generated a considerable overhead, calculation efforts could now be minimized by the use of a) base-C++ `for` loops and b) a set of custom *.cpp functions analogous to base-R `seq` and vector indexing.

#### Base-R deseasoning


```r
lineprof(deseason(x = australiaGPCP))
```

```
##    time   alloc release  dups           ref                  src
## 1 0.131 191.364  189.28 76256 deseason.R#33 deseason/<Anonymous>
## 2 0.009   9.498    0.00  4320 deseason.R#38 deseason/-
```

#### **Rcpp**-based deseasoning


```r
lineprof(deseasonC(x = australiaGPCP))
```

```
##    time alloc release dups            ref                     src
## 1 0.001 1.410   0.000   63 deseasonC.R#37 deseasonC/monthlyMeansC
## 2 0.005 2.561   5.599 1638 deseasonC.R#41 deseasonC/-
```
