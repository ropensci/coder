#' Categorize cases based on external data and classcodes (classification scheme)
#'
#' @inheritParams classify
#' @param data (\code{\link{data.frame}}) with case data including at least an id,
#'   and possibly a date, column.
#' @param codedata external code data (see \code{\link{as.codedata}})
#' @param cc \code{\link{classcodes}} object (or name of such).
#' @param index control possible inclusion of index vector.
#'   Set to \code{FALSE} if no index should be calculated, otherwise a value passed to argument
#'   \code{by} in function \code{\link{index}}. It is possible to
#'   include several indices as a character vector.
#'   \code{NULL} will include all available indices.
#' @param sort logical. Should output be sorted by the 'id' column?
#'   (Sorting by id is always done internally. To restore the original row order of \code{data}
#'   could be slow for large data sets.)
#' @param codify_args List of named arguments passed to \code{\link{codify}}
#'
#' @return \code{\link{data.table}} with
#'  \code{data} enhanced by logical columns indicating
#' membership of categories identified by \code{cc}, as well as
#' indices if specified by \code{index}.
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
#'   index = c("quan_original", "quan_updated"),
#'   codify_args = list(date = "event", days = c(-30, -1)),
#'   cc_args = list(tech_names = TRUE)
#' )
#' @family verbs
categorize <- function(
  data, codedata, cc, id, index = NULL, sort = TRUE, codify_args = list(), cc_args = list()) {

  cc_args$cc <- cc_name <- cc
  cc <- do.call(set_classcodes, cc_args)

  if (!id %in% names(data))      stop("No id column '", id, "' in data!")
  if (!is.character(data[[id]])) stop("Id column must be of type character!")
  if (!is.data.table(data)) {
    data <- as.data.table(data)
  }

  # Use id as key and check that it is unique!
  if (sort & !haskey(data)) setkeyv(data, id)
  if (anyDuplicated(data[[id]])) stop("Non-unique ids!")

  codify_args$data    <- data
  codify_args$codedata <- codedata
  codify_args$id   <- id
  cod              <- do.call(codify, codify_args)
  cl               <- classify(cod, cc)

  out       <- merge(data, as.data.table(cl),
                     by.x = id, by.y = id, sort = sort)

  # Add index named index if index not FALSE
  index_inh <- attr(cc, "indices")
  if (!identical(index, FALSE)) {
    index <-
      if (is.null(index) && !is.null(index_inh) && length(index_inh) > 0) {
        index_inh
      } else if (is.null(index)) {
        list(NULL)
      } else {
        index
      }
    indx        <- lapply(index, function(x) index(cl, index = x))
    indx        <- as.data.table(as.data.frame(indx), keep.rownames = id)
    ind_names   <- if (identical(index, list(NULL))) "index" else index
    if (!is.null(cc_args$tech_names) && cc_args$tech_names) {
      ind_names <- clean_text(cc_name, paste0("index_", ind_names))
    }
    setnames(indx, setdiff(names(indx), id), ind_names)
    out <- merge(out, indx,  by.x = id, by.y = id, sort = sort)
  }
  out
}
