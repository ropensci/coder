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
#' \item{condition (optional):}{a class might have conditions additional to what
#'   is expressed by \code{regex}. If so, these should be specified as quoted
#'   expressions that can be evaluated within the data frame used by
#'   \code{\link{classify}}}
#' \item{weights (optional):}{weights for each class used for \code{\link{index}}
#' calculation. Could be more than one and could have arbitrary names.}
#' }
#' Note that classes does not have to be disjunct.
#'
#' The package have several default classcodes included listed on its index page
#' `help(package = "classifyr")`
#'
#' @param x data frame with properties as described in the details section
#'
#' @return Object of class "classcodes"
#' @export
#' @name classcodes
#' @examples
#' as.classcodes(classifyr::elix_icd10)
as.classcodes <- function(x) {
  stopifnot(
    is.data.frame(x),
    all(c("group", "regex") %in% names(x)),
    !anyNA(x$group),
    !any(x$group == ""),
    !any(duplicated(x$group)),
    is.character(x$regex) | is.numeric(x$regex)
  )
  if (any(duplicated(x$regex))) {
    warning("Non unique elements of 'x$regex' implying identical classes with ",
      "multilpe names!")
  }
  structure(x, class = unique(c("classcodes", class(x))))
}

#' @export
#' @rdname classcodes
is.classcodes <- function(x) inherits(x, "classcodes")
