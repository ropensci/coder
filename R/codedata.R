#' Code data
#'
#' @inheritParams copybig
#' @param x data frame with columns "id", "code_date" and "code" or
#'   object in format used by NPR (see below).
#' @param y additional (optional) NPR data set if \code{x} contains data
#'  from NPR data. (see below).
#' @param .setkeys should keys be set for the data.table object?
#' To initially set the key for a large data set can be slow
#' but it could be beneficial for later use of the object.
#' @param ... by default, codes for future dates or dates before "1970-01-01"
#' are ignored (with a warning). Specify \code{to, from}
#' (as passed to \code{\link{filter_dates}}) to override.
#'
#' @section Data from NPR:
#'
#' Data from the Swedish Patient Register can be recognised as such if
#' argument \code{x} contains columns named \code{lpnr, indatuma/utdatuma} AND
#' (\code{hdia, bdia1, ..., bdia15} OR \code{op1, ..., op30}).
#'
#' Note that the name should be \code{indatuma/utdatuma} (with letter s
#' suffixed). This is to distinguish the character date format \code{\%Y\%m\%d}
#' from the SPSS date format sometimes stored in \code{indatum/utdatum}.
#' If the SPSS date is the only one available, the help function
#' \code{\link{spss2date}} can be used for transformation, but this must be done
#' before using \code{as.codedata}.
#'
#' If the data set is of this format, it is transformed to the codedata format
#' and returned as such.
#' Also, NPR data often comes in the form of two separate data sets, one for
#' inpatient and one for outpatient care. It is therefore possible to supply
#' an additional data set by argument \code{y}. It is assumed that data from
#' outpatient care has relevant dates stored as \code{utdatuma} and in-patient
#' data has relevant dates named \code{utdatuma}. This is however not tested
#' formally. If \code{utdatuma} is missing from the out-patient data,
#' \code{indatuma} is used without warning.
#'
#' @return \code{as.codedata} returns a \code{\link{data.table}} object
#'   with mandatory columns: "id" (individual id coerced to character),
#'   "code" and
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
as.codedata <- function(x, y = NULL, ..., .setkeys = TRUE, .copy = NA) {
  code_date <- NULL # Fix for R Check

  if (!is.data.table(x)) {
    x <- as.data.table(x)
  }

  if (!is.null(y)) {
    # Assume we have NPR-data
    if (!is.data.table(y)) y <- as.data.table(y)
    x <- rbind(x, y, fill = TRUE)
    y <- NULL # don't need it any more. Delete to Save space
  }

  x <- fix_possible_pardata(x, .copy)
  x <- x[dates_within(code_date, ...)]


  # Always save id as character. Even though it might be numeric,
  # it is easier if we always know its type.
  if (!is.character(x$id)) {
    x$id <- as.character(x$id)
  }

  keys <- c("id", "code_date", "code")
  if (.setkeys) setkeyv(x, keys)
  unique(x, by = keys)
}



# transform possible NPR data if reconised as such,
# otherwise return as is
fix_possible_pardata <- function(x, .copy = NA) {
  x <- copybig(x, .copy)

  names(x) <- tolower(names(x))
  all_names <- function(xnm) all(xnm %in% names(x))

  # Data can contain either diagnose data (ICD) or KVA
  nms_dia  <- c("hdia", paste0("bdia", 1:21))
  nms_op   <- paste0("op", 1:30)

  if (all_names(c(nms_dia, nms_op))) {
    stop("NPR data contains both ICD and KVA codes!")

    # Check if code columns recognized
  } else {
    if (all_names(nms_dia)) {
      code      <- "diagnose (ICD)"
      nms_codes <- nms_dia
    } else if (all_names(nms_op)) {
      code      <- "operation (KVA)"
      nms_codes <- nms_op
    }
    # If lpnr and code columns exist, inform and proceed, otherwise break
    if ("lpnr" %in% names(x) && exists("code")) {
      message("Data recognized as NPR data with ", code, " codes.")
    } else {
      return(x)
    }
  }

  # Simplified coalesce function from dplyr
  coalesce <- function(x, y) {
    x[is.na(x)] <- y[is.na(x)]
    x
  }

  # Remove columns not needed by referenece
  rem <- setdiff(names(x), c("lpnr", "indatuma", "utdatuma", nms_codes))
  if (!identical(rem, character(0)))
    x[, (rem) := NULL]

  # Transform to codedata format
  # silly workaround to avoid CHECK note
  variable <- code_date <- hdia <- code <- indatuma <- utdatuma <- NULL
  setnames(x, "lpnr", "id")

  # Will get warning if utdatum does not exist, but we don't need to see it
  suppressWarnings(
    melt(
      x,
      measure.vars  = nms_codes,
      value.name    = "code",
      na.rm         = TRUE
    )[
      code != "       " # Fixed character length, even if empty
    ][,
      # For out-patient data, use 'indatuma' (since it is the only one that exist),
      # for in-patient-data use 'utdatuma' (since it is more relevant)
      # Use versions with suffix a since these are in better format
      `:=`(
        code_date =
          as.Date(
            if (is.null(utdatuma)) indatuma else coalesce(utdatuma, indatuma),
            format = "%Y%m%d"
          ),
        hdia = variable == "hdia"
      )
    ][,
      c("indatuma", "utdatuma") := NULL
    ]
  )
}



check_codedata <- function(x) {
  names(x) <- tolower(names(x))
  if (!all(c("id", "code_date", "code") %in% names(x)))
    stop("data frame must contain columns: id, code_date and code")
  if (data.class(x[["code_date"]]) != "Date")
    stop("Column 'code_date' is not of format 'Date'!")
  if (!is.character(x[["id"]]))
    stop("Column 'id' must be character!")
}



#' @export
#' @rdname codedata
is.codedata <- function(x) {
  !inherits(tryCatch(check_codedata(x), error = function(e) e), "error")
}

