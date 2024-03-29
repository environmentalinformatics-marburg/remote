// Generated by using Rcpp::compileAttributes() -> do not edit by hand
// Generator token: 10BE3573-1514-4C36-9D1C-5A225CD40393

#include <Rcpp.h>

using namespace Rcpp;

#ifdef RCPP_USE_GLOBAL_ROSTREAM
Rcpp::Rostream<true>&  Rcpp::Rcout = Rcpp::Rcpp_cout_get();
Rcpp::Rostream<false>& Rcpp::Rcerr = Rcpp::Rcpp_cerr_get();
#endif

// corC
double corC(NumericVector x, NumericVector y);
RcppExport SEXP _remote_corC(SEXP xSEXP, SEXP ySEXP) {
BEGIN_RCPP
    Rcpp::RObject rcpp_result_gen;
    Rcpp::RNGScope rcpp_rngScope_gen;
    Rcpp::traits::input_parameter< NumericVector >::type x(xSEXP);
    Rcpp::traits::input_parameter< NumericVector >::type y(ySEXP);
    rcpp_result_gen = Rcpp::wrap(corC(x, y));
    return rcpp_result_gen;
END_RCPP
}
// lmC
List lmC(NumericVector x, NumericVector y);
RcppExport SEXP _remote_lmC(SEXP xSEXP, SEXP ySEXP) {
BEGIN_RCPP
    Rcpp::RObject rcpp_result_gen;
    Rcpp::RNGScope rcpp_rngScope_gen;
    Rcpp::traits::input_parameter< NumericVector >::type x(xSEXP);
    Rcpp::traits::input_parameter< NumericVector >::type y(ySEXP);
    rcpp_result_gen = Rcpp::wrap(lmC(x, y));
    return rcpp_result_gen;
END_RCPP
}
// predRsquaredSum
NumericVector predRsquaredSum(NumericMatrix pred_vals, NumericMatrix resp_vals, bool standardised);
RcppExport SEXP _remote_predRsquaredSum(SEXP pred_valsSEXP, SEXP resp_valsSEXP, SEXP standardisedSEXP) {
BEGIN_RCPP
    Rcpp::RObject rcpp_result_gen;
    Rcpp::RNGScope rcpp_rngScope_gen;
    Rcpp::traits::input_parameter< NumericMatrix >::type pred_vals(pred_valsSEXP);
    Rcpp::traits::input_parameter< NumericMatrix >::type resp_vals(resp_valsSEXP);
    Rcpp::traits::input_parameter< bool >::type standardised(standardisedSEXP);
    rcpp_result_gen = Rcpp::wrap(predRsquaredSum(pred_vals, resp_vals, standardised));
    return rcpp_result_gen;
END_RCPP
}
// respLmParam
List respLmParam(NumericMatrix x, NumericMatrix y, int cell);
RcppExport SEXP _remote_respLmParam(SEXP xSEXP, SEXP ySEXP, SEXP cellSEXP) {
BEGIN_RCPP
    Rcpp::RObject rcpp_result_gen;
    Rcpp::RNGScope rcpp_rngScope_gen;
    Rcpp::traits::input_parameter< NumericMatrix >::type x(xSEXP);
    Rcpp::traits::input_parameter< NumericMatrix >::type y(ySEXP);
    Rcpp::traits::input_parameter< int >::type cell(cellSEXP);
    rcpp_result_gen = Rcpp::wrap(respLmParam(x, y, cell));
    return rcpp_result_gen;
END_RCPP
}
// findudC
NumericVector findudC(NumericVector x);
RcppExport SEXP _remote_findudC(SEXP xSEXP) {
BEGIN_RCPP
    Rcpp::RObject rcpp_result_gen;
    Rcpp::RNGScope rcpp_rngScope_gen;
    Rcpp::traits::input_parameter< NumericVector >::type x(xSEXP);
    rcpp_result_gen = Rcpp::wrap(findudC(x));
    return rcpp_result_gen;
END_RCPP
}
// iodaC
double iodaC(NumericVector x, NumericVector y);
RcppExport SEXP _remote_iodaC(SEXP xSEXP, SEXP ySEXP) {
BEGIN_RCPP
    Rcpp::RObject rcpp_result_gen;
    Rcpp::RNGScope rcpp_rngScope_gen;
    Rcpp::traits::input_parameter< NumericVector >::type x(xSEXP);
    Rcpp::traits::input_parameter< NumericVector >::type y(ySEXP);
    rcpp_result_gen = Rcpp::wrap(iodaC(x, y));
    return rcpp_result_gen;
END_RCPP
}
// iodaSumC
NumericVector iodaSumC(NumericMatrix pred_vals, NumericMatrix resp_vals);
RcppExport SEXP _remote_iodaSumC(SEXP pred_valsSEXP, SEXP resp_valsSEXP) {
BEGIN_RCPP
    Rcpp::RObject rcpp_result_gen;
    Rcpp::RNGScope rcpp_rngScope_gen;
    Rcpp::traits::input_parameter< NumericMatrix >::type pred_vals(pred_valsSEXP);
    Rcpp::traits::input_parameter< NumericMatrix >::type resp_vals(resp_valsSEXP);
    rcpp_result_gen = Rcpp::wrap(iodaSumC(pred_vals, resp_vals));
    return rcpp_result_gen;
END_RCPP
}
// monthlyMeansC
NumericMatrix monthlyMeansC(NumericMatrix x, int nCycleWindow);
RcppExport SEXP _remote_monthlyMeansC(SEXP xSEXP, SEXP nCycleWindowSEXP) {
BEGIN_RCPP
    Rcpp::RObject rcpp_result_gen;
    Rcpp::RNGScope rcpp_rngScope_gen;
    Rcpp::traits::input_parameter< NumericMatrix >::type x(xSEXP);
    Rcpp::traits::input_parameter< int >::type nCycleWindow(nCycleWindowSEXP);
    rcpp_result_gen = Rcpp::wrap(monthlyMeansC(x, nCycleWindow));
    return rcpp_result_gen;
END_RCPP
}
// insertReconsC
NumericMatrix insertReconsC(List lRecons, NumericMatrix mdTemplate);
RcppExport SEXP _remote_insertReconsC(SEXP lReconsSEXP, SEXP mdTemplateSEXP) {
BEGIN_RCPP
    Rcpp::RObject rcpp_result_gen;
    Rcpp::RNGScope rcpp_rngScope_gen;
    Rcpp::traits::input_parameter< List >::type lRecons(lReconsSEXP);
    Rcpp::traits::input_parameter< NumericMatrix >::type mdTemplate(mdTemplateSEXP);
    rcpp_result_gen = Rcpp::wrap(insertReconsC(lRecons, mdTemplate));
    return rcpp_result_gen;
END_RCPP
}

static const R_CallMethodDef CallEntries[] = {
    {"_remote_corC", (DL_FUNC) &_remote_corC, 2},
    {"_remote_lmC", (DL_FUNC) &_remote_lmC, 2},
    {"_remote_predRsquaredSum", (DL_FUNC) &_remote_predRsquaredSum, 3},
    {"_remote_respLmParam", (DL_FUNC) &_remote_respLmParam, 3},
    {"_remote_findudC", (DL_FUNC) &_remote_findudC, 1},
    {"_remote_iodaC", (DL_FUNC) &_remote_iodaC, 2},
    {"_remote_iodaSumC", (DL_FUNC) &_remote_iodaSumC, 2},
    {"_remote_monthlyMeansC", (DL_FUNC) &_remote_monthlyMeansC, 2},
    {"_remote_insertReconsC", (DL_FUNC) &_remote_insertReconsC, 2},
    {NULL, NULL, 0}
};

RcppExport void R_init_remote(DllInfo *dll) {
    R_registerRoutines(dll, NULL, CallEntries, NULL, NULL);
    R_useDynamicSymbols(dll, FALSE);
}
