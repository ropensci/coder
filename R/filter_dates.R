#' Filter dates outside specified limits
#'
#' @param x object to filter
#' @param na.rm remove dates outside limits completely (otherwise keep position
#' in vector but set to `NA`)
#' @inheritDotParams dates_within
#'
#' @return Object of same class as `x`. If date vector, a filtered vector,
#' if data frame (with one column named "date"), the same data frame but only
#' with rows with dates within limits.
#' @export
#'
#' @examples
#' #                 valid         future      too early
#' x <- as.Date(c("2017-02-02", "2050-02-02", "1969-02-02"))
#' filter_dates(x) # "2017-02-02" NA           NA
#' filter_dates(x, na.rm = TRUE) # "2017-02-02"
#' filter_dates(data.frame(date = x, foo  = 1:3))
#'
#' @family helper
filter_dates <- function(x, ...) UseMethod("filter_dates", x)


#' @rdname filter_dates
#' @export
filter_dates.data.frame <- function(x, ...) {
  stopifnot("date" %in% names(x))
  ftr <- dates_within(x[["date"]], ...)
  if (any(!ftr, na.rm = TRUE)) {
    warning("Dates outside specified limits dropped (set with from/to)!")
    x[(ftr) | is.na(ftr), ]
  } else x
}

#' @rdname filter_dates
#' @export
filter_dates.Date <- function(x, ..., na.rm = FALSE) {
  y <- dates_within(x, ...)
  if (na.rm) x[y] else as.Date(ifelse(y, x, NA), origin = "1970-01-01")
}


#' Check if dates are within limits
#'
#' @param x Date vector
#' @param from first date of interval to compare with (`1970-01-01` by default,
#' since we assume that little data was recorded before 'epoch'; this is a bold
#' assumption, however, which should be explicitly re-considered for relevant
#' applications)
#' @param to last date of interval to compare with
#'   (the current data from [Sys.Date()], by default,
#'   since we assume that future events are unknown,
#'   thus indicating coding errors)
#'
#' @return Logical vector with `TRUE` if date within limits, `FALSE` otherwise.
#' @export
#' @examples
#'
#' #                 valid         future      too early
#' x <- as.Date(c("2017-02-02", "2050-02-02", "1969-02-02"))
#' dates_within(x) # TRUE FALSE FALSE
#' dates_within(x, from = "2000-01-01", to = "2100-01-01") #  TRUE  TRUE FALSE
#' @family helper
dates_within <- function(x, from = "1970-01-01", to = Sys.Date()) {

  stopifnot(is.Date(x))

  is.blank <- function(x)
    is.null(x) || is.na(x) || is.infinite(x) || as.character(x) == ""

  x  <- as.numeric(x)

  # Set all comparisons to TRUE for non specified limit values
  lower <- if (is.blank(from)) TRUE else x >= as.numeric(as.Date(from))
  upper <- if (is.blank(to))   TRUE else x <= as.numeric(as.Date(to))
  lower & upper
}
