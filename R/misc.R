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


#' Decide if large objects should be copied
#'
#' @param x object (potentially of large size)
#' @param .copy Should the object be copied internally by \code{\link{copy}}?
#' \code{NA} (by default) means that objects smaller than 1 Gb are copied.
#' If the size is larger, the argument must be set explicitly. Set \code{TRUE}
#' to make copies regardless of object size. This is recomended if enough RAM
#' is available. If set to \code{FALSE}, calculations might be carried out
#' but the object will be changed by reference.
#'
#' @return Either \code{x} unchanged, or a fresh copy of \code{x}.
copybig <- function(x, .copy = NA) {
  # Copy x if < 1 Gb
  # Require explicit specification for large objects
  big_x <- utils::object.size(x) > 2 ^ 30
  if (isTRUE(.copy) || (is.na(.copy) && !big_x)) {
    x <- data.table::copy(x)
    setnames(x, names(x), copy(names(x)))
  } else if (is.na(.copy) && big_x) {
    stop("Object is > 1 Gb. Set argument 'copy' to TRUE' or FALSE ",
         "to declare wether it should be copied or changed by reference!")
  }
  x
}
