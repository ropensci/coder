#' Calculate index based on classification scheme
#'
#' @param x matrix as output from \code{classify}
#' @param by name of column with 'weights' from corresponding \code{\link{classcodes}} object.
#' Can be omitted if the index is just the count of relevant classes.
#' @param from \code{\link{classcodes}} object. Can be omitted if information already
#' present as attribute of \code{x} (which is often the case) and/or if index
#' calculated without weights.
#'
#' @return Named numeric index vector with names corresponding to \code{rownames(x)}
#' @export
#'
#' @examples
#' # Calculate Elixhauser comorbidity index
#' classify(c("C80", "I20"), "elix_icd10") %>%
#'   index()
#'
#' # Calculate Charlson-index using original weights
#' classify(c("C80", "I21"), "charlson_icd10") %>%
#'   index("original")
#'
#' # Calculate Charlson-index using updated weights
#' classify(c("C80", "I21"), "charlson_icd10") %>%
#'   index("updated")
#'
#'
#' # Find patients with adverse events after hip surgery
#' codify(ex_people, ex_icd10, id = "name", date = "surgery") %>%
#'   classify("hip_adverse_events_icd10") %>%
#'   index()
index <- function(x, by = NULL, from = NULL) {

  stopifnot(is.matrix(x))

  # Find classcode object (NULL is valid if no weights supplied)
  from <- get_classcodes(from, x)

  # index is either the simple rowsum or made by vector multiplication of weights
  ans <-
    if (is.null(by))
      rowSums(x)
    else if (is.null(from))
      stop("Argument 'from' is missing!")
    else if (!(by %in% names(from)))
      stop(by, " (as given by argument 'by') is not a column of the classcodes object!")
    else
      c(x %*% from[[by]])

  names(ans) <- rownames(x)
  ans
}
