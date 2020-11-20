#' Summary data for all default classcodes object in the package
#'
#' Tabulate object names and list all related versions of implemented regular
#' expressions
#' and index weights.
#'
#' @return [tibble::tibble] with columns describing all default classcodes
#'   objects from the package.
#' @export
#' @family classcodes
#'
#' @examples
#' all_classcodes()
all_classcodes <- function() {

  # Get all classcodes object from the package
  names  <- utils::data(package = "coder")$results[, "Item"]
  loadNamespace("coder")
  cl     <- lapply(names, function(cc)
    try(getExportedValue("coder", cc), TRUE))
  is.cl  <- vapply(cl, is.classcodes, NA)
  names  <- names[is.cl]
  cl     <- cl[is.cl]

  clps <- function(x) paste(x, collapse = ", ")

  # Remove prefix "regex" to only present alternatives
  rgs_short <- function(x) {
    rgs <- attr(x, "regexprs")
    rgs[rgs != ""]
  }

  tibble::tibble(
    classcodes = names,
    regex      = vapply(lapply(cl, rgs_short), clps, ""),
    indices    = vapply(lapply(cl, attr, "indices"), clps, "")
  )
}
