#' Add classification data to data frame with case data
#'
#' This function can be used as a convenient short cut for the otherwise common
#' multi step procedure based on \code{\link{codify}}, \code{\link{classify}},
#' \code{\link{index}} and then combining the input data with the new result.
#'
#' @param what to add? classification scheme of type classcodes to classify by
#' @param to where should it be added? A data frame with at least two columns,
#' one with case (patient) identification (column name specified by argument id)
#' and one with a date of interest (column name specified by argument date)
#' @param from where do we find the class codes?
#' Object with code data for which \code{\link{is.codedata}} is \code{TRUE}
#' @param id,date,days arguments passed to \code{\link{codify}}
#' @param ind control possible inclusion of index vector. Set to \code{FALSE} if
#' no index should be calculated, otherwise a value passed to argument \code{by}
#' in function \code{\link{index}}. It is here also possible to include several
#' indices as a character vector.
#'
#' @return data frame with all data from input data frame \code{to} combined
#' with added class (and possibly index) data.
#'
#' @export
#'
#' @examples
#' add("elix_icd10", to = ex_people, from = ex_icd10,
#'   id = "name", date = "surgery")
add <- function(what, to, from, id, date, days = NULL, ind = NULL) {
  cod       <- codify(x = to, from = from, id = id, date = date, days = days)
  cl        <- classify(cod, what)

  mergefun  <- ifep("dplyr", dplyr::left_join, merge)
  out       <- mergefun(to, as.data.frame(cl), by = id)

  # Add index named ind if ind not FALSE
  if (!identical(ind, FALSE)) {
    if (is.null(ind)) ind <- list(ind)
    indx        <- lapply(ind, function(x) index(cl, by = x))
    indx        <- as.data.frame(indx)
    names(indx) <- if (identical(ind, list(NULL))) "index" else ind
    indx[[id]]  <- rownames(indx)
    out         <- mergefun(out, indx, id)
  }
  out
}