---
title: "Enhanced `desnoise()`-ing with **Rcpp**"
author: "Florian Detsch"
date: "28.05.2015"
output: html_document
---



Similar to `deseason`, the [`denoise`](https://github.com/environmentalinformatics-marburg/remote/blob/master/R/denoise.R) function recently received an update and now features [**Rcpp** functionality](https://github.com/environmentalinformatics-marburg/remote/blob/develop/R/denoise.R). The upgraded version is currently hosted on the GitHub 'develop' branch, and although possibilities to disable **Rcpp** features were implemented via `use.cpp`, we strongly recommend **remote** users to profit from the latest improvements in terms of computation time and memory usage.  

<br>

### Speed test

#### Prerequisites


```r
## required packages
# devtools::install_github("environmentalinformatics-marburg/remote", 
#                          ref = "develop")
library(remote)

# devtools::install_github("hadley/lineprof")
library(lineprof)

## data
data("australiaGPCP")
```

#### Base-R denoising


```r
system.time(
  dns_r <- denoise(australiaGPCP, expl.var = .8, use.cpp = FALSE)
)
```

```
## 
## Using the first 8 components (of 348) to reconstruct series...
##  these account for 0.8 of variance in orig. series
```

```
##    user  system elapsed 
##   2.909   0.000   2.904
```

#### **Rcpp**-based denoising


```r
system.time(
  dns_cpp <- denoise(australiaGPCP, expl.var = .8, use.cpp = TRUE)
)
```

```
## 
## Using the first 8 components (of 348) to reconstruct series...
##  these account for 0.8 of variance in orig. series
```

```
##    user  system elapsed 
##   0.204   0.000   0.203
```

<br>

### Line profiling

As was the case with `deseason`, the initial approach using `lapply` to generate single RasterLayers containing the reconstructed values and subsequent stacking via `brick` required quite some computation effort (and also allocated memory!). Now, a template matrix representing the entire input stack and the list containing the reconstructed values are directly passed on to `insertReconsC`, where base-C++ `for` loops take care of inserting the values into the template matrix. Like that, the final RasterLayers are created (and subsequently assigned to the output RasterStack via `setValues`) in one go, saving both time and memory.

#### Base-R denoising


```r
lineprof(denoise(x = australiaGPCP, expl.var = .8, use.cpp = FALSE))
```

```
## 
## Using the first 8 components (of 348) to reconstruct series...
##  these account for 0.8 of variance in orig. series
```

```
##    time   alloc release   dups                         ref                 src
## 1 0.035   5.436   0.000    886    c("denoise", "princomp") denoise/princomp   
## 2 0.010  12.620  10.829   3373      c("denoise", "lapply") denoise/lapply     
## 3 0.728 690.828 650.719 281435 c("denoise", "<Anonymous>") denoise/<Anonymous>
```

#### **Rcpp**-based denoising


```r
lineprof(denoise(x = australiaGPCP, expl.var = .8, use.cpp = TRUE))
```

```
## 
## Using the first 8 components (of 348) to reconstruct series...
##  these account for 0.8 of variance in orig. series
```

```
##    time  alloc release dups                         ref                 src
## 1 0.037  5.744   0.000  886    c("denoise", "princomp") denoise/princomp   
## 2 0.010 12.338  11.634 3229      c("denoise", "lapply") denoise/lapply     
## 3 0.004  1.725   0.000 1210 c("denoise", "<Anonymous>") denoise/<Anonymous>
```

<br>

### Equality check


```r
equal <- sapply(1:nlayers(australiaGPCP), function(i) {
  ## compare each layer
  tmp_dns_r <- dns_r[[i]]
  tmp_dns_cpp <- dns_cpp[[i]]
  identical(tmp_dns_r[], tmp_dns_cpp[])
})
all(equal)
```

```
## [1] TRUE
```



![vis_dns](http://i.imgur.com/484EQtN.png)
