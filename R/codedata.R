#' Code data
#'
#' @param x object
#' @param ... possible additional objects to merge with \code{x}
#'
#' @return \code{as.codedata} returns an object of class \code{tbl_df}
#'   with mandatory columns:
#' \describe{
#' \item{id}{individual id}
#' \item{date}{date when code were valid}
#' \item{code}{code}
#' }
#' Additional columns might exist (preserved from \code{x})
#'
#' \code{is.codedata} reuturns \code{TRUE} if these same conditions are met,
#' \code{FALSE} otherwise.
#' (Note that \code{codedata} is not a formal class of its own!)
#' @export
#' @name codedata
#'
as.codedata <- function(x, ...) UseMethod("as.codedata", x)

#' @export
#' @rdname codedata
is.codedata <- function(x) {
  is.data.frame(x) && all(c("id", "date", "code") %in% names(x))
}

#' @export
as.codedata.default <- function(x, ...)
  as.codedata(as.data.frame(x))

#' @export
as.codedata.data.frame <- function(x, ...) {
  names(x) <- tolower(names(x))
  stopifnot(c("id", "date", "code") %in% names(x))

  x <- ifep("dplyr", dplyr::distinct_(x, .keep_all = TRUE), unique(x))

  x$id   <- as.factor(x$id)
  x$date <- as.Date(x$date)
  x$code <- as.factor(x$code)
  x
}


#' @export
as.codedata.pardata <- function(x, ...) {

  x <- ifep("dplyr", dplyr::bind_rows(x, ...), rbind.fill(x, ...))
  dia_names <- names(x)[grepl("dia", names(x))]

  x <-
    ifep("tidyr",
      tidyr::gather_(x, "dia", "code", dia_names, na.rm = TRUE),
      stats::reshape(x, times = dia_names, varying = dia_names,
        idvar = "lpnr", direction = "long", timevar = "dia", v.names = "code"))

  x$hdia <- startsWith(x$dia, "hdia")
  names(x)[names(x) == "lpnr"]    <- "id"
  names(x)[names(x) == "indatum"] <- "date"
  NextMethod()
}
