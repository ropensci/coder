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
#'   procedure.) \code{c(-Inf, Inf)} (as default) means no limitation.
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
codify <- function(x, from, id = "id", date, days = c(-Inf, Inf)) {

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
  matchfun <- ifep("fastmatch", fastmatch::fmatch, match)
  from <- from[matchfun(from$id, x[[id]], 0) > 0, ]

  names(x)[names(x) == id]   <- "id"
  names(x)[names(x) == date] <- "xdate"
  x$xdate <- as.numeric(x$xdate)

  x <-  ifep("dplyr",
          suppressWarnings(dplyr::left_join(x, from, by = "id")),
          merge(x, from, by = "id", all.x = TRUE))

  # Indicate wether a case is within specified time period
  x$date <- as.numeric(x$date) # faster comparisons for numeric than dates
  x$in_period <- FALSE
  x$in_period[
    x$date >= x$xdate + min(days) &
    x$date <= x$xdate + max(days)] <- TRUE
  x$in_period[is.na(x$date)] <- NA


  # Elements from x without codes from the period (or without codes at all)
  # should have codes = NA
  cases_in_period <-
    ifep("dplyr", dplyr::filter_(x, ~in_period), x[x$in_period, ])

  # Filter out cases not in period
  cases_not_in_period <-
    ifep("dplyr",
      yes = {
        y <- dplyr::filter_(x, ~(!in_period | is.na(in_period)))
        y <- dplyr::anti_join(y, cases_in_period, "id")
        y <- dplyr::distinct_(y,
          .dots = setdiff(names(y), c("date", "code")))
        dplyr::mutate_(y, date = NA, code = NA)
      },
      no = {
        y <- x[!x$in_period | is.na(x$in_period), ]
        y <- y[!(y$id %in% cases_in_period$id), ]
        y <- y[, setdiff(names(y), c("date", "code"))]
        y <- unique(y)
        y$date <- y$code <- NA
        y
      }
    )

  # Combine all cases
  bindfun <- ifep("dplyr", dplyr::bind_rows, rbind.fill)
  x <- bindfun(cases_not_in_period, x[x$in_period & !is.na(x$in_period), ])

  # Dates were handled as numerics but should be coerced back to dates
  x$date  <- as.Date(x$date,  origin = "1970-01-01")
  x$xdate <- as.Date(x$xdate, origin = "1970-01-01")

  # Back to original
  names(x)[names(x) == "id"]    <- id
  names(x)[names(x) == "date"]  <- "code_date"
  names(x)[names(x) == "xdate"] <- "date"

  # Add id attribute
  structure(x, id = id)
}
