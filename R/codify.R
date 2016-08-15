#' codify elements
#'
#' @param x data.frame with at least two columns, one with case (patient)
#'   identification (column name specified by argument \code{id}) and one with a
#'   date of interest (column name specified by argument \code{date})
#' @param from object with code data for which \code{\link{is.codedata}} is
#'   \code{TRUE}
#' @param id name of column in \code{x} containing case (patient) identification
#' @param date name of column in \code{x} with date of interest
#' @param days numeric vector of length two with lower and upper bound of range
#'   of days relative to \code{date} for which codes from \code{from} are
#'   relevant. (For example \code{c(-365, 0)} implies a time window of one year
#'   prior to \code{date}, which might be useful for calculating comorbidity
#'   indeces, while \code{c(0, 30)} gives a window of 30 days after \code{date},
#'   which might be used for calculating adverse events after a surgical
#'   procedure.)
#'
#' @return Object of class \code{tbl_df} with columns corresponding to \code{x}
#'   and additional columns matched from \code{from}: \itemize{ \item
#'   \code{code}: code as matchaed from \code{from} (\code{NA} if no match
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
codify <- function(x, from, id = "id", date, days) {

  stopifnot(
    is.data.frame(x),
    all(c(id, date) %in% names(x)),
    is.codedata(from),
    is.numeric(days),
    length(days) == 2
  )

  # id variable must be of same format in both data frames for left_join
  if (is.factor(from[["id"]]))
    x[id] <- as.factor(x[[id]])

  # Prefilter to increase speed (faster than left_join)
  from <- from[fastmatch::fmatch(from$id, x[[id]], 0) > 0, ]

  res <-
    suppressWarnings(
      dplyr::rename_(x, id = id, xdate = date) %>%
      dplyr::mutate_(xdate = ~as.numeric(xdate)) %>%
      dplyr::left_join(from, by = "id")
    )

  # Indicate wether a case is within specified time period
  res$date <- as.numeric(res$date) # faster comparisons for numeric than dates
  res$in_period <- TRUE
  res$in_period[
    res$xdate < res$date + days[1] |
    res$xdate > res$date + days[2]] <- FALSE
  res$in_period[is.na(res$date)] <- NA


  # Elements from x without codes from the period (or without codes at all)
  # should have codes = NA
  cases_in_period <- dplyr::filter_(res, ~in_period)

  cases_not_in_period <-
    res %>%
    dplyr::filter_(~(!in_period | is.na(in_period))) %>%
    dplyr::anti_join(cases_in_period, "id")
  # Needs intermediate assignment to acces names without reference to '.',
  # which generates note in devtools::check
  cases_not_in_period <-
    cases_not_in_period %>%
    dplyr::distinct_(
      .dots = setdiff(names(cases_not_in_period), c("date", "code"))) %>%
    dplyr::mutate_(date = NA, code = NA)

  # Combine all cases
  res <-
    dplyr::bind_rows(
      cases_not_in_period,
      res[res$in_period & !is.na(res$in_period), ]
    ) %>%
    # Dates were handled as numerics for speed but should be coerced back to dates
    dplyr::mutate_(
      date  = ~as.Date(date,  origin = "1970-01-01"),
      xdate = ~as.Date(xdate, origin = "1970-01-01")
    )

  names(res)[names(res) == "id"]    <- id
  names(res)[names(res) == "date"]  <- "code_date"
  names(res)[names(res) == "xdate"] <- "date"

  # Add id attribute
  structure(res, id = id)
}
