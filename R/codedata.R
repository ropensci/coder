#' Code data
#'
#' Make structured code data set.
#'
#' @param x data table/frame with columns `id` (character), `code`,
#'   and optional `code_date` (Date).
#' @param id,code column names (from `x`) with case id:s (character) and
#'    codes of interest.
#' @param code_date optional column name (from `x`) with relevant dates
#'  corresponding to each code. If there is a column named `code_date` this will
#'  be used by default.
#' @param period optional date vector of length two with lower and upper limits
#'   for inclusion period
#' @param .setkeys should output be indexed (Beneficial for large data sets.)
#' @param alnum Should codes be cleaned from all non alphanumeric characters?
#' @param ... arguments passed between methods
#'
#' @return
#'   [data.table] with columns: `id` (character), `code` and
#'   optionally `code_date` (Date)
#'   Possible additional columns from `x` are preserved.
#'
#' @export
#' @examples
#'
#' x <-
#'   data.frame(
#'     id               = "1",
#'     code_date        = as.Date("2017-01-01"),
#'     code             = "a",
#'     stringsAsFactors = FALSE
#'   )
#' as.codedata(x)
#'
#' # Ignore codes for dates outside specified limits
#' y <-
#'   data.frame(
#'     id               = "2",
#'     code_date        = as.Date("3017-02-02"),
#'     code             = "b",
#'     stringsAsFactors = FALSE
#'   )
#' z <- rbind(x, y)
#' as.codedata(z, period = c(as.Date("1970-01-01"), Sys.Date()))
#'
#' @family codedata
#' @name as.codedata
as.codedata <- function(x, ...) {
  UseMethod("as.codedata")
}


#' @export
as.codedata.data.frame <- function(x, ...) {
  as.codedata(as.data.table(x), ...)
}

#' @export
#' @rdname as.codedata
as.codedata.data.table <-
  function(
    x, id = "id", code = "code",
    code_date = if (utils::hasName(x, "code_date")) "code_date" else NULL,
    period = NULL, .setkeys = TRUE, alnum = FALSE, ...) {

    setnames(x, c(id, code, code_date),
             c("id", "code", if (!is.null(code_date)) "code_date"))

    code_date <- id <- code <- NULL # Fix for R Check
    hasdates  <- utils::hasName(x, "code_date")
    keys      <- c("id", if (hasdates) "code_date", "code")

    check_codedata(x)

    if (hasdates & !is.null(period))
      x <- x[dates_within(code_date, from = period[1], to = period[2])]
    if (alnum)    x[, code := gsub("[^[:alnum:]]", "", code)]
    if (.setkeys) setkeyv(x, keys)

    unique(x, by = keys)[]
  }


# Help function -----------------------------------------------------------

check_codedata <- function(x) {
  names(x) <- tolower(names(x))
  if (!all(c("id", "code") %in% names(x)))
    stop("data frame must contain columns: 'id' and 'code'")
  if (utils::hasName(x, "code_date") && !is.Date(x[["code_date"]]))
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
