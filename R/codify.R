#' Codify elements (within period)
#'
#' Enhance case data with code data, possibly limited to relevant period.
#'
#' @inheritParams copybig
#' @inheritDotParams as.codedata alnum
#' @param data \code{\link{data.frame}} with at least case id, and optional
#'   date of interest
#' @param codedata output from \code{\link{as.codedata}}.
#' @param id,date column names (from \code{data}) with case id (character)
#'   and date of interest (optional).
#' @param days numeric vector of length two with lower and upper bound for range
#'   of relevant days relative to \code{date}. See "Relevant period".
#'
#' @return
#'   \code{data} (coerced to \code{data.table}) with additional columns:
#'   \code{code, code_date}: left joined from \code{codedata} or \code{NA}
#'   if no match within period. \code{in_period}: Boolean indicator if the case
#'   had at least one code within the specified period.
#'
#'   The output has one row for each combination of "id" from \code{data} and
#'   "code" from \code{codedata}. Rows from \code{data} might be repeated
#'    accordingly.
#'
#' @section Relevant period:
#'   Some examples for argument \code{days}:
#'   \itemize{
#'     \item \code{c(-365, -1)}: window of one year prior to the \code{date}
#'       column of \code{data}.            Useful for patient co-morbidity.
#'     \item \code{c(1, 30)}: window of 30 days after \code{date}.
#'       Useful for adverse events after a surgical procedure.
#'    \item \code{c(-Inf, Inf)}: no limitation on non missing dates.
#'    \item \code{NULL}: no time limitation at all.
#'   }
#'
#' @export
#'
#' @examples
#' codify(ex_people, ex_icd10, id = "name", date = "event", days = c(-365, 0))
#' @family verbs
codify <- function(
  data, codedata, id = "id", date = NULL, days = NULL, .copy = NA, ...) {

  if (!id %in% names(data))      stop("No id column '", id, "' in data!")
  if (!is.character(data[[id]])) stop("Id column must be of type character!")

  # Determine if coding should be limited by time period
  usedate <- !is.null(days)
  idcols  <- c(id, if (usedate) "date")
  if (usedate && is.null(date)) {
    stop("Argument 'date' must be specified if 'days' is not NULL!")
  } else if (usedate && !is.Date(data[[date]])) {
    stop("Date column '", date, "' is not of class 'Date'!")
  } else if (!usedate && !is.null(date)) {
    warning("Date column ignored since days = NULL!")
  }

  if (!is.data.table(data)) data <- data.table(data)
  x2 <- copybig(data, .copy) # New name to avoid copy complications
  if (usedate) setnames(x2, date, "date")
  if (!is.codedata(codedata))
    codedata <- as.codedata(codedata, .copy = .copy, ...)

  in_period <- code_date <- NULL # Silly work around to avoid check notes
  x2_id_date <- x2[, idcols, with = FALSE] # To avoid unique on all data

  out <-
    merge(x2_id_date, codedata, by.x = id,
          by.y = "id", all.x = TRUE, allow.cartesian = TRUE)[,
      in_period :=
        if (!usedate) TRUE
        else between(
          as.numeric(code_date),
          as.numeric(date) + min(days),
          as.numeric(date) + max(days)
        )
    ][
      (!in_period), `:=`(code = NA, code_date = NA)][,
      # If codes within period: keep them all. If not: Keep the first as marker.
      if (any(in_period, na.rm = TRUE)) .SD[in_period] else .SD[1],
      by = idcols
    ]
  out <- merge(unique(out), x2, by = idcols) # to get back all data
  if (usedate) setnames(x2, "date", date)
  structure(out, id = id)
}
