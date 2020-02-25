#' Use data from the Swedish National Patient Register as codedata
#'
#' Data from the Swedish National Patient Register (NPR) can be recognized as such if
#' \code{x} contains columns named \code{lpnr, indatuma/utdatuma} AND
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
#' @inheritParams copybig
#' @param x,y data frames with columns specified below.
#' @param nprdate Name (as character) of date column to be recognized as code
#' date for out-patients: "indatuma" or "utdatuma".
#' @param ... arguments passed to \code{\link{as.codedata}}
#'
#' @return Output from \code{\link{as.codedata}}
#' @export
npr2codedata <- function(x, y = NULL, nprdate = "utdatuma", .copy = NA, ...) {

  # Help function
  ascodedata <- function(x, ...) {
    x[, hdia := variable == "hdia"]
    as.codedata(x[, list(id, code, code_date, hdia)], ...)
  }

  # silly workaround to avoid CHECK note
  variable <- code_date <- hdia <- code <- indatuma <- utdatuma <- diagnos <-
    op <- id <- NULL

  if (!is.data.table(x)) {
    x <- as.data.table(x)
  }

  stopifnot(nprdate %in% c("indatuma", "utdatuma"))
  x <- copybig(x, .copy)

  if (!is.null(y)) {
    if (!is.data.table(y)) y <- as.data.table(y)
    x <- rbind(x, y, fill = TRUE)
    y <- NULL # don't need it any more. Delete to Save space
  }

  setnames(x, names(x), tolower(names(x)))
  if ("lopnr" %in% names(x)) setnames(x, "lopnr", "id")
  if ("lpnr"  %in% names(x)) setnames(x, "lpnr", "id")
  x[, id := as.character(id)]

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
      return(ascodedata(x, ...))
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
  # depending on type of code). Change to NA in order to remove automatically
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

  ascodedata(x, ...)
}
