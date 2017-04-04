#' Code data
#'
#' @param x data frame with columns "id", "date" and "code" or
#'   object data in format used by NPR (see below).
#' @param y additional (optional) NPR data set if \code{x} contains data
#'  from NPR data. (see below).
#' @param setkeys should keys be set for the data.table object?
#' To initially set the key for a large data set can be slow
#' but it could be beneficial for later use of the object.
#' @param ... by default, codes for future dates or dates before "1970-01-01"
#' are ignored (with a warning). Specify \code{to, from}
#' (as passed to \code{\link{filter_dates}}) to override.
#'
#' @section Data from NPR:
#'
#' Data from the Swedish Patient Register can be recognised as such if
#' argument \code{x} contains columns named \code{lpnr, indatum} AND
#' \code{hdia, bdia1, ..., bdia15} OR \code{op1, ..., op30}.
#'
#' If so happens, this data is transformed into the ordinary codedata format
#' and returned as such.
#' Also, NPR data often comes in the form of two separate data sets, one for
#' inpatient and one for outpatient care. It is therefore possible to supply
#' an additional data set by argument \code{y}.
#'
#' @return \code{as.codedata} returns a \code{\link{data.table}} object
#'   with mandatory columns: "id" (individual id), "code" and
#'   "date" (when the code was valid).
#'   Possible additional columns from \code{x} are preserved
#'   if data is not recognised as coming from NPR.
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
as.codedata <- function(x, y = NULL, ..., setkeys = TRUE) {

  if (!is.data.table(x)) x <- as.data.table(x)
  if (!is.null(y)) {
    if (!is.data.table(y)) y <- as.data.table(y)
    x <- rbind(x, y, fill = TRUE)
  }
  setnames(x, names(x), tolower(names(x)))

  x <- fix_possible_pardata(x)

  # limit to specified dates if given
  x <- x[dates_within(date, ...)]
  keys <- c("id", "date", "code")
  if (setkeys) setkeyv(x, keys)
  unique(x, by = keys)
}



# transform possible NPR data if reconised as such,
# otherwise return as is
fix_possible_pardata <- function(x) {

  all_names <- function(xnm) all(xnm %in% names(x))

  # Data can contain either diagnose data (ICD) or KVA
  nms      <- c("lpnr", "indatum")
  nms_dia  <- c("hdia", paste0("bdia", 1:15))
  nms_op   <- paste0("op", 1:30)

  if (all_names(c(nms_dia, nms_op))) {
    stop("Data looks like NPR data but contains both ICD and KVA codes!")
  } else if (all_names(c(nms, nms_dia))) {
    message("NPR data with diagnose (ICD) codes.")
    nms_codes <- nms_dia
  } else if (all_names(c(nms, nms_op))) {
    message("NPR data with operation (KVA) codes.")
    nms_codes <- nms_op
  } else {
    return(x)
  }

  # Remove columns not needed by referenece
  rem <- setdiff(names(x), c(nms, nms_codes))
  if (!identical(rem, character(0)))
    x[, rem := NULL]

  # Transform to codedata format
  # silly workaround to avoid CHECK note
  variable <- date <- hdia <- code <- indatum <- NULL
  setnames(x, "lpnr", "id")
  melt(
    x,
    measure.vars  = nms_codes,
    value.name    = "code",
    na.rm         = TRUE
  )[,
    date          := as.Date(indatum, format = "%Y-%m-%d")
  ][,
    indatum       := NULL
  ][
    variable      == "op1"  |
    variable      == "hdia" |
    code          != "",
    hdia          := as.character(variable) == "hdia"
  ][
    code          != ""
  ]
}



check_codedata <- function(x) {
  names(x) <- tolower(names(x))
  if (!all(c("id", "date", "code") %in% names(x)))
    stop("data frame must contain columns: id, date and code")
  if (data.class(x[["date"]]) != "Date")
    stop("Column 'date' is not of format 'Date'!")
}



#' @export
#' @rdname codedata
is.codedata <- function(x) {
  !inherits(tryCatch(check_codedata(x), error = function(e) e), "error")
}

