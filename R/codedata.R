#' Code data
#'
#' @param x data frame with columns "id", "date" and "code" or
#'   object of class \code{\link{pardata}}.
#' @param y optional additional \code{\link{pardata}} object to combine with
#' the first. Useful for combining data from in- and outpatient healt care.
#' @param limits ignore (possibly invalid) dates outside this range.
#'   Set to \code{NULL} for no filtering.
#' @param ... pass arguments between methods
#'
#' @return \code{as.codedata} returns a data frame
#'   with mandatory columns:
#' \describe{
#' \item{id}{individual id}
#' \item{date}{date when code were valid}
#' \item{code}{code}
#' }
#' Additional columns might exist (preserved from \code{x})
#'
#' \code{is.codedata} returns \code{TRUE} if these same conditions are met and
#' \code{FALSE} otherwise.
#' (Note that \code{codedata} is not a formal class of its own!)
#' @export
#' @name codedata
#'
#' @examples
#'
#' x <- data.frame(id = 1, date = as.Date("2017-02-02"), code = "a")
#' as.codedata(x)
#'
#' # Drop dates outside specified limits
#' y <- data.frame(id = 2, date = as.Date("3017-02-02"), code = "b")
#' z <- rbind(x, y)
#' as.codedata(z)
#'
as.codedata <- function(x, ...) UseMethod("as.codedata", x)

#' @export
#' @rdname codedata
is.codedata <- function(x) {
  is.data.frame(x) &&
    all(c("id", "date", "code") %in% names(x)) &&
    data.class(x[["date"]]) == "Date"
}

#' @export
as.codedata.default <- function(x, ...)
  stop("'x' must be either a data frame or a 'pardata' object!")

#' @rdname codedata
#' @export
as.codedata.data.frame <-
  function(x, limits = c(as.Date("1970-01-01"), Sys.Date()), ...) {

    names(x) <- tolower(names(x))
  if (!all(c("id", "date", "code") %in% names(x)))
    stop("data frame must contain columns: id, date and code")
  if (data.class(x$date) != "Date")
    stop("Column 'date' is not of format 'Date'!")

  x <- ifep("dplyr", dplyr::distinct_(x, .keep_all = TRUE), unique(x))

  # Drop dates outside limits
  if (!is.null(limits)) {
    if (length(limits) != 2 || limits[1] > limits[2]) {
      stop("limits must be a vector of length two and with its second ",
           "element larger than its first")
    }
    ftr <- x$date < limits[1] | x$date > limits[2]
    if (any(ftr)) {
      warning("Dates outside specified limits dropped! ",
              "(Use argument 'limits' to override!)")
      x <- ifep("dplyr", dplyr::filter_(x, ~ ftr), x[ftr])
    }
  }

  x$id   <- as.factor(x$id)
  x$code <- as.factor(x$code)
  x
}

#' @rdname codedata
#' @export
as.codedata.pardata <- function(x, y = NULL, ...) {

  if (!is.null(y)) {
    x <- ifep("dplyr", dplyr::bind_rows(x, y), rbind.fill(x, y))
  }
  dia_names <- names(x)[grepl("dia", names(x))]

  x <-
    ifep("tidyr",
      tidyr::gather_(x, "dia", "code", dia_names, na.rm = TRUE),
      data.frame(
        stats::reshape(
          x,
          times          = dia_names,
          varying        = dia_names,
          idvar          = "lpnr",
          direction      = "long",
          timevar        = "dia",
          v.names        = "code"
        ),
        stringsAsFactors = FALSE,
        row.names        = NULL
      )
    )

  x$hdia <- startsWith(x$dia, "hdia")
  names(x)[names(x) == "lpnr"]    <- "id"
  names(x)[names(x) == "indatum"] <- "date"
  NextMethod()
}
