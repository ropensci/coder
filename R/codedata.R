#' Code data
#'
#' @param x object
#' @param ... possible additional objects to merge with \code{x}
#'
#' @return \code{as.codedata} returns an object of class \code{tbl_df} with columns:
#' \describe{
#' \item{id}{individual id}
#' \item{date}{date when code were valid}
#' \item{code}{code}
#' }
#' \code{as.codedata} reuturns \code{TRUE} if these same conditions are met,
#' \code{FALSE} otherwise.
#' (Note that \code{codedata} is not a formal class of its own!)
#' @export
#' @name codedata
#'
#' @examples
#' \dontrun{
#' as.codedata(oppen, sluten)
#' }
as.codedata <- function(x, ...) UseMethod("as.codedata", x)

#' @export
#' @rdname codedata
is.codedata <- function(x) is.data.frame(x) && all(c("id", "date", "code") %in% names(x))


#' @export
as.codedata.default <- function(x, ...) {
  x <- tibble::as_data_frame(x)
  names(x) <- tolower(names(x))
  stopifnot(c("id", "date", "code") %in% names(x))

  dplyr::select_(x, "id", "date", "code") %>%
  dplyr::distinct_( "id", "date", "code") %>%
  # Saving data as factor variable makes the dataset considerably smaller
  dplyr::mutate(
    id   = as.factor(id),
    date = as.Date(date),
    code = as.factor(code)
  )
}


#' @export
as.codedata.pardata <- function(x, ...) {

  x <- dplyr::bind_rows(x, ...)
  dia_names <- names(x)[grepl("dia", names(x))]

  x %>%
    tidyr::gather_("tmp", "code", dia_names, na.rm = TRUE) %>%
    dplyr::rename_(
      id   = ~lpnr,
      date = ~indatum) %>%
    dplyr::select_(~-tmp) %>%
    as.codedata()
}

