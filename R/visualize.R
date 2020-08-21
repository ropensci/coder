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
#'
#' @examples
#' \dontrun{
#'
#'  # How is depression classified according to Elixhauser?
#'  visualize("elixhauser", "depression")
#'
#'  # Compare the two diabetes groups according to Charlson
#'  visualize("charlson",
#'    c("diabetes without complication", "diabetes complication"))
#'
#'  # Is this different from the "Royal College of Surgeons classification?
#'  # Yes, there is only one group for diabetes
#'  visualize("charlson",
#'    c("diabetes without complication", "diabetes complication"),
#'    regex = "rcs"
#'  )
#'
#'  # Show all groups from Charlson
#'  visualize("charlson")
#'
#' }
#'
#'  # Get URL for later visualization
#'  visualize("hip_ae", show = FALSE)
#' @family classcodes
#' @importFrom generics visualize
visualize.classcodes <- function(x, group = NULL, show = TRUE, ...) {
  if (!is.null(group))
    x <- x[x$group %in% group, ]
  r <- paste0(x$regex, collapse = "|")
  r <- utils::URLencode(r)
  u <- paste0("https://jex.im/regulex/#!embed=true&flags=&re=", r)
  if (show) utils::browseURL(u)
  invisible(u)
}

#' @export
visualize.character <- function(x, group = NULL, show = NULL, ...) {
  x <- set_classcodes(x, ...)
  visualize(x, ...)
}