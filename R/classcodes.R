#' Classcodes methods
#'
#' "Classcodes" are classifying schemes based on regular expression stored in
#' data frames. These are essential to the package and constitute the third
#' part of the triad of case data, code data and a classification scheme.
#'
#' A classcodes object is a data frame with mandatory columns:
#'
#' - `group`: unique and non missing class names
#' - `At least one column with regular expressions
#'    ([regex] without Perl-like versions) defining class
#'    membership. Those columns can have arbitrary names
#'    (as specified by the `regex`argument).
#'    Occurrences of non unique regular expressions will lead to the same class
#'    having multiple names. This is accepted but will raise a warning.
#'    Classes do not have to be disjunct.
#'
#' The object can have additional optional columns:
#'
#' - `description`: description of each category
#' - `condition`: a class might have conditions additional to what
#'   is expressed by the regular expressions.
#'   If so, these should be specified as quoted
#'   expressions that can be evaluated within the data frame used by
#'   [classify()]
#' - weights for each class used by
#'   [index()]. Could be more than one and could have arbitrary names
#'   (as specified by the `indices`argument).
#'
#'
#' @param x data frame with columns described in the details section
#' @param regex,indices character vector with names of columns in `x` containing
#'   regular expressions/indices.
#' @param hierarchy named list of pairwise group names to appear as superior and
#'   subordinate for indices. See [elixhauser] for a possible application.
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
#' @example man/examples/as.classcodes.R
#' @family classcodes
as.classcodes <- function(x, ...) {
  UseMethod("as.classcodes")
}

#' @export
#' @rdname classcodes
as.classcodes.classcodes <- function(x,
                                     ...,
                                     regex     = attr(x, "regexpr"),
                                     indices   = attr(x, "indices"),
                                     hierarchy = attr(x, "hierarchy")
                                     ) {
  attr(x, "regexprs")  <- intersect(regex,   names(x))
  attr(x, "indices")   <- intersect(indices, names(x))
  attr(x, "hierarchy") <- hierarchy
  check_classcodes(x)
  x
}

#' @export
#' @rdname classcodes
as.classcodes.default <- function(x,
                                  ...,
                                  regex     = NULL,
                                  indices   = NULL,
                                  hierarchy = attr(x, "hierarchy"),
                                  .name     = NULL
                                  ) {

  # To avoid infinite recursive looping due to `$<-.classcodes` method
  class(x) <- setdiff(class(x), "classcodes")

  out <-
    tibble::as_tibble(
      stats::setNames(x, gsub("(reg|ind)ex_", "", names(x)))
    )

  out <-
    structure(
      out,
      class       = unique(c("classcodes", class(out))),
      regexprs    = find_attr(x, regex, "regular expressions", "regex_", TRUE),
      indices     = find_attr(x, indices, "indices", "index_", FALSE),
      hierarchy   = hierarchy,
      name        = .name
    )
  check_classcodes(out)
  out
}

# Set regex and indices attributes either by arguments,
# or by prefixed column names
find_attr <- function(x, arg, what, prefix, must) {
  if (!is.null(arg)) {
    arg_found <- arg %in% colnames(x)
    if (!all(arg_found)) {
      stop("Column with ", what, " not found in `x`: ",
           paste(arg[!arg_found], collapse = ", "), call. = FALSE)
    }
    arg
    # Old method by prefixed column names
  } else {
    pre <- colnames(x)[startsWith(colnames(x), prefix)]
    if (length(pre) == 0)
      if (must)
        stop("`x` must have at least one column with ", what, call. = FALSE)
    gsub(prefix, "", pre)
  }
}

check_classcodes <- function(x) {

  if (!is.data.frame(x))
    stop("Classcodes objects must inherit from data.frame!")
  if (!"group" %in% names(x))
    stop("classcodes object must have a column named `group`!")
  if (anyNA(x$group) || any(x$group == ""))
    stop("`x$group` have missing values (NA or ''). This is not allowed!")
  if (any(duplicated(x$group)))
    stop("All values of `x$group` must be unique!")

  # Check that regex exist
  rg <- attr(x, "regexprs")
  if (!any(startsWith(names(x), "regex")) &&
      (is.null(rg) || length(rg) == 0)) {
    stop("classcodes must have column with regular expression!")
  }

  # If hierarchy specified, it must relates to columns in x
  hi <- attr(x, "hierarchy")
  if (!is.null(hi)) {
    hi_cols <- c(hi, recursive = TRUE)
    if (!all(hi_cols %in% x$group)) {
      stop(
        "Hierarchical conditions not found in `x$group`: ",
        paste(hi_cols[!hi_cols %in% x$group], collapse = ", "),
        call. = FALSE
      )
    }
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

#' Print classcodes object
#'
#' @param x object of type classcodes
#' @param n number of rows to preview (`n = 0` is allowed)
#' @param ... arguments passed to print method for tibble
#' @export
#' @family classcodes
#' @examples
#' # Default printing
#' coder::elixhauser
#'
#' # Print all rows
#' print(coder::elixhauser, n = 31)
print.classcodes <- function(x, n = NULL, ...) {
  at <- function(y) paste(attr(x, y), collapse = ", ")
  writeLines(paste(
    "\nClasscodes object\n",
    "\nRegular expressions:\n  ", at("regexprs"),
    if (!is.null(attr(x, "indices")))
      "\nIndices:\n  ", at("indices"),
    if (!is.null(attr(x, "hierarchy")))
      "\nHierarchy:\n  ",
    paste(attr(x, "hierarchy"), collapse = ",\n   "),
    "\n"
  ))
  if (is.null(n) || n != 0) {
    print(tibble::as_tibble(x), n = n, ...)
  }
}

#' @export
as.data.frame.classcodes <- function(x, ...) {
  class(x) <- setdiff(class(x), "classcodes")
  NextMethod()
}

#' @export
#' @importFrom tibble as_tibble
as_tibble.classcodes <- function(x, ...) {
  class(x) <- setdiff(class(x), "classcodes")
  NextMethod()
}
