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
##  dsn_r <- deseason(australiaGPCP) 497.8515 505.9726 514.5156 510.9539 515.2286 607.0145    20
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
##  dsn_cpp <- deseasonC(australiaGPCP) 24.65897 26.45659 31.68348 27.45329 28.15544 117.8348    20
```

#### Visual inspection

![plot of chunk vis](figure/vis-1.png) 

### Line profiling

While the initial approach using `lapply` along with `raster::calc` generated a considerable overhead, calculation efforts could now be minimized by the use of a) base-C++ `for` loops and b) a set of custom *.cpp functions analogous to base-R `seq` and vector indexing.

#### Base-R deseasoning


```r
lineprof(deseason(x = australiaGPCP))
```

```
##    time   alloc release  dups           ref                  src
## 1 0.144 194.120 170.868 76349 deseason.R#33 deseason/<Anonymous>
## 2 0.008   8.208   0.000  3659 deseason.R#38 deseason/-
```

#### **Rcpp**-based deseasoning


```r
lineprof(deseasonC(x = australiaGPCP))
```

```
##    time alloc release dups            ref          src
## 1 0.001 1.417   0.000   65 deseasonC.R#38 deseasonC/[[
## 2 0.004 1.318   5.006 1078 deseasonC.R#41 deseasonC/-
```
