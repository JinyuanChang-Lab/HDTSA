#' @name PCA_TS
#' @title Principal component analysis for vector time series
#' @description \code{PCA_TS()} seeks for a contemporaneous linear
#'   transformation for a multivariate time series such that the transformed
#'   series is segmented into several lower-dimensional subseries: \deqn{{\bf
#'   y}_t={\bf Ax}_t,} where \eqn{{\bf x}_t} is an unobservable \eqn{p \times 1}
#'   weakly stationary time series consisting of \eqn{q\ (\geq 1)} both
#'   contemporaneously and serially uncorrelated subseries. See Chang, Guo and
#'   Yao (2018).
#'
#'
#'
#' @details The threshold operator \eqn{T_\delta(\cdot)} is defined as
#'   \eqn{T_\delta({\bf W}) = \{w_{i,j}1(|w_{i,j}|\geq \delta)\}} for any matrix
#'   \eqn{{\bf W}=(w_{i,j})}, with the threshold level \eqn{\delta \geq 0} and \eqn{1(\cdot)}
#'   representing the indicator function. We recommend to choose
#'   \eqn{\delta=0} when \eqn{p} is fixed and \eqn{\delta>0} when \eqn{p \gg n}.
#' 
#'   For large \eqn{p}, since the sample covariance matrix may not be consistent,
#'   we recommend to use the method proposed
#'   in Cai, Liu and Luo (2011) to estimate the precision matrix 
#'   \eqn{\hat{{\bf V}}^{-1}} (\code{opt = 2}).
#'   
#'   \code{control} is a list of arguments passed to the function \code{clime()},
#'   which contains the following components:
#'   \itemize{
#'    \item \code{nlambda}: Number of values for program generated lambda. The default is 100.
#'    \item \code{lambda.max}: Maximum value of program generated lambda. The default is 0.8.
#'    \item \code{lambda.min}: Minimum value of program generated lambda. 
#'    The default is \eqn{10^{-4}} (\eqn{n>p}) or \eqn{10^{-2}} (\eqn{n<p}).
#'    \item \code{standardize}: Logical. If \code{standardize = TRUE}, the
#'    variables will be standardized to have mean zero and unit standard
#'    deviation. The default is \code{FALSE}.
#'    \item \code{linsolver}: An option used to choose which method should be employed.
#'    Available options include \code{"primaldual"} (the default) and \code{"simplex"}.
#'    Rule of thumb: \code{"primaldual"} for large \eqn{p}, \code{"simplex"} for small \eqn{p}.
#'   }
#'
#' @param Y  An \eqn{n \times p} data matrix \eqn{{\bf Y} = ({\bf y}_1, \dots , {\bf y}_n )'},
#'   where \eqn{n} is the number of the observations of the \eqn{p \times 1}
#'   time series \eqn{\{{\bf y}_t\}_{t=1}^n}. The procedure will first
#'   normalize \eqn{{\bf y}_t} as \eqn{\hat{{\bf V}}^{-1/2}{\bf y}_t}, where
#'   \eqn{\hat{{\bf V}}} is an estimator for covariance of \eqn{{\bf y}_t}.
#'   See details below for the selection of \eqn{\hat{{\bf V}}^{-1}}.
#' @param lag.k  The time lag \eqn{K} used to calculate the nonnegative definte
#'   matrix \eqn{\hat{{\bf W}}_y}: \deqn{\hat{\mathbf{W}}_y\ =\ \mathbf{I}_p+
#'   \sum_{k=1}^{K} T_\delta \{\hat{\mathbf{\Sigma}}_y(k)\} T_\delta \{\hat{\mathbf{\Sigma}}_y(k)\}',
#'    } where \eqn{\hat{\bf \Sigma}_y(k)} is the sample autocovariance of
#'   \eqn{ \hat{{\bf V}}^{-1/2}{\bf y}_t} at lag \eqn{k} and \eqn{T_\delta(\cdot)}
#'   is a threshold operator with the threshold level \eqn{\delta \geq 0}. See 'Details'.
#'   The default is 5.
#'   
#' @param thresh   Logical. If \code{thresh = FALSE} (the default), no thresholding will
#'   be applied to estimate \eqn{\hat{\bf W}_y}. If \code{thresh = TRUE}, the
#'   argument \code{delta} is used to specify the threshold level \eqn{\delta}.
#' @param delta  The value of the threshold level \eqn{\delta}. The default is
#'  \eqn{ \delta = 2 \sqrt{n^{-1}\log p}}.
#' @param prewhiten Logical. If \code{TRUE} (the default), we prewhiten each
#'   transformed component series of \eqn{\hat{\bf z}_t} [See Section 2.2.1 in
#'   Chang, Guo and Yao (2018)] by fitting a univariate AR model with the order
#'   between 0 and 5 determined by AIC. If \code{FALSE}, then the prewhiten
#'   procedure will not be performed.
#' @param opt An option used to choose which method will be implemented to get a
#' consistent estimate \eqn{\hat{\bf V}} (or \eqn{\hat{\bf V}^{-1}}) for the
#' covariance (precision) matrix of \eqn{{\bf y}_t}. If \code{opt = 1},
#' \eqn{\hat{\bf V}} will be defined as the sample covariance matrix. If
#' \code{opt = 2}, the precision matrix \eqn{\hat{\bf V}^{-1}} will be calculated
#' by using the function \code{clime()} of \pkg{clime} (Cai, Liu and Luo, 2011) with
#' the arguments passed by \code{control}.
#' @param control A list of control arguments. See ‘Details’.
#' @param permutation The method of permutation procedure to assign the
#'   components of \eqn{\hat{\bf z}_t} to different groups [See Section 2.2.1 in
#'   Chang, Guo and Yao (2018)]. Available options include: \code{"max"} (the default) for the
#'   maximum cross correlation method and \code{"fdr"} for the false discovery
#'   rate procedure based on multiple tests. See Sections
#'   2.2.2 and 2.2.3 in Chang, Guo and Yao (2018) for more information.
#' @param m A positive integer used in the permutation procedure [See (2.10) in
#'   Chang, Guo and Yao (2018)]. The default is 10.
#' @param beta The error rate used in the permutation procedure[See (2.16) in
#'   Chang, Guo and Yao (2018)] when \code{permutation = "fdr"}.
#' @export
#' @return An object of class \code{"tspca"}, which contains the following
#' components: 
#'   \item{B}{The \eqn{p\times p} transformation matrix
#'   \eqn{\hat{\bf B}=\hat{\bf \Gamma}_y'\hat{{\bf V}}^{-1/2}}, where
#'   \eqn{\hat{\bf \Gamma}_y} is a \eqn{p \times p} orthogonal matrix with the
#'   columns being the eigenvectors of \eqn{\hat{\bf W}_y}.}
#'   \item{X}{The \eqn{n \times p} matrix
#'   \eqn{\hat{\bf X}=(\hat{\bf x}_1,\dots,\hat{\bf x}_n)'} with
#'   \eqn{\hat{\bf x}_t = \hat{\bf B}{\bf y}_t}.}
#'   \item{NoGroups}{The number of groups.}
#'   \item{No_of_Members}{The number of members in each group.}
#'   \item{Groups}{The indices of the components of \eqn{\hat{\bf x}_t} that
#'   belong to each group.}
#'   \item{method}{A string indicating which permutation procedure is performed.}
#'   
#'
#'
#' @references 
#'   Cai, T., Liu, W., & Luo, X. (2011). A constrained L1 minimization
#'   approach for sparse precision matrix estimation. \emph{Journal of the American
#'   Statistical Association}, \strong{106}, 594--607. \doi{doi:10.1198/jasa.2011.tm10155}.
#'   
#'   Chang, J., Guo, B., & Yao, Q. (2018). Principal component
#'   analysis for second-order stationary vector time series. \emph{The Annals of
#'   Statistics}, \strong{46}, 2094--2124. \doi{doi:10.1214/17-AOS1613}.
#' @importFrom stats acf ar pnorm var
#' @useDynLib HDTSA
#' @importFrom Rcpp sourceCpp
#' @importFrom Rcpp evalCpp
#' @export
#' @examples
#' # Example 1 (Example 1 in the supplementary material of Chang, Guo and Yao (2018)).
#' # p=6, x_t consists of 3 independent subseries with 3, 2 and 1 components.
#' 
#' ## Generate x_t
#' p <- 6;n <- 1500
#' X <- mat.or.vec(p,n)
#' x <- arima.sim(model = list(ar = c(0.5, 0.3), ma = c(-0.9, 0.3, 1.2,1.3)),
#' n = n+2, sd = 1)
#' for(i in 1:3) X[i,] <- x[i:(n+i-1)]
#' x <- arima.sim(model = list(ar = c(0.8,-0.5),ma = c(1,0.8,1.8) ), n = n+1, sd = 1)
#' for(i in 4:5) X[i,] <- x[(i-3):(n+i-4)]
#' x <- arima.sim(model = list(ar = c(-0.7, -0.5), ma = c(-1, -0.8)), n = n, sd = 1)
#' X[6,] <- x
#' 
#' ## Generate y_t
#' A <- matrix(runif(p*p, -3, 3), ncol = p)
#' Y <- A%*%X
#' Y <- t(Y)
#' 
#' ## permutation = "max" or permutation = "fdr"
#' res <- PCA_TS(Y, lag.k = 5,permutation = "max")
#' res1 <- PCA_TS(Y, lag.k = 5,permutation = "fdr", beta = 10^(-10))
#' Z <- res$X
#' 
#'
#' # Example 2 (Example 2 in the supplementary material of Chang, Guo and Yao (2018)).
#' # p=20, x_t consists of 5 independent subseries with 6, 5, 4, 3 and 2 components.
#' 
#' ## Generate x_t
#' p <- 20;n <- 3000
#' X <- mat.or.vec(p,n)
#' x <- arima.sim(model = list(ar = c(0.5, 0.3), ma = c(-0.9, 0.3, 1.2, 1.3)), 
#' n.start = 500, n = n+5, sd = 1)
#' for(i in 1:6) X[i,] <- x[i:(n+i-1)]
#' x <- arima.sim(model = list(ar = c(-0.4, 0.5), ma = c(1, 0.8, 1.5, 1.8)),
#' n.start = 500, n = n+4, sd = 1)
#' for(i in 7:11) X[i,] <- x[(i-6):(n+i-7)]
#' x <- arima.sim(model = list(ar = c(0.85,-0.3), ma=c(1, 0.5, 1.2)),
#' n.start = 500, n = n+3,sd = 1)
#' for(i in 12:15) X[i,] <- x[(i-11):(n+i-12)]
#' x <- arima.sim(model = list(ar = c(0.8, -0.5),ma = c(1, 0.8, 1.8)),
#' n.start = 500, n = n+2,sd = 1)
#' for(i in 16:18) X[i,] <- x[(i-15):(n+i-16)]
#' x <- arima.sim(model = list(ar = c(-0.7, -0.5), ma = c(-1, -0.8)),
#' n.start = 500,n = n+1,sd = 1)
#' for(i in 19:20) X[i,] <- x[(i-18):(n+i-19)]
#' 
#' ## Generate y_t
#' A <- matrix(runif(p*p, -3, 3), ncol =p)
#' Y <- A%*%X
#' Y <- t(Y)
#' 
#' ## permutation = "max" or permutation = "fdr"
#' res <- PCA_TS(Y, lag.k = 5,permutation = "max")
#' res1 <- PCA_TS(Y, lag.k = 5,permutation = "fdr",beta = 10^(-200))
#' Z <- res$X
#' 
PCA_TS <- function(Y, lag.k = 5, opt = 1, permutation = c("max", "fdr"), thresh = FALSE,
                   delta = 2 * sqrt(log(ncol(Y)) / nrow(Y)), prewhiten = TRUE, m = NULL,
                   beta, control = list())
{
  #for timeseries
  permutation <- match.arg(permutation)
  seglist <- segmentTS(Y = Y, lag.k = lag.k,
                       thresh = thresh,
                       delta = delta,
                       opt,
                       control = control)
  Z <- seglist$Z
  B <- seglist$B
  
  #---------------permutation of MAX----------------------
  if (permutation == "max") {
    # METHOD <- c(METHOD, "Maximum cross correlation method")
    out <- permutationMax(Z, prewhiten, m)
    output <- structure(list(B = B, X = Z, NoGroups = out$NoGroups,
                             No_of_Members = out$No_of_Members,
                             Groups = out$Groups,
                             method = "Maximum cross correlation method"),
                        class = "tspca")
    return(output)
  }
  #---------------permutation of FDR----------------------
	else if (permutation == "fdr") {
    # METHOD <- c(METHOD, "FDR based on multiple tests")
    out <- permutationFDR(Z, prewhiten, beta, m)
    output <- structure(list(B = B, X = Z, NoGroups = out$NoGroups,
                             No_of_Members = out$No_of_Members,
                             Groups = out$Groups,
                             method = "FDR based on multiple tests"),
                        class = "tspca")
    return(output)
  }
}


