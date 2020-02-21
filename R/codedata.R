#' Code data
#'
#' @param x data frame with columns "id" (character), "code",
#'   and optional "code_date" (Date).
#' @param .setkeys should keys be set for the \code{\link{data.table}} object?
#'   (Beneficial for large data sets.)
#' @param ... by default, codes for future dates or dates before "1970-01-01"
#'   are ignored (with a warning). Set \code{to, from}
#'   (passed to \code{\link{filter_dates}}) to override.
#' @param alnum Should codes be cleaned from all non alphanumeric characters?
#'
#' @return
#'   \code{\link{data.table}} with columns: "id" (character), "code" and
#'   optionally "code_date" (Date)
#'   Possible additional columns from \code{x} are preserved.
#'
#' @export
#' @seealso npr2codedata
#'
#' @examples
#'
#' x <- data.frame(
#'   id = 1,
#'   code_date = as.Date("2017-02-02"),
#'   code = "a"
#' )
#' as.codedata(x)
#'
#' # Drop dates outside specified limits
#' y <- data.frame(id = 2, code_date = as.Date("3017-02-02"), code = "b")
#' z <- rbind(x, y)
#' as.codedata(z)
#'
#' @family codedata
as.codedata <- function(x, ..., .setkeys = TRUE, alnum = FALSE) {

  code_date <- id <- code <- NULL # Fix for R Check
  hasdates  <- "code_date" %in% names(x)
  keys      <- c("id", if (hasdates) "code_date", "code")

  check_codedata(x)

  if (!is.data.table(x)) x <- as.data.table(x)
  if (hasdates)          x <- x[dates_within(code_date, ...)]
  if (alnum)             x[, code := gsub("[^[:alnum:]]", "", code)]
  if (.setkeys)          setkeyv(x, keys)

  unique(x, by = keys)[]
}


# Help function -----------------------------------------------------------

check_codedata <- function(x) {
  names(x) <- tolower(names(x))
  if (!all(c("id", "code") %in% names(x)))
    stop("data frame must contain columns: id and code")
  if ("code_data" %in% names(x) && !is.Date(x[["code_date"]]))
    stop("Column 'code_date' is not of format 'Date'!")
  if (!is.character(x[["id"]]))
    stop("Column 'id' must be character!")
}


# is.codedata -------------------------------------------------------------

#' @export
#' @rdname as.codedata
is.codedata <- function(x) {
  !inherits(tryCatch(check_codedata(x), error = function(e) e), "error")
}
