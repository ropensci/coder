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
#' @param npr Is data from the Swedish patient register?
#'   If so, the format might be recognized automatically (no guarantee).
#' @param nprdate If \code{x} is recognized as a data set from the Swedish
#' National Patient Register, which date variable should be recognized as code
#' date for out patients? Could be either "indatuma" or "utdatuma".
#' (Note that in patients only have one date.)
#' @param alnum Should codes be cleaned from all non alphanumeric characters (boolean)?
#'
#' @section Data from NPR:
#'
#' Data from the Swedish Patient Register can be recognized as such if
#' argument \code{x} contains columns named \code{lpnr, indatuma/utdatuma} AND
#' (\code{hdia, bdia1, ..., bdia15} OR \code{op1, ..., op30}).
#'
#' Note that the name should be \code{indatuma/utdatuma} (with letter "a"
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
#'   with mandatory columns: "id" (individual id coerced to character) and
#'   "code". It has an optional column
#'   "code_date" (when the code was valid) if there was such a column in
#'   \code{x} or if the data is recognized from NPR.
#'   Possible additional columns from \code{x} are preserved
#'   if data is not recognized as coming from NPR.
#'
#' \code{is.codedata} returns \code{TRUE} if these same conditions are met and
#' \code{FALSE} otherwise.
#' (Note that \code{codedata} is not a formal R class of its own!)
#' @export
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
as.codedata <- function(
    x, y = NULL, ..., .setkeys = TRUE, .copy = NA,
    npr = FALSE, nprdate = "utdatuma", alnum = FALSE) {

  code_date <- id <- code <- NULL # Fix for R Check
  if (!npr) check_codedata(x)

  if (!is.data.table(x)) {
    x <- as.data.table(x)
  }

  if (!is.null(y)) {
    # Assume we have NPR-data
    if (!is.data.table(y)) y <- as.data.table(y)
    x <- rbind(x, y, fill = TRUE)
    y <- NULL # don't need it any more. Delete to Save space
  }

  if (npr) {
    x <- fix_possible_pardata(x, nprdate = nprdate, .copy)
  }
  hasdates <- "code_date" %in% names(x)
  if (hasdates) {
    x <- x[dates_within(code_date, ...)]
  }

  # Always save id as character. Even though it might be numeric,
  # it is easier if we always know its type.
  x[, id := as.character(id)]

  # Remove all non alfanumeric characters
  if (alnum) {
    x[, code := gsub("[^[:alnum:]]", "", code)]
  }

  keys <- c("id", if (hasdates) "code_date", "code")
  if (.setkeys) setkeyv(x, keys)
  unique(x, by = keys)[]
}



# transform possible NPR data if recognized as such,
# otherwise return as is
fix_possible_pardata <- function(x, nprdate = "utdatuma", .copy = NA) {

  # silly workaround to avoid CHECK note
  variable <- code_date <- hdia <- code <- indatuma <- utdatuma <- diagnos <-
    op <- id <- NULL

  stopifnot(nprdate %in% c("indatuma", "utdatuma"))
  x <- copybig(x, .copy)

  setnames(x, names(x), tolower(names(x)))
  if ("lopnr" %in% names(x)) setnames(x, "lopnr", "id")
  if ("lpnr"  %in% names(x)) setnames(x, "lpnr", "id")

  # New format of NPR data from NBHW can have all dia codes in one column
  # So far only implemented for dia-codes.
  # Should be considered for OP codes as well.
  if (!any(startsWith(names(x), "bdia")) &&
      !any(startsWith(names(x), "op"))   &&
      "diagnos" %in% names(x)) {
    # Don't know how many columns it will be (how many codes there are)
    spl <- tstrsplit(x$diagnos, " ")
    x[
      , hdia := NULL][
      , c("hdia", paste0("bdia", seq_len(length(spl) - 1))) := spl
    ]
  } else if ("op" %in% names(x) & !"op1" %in% names(x)) {
    spl <- tstrsplit(x$op, " ")
    x[
      , op := NULL][
      , c(paste0("op", seq_along(spl))) := spl
    ]
  }


  if ("hdia" %in% names(x) && "op" %in% names(x)) {
    stop("NPR data contains both ICD and KVA codes!")

    # Check if code columns recognized
  } else {
    if ("hdia" %in% names(x)) {
      code      <- "diagnose (ICD)"
      # Both in- and outpatient data have at least 15 bdia but outpatient can
      # have as many as 21, we identify this by regex.
      nms_codes <- names(x)[grepl("[hb]dia", names(x))]
      blanks    <- "       " # Missing codes
    } else if ("op1" %in% names(x)) {
      code      <- "operation (KVA)"
      nms_codes <- names(x)[startsWith(names(x), "op")]
      blanks    <- "     "   # Missing codes
    }
    # If id and code columns exist, inform and proceed, otherwise break
    if ("id" %in% names(x) && !is.null(code)) {
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
  rem <- setdiff(names(x), c("id", "indatuma", "utdatuma", nms_codes))
  if (!identical(rem, character(0)))
    x[, (rem) := NULL]

  # Cells without codes are populated with empty strings (of different lengths
  # depending on type of code). Change to NA in order to remove automaticaly
  # by melt below
  x[, (nms_codes) :=
    lapply(.SD, function(x) {x[x == blanks] <- NA_character_; x}),
    .SDcols = nms_codes
  ]

  x <-
    melt(
      x,
      measure.vars  = nms_codes,
      value.name    = "code",
      na.rm         = TRUE
    )

  # If utdatuma should be used for inpatients, indatum must still be used for
  # outpatients. Then st
  if (nprdate == "utdatuma") {
    x[is.na(utdatuma), utdatuma := indatuma]
    setnames(x, "utdatuma", "indatuma")
  }
  x[, code_date := as.Date(indatuma, format = "%Y%m%d")]


  if (code == "diagnose (ICD)") {
    x[, list(id, code, code_date, hdia = variable == "hdia")]
  } else {
    x[, list(id, code, code_date)]
  }
}



check_codedata <- function(x) {
  names(x) <- tolower(names(x))
  if (!all(c("id", "code") %in% names(x)))
    stop("data frame must contain columns: id and code")
  if ("code_data" %in% names(x) && !is.Date(x[["code_date"]]))
    stop("Column 'code_date' is not of format 'Date'!")
  if (!is.character(x[["id"]]))
    stop("Column 'id' must be character!")
}



#' @export
#' @rdname as.codedata
is.codedata <- function(x) {
  !inherits(tryCatch(check_codedata(x), error = function(e) e), "error")
}
