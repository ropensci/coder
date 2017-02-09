#' Data from the Swedish Patient Register (PAR).
#'
#' Functions to check that a data set contains patient data from
#' the Swedish Patient Register (PAR).
#'
#' @param x,y objects to coerce to \code{\link{data.table}} with par-data
#' (typically in- and outpatient data sets)
#'
#' @return \code{as.pardata} returns an object of class "pardata".
#' \code{is.pardata} returns \code{TRUE} if object is of class "pardata",
#' \code{FALSE} otherwise.
#' @export
#' @name pardata
as.pardata <- function(x, y = NULL) {

  f <- function(x) {
    nms <- c("lpnr", "indatum", "hdia", paste0("bdia", 1:15))
    names(x) <- tolower(names(x))
    if (!all(nms %in% names(x)))
      stop("NPR data must have column with names: ", paste0(nms, collapse = ", "))
    x <- as.data.table(x[, nms])
  }

  x <- if (is.null(y)) f(x) else rbind(f(x), f(y))
  structure(x, class = unique(c("pardata", class(x))))
}


#' @rdname pardata
#' @export
is.pardata <- function(x) inherits(x, "pardata")
