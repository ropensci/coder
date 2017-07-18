#' Get classcodes object
#'
#' @param x classcodes specification as either a name or a classcodes object,
#' or a classcodes object itself.
#' @param from object that classcodes could be inherited from
#'
#' @return \code{\link{classcodes}} object or \code{NULL} if no object found.
get_classcodes <- function(x, from = NULL) {

  # Possible inherited classcodes
  inh <- attr(from, "classcodes")

  if      (is.classcodes(x)) {
    x
  } else if (is.character(x) && exists(x, envir = .GlobalEnv)) {
    get(x)
  } else if (is.character(x) &&
           x %in% utils::data(package = "classifyr")$results[, "Item"]) {
    utils::data(list = x, package = "classifyr", envir = environment())
    return(get(x, envir = environment()))
  } else if (is.null(x) && is.classcodes(inh)) {
    inh
  } else if (is.null(x) &&
           inh %in% utils::data(package = "classifyr")$results[, "Item"]) {
    utils::data(list = inh, package = "classifyr", envir = environment())
    return(get(inh, envir = environment()))
  } else {
    stop("No classcodes object found!")
  }
}


#' @import data.table
NULL

