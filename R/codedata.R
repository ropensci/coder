#' Code data
#'
#' @param x data frame with columns "id", "date" and "code" or
#'   object of class \code{\link{pardata}}.
#' @param ... possible additional objects to merge with \code{x}
#'
#' @return \code{as.codedata} returns a data frame
#'   with mandatory columns:
#' \describe{
#' \item{id}{individual id}
#' \item{date}{date when code were valid}
#' \item{code}{code}
#' }
#' Additional columns might exist (preserved from \code{x})
#'
#' \code{is.codedata} returns \code{TRUE} if these same conditions are met and
#' \code{FALSE} otherwise.
#' (Note that \code{codedata} is not a formal class of its own!)
#' @export
#' @name codedata
#'
as.codedata <- function(x, ...) UseMethod("as.codedata", x)

#' @export
#' @rdname codedata
is.codedata <- function(x) {
  is.data.frame(x) &&
    all(c("id", "date", "code") %in% names(x)) &&
    data.class(x[["date"]]) == "Date"
}

#' @export
as.codedata.default <- function(x, ...)
  stop("'x' must be either a data frame or a 'pardata' object!")

#' @export
as.codedata.data.frame <- function(x, ...) {
  names(x) <- tolower(names(x))
  if (!all(c("id", "date", "code") %in% names(x)))
    stop("data frame must contain columns: id, date and code")
  if (data.class(x$date) != "Date")
    stop("Column 'date' is not of format 'Date'!")

  x <- ifep("dplyr", dplyr::distinct_(x, .keep_all = TRUE), unique(x))

  x$id   <- as.factor(x$id)
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
      data.frame(
        stats::reshape(
          x,
          times          = dia_names,
          varying        = dia_names,
          idvar          = "lpnr",
          direction      = "long",
          timevar        = "dia",
          v.names        = "code"
        ),
        stringsAsFactors = FALSE,
        row.names        = NULL
      )
    )

  x$hdia <- startsWith(x$dia, "hdia")
  names(x)[names(x) == "lpnr"]    <- "id"
  names(x)[names(x) == "indatum"] <- "date"
  NextMethod()
}
