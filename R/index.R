#' Calculate index based on classification scheme
#'
#' @param x matrix as output from \code{classify}
#' @param by object of class \code{classcodes}.
#' Needed if classes have different weights. \code{NULL} (as by default)
#' gives index = 1 if element belongs to any class, 0 otherwise.
#'
#' @return Named numeric index vector with names corresponding to \code{rownames(x)}
#' @export
#'
#' @examples
#' x <- classify(c("C80", "I20", "XXX"))
#' index(x)
#'
#' # Find patients with adverse events after hip surgery
#' distill(ex_people, ex_icd10, id = "name", date = "surgery") %>%
#' classify("hip_adverse_events_icd10") %>%
#'   index()
index <- function(x, by = NULL) {

  stopifnot(is.matrix(x))

  id <- if (is.null(by) & !is.null(attr(x, "classcodes"))) attr(x, "classcodes")
        else id

  if (is.character(by)) by <- get(by)

  ans <-
    if ("w" %in% names(by)) x %*% by$w
    else rowSums(x)

  names(ans) <- rownames(x)
  ans
}
