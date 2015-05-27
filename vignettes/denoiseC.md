---
title: "Enhanced `desnoise()`-ing with **Rcpp**"
author: "Florian Detsch"
date: "27.05.2015"
output: html_document
---



Similar to `deseason`, the [`denoise`](https://github.com/environmentalinformatics-marburg/remote/blob/master/R/denoise.R) function recently received an update and now features [**Rcpp** functionality](https://github.com/environmentalinformatics-marburg/remote/blob/develop/R/denoiseC.R), resulting in massively reduced computation times (more than 50 times faster).   

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
  dns_r <- denoise(australiaGPCP, expl.var = .8)
)
```

```
## 
## Using the first 8 components (of 348) to reconstruct series...
##  these account for 0.8 of variance in orig. series
```

```
##    user  system elapsed 
##   2.839   0.000   2.832
```

#### **Rcpp**-based denoising


```r
system.time(
  dns_cpp <- denoiseC(australiaGPCP, expl.var = .8)
)
```

```
## 
## Using the first 8 components (of 348) to reconstruct series...
##  these account for 0.8 of variance in orig. series
```

```
##    user  system elapsed 
##   0.310   0.000   0.211
```

#### Visual inspection

![plot of chunk vis_dns](/media/permanent/programming/r/remote/documentation/figure/vis_dns-1.png) 

### Line profiling

As was the case with `deseason`, the initial approach using `lapply` to generate single RasterLayers containing the reconstructed values and subsequent stacking via `brick` required quite some computation effort (and also allocated memory!). Now, a template matrix representing the entire input stack and the list containing the reconstructed values are directly passed on to `insertReconsC`, where base-C++ `for` loops take care of inserting the values into the template matrix. Like that, the final RasterLayers are created (and subsequently assigned to the output RasterStack via `setValues`) in one go, saving both time and memory.

#### Base-R denoising


```r
lineprof(denoise(x = australiaGPCP, expl.var = .8))
```

```
## 
## Using the first 8 components (of 348) to reconstruct series...
##  these account for 0.8 of variance in orig. series
```

```
##    time   alloc release   dups          ref                 src
## 1 0.061   4.373   3.656    895 denoise.R#42 denoise/princomp   
## 2 0.011  12.421   9.074   3272 denoise.R#68 denoise/lapply     
## 3 0.709 689.088 683.790 281120 denoise.R#74 denoise/<Anonymous>
```

#### **Rcpp**-based denoising


```r
lineprof(denoiseC(x = australiaGPCP, expl.var = .8))
```

```
## 
## Using the first 8 components (of 348) to reconstruct series...
##  these account for 0.8 of variance in orig. series
```

```
##    time  alloc release dups           ref                  src
## 1 0.041  5.469   3.457  886 denoiseC.R#42 denoiseC/princomp   
## 2 0.011 11.156   9.563 3252 denoiseC.R#68 denoiseC/lapply     
## 3 0.005  0.749   4.108  491 denoiseC.R#74 denoiseC/<Anonymous>
```
