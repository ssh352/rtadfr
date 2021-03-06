#' Estimate the ADF/SADF/GSADF test statistic
#'
#' Calculates recursive and non-recursive right-tailed unit root tests
#' statistics.
#'
#' @param y     Vector to be tested for an explosive root.
#' @param r0    Minimal Window size.
#' @param test  Test type, either "adf", "sadf" of "gsadf".
#' @param type  Deterministic terms, either, either "none", "drift" or "trend".
#' @param lags  Number of lags for y to be included.
#' @param selectlags Lag selection can be achieved according to the Akaike "AIC"
#'   or the Bayes "BIC" information criteria. The maximum number of lags
#'   considered is set by lags. The default is to use a "fixed" lag length set
#'   by lags.
#'
#' @return  List with test statistic, date-stamping sequence
#'
#' @references
#' Phillips, P. C. B., Wu, Y., & Yu, J. (2011). Explosive Behavior
#' in the 1990s Nasdaq: When Did Exuberance Escalate Asset Values?,
#' \emph{International Economic Review}, 201(1), 201--226.
#'
#' Phillips, P. C. B., Shi, S., & Yu, J. (2015). Testing for multiple bubbles:
#' Historical episodes of exuberance and collapse in the S&P 500.
#' \emph{International Economic Review}, 56(4), 1034--1078.
#'
#' @export
#'
#' @importFrom urca ur.df
#'
#' @examples
#' \dontrun{
#' t  <- 100
#' y  <- rnorm(t)
#' r0 <- round(t*(0.01+1.8/sqrt(t))) # minimal window size
#' rtadf(y, r0, test ="sadf")
#' }
rtadf <- function(y, r0, test = c("adf", "sadf", "gsadf"),
                  type = c("none", "drift", "trend"),
                  lags = 1, selectlags = c("Fixed", "AIC", "BIC")) {


  if (test == "adf") {
    testStat <- ur.df(y, type, lags, selectlags)@teststat
    output <- list("testStat" = testStat)
  } else if (test == "sadf") {
    testStat <- ur.sadf(y, r0, type, lags, selectlags)$stat
    testSeq  <- c(rep(NA, r0 - 1),
                  ur.sadf(y, r0, type, lags, selectlags)$sequence)
    output <- list("testStat" = testStat, "testSeq" = testSeq)
  } else if (test == "gsadf") {
    testStat <- ur.gsadf(y, r0, type, lags, selectlags)$stat
    testSeq  <- c(rep(NA, r0 - 1),
                  ur.gsadf(y, r0, type, lags, selectlags)$sequence)
    output <- list("testStat" = testStat, "testSeq" = testSeq)
  }

  output$Cval <- data.frame("significance level" = c("90%", "95%", "99%"),
                                      "critical values" = sapply(c(0.9, 0.95, 0.99),
                                                                 rtadfCval, t = length(y),
                                                                 testType = test))

  return(output)
}
