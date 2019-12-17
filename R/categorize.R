#' Categorize cases based on external data and classification scheme
#'
#' \code{categorize} is the main function of the package.
#' \code{categorise} is used as an additional alias.
#'
#' @param .data To which data set should the categories be added?
#'   A data frame with at least one column with case (patient) identification
#'   (column name specified by argument id). A column with a date of interest
#'   (column name specified by argument date) is mandatory if days != NULL.
#' @param from where do we find the class codes? \code{\link{as.codedata}}
#' @param what What to add? Specify classification scheme
#'   (\code{\link{classcodes}} classcode object) specifying categories to add
#'   based on individual code groups.
#' @param ind control possible inclusion of index vector. Set to \code{FALSE} if
#'   no index should be calculated, otherwise a value passed to argument
#'   \code{by} in function \code{\link{index}}. It is possible to
#'   include several indices as a character vector.
#'   \code{NULL} will include all available indices.
#' @param sort logical. Should output be sorted by the 'id' column?
#'   (This could effect computational speed for large data sets.)
#'   Data is sorted by 'id' internally. It is therefore faster to keep the output
#'   sorted this way, but this might be inconvinient if the original
#'   order was intended. Set to \code{FALSE} in order to not shuffle the
#'   input data.
#' @param codify_args List of named arguments passed to \code{\link{codify}}
#' @inheritParams classify
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
#' categorize(ex_people, ex_icd10, "elixhauser", id = "name")
#'
#' # Add Charlson categorias and two versions of a calculated index.
#' # Only include recent hospital visits within 30 days before surgery,
#' # and use technical variable names to clearly identify the new columns.
#' categorize(ex_people, ex_icd10, "charlson",
#'   id = "name",
#'   ind = c("quan_original", "quan_updated"),
#'   codify_args = list(date = "surgery", days = c(-30, -1)),
#'   cc_args = list(tech_names = TRUE)
#' )
#' @family verbs
categorize <- function(
  .data, from, what, id, ind = NULL, sort = TRUE, codify_args = list(), cc_args = list()) {

  cc_args$x <- cc_name <- what
  what <- do.call(set_classcodes, cc_args)

  if (!is.data.table(.data)) {
    .data <- as.data.table(.data)
  }

  # Use id as key and check that it is unique!
  if (sort & !haskey(.data)) setkeyv(.data, id)
  if (anyDuplicated(.data[[id]])) stop("Non-unique ids!")

  codify_args$x    <- .data
  codify_args$from <- from
  codify_args$id   <- id
  cod       <- do.call(codify, codify_args)
  cl        <- classify(cod, what)

  .data$id_chr <- as.character(.data[[id]]) # To be able to merge
  out       <- merge(.data, as.data.table(cl),
                     by.x = "id_chr", by.y = id, sort = sort)
  id_chr <- NULL # to avoid check note
  .data[, id_chr := NULL] # Don't need it any more

  # Add index named ind if ind not FALSE
  ind_inh <- attr(what, "indices")
  if (!identical(ind, FALSE)) {
    ind <-
      if (is.null(ind) && !is.null(ind_inh) && length(ind_inh) > 0) {
        ind_inh
      } else if (is.null(ind)){
        list(NULL)
      } else {
        ind
      }
    indx        <- lapply(ind, function(x) index(cl, by = x))
    indx        <- as.data.table(as.data.frame(indx), keep.rownames = id)
    ind_names   <- if (identical(ind, list(NULL))) "index" else ind
    if (!is.null(cc_args$tech_names) && cc_args$tech_names) {
      ind_names <- clean_text(cc_name, paste0("index_", ind_names))
    }
    setnames(indx, setdiff(names(indx), id), ind_names)
    out <- merge(out, indx,  by.x = "id_chr", by.y = id, sort = sort)
  }
  out[, id_chr := NULL][]
}
