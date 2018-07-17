#' Categorize cases based on external data and classification scheme
#'
#' \code{add} and \code{categorize/categorise} are the main functions
#' of the package. They are basically synonyms but use a differnt order of
#' arguments (see "When to use each funtion" for details).
#'
#' @inheritParams classify
#' @param what What to add? Specify classification scheme
#' (\code{\link{classcodes}} classcode object) specifying categories to add
#' based on individual code groups.
#' @param to,.data To which data set should the categories be added?
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
#'
#' @section When to use each funtion:
#'
#' Both \code{add} and \code{categorize/categorise} are used as a single step
#' function to categorize cases (for example patients) using external code data
#' (for example privious hospital records with ICD10-codes) based on a
#' classification scheme (for example a comorbidity index). It involves a
#' couple of intermediate steps that are abstracted away for convenience.
#'
#' \describe{
#'
#'   \item{\code{add}}{The order of arguments in the \code{add} function is
#'   ment to maximize readability and understanding of the task performed.
#'   It should be relatively easy to read the function call (with its argument)
#'   as a full sentence.}
#'
#'   \item{\code{categorize/categorise}}{Although \code{add} might be easier
#'   to use and read alone, it is not well suited for chained
#'   expression using the magrittr pipe (\code{\%>\%}).
#'   \code{categorize/categorise} on the other hand, use \code{.data} as a first
#'   argument and is therefore natural in this context.}
#'
#'   \item{\code{\link{codify}}, \code{\link{classify}}, \code{\link{index}}}{
#'   \code{add/categorize/categorise} combine several steps and add new data
#'   to an existing data frame. Use \code{\link{codify}}, \code{\link{classify}}
#'   and \code{\link{index}} as individual smaller steps for more fine grained
#'   control over different types od in- and output data.}
#' }

#' @export
#'
#' @examples
#' # Add Elixhauser based on all registered ICD10-codes
#' add("elix_icd10", to = ex_people, from = ex_icd10,
#'   id = "name", date = "surgery")
#'
#' # Add Charlson categorias and two versions of a calculated index.
#' # Only include recent hospital visits within 30 days before surgery,
#' # and use technical variable names to clearly identify the new columns.
#'
#' add("charlson_icd10", to = ex_people, from = ex_icd10,
#'   id = "name", date = "surgery", days = c(-30, -1),
#'   ind = c("quan_original", "quan_updated"),
#'   tech_names = TRUE
#')
add <- function(
  what, to, from, id, date = NULL,
  days = NULL, ind = NULL, tech_names = FALSE, sort = TRUE) {

  if (!is.data.table(to)) {
    to <- as.data.table(to)
  }

  cod       <- codify(x = to, from = from, id = id, date = date, days = days)
  cl        <- classify(cod, what, tech_names = tech_names)

  to$id_chr <- as.character(to[[id]]) # To be able to merge
  out       <- merge(to, as.data.table(cl),
                     by.x = "id_chr", by.y = id, sort = sort)
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
        attr(cl, "classcodes"), "_index_",
        gsub("\\W", "_", tolower(ind_names), perl = TRUE))
    }
    setnames(indx, setdiff(names(indx), id), ind_names)
    out <- merge(out, indx,  by.x = "id_chr", by.y = id, sort = sort)
  }
  out[, id_chr := NULL][]
}

#' @rdname add
#' @export
#' @examples
#'
#' \dontrun{
#' # Use 'categorize' to chain with magrittr pipe:
#' ex_people %>%
#'   categorize(ex_icd10, "elix_icd10",
#'   id = "name", date = "surgery")
#' }
categorize <- function(.data, from, what, id, date, ...)
  add(what = what, to = .data, from = from, id = id, date = date, ...)

#' @rdname add
#' @export
categorise <- categorize
