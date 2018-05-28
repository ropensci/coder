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
#'
#' @examples
#'
#' # Calculate Elixhauser comorbidity index
#' cl <- classify(c("C80", "I20"), "elix_icd10")
#' index(cl)
#'
#' # Calculate Charlson-index using original weights
#' cl <- classify(c("C80", "I21"), "charlson_icd10")
#' index(cl, "quan_original")
#'
#' # Calculate Charlson-index using updated weights
#' cl <- classify(c("C80", "I21"), "charlson_icd10")
#' index(cl, "quan_updated")
#'
#'
#' # Find patients with adverse events after hip surgery
#' co <- codify(ex_people, ex_icd10, id = "name",
#'     date = "surgery", days = c(-365, 0))
#' cl <- classify(co, "hip_adverse_events_icd10_old")
#' index(cl)
#'
#' @name index_fun
NULL

# Use strange names to avoid name collision with index.html used by pkgdown!
#' @rdname index_fun
#' @export
index <- function(x, ...) UseMethod("index")

#' @export
#' @rdname index_fun
index.data.frame <- function(x, ...) {
  message("column '", names(x)[1], "' used as id!")
  y <- as.matrix(x[-1])
  dimnames(y)[1] <- x[1]
  index(y, from = attr(x, "classcodes"), ...)
}

#' @rdname index_fun
#' @export
index.matrix <- function(x, by = NULL, from = NULL, ...) {

  # Find classcodes object (NULL is valid if no weights supplied)
  from <- get_classcodes(from, x)

  # clean text to compare colnames if tech_names used
  regularize <- function(x) {
    gsub("\\W", "_", tolower(x), perl = TRUE)
  }
  # index is either the simple rowsum or made by
  # vector multiplication of weights
  ans <-
    if (is.null(by)) {
      message("index calculated as number of relevant categories")
      rowSums(x)
    } else if (is.null(from)) {
      stop("Argument 'from' is missing!")
    } else if (!(by %in% names(from))) {
      stop(gettextf("'%s' is not a column of the classcodes object!", by))
    } else if (!all(vapply(regularize(from$group),
      function(y) any(grepl(y, regularize(colnames(x)))), logical(1)))) {
      stop("Data non consistent with specified classcodes!")
    } else {
      c(x %*% from[[by]])
    }

  # Needs further development!
  if (identical(from, coder::charlson_icd10) &&
      any(by %in% c("charlson", "dhoore")))
    warning("Leukemia and lymphona not implemented and therefore ignored!")

  names(ans) <- rownames(x)
  ans
}
