#' Code data
#'
#' @param x object
#' @param ... possible additional objects to merge with \code{x}
#'
#' @return \code{as.codedata} returns an object of class \code{tbl_df}
#'   with mandatory columns:
#' \describe{
#' \item{id}{individual id}
#' \item{date}{date when code were valid}
#' \item{code}{code}
#' }
#' Additional columns might exist (preserved from \code{x})
#' \code{is.codedata} reuturns \code{TRUE} if these same conditions are met,
#' \code{FALSE} otherwise.
#' (Note that \code{codedata} is not a formal class of its own!)
#' @export
#' @name codedata
#'
as.codedata <- function(x, ...) UseMethod("as.codedata", x)

#' @export
#' @rdname codedata
is.codedata <- function(x) {
  is.data.frame(x) && all(c("id", "date", "code") %in% names(x))
}


#' @export
as.codedata.default <- function(x, ...) {
  x <- as.data.frame(x)
  names(x) <- tolower(names(x))
  stopifnot(c("id", "date", "code") %in% names(x))

  dplyr::distinct_(x, .keep_all = TRUE) %>%
  # Saving data as factor variable makes the dataset considerably smaller
  dplyr::mutate_(
    id   = ~as.factor(id),
    date = ~as.Date(date),
    code = ~as.factor(code)
  )
}


#' @export
as.codedata.pardata <- function(x, ...) {

  x <- dplyr::bind_rows(x, ...)
  dia_names <- names(x)[grepl("dia", names(x))]

  x <- stats::reshape(x, times = dia_names, varying = list(dia_names),
    idvar = "id", ids = "id", direction = "long", timevar = "dia")
  names(x)[names(x) == "hdia"] <- "code"

  x %>%
    dplyr::transmute_(
      id   = ~lpnr,
      date = ~indatum,
      code = ~code,
      hdia = ~startsWith(dia, "hdia")
    ) %>%
    as.codedata()
}
