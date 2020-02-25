#' codify elements
#'
#' @inheritParams copybig
#' @param data data.frame with at least two columns, one with case (patient)
#'   identification (column name specified by argument \code{id}) and one with a
#'   date of interest (column name specified by argument \code{date})
#' @param codedata object with code data for which \code{\link{is.codedata}} is
#'   \code{TRUE}
#' @param id name ( of column in \code{x} with case id (character).
#' @param date name of column in \code{x} with possible date of interest
#'   (\code{NULL} by default; must be specified if \code{days != NULL}).
#' @param days numeric vector of length two with lower and upper bound of range
#'   of days relative to \code{date} for which codes from \code{from} are
#'   relevant. (For example \code{c(-365, -1)} implies a time window of one year
#'   prior to \code{date}, which might be useful for calculating comorbidity
#'   indices, while \code{c(1, 30)} gives a window of 30 days after \code{date},
#'   which might be used for calculating adverse events after a surgical
#'   procedure.) \code{c(-Inf, Inf)} means no limitation on non missing dates.
#'   \code{NULL} means no time limitation at all.
#' @inheritDotParams as.codedata alnum
#'
#' @return Data frame (\code{data.table}) with columns corresponding to \code{x}
#'   and additional columns matched from \code{from}: \itemize{ \item
#'   \code{code}: code as matched from \code{from} (\code{NA} if no match
#'   within period) \item \code{code_date}: corresponding date for which the
#'   code was valid (\code{NA} if no match within period) \item
#'   \code{in_period}: Boolean indicator if the unit (patient) had at least one
#'   code within the specified period } The output has at one row for each
#'   combination of "id" and code. Note that other columns of \code{x} might be
#'   repeated accordingly.
#'
#' @export
#'
#' @examples
#' codify(ex_people, ex_icd10, id = "name", date = "surgery", days = c(-365, 0))
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
  if (!is.codedata(codedata)) codedata <- as.codedata(codedata, .copy = .copy, ...)

  in_period <- code_date <- NULL # Silly work around to avoid check notes
  x2_id_date <- x2[, idcols, with = FALSE] # To avoid unique on all data

  out <-
    merge(x2_id_date, codedata, by.x = id, by.y = "id", all.x = TRUE, allow.cartesian = TRUE)[,
      in_period :=
        if (!usedate) TRUE
        else between(
          as.numeric(code_date), as.numeric(date) + min(days), as.numeric(date) + max(days))
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
