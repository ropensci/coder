#' Code data
#'
#' @param x data frame with columns "id", "date" and "code" or
#'   object of class \code{\link{pardata}}.
#' @param y optional additional \code{\link{pardata}} object to combine with
#' the first. Useful for combining data from in- and outpatient healt care.
#' @param ... by default, codes for future dates or dates before "1970-01-01"
#' are ignored (with a warning). Specify \code{limits}
#' (as passed to \code{\link{filter_dates}}) to override.
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
#' @examples
#'
#' x <- data.frame(id = 1, date = as.Date("2017-02-02"), code = "a")
#' as.codedata(x)
#'
#' # Drop dates outside specified limits
#' y <- data.frame(id = 2, date = as.Date("3017-02-02"), code = "b")
#' z <- rbind(x, y)
#' as.codedata(z)
#'
as.codedata <- function(x, ...) UseMethod("as.codedata", x)

#' @export
#' @rdname codedata
is.codedata <- function(x) {
  is.data.frame(x) &&
    all(c("id", "date", "code") %in% names(x)) &&
    data.class(x[["date"]]) == "Date"
}


#' @rdname codedata
#' @export
#' @import data.table
as.codedata.data.frame <- function(x, ...) {

    names(x) <- tolower(names(x))
  if (!all(c("id", "date", "code") %in% names(x)))
    stop("data frame must contain columns: id, date and code")
  if (data.class(x$date) != "Date")
    stop("Column 'date' is not of format 'Date'!")

  x <- filter_dates(x, ...)

  x <- as.data.table(x)
  setkeyv(x, c("id", "date", "code"))
  unique(x, by = key(x))
}

#' @rdname codedata
#' @export
as.codedata.pardata <- function(x, y = NULL, ...) {

  if (!is.null(y)) {
    x <- ifep("dplyr", dplyr::bind_rows(x, y), rbind.fill(x, y))
  }
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
