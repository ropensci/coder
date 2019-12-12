#' Summary data for all default classcodes object in the package
#'
#' @return Data frame with columns describing all default classcodes
#'   objects from the package.
#' @export
#' @family classcodes
#'
#' @examples
#' all_classcodes()
all_classcodes <- function() {

  # Get all classcodes object from the package
  names  <- utils::data(package = "coder")$results[, "Item"]
  cl     <- lapply(names, function(x) try(get_classcodes(x), TRUE))
  is.cl  <- vapply(cl, is.classcodes, NA)
  names  <- names[is.cl]
  cl     <- cl[is.cl]


  # If the coding used for the classcodes object is not included in the package,
  # no codes would be recognized. This should be NA however, not 0.
  no_codes <- function(x) {
    s <- summary(x)$summary
    if (!is.null(s)) sum(s$n) else NA
  }

  clps <- function(x) paste(x, collapse = ", ")

  # Remove prefix "regex" to only present alternatives
  rgs_short <- function(x) {
    rgs <- gsub("regex_?", "", attr(x, "regexprs"))
    rgs[rgs != ""]
  }

  data.frame(
    clascodes   = names,
    coding      = vapply(cl, attr, "", "coding"),
    alt_regex   = vapply(lapply(cl, rgs_short), clps, ""),
    indices     = vapply(lapply(cl, attr, "indices"), clps, ""),
    N           = vapply(cl, nrow, NA_integer_),
    n           = vapply(cl, no_codes, NA_integer_),
    stringsAsFactors = FALSE
  )
}
