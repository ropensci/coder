#' Code data
#'
#' @param x data frame with columns "id", "date" and "code" or
#'   object of class \code{\link{pardata}}.
#' @param setkeys should keys be set for the data.table object?
#' To initially set the key for a large data set can be slow
#' but it could be beneficial for later use of the object.
#' @param ... by default, codes for future dates or dates before "1970-01-01"
#' are ignored (with a warning). Specify \code{to, from}
#' (as passed to \code{\link{filter_dates}}) to override.
#'
#' @return \code{as.codedata} returns a \code{\link{data.table}} object
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


# Internal help function. No need to export or document
#' @import data.table
#' @export
as.codedata.data.frame <- function(x, ...) {
  check_codedata(x) # too fail early
  as.codedata(as.data.table(x), ...)
}


#' @rdname codedata
#' @export
#' @import data.table
as.codedata.data.table <- function(x, ..., setkeys = FALSE) {

  names(x) <- tolower(names(x))
  check_codedata(x)

  # limit to specified dates if given
  x <- x[dates_within(date, ...)]
  keys <- c("id", "date", "code")
  if (setkeys) setkeyv(x, keys)
  unique(x, by = keys)
}


#' @export
#' @rdname codedata
is.codedata <- function(x) {
  !inherits(tryCatch(check_codedata(x), error = function(e) e), "error")
}

check_codedata <- function(x) {
  names(x) <- tolower(names(x))
  if (!all(c("id", "date", "code") %in% names(x)))
    stop("data frame must contain columns: id, date and code")
  if (data.class(x[["date"]]) != "Date")
    stop("Column 'date' is not of format 'Date'!")
}