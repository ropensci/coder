#' Calculate index based on classification scheme
#'
#' @param x output from \code{classify}
#' (or possibly from \code{\link{as.data.frame.classified}})
#' @param by name of column with 'weights' from corresponding
#'   \code{\link{classcodes}} object. Can be omitted if the index is just the
#'   count of relevant classes.
#' @param from \code{\link{classcodes}} object. Can be omitted if information
#'   already present as attribute of \code{x} (which is often the case) and/or
#'   if index calculated without weights.
#'
#' @param ... used internally
#'
#' @return Named numeric index vector with names corresponding to
#'   \code{rownames(x)}
#' @export
#'
#' @examples
#'
#' # Make the pipe operator available
#' `%>%` <- dplyr::`%>%`
#'
#' # Calculate Elixhauser comorbidity index
#' classify(c("C80", "I20"), "elix_icd10") %>%
#'   index()
#'
#' # Calculate Charlson-index using original weights
#' classify(c("C80", "I21"), "charlson_icd10") %>%
#'   index("quan_original")
#'
#' # Calculate Charlson-index using updated weights
#' classify(c("C80", "I21"), "charlson_icd10") %>%
#'   index("quan_updated")
#'
#'
#' # Find patients with adverse events after hip surgery
#' codify(ex_people, ex_icd10, id = "name",
#'     date = "surgery", days = c(-365, 0)) %>%
#'   classify("hip_adverse_events_icd10") %>%
#'   index()
#'
#' @name index
index <- function(x, ...) UseMethod("index")

#' @export
#' @rdname index
index.data.frame <- function(x, ...) {
  message("column '", names(x)[1], "' used as id!")
  y <- as.matrix(x[-1])
  dimnames(y)[1] <- x[1]
  index(y, from = attr(x, "classcodes"), ...)
}

#' @rdname index
#' @export
index.matrix <- function(x, by = NULL, from = NULL, ...) {

  # Find classcode object (NULL is valid if no weights supplied)
  from <- get_classcodes(from, x)

  # index is either the simple rowsum or made by
  # vector multiplication of weights
  ans <-
    if (is.null(by))
      rowSums(x)
    else if (is.null(from))
      stop("Argument 'from' is missing!")
    else if (!(by %in% names(from)))
      stop(gettextf("'%s' is not a column of the classcodes object!", by))
    else if (!setequal(colnames(x), from$group))
      stop("Data non consistent with specified classcodes!")
    else
      c(x %*% from[[by]])

  # Needs further development!
  if (identical(from, classifyr::charlson_icd10) &&
      any(by %in% c("charlson", "dhoore")))
    warning("Leukemia and lymphona not implemented and therefore ignored!")

  names(ans) <- rownames(x)
  ans
}
