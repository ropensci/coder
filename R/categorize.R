#' Categorize cases based on external data and classification scheme
#'
#' This is the main function of the package, which relies of a triad of objects:
#' (1) \code{data}) with unit id:s and possible dates of interest;
#' (2) \code{codedata} for corresponding
#' units and with optional dates of interest and;
#' (3) a classification scheme ('classcodes' object; \code{cc}) with regular
#' expressions to identify and categorize relevant codes.
#'
#' The function combines the three underlying steps performed by
#' \code{\link{codify}}, \code{\link{classify}} and \code{\link{index_fun}}.
#'  Relevant arguments are passed forward to those functions by
#'  \code{codify_args} and \code{cc_args}.
#'
#' @seealso For more details see the help vignette:
#' \code{vignette("coder", package = "coder")} and the package website
#' \url{https://eribul.github.io/coder}
#'
#'
#' @param data data frame with mandatory id column
#'   (identified by argument \code{id}),
#'   and semi-optional column with date of interest
#'   (identified by argument \code{date} if \code{days != NULL}).
#' @param codedata external code data (see \code{\link{as.codedata}})
#' @param cc \code{\link{classcodes}} object (or name of such object).
#' @param index control possible inclusion of index vector.
#'   Set to \code{FALSE} if no index should be calculated, otherwise a value
#'   passed to argument
#'   \code{by} in function \code{\link{index}}. It is possible to
#'   include several indices as a character vector.
#'   \code{NULL} will include all available indices as specified by the
#'   "indices" attribute of the \code{cc} object (\code{attr(cc, "indices")})
#' @param sort logical. Should output be sorted by the 'id' column?
#'   (This could effect computational speed for large data sets.)
#'   Data is sorted by 'id' internally. It is therefore faster to keep the
#'   output sorted this way, but this might be inconvenient if the original
#'   order was intended. Set to \code{FALSE} in order to not shuffle the
#'   input data.
#' @param codify_args List of named arguments passed to \code{\link{codify}}
#' @inheritParams classify
#'
#' @return Object of class \code{data.table} made from \code{data} combined with
#' logical columns indicating membership of categories identified by the
#' \code{classcodes} object (the \code{cc} argument).
#' Indices are also included if specified by the 'index' argument.
#'
#' @export
#'
#' @examples
#' # Add Elixhauser based on all registered ICD10-codes
#' categorize(ex_people, ex_icd10, "elixhauser", id = "name")
#'
#' # Add Charlson categories and two versions of a calculated index.
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
  data, codedata, cc, id, index = NULL, sort = TRUE,
  codify_args = list(), cc_args = list()) {

  stopifnot(id %in% names(data), is.character(data[[id]]))

  cc_args$cc <- cc_name <- cc
  cc <- do.call(set_classcodes, cc_args)

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
  cl               <- classify(cod, cc, cc_args = NULL) # NULL since cc alr. set

  data$id_chr <- as.character(data[[id]]) # To be able to merge
  out       <- merge(data, as.data.table(cl),
                     by.x = "id_chr", by.y = id, sort = sort)
  id_chr <- NULL # to avoid check note
  data[, id_chr := NULL] # Don't need it any more

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
      ind_names <-
        clean_text(
          cc_name, paste0(attr(cc, "regex_name"), "_index_",
          # we always want one "index_", not two if index name already prefixed
          gsub("index_", "", ind_names)))
    }
    setnames(indx, setdiff(names(indx), id), ind_names)
    out <- merge(out, indx,  by.x = "id_chr", by.y = id, sort = sort)
  }
  out[, id_chr := NULL][]
}
