#' codify elements
#' @inheritParams copybig
#' @param x data.frame with at least two columns, one with case (patient)
#'   identification (column name specified by argument \code{id}) and one with a
#'   date of interest (column name specified by argument \code{date})
#' @param from object with code data for which \code{\link{is.codedata}} is
#'   \code{TRUE}
#' @param id name of column in \code{x} containing case (patient) identification
#' @param date name of column in \code{x} with possible date of interest
#'   (\code{NULL} by default but must be specified if argument 'days' is
#'   used).
#' @param days numeric vector of length two with lower and upper bound of range
#'   of days relative to \code{date} for which codes from \code{from} are
#'   relevant. (For example \code{c(-365, -1)} implies a time window of one year
#'   prior to \code{date}, which might be useful for calculating comorbidity
#'   indices, while \code{c(1, 30)} gives a window of 30 days after \code{date},
#'   which might be used for calculating adverse events after a surgical
#'   procedure.) \code{c(-Inf, Inf)} means no limitation on non missing dates.
#'   \code{NULL} means no time limitation at all.
#'
#' @return Data frame (\code{data.table}) with columns corresponding to \code{x}
#'   and additional columns matched from \code{from}: \itemize{ \item
#'   \code{code}: code as matched from \code{from} (\code{NA} if no match
#'   within period) \item \code{code_date}: corresponding date for which the
#'   code was valid (\code{NA} if no match within period) \item
#'   \code{in_period}: boolean indicator if the unit (patient) had at least one
#'   code within the specified period } The output has at one row for each
#'   combination of "id" and code. Note that other columns of \code{x} might be
#'   repeated accordingly.
#'
#' @export
#'
#' @examples
#' codify(ex_people, ex_icd10, id = "name", date = "surgery", days = c(-365, 0))
codify <- function(x, from, id = "id", date = NULL, days = NULL, .copy = NA) {

  # Determine if coding should be limited by time period
  usedate <- !is.null(days)
  idcols  <- c(id, if (usedate) "date")
  if (usedate && is.null(date)) {
    stop("Argument 'date' must be specified if 'days' is not NULL!")
  } else if (!usedate && !is.null(date)) {
    warning("Date column ignored since days = NULL!")
  }


  if (!is.data.table(x)) {
    x <- data.table(x)
  }
  x2 <- copybig(x, .copy) # New name to avoid copy complications
  if (usedate) setnames(x2, date, "date")
  if (!is.codedata(from)) {
    from <- as.codedata(from, .copy = .copy)
  }

  # id column must be character to merge with columkn from codedata
  if (!is.character(x2[[id]]) && !is.factor(x2[[id]])) {
    x2[[id]] <- as.character(x2[[id]])
    warning(id, " coerced to character!")
  }

  # Silly work around to avoid check notes
  in_period <- code_date <- NULL
  # To avoid unique on all data
  x2_id_date <- x2[, idcols, with = FALSE]

  out <-
    merge(x2_id_date, from, by.x = id, by.y = "id",
          all.x = TRUE, allow.cartesian = TRUE)[,
      in_period :=
        if (!usedate) TRUE
        else
          between(
            as.numeric(code_date),
            as.numeric(date) + min(days),
            as.numeric(date) + max(days)
          )
    ][
      (!in_period),
      `:=`(
        code      = NA,
        code_date = NA
      )
    ][
      ,
      # If there are some codes within the period, keep them all
      # If there are no codes within the period,
      # keep only the first as a marker
      if (any(in_period, na.rm = TRUE)) .SD[in_period] else .SD[1],
      by = idcols
    ]
  out <- merge(unique(out), x2, by = idcols) # to get back all data
  if (usedate) setnames(x2, "date", date)
  structure(out, id = id)
}