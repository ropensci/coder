#' Filter dates outside specified limits
#'
#' @param x object to filter
#' @param na.rm remove dates outside limits completely (otherwise keep position
#' in vector but set to \code{NA})
#' @param ... arguments passed to \code{\link{dates_within}}.
#' It is here useful to specify the \code{limits} argument
#'
#' @return Object of same class as \code{x}. If date vector, a filtered vector,
#' if data frame (with one column named "date"), the same data frame but only
#' with rows with dates within limits.
#' @export
#' @seealso \code{\link{dates_within}}
#'
#' @examples
#' #                 valid         future      too early
#' x <- as.Date(c("2017-02-02", "2050-02-02", "1969-02-02"))
#' filter_dates(x) # "2017-02-02" NA           NA
#' filter_dates(x, na.rm = TRUE) # "2017-02-02"
#'
#' filter_dates(
#'   data.frame(
#'     date = x,
#'     foo  = 1:3
#'   )
#' )
filter_dates <- function(x, ...) UseMethod("filter_dates", x)


#' @rdname filter_dates
#' @export
filter_dates.data.frame <- function(x, ...) {
  stopifnot("date" %in% names(x))
  ftr <- dates_within(x[["date"]], ...)
  if (any(!ftr)) {
    warning("Dates outside specified limits dropped! ",
            "(Use argument 'limits' to override!)")
    ifep("dplyr", dplyr::filter_(x, ~ ftr), x[ftr, ])
  } else {
    x
  }
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
#' @param limits date vector of length two with lower and upper limit to check
#'
#' @return Logical vector with \code{TRUE} if date within limits, \code{FALSE}
#'  otherwise.
#' @export
#' @seealso \code{\link{filter_dates}}
#'
#' @examples
#'
#' #                 valid         future      too early
#' x <- as.Date(c("2017-02-02", "2050-02-02", "1969-02-02"))
#' dates_within(x) # TRUE FALSE FALSE
#' dates_within(x, as.Date(c("2000-01-01", "2100-01-01"))) #  TRUE  TRUE FALSE
dates_within <- function(x, limits = c(as.Date("1970-01-01"), Sys.Date())) {

  # Check limits of correct format
  if (is.null(limits)) {
    TRUE # Alwyas TRUE if no limits
  } else {
    if (!inherits(limits, "Date") ||
        length(limits) != 2      ||
        limits[1] > limits[2]) {
      stop("limits must be a Date vector of length two with its second ",
           "date after the first!")
    }
    # Generally much faster to compare numerics than dates
    dt  <- as.numeric(x)
    lmt <- as.numeric(limits)
    dt >= lmt[1] & dt <= lmt[2]
  }
}
