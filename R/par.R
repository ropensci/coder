#' Data from the Swedish Patient Register (PAR).
#'
#' Functions to check that a data set contains patient data from
#' the Swedish Patient Register (PAR).
#'
#' @param x data.frame with par-data
#'
#' @return \code{as.pardata} returns an object of class "pardata".
#' \code{is.pardata} returns \code{TRUE} if object is of class "pardata",
#' \code{FALSE} otherwise.
#' @export
#' @name pardata
as.pardata <- function(x) {

  x <- as.data.frame(x)
  names(x) <- tolower(names(x))

  varnames <- c(
    "lpnr", "indatum", "hdia", "bdia1", "bdia2", "bdia3", "bdia4",
    "bdia5", "bdia6", "bdia7", "bdia8", "bdia9", "bdia10", "bdia11",
    "bdia12", "bdia13", "bdia14", "bdia15")
  stopifnot(varnames %in% names(x))

  class(x) <- c("pardata", unique(class(x)))
  x
}


#' @rdname pardata
#' @export
is.pardata <- function(x) inherits(x, "pardata")
