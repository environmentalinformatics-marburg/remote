#include <Rcpp.h>
using namespace Rcpp;


///////////////// linear model functions //////////////////////////////////
// [[Rcpp::export]]
double corC(NumericVector x, NumericVector y) {
  int nx = x.size(), ny = y.size();
  
  if (nx != ny) stop("Input vectors must have equal length!");
  
  double sum_x = sum(x), sum_y = sum(y);
  
  NumericVector xy = x * y;
  NumericVector x_squ = x * x, y_squ = y * y;
  
  double sum_xy = sum(xy);
  double sum_x_squ = sum(x_squ), sum_y_squ = sum(y_squ);
  
  double out = ((nx * sum_xy) - (sum_x * sum_y)) / sqrt((nx * sum_x_squ - pow(sum_x, 2.0)) * (nx * sum_y_squ - pow(sum_y, 2.0)));
  
  return out;
}


// [[Rcpp::export]]
List lmC(NumericVector x, NumericVector y) {
  // Check if input vectors have equal length
  int nx = x.size(); // C++ size() is equal to R length()
  int ny = y.size();
  // Throw error message in case of unequal length
  if (nx != ny) stop("Input vectors must have equal length!");

  // Calculate r value based on linear regression formula
  double sum_x = sum(x); // C++ sum() is equal to R sum()
  double sum_y = sum(y);
  
  NumericVector xy = x * y; // Arithmetic operations work the same way as in R
  NumericVector x_squ = x * x;
  NumericVector y_squ = y * y;
  
  double sum_xy = sum(xy);
  double sum_x_squ = sum(x_squ);
  double sum_y_squ = sum(y_squ);
  
  // C++ pow() is equal to R ^
  double lm_r = ((nx * sum_xy) - (sum_x * sum_y)) / sqrt((nx * sum_x_squ - pow(sum_x, 2.0)) * (nx * sum_y_squ - pow(sum_y, 2.0)));

  // Calculate intercept and slope
  double lm_intercept = ((sum_y * sum_x_squ) - (sum_x * sum_xy)) / ((nx * sum_x_squ) - pow(sum_x, 2.0));
  double lm_slope = ((nx * sum_xy) - (sum_x * sum_y)) / ((nx * sum_x_squ) - pow(sum_x, 2.0));

  // Calculate residuals
  NumericVector lm_predicted_values = lm_slope * x + lm_intercept;
  NumericVector lm_residuals = y - lm_predicted_values;
  
  // Calculate test statistics
  int lm_df = ny - 2; // Degrees of freedom 
  
  double lm_stderr = sqrt(sum(pow(lm_residuals, 2.0)) / lm_df) / 
                     sqrt(sum(pow(x - mean(x), 2.0))); // Standard error
                     
  double lm_tscore = lm_slope / lm_stderr; // t score

  
  // List and return single parameters
  return List::create(lm_r, lm_intercept, lm_slope, lm_residuals, lm_tscore, lm_df);
}


// [[Rcpp::export]]
NumericVector predRsquaredSum(NumericMatrix pred_vals, NumericMatrix resp_vals, 
                              bool standardised) {
  // Number of rows of input matrices
  int nrow_pred = pred_vals.nrow(), nrow_resp = resp_vals.nrow();
  
  // Loop through all predictor cells
  NumericVector lm_rsq_sum(nrow_pred);
  for (int i = 0; i < nrow_pred; i++) {
    
    // For the current predictor cell, loop through all response cells
    // and calculate the corresponding R-squared value
    NumericVector lm_rsq(nrow_resp);
    for (int j = 0; j < nrow_resp; j++) {
      lm_rsq[j] = pow(corC(pred_vals(i, _), resp_vals(j, _)), 2.0);
      
      // Perform standardisation (optional)
      if (!standardised) {
        lm_rsq[j] = lm_rsq[j] * var(resp_vals(j, _));
      }
      
      // Replace possible NaN with 0
      if (lm_rsq[j] != lm_rsq[j]) {
        lm_rsq[j] = 0;
      }
    }
    
    // Sum up R-squared values of current predictor cell
    lm_rsq_sum[i] = sum(lm_rsq);
  }

  return lm_rsq_sum;
}


// [[Rcpp::export]]
List respLmParam(NumericMatrix x, NumericMatrix y, int cell) {
  int nrow_y = y.nrow();
  
  List lmC_out(nrow_y);
  for (int i = 0; i < nrow_y; i++) {
    lmC_out[i] = lmC(x(cell, _), y(i, _));
  }
  
  return lmC_out;
}

