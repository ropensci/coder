#' Classcodes methods
#'
#' "Classcodes" are classifying schemes based on regular expression stored in
#' data frames. These are essential to the package and constitute the third
#' part of the triad of case data, code data and classification scheme.
#'
#' A classcodes object is a data frame with columns:
#' \describe{
#' \item{group:}{unique and non missing class name}
#' \item{regex:}{regular expression defining class membership
#' (see \code{\link{regex}} for details). Occurrences of non unique regular
#' expressions will lead to the same class having multiple names. This is
#' accepted but will raise a warning.}
#' \item{description (optional):}{description of each category}
#' \item{condition (optional):}{a class might have conditions additional to what
#'   is expressed by \code{regex}. If so, these should be specified as quoted
#'   expressions that can be evaluated within the data frame used by
#'   \code{\link{classify}}}
#' \item{weights (optional):}{weights for each class used for
#'   \code{\link{index}} calculation.
#'   Could be more than one and could have arbitrary names.}
#'   \item{hierarchy}{pairwise hierarchys for wich only the superior class
#'     should be used for indexing}
#' }
#' Note that classes does not have to be disjunct.
#'
#' The package have several default classcodes included listed on its index page
#' `help(package = "coder")`
#'
#' @param x data frame with properties as described in the details section
#' @param hierarchy list of pairwise group names to appear as superior and subordinate classes.
#'   To be used for indexing when the subordinate class is redundant.
#' @return Object of class "classcodes" (data frame) with attribute \code{code}
#' specifying the coding used (for example "icd10", or "ATC").
#' Could be \code{NULL} for unknown or arbitrary coding.
#'
#' @seealso Regular expressions used in classcodes can often be quite complex
#' and hard to interpret. Use \code{\link{visualize}} to visualize classcodes
#' graphically or \code{\link{summary.classcodes}} to
#' list all codes individually.
#'
#' @export
#' @name classcodes
#' @examples
#' as.classcodes(coder::elixhauser)
#' @family classcodes
as.classcodes <- function(x, hierarchy = attr(x, "hierarchy")) {

  class(x) <- setdiff(class(x), "classcodes") # To avoid infinite recursive looping due to `$<-.classcodes` method

  stopifnot(
    is.data.frame(x),
    "group" %in% names(x),
    any(startsWith(names(x), "regex")),
    !anyNA(x$group),
    !any(x$group == ""),
    !any(duplicated(x$group))
  )

  rgs <- colnames(x)[startsWith(colnames(x), "regex")]
  structure(
    x,
    class       = unique(c("classcodes", class(x))),
    regexprs    = colnames(x)[startsWith(colnames(x), "regex")],
    indices     = colnames(x)[startsWith(colnames(x), "index")],
    hierarchy   = hierarchy
  )
}

#' @export
#' @rdname classcodes
#' @family classcodes
is.classcodes <- function(x) inherits(x, "classcodes")

#' @export
`[.classcodes` <- function(x, ...) {
  hi <- attr(x, "hierarchy")
  x <- NextMethod()
  attr(x, "hierarchy") <- hi
  as.classcodes(x)
}

#' @export
`[<-.classcodes` <- function(x, i, j, value) {
  as.classcodes(NextMethod())
}

#' @export
`$<-.classcodes` <- function(x, name, value) {
  x <- NextMethod()
  as.classcodes(x)
}
