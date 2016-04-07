#' Patient ICD codes
#'
#' @param x object
#' @param ... possible additional objects to merge with \code{x}
#'
#' @return \code{as.icd_data} returns an object of class \code{tbl_df} with columns:
#' \describe{
#' \item{lpnr}{patient id}
#' \item{date}{date when the icd code were valid}
#' \item{icd}{icd code}
#' }
#' \code{as.icd_data} reuturns \code{TRUE} if these same condityions are met,
#' \code{FALSE} otherwise.
#' (Note that \code{icd_data} is not a formal class of its own!)
#' @export
#' @name icd_data
#'
#' @examples
#' \dontrun{
#' as.icd_data(oppen, sluten)
#' }
as.icd_data <- function(x, ...) UseMethod("as.icd_data", x)

#' @export
#' @rdname icd_data
is.icd_data <- function(x) dplyr::is.tbl(x) && all(c("lpnr", "icd_date", "icd") %in% names(x))


#' @export
as.icd_data.default <- function(x, ...) {
  x <- tibble::as_data_frame(x)
  names(x) <- tolower(names(x))
  stopifnot(c("lpnr", "icd_date", "icd") %in% names(x))

  dplyr::select_(x, "lpnr", "icd_date", "icd") %>%
  dplyr::distinct_( "lpnr", "icd_date", "icd") %>%
  # Saving data as factor variable makes the dataset considerably smaller
  dplyr::mutate(
    lpnr = as.factor(lpnr),
    icd = as.factor(icd)
  )
}


#' @export
as.icd_data.pardata <- function(x, ...) {
  dia_names <- names(x)[grepl("dia", names(x))]

  dplyr::bind_rows(x, ...) %>%
    tidyr::gather_("id", "icd", dia_names) %>%
    dplyr::rename_(icd_date = ~indatum) %>%
    dplyr::filter_(~icd != '') %>%
    as.icd_data()
}

