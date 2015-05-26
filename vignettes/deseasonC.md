---
title: "Enhanced `deseason()`-ing with **Rcpp**"
author: "Florian Detsch"
date: "26.05.2015"
output: html_document
---


```
## 
## 
## processing file: deseasonC.Rmd
```

```
## Error in parse_block(g[-1], g[1], params.src): duplicate label 'set-options'
```



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
##                     expr     min      lq     mean   median      uq     max neval
##  deseason(australiaGPCP) 525.516 539.505 550.9109 551.1757 555.346 622.959    20
```

#### **Rcpp**-based deseasoning


```r
microbenchmark(
  deseasonC(australiaGPCP)
, times = 20L)
```

```
## Unit: milliseconds
##                      expr     min       lq     mean   median       uq      max neval
##  deseasonC(australiaGPCP) 22.0234 22.31132 29.60885 22.79637 26.26797 133.0466    20
```


### Line profiling

While the initial approach using `lapply` along with `raster::calc` generated a considerable overhead, calculation efforts could now be minimized by the use of a) base-C++ `for` loops and b) a set of custom *.cpp functions analogous to base-R `seq` and vector indexing.

#### Base-R deseasoning


```r
lineprof(deseason(x = australiaGPCP))
```

```
##    time   alloc release  dups                          ref                  src
## 1 0.126 194.523 164.674 76898 c("deseason", "<Anonymous>") deseason/<Anonymous>
## 2 0.008   7.151   0.000  3150           c("deseason", "-") deseason/-
```

#### **Rcpp**-based deseasoning


```r
lineprof(deseasonC(x = australiaGPCP))
```

```
##    time alloc release dups                             ref                     src
## 1 0.001 1.248       0   63 c("deseasonC", "monthlyMeansC") deseasonC/monthlyMeansC
## 2 0.004 2.479       0 1608             c("deseasonC", "-") deseasonC/-
```
