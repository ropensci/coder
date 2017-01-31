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

  stopifnot(
    all(c("lpnr", "indatum", "hdia", paste0("bdia", 1:15)) %in% names(x))
  )

  class(x) <- c("pardata", unique(class(x)))
  x
}


#' @rdname pardata
#' @export
is.pardata <- function(x) inherits(x, "pardata")
