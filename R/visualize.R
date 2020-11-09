#' Visualize classification scheme in web browser
#'
#' Classes are visualized by their regular expressions in a web browser.
#' The visualization does not give any details on group names, conditions or
#' weights but might be useful both for understanding of a classification scheme
#' in use, and during the creation and debugging of such.
#'
#' @param x [classcodes] object or name of such object included in the package
#' (see [all_classcodes()]).
#' @inheritParams set_classcodes
#' @param group names (as character vector) of groups to visualize
#' (all groups if `NULL`)
#' @param show should a visualization be shown in a web browser.
#' Set to `FALSE` to just retrieve a URL for later use.
#' @inheritDotParams set_classcodes regex
#' @return URL to website with visualization (invisible)
#' @export
#' @example man/examples/visualize.R
#' @family classcodes
visualize.classcodes <- function(x, group = NULL, show = TRUE, ...) {
  x <- set_classcodes(x, ...)
  if (!is.null(group))
    x <- x[x$group %in% group, ]
  r <- paste0(x[[attr(x, "regexpr")]], collapse = "|")
  r <- utils::URLencode(r)
  u <- paste0("https://jex.im/regulex/#!embed=true&flags=&re=", r)
  if (show) utils::browseURL(u)
  invisible(u)
}

#' @export
visualize.character <- function(x, group = NULL, show = TRUE, ...) {
  visualize(set_classcodes(x, ...), group = group, show = show)
}