#' Set classcodes object
#'
#' @param cc [`classcodes`] object or name of such
#' @param classified object that classcodes could be inherited from
#' @param regex name of column with regular expressions to use for
#'   classification, either with or without prefix `regex_`.
#'   `NULL` (default) uses the first classcodes column with prefix "regex".
#'   This should be a sensible choice for default classcodes object included
#'   in the package.
#' @param start,stop should codes start/end with the specified regular
#'   expressions? If `TRUE`, column "regex" is prefixed/suffixed
#'   by `^/$`.
#' @param tech_names should technical column names be used? If `FALSE`,
#'   colnames are taken directly from group names of `by`, if `TRUE`,
#'   these are changed to more technical names avoiding special characters and
#'   are prefixed by the name of the classification scheme.
#'
#' @return [`classcodes`] object.
#' @family classcodes
#' @export
#' @examples
#' # Prepare a classcodes object for the Charlson comorbidity classification
#' # based on the default regular expressions
#' set_classcodes(charlson)
#'
#' # Same as above but based on regular expressions for ICD-8
#' set_classcodes(charlson, regex = "icd8_brusselaers")
set_classcodes <- function(
  cc, classified = NULL, regex = NULL,
  start = TRUE, stop = FALSE, tech_names = FALSE) {

  # Possible inherited classcodes
  inh <- attr(classified, "classcodes")

  obj <-
    if (is.classcodes(cc)) {
      cc
    } else if (is.character(cc) &&
               cc %in% utils::data(package = "coder")$results[, "Item"]) {
      utils::data(list = cc, package = "coder", envir = environment())
      get(cc, envir = environment())
    } else if (is.null(cc) && is.classcodes(inh)) {
      inh
    } else if (is.null(cc) && !is.null(inh) && !identical(inh, character(0)) &&
               inh %in% utils::data(package = "coder")$results[, "Item"]) {
      utils::data(list = inh, package = "coder", envir = environment())
      get(inh, envir = environment())
    } else {
      stop("No classcodes object found!")
    }

  # Fix name attribute if not already set
  nm <- if (is.character(cc)) cc else attr(cc, "name", exact = TRUE)
  if (is.classcodes(obj)) {
    attr(obj, "name") <- nm
  } else {
    obj <- as.classcodes(obj, .name = nm)
  }

  if (tech_names) {

    long_names <- function(x) {
      clean_text(
        attr(obj, "name", exact = TRUE),
        paste(
          if (is.null(regex)) attr(obj, "regexpr")[1] else regex,
          x,
          sep = "_"
        )
      )
    }

    hi <- attr(obj, "hierarchy")
    if (!is.null(hi))
      attr(obj, "hierarchy") <- lapply(hi, long_names)
    obj$group <- long_names(obj$group)
  }

  # identify regex column from regex attributes
  objrgs <- attr(obj, "regexpr")
  if (is.null(regex)) {
    regex <- objrgs[1]
    if (regex != "regex")
      message("Classification based on: ", regex)
  } else {
    regex <- objrgs[objrgs == regex | endsWith(objrgs, regex)]
  }
  if (length(regex) != 1) stop("Column with regular expression not found!")
  # Remove all alternative regexs and keep only rows with regex
  obj <- obj[!is.na(obj[[regex]]),
             !names(obj) %in% setdiff(attr(obj, "regexpr"), regex)]
  attr(obj, "regexprs") <- regex
  # Save original name of regex to use with tech_names = TRUE
  attr(obj, "regex_name") <- regex

  # Add prefix/suffix if specified
  obj[[regex]] <-
    if (start & !stop) {
      paste0("^(", obj[[regex]], ")")
    } else if (!start & stop) {
      paste0("(", obj[[regex]], ")$")
    } else if (start & stop) {
      paste0("^(", obj[[regex]], ")$")
    } else {
      obj[[regex]]
    }

  obj
}
