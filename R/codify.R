
#' codify elements
#'
#' @param x data.frame with at least two columns, one with case (patient)
#' identification (column name specified by argument \code{id}) and one with a
#' date of interest (column name specified by argument \code{date})
#' @param from object with code data for which \code{\link{is.codedata}} is \code{TRUE}
#' @param id name of column in \code{x} containing case (patient) identification
#' @param date name of column in \code{x} with date of interest
#' @param years number of years before \code{date} during which codes from
#' \code{from} are relevant
#'
#' @return Object of class \code{tbl_df} with columns corresponding to \code{x}
#' and additional columns matched from \code{from}:
#' \itemize{
#'   \item \code{code}: code as matchaed from \code{from} (\code{NA} if no match within period)
#'   \item \code{code_date}: corresponding date for which the code was valid
#'         (\code{NA} if no match within period)
#'   \item \code{in_period}: boolean indicator if the unit (patient) had at least one
#'   code within the specified period
#' }
#'  Ther output has at one row for each combination of unit and code.
#'
#' @export
#'
#' @examples
#' codify(ex_people, ex_icd10, id = "name", date = "surgery")
codify <- function(x, from, id = "id", date, years = 1) {

  stopifnot(
    is.data.frame(x),
    all(c(id, date) %in% names(x)),
    is.codedata(from),
    is.numeric(years),
    years > 0
  )

  # Need factor to be compatible for left_join
  x[id] <- as.factor(x[[id]])

  # Prefilter to increase speed (faster than left_join)
  from <- from[fastmatch::fmatch(from$id, x[[id]], 0) > 0, ]

  res <-
    suppressWarnings(
      dplyr::rename_(x, id = id, xdate = date) %>%
      dplyr::mutate_(xdate = ~as.Date(xdate)) %>%
      dplyr::left_join(from, by = "id")
    )


  # Indicate wether a case is within specified time period
  res$in_period <- TRUE
  res$in_period[res$xdate <= res$date | res$xdate > res$date + 365 * years] <- FALSE
  res$in_period[(is.na(res$date) & is.na(res$code))] <- NA


  # Elements from x without codes from the period (or without codes at all)
  # should have codes = NA
  cases_in_period <-
    res %>%
    dplyr::filter_(~in_period)

  cases_not_in_period <-
    res %>%
    dplyr::filter_(~(!in_period | is.na(in_period))) %>%
    dplyr::anti_join(cases_in_period, "id") %>%
    dplyr::distinct_(setdiff(names(.), c("date", "code"))) %>%
    dplyr::mutate_(date = NA, code = NA)

  res <- dplyr::bind_rows(
    cases_not_in_period,
    res[res$in_period & !is.na(res$in_period), ]
  )


  # Get back to original column names of x
  nr <- names(res)
  nr[nr == "id"]    <- id
  nr[nr == "date"]  <- "code_date"
  nr[nr == "xdate"] <- date
  names(res) <- nr

  attr(res, "id") <- id
  res
}