#' Codify elements (within period)
#'
#' Enhance case data with code data, possibly limited to relevant period.
#'
#' @inheritParams copybig
#' @param data a table with columns id (`character`), code, and optionally date
#'   ([`Date`])
#' @param codedata additional data with columns
#'   including case id (`character`), code and an optional date ([Date]) for
#'   each code. An optional column `condition` might distinguish codes/dates
#'   with certain characteristics (see example).
#' @param id,code,date,code_date column names with case id
#'   (`character` from `data` and `codedata`), `code` (from `data`) and
#'   optional date ([Date] from `data`) and
#'   `code_date` ([Date] from `codedata`).
#' @param days numeric vector of length two with lower and upper bound for range
#'   of relevant days relative to `date`. See "Relevant period".
#' @param alnum Should codes be cleaned from all non alphanumeric characters?
#' @param n number of rows to preview as tibble.
#'   The output is technically a [data.table::data.table], which might be an
#'   unusual format to look at. Use `n = NULL` to print the object as is.
#' @param ... arguments passed between methods
#' @return
#'   Object of class `codified` (inheriting from [data.table::data.table]).
#'   Essentially `data` with additional columns:
#'   `code, code_date`: left joined from `codedata` or `NA`
#'   if no match within period. `in_period`: Boolean indicator if the case
#'   had at least one code within the specified period.
#'
#'   The output has one row for each combination of "id" from `data` and
#'   "code" from `codedata`. Rows from `data` might be repeated
#'    accordingly.
#'
#' @section Relevant period:
#'   Some examples for argument `days`:
#'
#'   - `c(-365, -1)`: window of one year prior to the `date`
#'       column of `data`. Useful for patient co-morbidity.
#'   - `c(1, 30)`: window of 30 days after `date`.
#'       Useful for adverse events after a surgical procedure.
#'   -  `c(-Inf, Inf)`: no limitation on non missing dates.
#'   - `NULL`: no time limitation at all.
#'
#' @export
#' @name codify
#'
#' @examples
#' codify(ex_people, ex_icd10, id = "name", code = "icd10",
#'   date = "surgery", code_date = "admission", days = c(-365, 0))
#' @family verbs
codify <- function(data,
                   codedata,
                   ...,
                   id,
                   code,
                   date      = NULL,
                   code_date = NULL,
                   days      = NULL
                   ) {

  if (!id %in% names(data))
    stop("No id column '", id, "' in data!", call. = FALSE)
  if (!id %in% names(codedata))
    stop("No id column '", id, "' in codedata!", call. = FALSE)
  if (!is.character(data[[id]]) || !is.character(codedata[[id]]))
    stop(id, " must be `character` in 'data' and 'codedata'!", call. = FALSE)
  if (anyDuplicated(data[[id]]))
    stop("Non-unique ids!", call. = FALSE)
  if(!utils::hasName(codedata, code))
    stop("codedata must have column ", code, call. = FALSE)

  # Determine if coding should be limited by time period
  usedate <- !is.null(days)
  idcols  <- c(id, if (usedate) date)
  if (usedate) {
    if (is.null(date))
      stop("Argument 'date' must be specified if 'days' is not NULL!")
    if (!inherits(data[[date]], "Date"))
      stop("data column '", date, "' is not of class 'Date'!")
    if (is.null(code_date))
      stop("Argument 'code_date' must be specified if 'days' is not NULL!")
    if (!inherits(codedata[[code_date]], "Date"))
      stop("codedata column '", date, "' is not of class 'Date'!")
  }
  if (!usedate && !is.null(date)) {
    warning("Date column ignored since days = NULL!")
  }

  UseMethod("codify")
}



#' @export
#' @rdname codify
codify.data.frame <- function(data,
                              ...,
                              id,
                              date = NULL,
                              days = NULL
                              ) {
  data <- data.table(data, key = c(id, if (!is.null(days)) date))
  codify.data.table(data, ..., id = id, date = date, days = days)
}



#' @export
#' @rdname codify
codify.data.table <- function(data,
                              codedata,
                              ...,
                              id,
                              code,
                              date = NULL,
                              code_date = NULL,
                              days = NULL,
                              alnum = FALSE,
                              .copy = NA
                              ) {

  usedate <- !is.null(days)
  idcols  <- c(id, if (usedate) date)

  # data is already data.table but might have the wrong keys if argument
  # not passed through codify.data.table
  if (!setequal(key(data), idcols)) {
    setkeyv(data, idcols)
  }
  if (!is.data.table(codedata)) {
    codedata <- data.table(codedata, key = c(id, if (usedate) code_date, code))
  }

  # Make data.tables 'x1' and 'x2' instead of 'data' and 'codedata'
  x1 <- copybig(data, .copy) # New name to avoid copy complications
  x2 <- copybig(codedata, .copy)

  if (alnum) {
    x2[, (code) := gsub("[^[:alnum:]]", "", code)]
  }

  ..date <- ..code_date <- in_period  <- NULL # to avoid check notes

  # Use faster date format
  if (usedate) {
    data[, (date) := as.IDate(.SD[[date]])]
    codedata[, (code_date) := as.IDate(.SD[[..code_date]])]
  }

  x1_id_date <- x1[, idcols, with = FALSE] # To avoid unique on all data

  out <- merge(x1_id_date, x2, by = id, all.x = TRUE, allow.cartesian = TRUE)[,
    in_period :=
      if (!usedate) TRUE
      else {
        between(
          .SD[[..code_date]],
          .SD[[..date]] + min(days),
          .SD[[..date]] + max(days),
          NAbounds = NA
        )
      }][
    # Set codes and their dates to NA if outside relevant time window
    !(in_period), c(code, code_date)      := NA][,
    # If codes within period: keep them all. If not: Keep the first as marker.
    if (any(in_period, na.rm = TRUE)) .SD[in_period] else .SD[1],
      by = idcols
    ]

  out <- merge(unique(out), x1, by = idcols) # to get back all data

  structure(
    out, id = id, code = code,
    class = unique(c("codified", class(out)))
  )
}



#' @export
#' @rdname codify
print.codified <- function(x, ..., n = 10) {
 print_tibble(x, ..., n = n)
}