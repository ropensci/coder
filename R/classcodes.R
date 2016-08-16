#' Classcode methods
#'
#' "Classcodes" are classifying schemes based on regular expression.
#'
#' A classcode object have columns:
#' \describe{
#' \item{group:}{unique and non empty (NA or "" if character) group name}
#' \item{regex:}{unique regular expression defining class membership}
#' \item{condition (optional):}{a group might have conditions additional to what
#'   is expressed by \code{regex}. If so, these should be specified as quoted
#'   expressions that can be evaluated within the data frame used by
#'   \code{\link{classify}}}
#' \item{weights (optional):}{wieights for each class used for \code{\link{index}}
#' calculation. Could be more than one and could have arbitrary names.}
#' }
#' Note that classes does not have to be disjunct.
#'
#' @param x data.frame with properties as described in the details section
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
    !any(duplicated(x$regex)),
    is.character(x$regex) | is.numeric(x$regex)
  )
  structure(x, class = unique(c("classcodes", class(x))))
}

#' @export
#' @rdname classcodes
is.classcodes <- function(x) inherits(x, "classcodes")
