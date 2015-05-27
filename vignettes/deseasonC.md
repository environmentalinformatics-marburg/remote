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
##  dsn_r <- deseason(australiaGPCP) 496.0324 512.0425 519.6378 516.6613 521.6685 601.8646    20
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
##  dsn_cpp <- deseasonC(australiaGPCP) 23.18665 25.55828 27.11424 27.70182 28.20635 29.80169    20
```

#### Visual inspection



![vis_dsn](http://i.imgur.com/TQGlCDu.png)

### Line profiling

While the initial approach using `lapply` along with `raster::calc` generated a considerable overhead, calculation efforts could now be minimized by the use of a) base-C++ `for` loops and b) a set of custom *.cpp functions analogous to base-R `seq` and vector indexing.

#### Base-R deseasoning


```r
lineprof(deseason(x = australiaGPCP))
```

```
##    time   alloc release  dups           ref                  src
## 1 0.144 192.367 190.155 76362 deseason.R#33 deseason/<Anonymous>
## 2 0.008   8.214   0.000  3630 deseason.R#38 deseason/-
```

#### **Rcpp**-based deseasoning


```r
lineprof(deseasonC(x = australiaGPCP))
```

```
##    time alloc release dups            ref                     src
## 1 0.001 1.687   0.000   63 deseasonC.R#37 deseasonC/monthlyMeansC
## 2 0.005 2.616   5.574 1492 deseasonC.R#41 deseasonC/-
```
