#' Add classification data to data frame with case data
#'
#' This function can be used as a convenient short cut for the otherwise common
#' multi step procedure based on \code{\link{codify}}, \code{\link{classify}},
#' \code{\link{index}} and then combining the input data with the new result.
#' @inheritParams classify
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
add <- function(what, to, from, id, date, days = NULL, ind = NULL, tech_names = FALSE) {

  # Save name of object for later use
  .what <- gsub("\"", "", deparse(substitute(what)))

  if (!is.data.table(to)) {
    to <- as.data.table(to)
  }

  cod       <- codify(x = to, from = from, id = id, date = date, days = days)
  cl        <- classify(cod, what, tech_names = tech_names)

  to$id_chr <- as.character(to[[id]]) # To be able to merge
  out       <- merge(to, as.data.table(cl), by.x = "id_chr", by.y = id)
  id_chr <- NULL # to avoid check note
  to[, id_chr := NULL] # Don't need it any more

  # Add index named ind if ind not FALSE
  if (!identical(ind, FALSE)) {
    if (is.null(ind)) {
      ind <- list(ind)
    }
    indx        <- lapply(ind, function(x) index(cl, by = x))
    indx        <- as.data.table(as.data.frame(indx), keep.rownames = id)
    ind_names   <- if (identical(ind, list(NULL))) "index" else ind
    if (tech_names) {
      ind_names <- paste0(
        .what, "_index_", gsub("\\W", "_", tolower(ind_names), perl = TRUE))
    }
    setnames(indx, setdiff(names(indx), id), ind_names)
    out <- merge(out, indx,  by.x = "id_chr", by.y = id)
  }
  out[, id_chr := NULL][]
}