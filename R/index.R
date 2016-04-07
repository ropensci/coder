#' Calculate index based on classification scheme
#'
#' @param x matrix as output from \code{classify}
#' @param classcodes object of class \code{classcodes}.
#' Needed if classes have different weights. \code{NULL} (as by default)
#' gives index = 1 if element belongs to any class, 0 otherwise.
#'
#' @return Named numeric index vector with names corresponding to \code{rownames(x)}
#' @export
#'
#' @examples
#' x <- classify(c("C80", "I20", "XXX"))
#' index(x)
index <- function(x, classcodes = NULL) {
  stopifnot(is.matrix(x))
  ans <-
    if (is.character(classcodes)) {
      classcodes <- get(classcodes)
      if ("w" %in% names(classcodes))
        x %*% classcodes$w
    } else {
        as.numeric(apply(x, 1, any))
    }
  names(ans) <- rownames(x)
  ans
}
