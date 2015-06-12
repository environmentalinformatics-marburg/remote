---
title: "Enhanced `deseason()`-ing with **Rcpp**"
author: "Florian Detsch"
date: "28.05.2015"
output: html_document
---



The [`deseason`](https://github.com/environmentalinformatics-marburg/remote/blob/master/R/deseason.R) function included in the [R **remote** package](https://github.com/environmentalinformatics-marburg/remote) has recently been [upgraded with **Rcpp**](https://github.com/environmentalinformatics-marburg/remote/blob/develop/R/deseason.R) functionality and is currently hosted on the GitHub 'develop' branch. Through the newly implemented `use.cpp` argument, it is up to the user to choose between stand-alone R and **Rcpp** realization. Due to advantages in terms of both computation time and memory usage (see below), however, we strongly encourage **remote** users to consider the latter.  

<br>

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
  dsn_r <- deseason(australiaGPCP, use.cpp = FALSE)
, times = 20L)
```

```
## Unit: milliseconds
##                                               expr      min       lq     mean   median       uq      max neval
##  dsn_r <- deseason(australiaGPCP, use.cpp = FALSE) 504.5201 518.5982 525.8125 523.0313 529.7324 564.1192    20
```

#### **Rcpp**-based deseasoning


```r
microbenchmark(
  dsn_cpp <- deseason(australiaGPCP, use.cpp = TRUE)
, times = 20L)
```

```
## Unit: milliseconds
##                                                expr      min       lq     mean   median       uq      max neval
##  dsn_cpp <- deseason(australiaGPCP, use.cpp = TRUE) 21.91912 22.14009 24.76973 26.20123 26.48253 27.01011    20
```

<br>

### Line profiling

While the initial approach using `lapply` along with `raster::calc` generated a considerable overhead, calculation efforts could now be minimized by the use of a) base-C++ `for` loops and b) a set of custom *.cpp functions analogous to base-R `seq` and vector indexing.

#### Base-R deseasoning


```r
lineprof(deseason(x = australiaGPCP, use.cpp = FALSE))
```

```
##    time   alloc release  dups                          ref                  src
## 1 0.123 192.985 187.954 77124 c("deseason", "<Anonymous>") deseason/<Anonymous>
## 2 0.008   7.615   0.000  3558           c("deseason", "-") deseason/-
```

#### **Rcpp**-based deseasoning


```r
lineprof(deseason(x = australiaGPCP, use.cpp = TRUE))
```

```
##    time alloc release dups                            ref                    src
## 1 0.001 1.448       0   63 c("deseason", "monthlyMeansC") deseason/monthlyMeansC
## 2 0.004 2.556       0 1560             c("deseason", "-") deseason/-
```

<br>

### Equality check


```r
equal <- sapply(1:nlayers(australiaGPCP), function(i) {
  ## compare each layer
  tmp_dsn_r <- dsn_r[[i]]
  tmp_dsn_cpp <- dsn_cpp[[i]]
  identical(tmp_dsn_r[], tmp_dsn_cpp[])
})
all(equal)
```

```
## [1] TRUE
```



![vis_dsn](http://i.imgur.com/TQGlCDu.png)
