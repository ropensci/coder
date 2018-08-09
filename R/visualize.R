
#' Visualise classification scheme in web browser
#'
#' Classes are visualised by their regular expressions in a web browser.
#' The visualisation does not give any details on group names, conditions or
#' weights but might be useful both for understanding of a clasification scheme
#' in use, and during the creation and debugging of such.
#'
#' @inheritParams get_classcodes
#' @param group names (as character vector) of groups to visualise
#' (all groups if \code{NULL})
#' @param show should a visualisation be shown in a web browser.
#' Set to \code{FALSE} to just retrieve a URL for later use.
#'
#' @return URL to website with visualisation (invisible)
#' @export
#'
#' @examples
#' \dontrun{
#'
#'  # How is depression classified according to Elixhauser?
#'  visualize("elix_icd10", "depression")
#'
#'  # Compare the two diabetes groups according to Charlson
#'  visualize("charlson_icd10",
#'    c("diabetes without complication", "diabetes complication"))
#'
#'  # Show all groups from Charlson
#'  visualize("charlson_icd10")
#'
#'  # Get URL for later visualisation
#'  (visualize("tha_fracture_ae_icd10", show = FALSE))
#'
#' }
#' @family classcodes
visualize <- function(x, group = NULL, show = TRUE) {
  x <- get_classcodes(x)

  if (!is.null(group))
    x <- x[x$group %in% group, ]
  r <- paste0(x$regex, collapse = "|")
  r <- utils::URLencode(r)
  u <- paste0("https://jex.im/regulex/#!embed=true&flags=&re=", r)
  if (show) utils::browseURL(u)
  invisible(u)
}


#' @rdname visualize
#' @export
visualise <- visualize