///////////////// index of agreement functions ////////////////////////////
// [[Rcpp::export]]
NumericVector findudC(NumericVector x) {
  NumericVector v = diff(x);
  NumericVector z = v.size();
  NumericVector mm(v.size(), -1.0);
  NumericVector pp(v.size(), 1.0);
  NumericVector res = ifelse( v > z, pp, mm);
  return res;
}

// [[Rcpp::export]]
double iodaC(NumericVector x, NumericVector y) {
  NumericVector hh(x.size(), 1.0);
  NumericVector mm(x.size(), 0.0);
  NumericVector e = ifelse(findudC(x) == findudC(y), hh, mm);
  double m = mean(e);
  return m;
}

// [[Rcpp::export]]
NumericVector iodaSumC(NumericMatrix pred_vals, NumericMatrix resp_vals) {
  // Number of rows of input matrices
  int nrow_pred = pred_vals.nrow(), nrow_resp = resp_vals.nrow();
  
  // Loop through all predictor cells
  NumericVector ioda_sum(nrow_pred);
  for (int i = 0; i < nrow_pred; i++) {
    
    NumericVector ioda(nrow_resp);
    for (int j = 0; j < nrow_resp; j++) {
      
      ioda[j] = iodaC(pred_vals(i, _), resp_vals(j, _));
      
    }
    
    // Sum up IOA values of current predictor cell
    ioda_sum[i] = sum(ioda);
  }

  return ioda_sum;
}

///////////////// deseasoning functions ////////////////////////////
// [[Rcpp::export]]
NumericVector seqC(double start, double end, double by) {
  
  // Check for remainder (output vector expansion required if other than zero) 
  // and initialize output vector containing the sequence
  int nRemainder = fmod(end, by);
  int nExpand = 0;
  if (nRemainder > 0)
    nExpand += 1; 
      
  NumericVector index((end / by) + nExpand);
    
  // Count iterations
  int i = 0;
  // Create sequence from start to end by increment value
  for (double j = start; j < (end + 1); j = j + by) {
    index[i] = j;
    i += 1;
  }
  
  // Return sequence
  return index;
}

//// R call
///*** R
//  seqC(1, 120, 12) # no remainder
//  seqC(1, 121, 12) # remainder
//*/

// [[Rcpp::export]]
NumericVector indexC(NumericVector x, IntegerVector index, bool withinC = false) {  
  // Length of the index vector
  int n = index.size();
  // Initialize output vector
  NumericVector out(n);

  // Subtract 1 from index as C++ starts to count at 0 (skip if function is 
  // called by another C++ function)
  if (!withinC)
    index = index - 1; 
  // Loop through index vector and extract values of x at the given positions
  for (int i = 0; i < n; i++) {
    out[i] = x[index[i]];
  }

  // Return output
  return out;
}

//// R call
///*** R
//  set.seed(10)
//  indexC(runif(10), c(1, 3, 8))
//*/

// [[Rcpp::export]]
NumericMatrix monthlyMeansC(NumericMatrix x, int nCycleWindow) {
  // input matrix: number of rows and columns
  int nRows = x.nrow(), nCols = x.ncol();  

  // temporary arrays: monthly indexes and referring values
  int nLenVec = nCols / nCycleWindow;
  
  IntegerVector aiSameMonthInd(nLenVec);
  NumericVector adSameMonthVal(nLenVec);
  
  // output matrix: setup
  NumericMatrix mdMonthlyMeans(nRows, nCycleWindow);
  
  // loop over rows
  for (int i = 0; i < nRows; i++) {
    // per row, loop over months 
    for (int j = 0; j < nCycleWindow; j++) {
      // indexes (e.g. 0, 12, 24, ... for January)
      aiSameMonthInd = seqC(j, nCols, nCycleWindow);
      // referring values
      adSameMonthVal = indexC(x(i, _), aiSameMonthInd, true);
      // output matrix: insert mean monthly values
      mdMonthlyMeans(i, j) = mean(adSameMonthVal);
    }
  }
  
  return mdMonthlyMeans;
}

///////////////// denoise functions ////////////////////////////
// [[Rcpp::export]]
NumericMatrix insertReconsC(List lRecons, NumericMatrix mdTemplate) {
  
  int nListLength = lRecons.size();
  // std::cout << nListLength;
  
  NumericVector dListSlot;
  for (int i = 0; i < nListLength; i++) {
    // current slot entries
    dListSlot = lRecons[i];
    // std::cout << dListSlot[30] << "\n";
    
    // insert values into matrix
    mdTemplate(_, i) = dListSlot;
  }
  
  return mdTemplate;
}
