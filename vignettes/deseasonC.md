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
  deseason(australiaGPCP)
, times = 20L)
```

```
## Unit: milliseconds
##                     expr      min       lq     mean   median       uq      max neval
##  deseason(australiaGPCP) 521.6178 536.1171 545.9737 547.5532 555.6528 568.9154    20
```

#### **Rcpp**-based deseasoning


```r
microbenchmark(
  deseasonC(australiaGPCP)
, times = 20L)
```

```
## Unit: milliseconds
##                      expr      min       lq   mean   median       uq      max neval
##  deseasonC(australiaGPCP) 23.14732 25.58579 32.428 27.83234 28.88849 132.3756    20
```


### Line profiling

While the initial approach using `lapply` along with `raster::calc` generated a considerable overhead, calculation efforts could now be minimized by the use of a) base-C++ `for` loops and b) a set of custom *.cpp functions analogous to base-R `seq` and vector indexing.

#### Base-R deseasoning


```r
lineprof(deseason(x = australiaGPCP))
```

```
##    time   alloc release  dups                          ref                  src
## 1 0.150 192.626 163.368 76415 c("deseason", "<Anonymous>") deseason/<Anonymous>
## 2 0.011   9.402   0.000  4029           c("deseason", "-") deseason/-
```

#### **Rcpp**-based deseasoning


```r
lineprof(deseasonC(x = australiaGPCP))
```

```
##    time alloc release dups                             ref                     src
## 1 0.002 2.654       0   63 c("deseasonC", "monthlyMeansC") deseasonC/monthlyMeansC
## 2 0.001 0.699       0  125     c("deseasonC", "setValues") deseasonC/setValues    
## 3 0.006 2.594       0 1381             c("deseasonC", "-") deseasonC/-
```
