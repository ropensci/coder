#' Classcodes methods
#'
#' "Classcodes" are classifying schemes based on regular expression stored in
#' data frames. These are essential to the package and constitute the third
#' part of the triad of case data, code data and a classification scheme.
#'
#' A classcodes object is a data frame with mandatory columns:
#'
#' - `group`: unique and non missing class names
#' - `regex_*`: regular expressions ([regex]) defining class membership.
#'    Could be more than one and could have arbitrary names.
#'    Occurrences of non unique regular expressions will lead to the same class
#'    having multiple names. This is accepted but will raise a warning.
#'    Classes do not have to be disjunct;
#'    the same code can be recognized by more than one `regex_*`.
#'
#' The object can have additional optional columns:
#'
#' - `description`: description of each category
#' - `condition`: a class might have conditions additional to what
#'   is expressed by `regex_*`. If so, these should be specified as quoted
#'   expressions that can be evaluated within the data frame used by
#'   [classify()]
#' - `index_*`: weights for each class used by
#'   [index()]. Could be more than one and could have arbitrary names.
#'
#'
#' @param x data frame with columns described in the details section
#' @param hierarchy list of pairwise group names to appear as superior and
#' @param ... arguments passed between methods
#' subordinate classes.
#'   To be used for indexing when the subordinate class is redundant
#'   (see the details section of [`elixhauser`] for an example).
#' @param .name used internally for name dispatch
#'
#' @return Object of class "classcodes" (data frame) with additional attributes:
#'
#' - `code:` the coding used (for example "icd10", or "ATC").
#'    `NULL` for unknown/arbitrary coding.
#' - `regexprs:` name of columns with regular expressions
#' - `indices:` name of columns with (optional) index weights
#' - `hierarchy:` list as specified by the `hierarchy` argument.
#' - `name:` name as specified by the `.name` argument.
#'
#' @seealso
#' A vignette provides additional details and examples:
#' `vignette("classcodes", package = "coder")`
#'
#' The package have several default classcodes included, see [all_classcodes()].
#'
#' Regular expressions used in classcodes can often be quite complex
#' and hard to interpret. Use [visualize()] to visualize classcodes
#' graphically or [summary.classcodes()] to list all codes individually.
#'
#' @export
#' @name classcodes
#' @examples
#' as.classcodes(coder::elixhauser)
#' @family classcodes
as.classcodes <- function(x, ...) {
  UseMethod("as.classcodes")
}

#' @export
#' @rdname classcodes
as.classcodes.classcodes <- function(x, ...) {
  attr(x, "regexprs") <- intersect(attr(x, "regexprs"), names(x))
  attr(x, "indices") <- intersect(attr(x, "indices"), names(x))
  check_classcodes(x)
  x
}

#' @export
#' @rdname classcodes
as.classcodes.default <- function(x, ..., hierarchy = attr(x, "hierarchy"), .name = NULL) {

  # To avoid infinite recursive looping due to `$<-.classcodes` method
  class(x) <- setdiff(class(x), "classcodes")

  check_classcodes(x)


  rgs  <- colnames(x)[startsWith(colnames(x), "regex_")]
  indx <- colnames(x)[startsWith(colnames(x), "index_")]
  names(x) <- gsub("(reg|ind)ex_", "", names(x))

  structure(
    tibble::as_tibble(x),
    class       = unique(c("classcodes", class(x))),
    regexprs    = gsub("regex_", "", rgs),
    indices     = gsub("index_", "", indx),
    hierarchy   = hierarchy,
    name        = .name
  )
}


check_classcodes <- function(x) {
  stopifnot(
    is.data.frame(x),
    "group" %in% names(x),
    !anyNA(x$group),
    !any(x$group == ""),
    !any(duplicated(x$group))
  )

  rg <- attr(x, "regexprs")

  if (!any(startsWith(names(x), "regex")) &&
      (is.null(rg) || length(rg) == 0)) {
    stop("classcodes must have column with regular expression!")
  }
}


#' @export
#' @rdname classcodes
#' @family classcodes
is.classcodes <- function(x) inherits(x, "classcodes")

#' @export
`[.classcodes` <- function(x, ...) {
  hi <- attr(x, "hierarchy")
  nm <- attr(x, "name", exact = TRUE)
  x  <- NextMethod()
  attr(x, "hierarchy") <- hi
  as.classcodes(x, .name = nm)
}

#' @export
`[<-.classcodes` <- function(x, i, j, value) {
  as.classcodes(NextMethod(), .name = attr(x, "name", exact = TRUE))
}

#' @export
`$<-.classcodes` <- function(x, name, value) {
  as.classcodes(NextMethod(), .name = attr(x, "name", exact = TRUE))
}

#' @export
print.classcodes <- function(x, ...) {
  at <- function(y) paste(attr(x, y), collapse = ", ")
  writeLines(paste(
    "\nClasscodes object\n",
    "\nRegular expressions:\n  ", at("regexprs"),
    if (!is.null(attr(x, "indices")))
      "\nIndices:\n  ", at("indices"),
    if (!is.null(attr(x, "hierarchy")))
      "\nHierarchy:\n  ",
    paste(names(attr(x, "hierarchy")), collapse = ", "),
    "\n"
  ))

  NextMethod()
}

#' @export
as.data.frame.classcodes <- function(x, ...) {
  class(x) <- setdiff(class(x), "classcodes")
  NextMethod()
}

