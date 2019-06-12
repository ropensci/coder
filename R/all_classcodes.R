#' Summary data for all default classcodes object in the package
#'
#' @return Data frame with columns describing the classification schemes.
#' @export
#' @family classcodes
#'
#' @examples
#' all_classcodes()
all_classcodes <- function() {

  # Get all classcodes object from the package
  names  <- utils::data(package = "coder")$results[, "Item"]
  cl <- lapply(names, get_classcodes)
  is.cl <- vapply(cl, is.classcodes, NA)
  names  <- names[is.cl]
  cl <- cl[is.cl]


  # If the coding used for the classcodes object is not included in the package,
  # no codes would be recognized. This should be NA however, not 0.
  no_codes <- function(x) {
    s <- summary(x)$summary
    if (!is.null(s)) sum(s$n) else NA
  }

  data.frame(
    clascodes   = names,
    description = vapply(cl, function(.) attr(., "description"), ""),
    coding      = vapply(cl, function(.) attr(., "coding"), ""),
    indices     = vapply(
                    lapply(cl, function(.) attr(., "indices")),
                    paste, "", collapse  = ", "
                  ),
    N           = vapply(cl, function(.) nrow(.), NA_integer_),
    n           = vapply(cl, no_codes, NA_integer_),
    stringsAsFactors = FALSE
  )
}
