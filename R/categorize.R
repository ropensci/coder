#' Categorize cases based on external data and classification scheme
#'
#' \code{categorize} is the main function of the package.
#' \code{categorise} is used as an additional alias.
#'
#' @inheritParams classify
#' @param what What to add? Specify classification scheme
#' (\code{\link{classcodes}} classcode object) specifying categories to add
#' based on individual code groups.
#' @param .data To which data set should the categories be added?
#'   A data frame with at least one column with case (patient) identification
#'   (column name specified by argument id). A column with a date of interest
#'   (column name specified by argument date) is mandatory if days != NULL.
#' @param from where do we find the class codes? \code{\link{codedata}}
#' @param id,date,days arguments passed to \code{\link{codify}}
#' @param ind control possible inclusion of index vector. Set to \code{FALSE} if
#'   no index should be calculated, otherwise a value passed to argument
#'   \code{by} in function \code{\link{index}}. It is possible to
#'   include several indices as a character vector.
#' @param sort logical. Should output be sorted by the 'id' column?
#' (This could effect computational speed for large data sets.)
#' Data is sorted by 'id' internally. It is therefore faster to keep the output
#' sorted this way, but this might be inconvinient if the original
#' order was intended. Set to \code{FALSE} in order to not shuffle the
#' input data.
#'
#' @return data frame ('data.table' object) with all data from
#' the input data set \code{to/.data} combined with logical columns indicating
#' membership of categories identified by the classcode object.
#' Indices are also included if so specified by the 'ind' argument.
#'
#' @export
#'
#' @examples
#' # Add Elixhauser based on all registered ICD10-codes
#' categorize(ex_people, ex_icd10, "elix_icd10", id = "name")
#'
#' # Add Charlson categorias and two versions of a calculated index.
#' # Only include recent hospital visits within 30 days before surgery,
#' # and use technical variable names to clearly identify the new columns.
#' categorize(ex_people, ex_icd10, "charlson_icd10",
#'   id = "name", date = "surgery", days = c(-30, -1),
#'   ind = c("quan_original", "quan_updated"),
#'   tech_names = TRUE
#')
#' @family verbs
categorize <- function(
  .data, from, what, id, date = NULL, days = NULL, ind = NULL,
  tech_names = FALSE, sort = TRUE) {

  if (!is.data.table(.data)) {
    .data <- as.data.table(.data)
  }

  # Use id as key and check that it is unique!
  if (sort & !haskey(.data)) setkeyv(.data, id)
  if (anyDuplicated(.data[[id]])) stop("Non-unique ids!")

  cod       <- codify(x = .data, from = from, id = id, date = date, days = days)
  cl        <- classify(cod, what, tech_names = tech_names)

  .data$id_chr <- as.character(.data[[id]]) # To be able to merge
  out       <- merge(.data, as.data.table(cl),
                     by.x = "id_chr", by.y = id, sort = sort)
  id_chr <- NULL # to avoid check note
  .data[, id_chr := NULL] # Don't need it any more

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
        attr(cl, "classcodes"), "_index_",
        gsub("\\W", "_", tolower(ind_names), perl = TRUE))
    }
    setnames(indx, setdiff(names(indx), id), ind_names)
    out <- merge(out, indx,  by.x = "id_chr", by.y = id, sort = sort)
  }
  out[, id_chr := NULL][]
}


#' @rdname categorize
#' @export
categorise <- categorize
