#' Calculate index based on classification scheme
#'
#' @param classified output from \code{classify}
#' @param index name of column with 'weights' from corresponding
#'   \code{\link{classcodes}} object. Can be \code{NULL} if the index is just a
#'   count of relevant classes.
#' @param cc \code{\link{classcodes}} object. Can be \code{NULL} if information
#'   already present as attribute of \code{classified} (which is often the case) and/or
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
#' cl <- classify(c("C80", "I20"), "elixhauser")
#' index(cl)
#'
#' # Calculate Charlson-index using original weights
#' cl <- classify(c("C80", "I21"), "charlson")
#' index(cl, "quan_original")
#'
#' # Calculate Charlson-index using updated weights
#' cl <- classify(c("C80", "I21"), "charlson")
#' index(cl, "quan_updated")
#'
#' @name index_fun
NULL

# Use strange names to avoid name collision with index.html used by pkgdown!
#' @rdname index_fun
#' @export
#' @family verbs
index <- function(classified, ...) UseMethod("index")

#' @export
#' @rdname index_fun
index.data.frame <- function(classified, ...) {
  message("column '", names(classified)[1], "' used as id!")
  y <- as.matrix(classified[-1])
  dimnames(y)[1] <- classified[1]
  index(y, from = attr(classified, "classcodes"), ...)
}

#' @rdname index_fun
#' @export
index.matrix <- function(classified, index = NULL, cc = NULL, ...) {

  # Find classcodes object (NULL is valid if no weights supplied)
  cc <- set_classcodes(cc, classified)

  # clean text to compare colnames if tech_names used
  regularize <- function(x) {
    gsub("\\W", "_", tolower(x), perl = TRUE)
  }
  # index is either the simple rowsum or made by
  # vector multiplication of weights
  out <-
    if (is.null(index)) {
      message("index calculated as number of relevant categories")
      rowSums(classified)
    } else if (is.null(cc)) {
      stop("Argument 'from' is missing!")
    } else if (!(index %in% names(cc))) {
      stop(gettextf("'%s' is not a column of the classcodes object!", index))
    } else if (!all(vapply(regularize(cc$group),
      function(y) any(grepl(y, regularize(colnames(classified)))), logical(1)))) {
      stop("Data non consistent with specified classcodes!")
    } else {
      c(classified %*% cc[[index]])
    }

  names(out) <- rownames(classified)
  out
}
