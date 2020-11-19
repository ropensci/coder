#' Set classcodes object
#'
#' Prepare a `classcodes`object by specifying the regular expressions
#' to use for classification.
#'
#' @param cc [`classcodes`] object (or name of a default object from
#'  [all_classcodes()]).
#' @param classified object that classcodes could be inherited from
#' @param regex name of column with regular expressions to use for
#'   classification.
#'   `NULL` (default) uses `attr(obj, "regexpr")[1]`.
#' @param start,stop should codes start/end with the specified regular
#'   expressions? If `TRUE`, column "regex" is prefixed/suffixed
#'   by `^/$`.
#' @param tech_names should technical column names be used? If `FALSE`,
#'   colnames are taken directly from group names of `cc`, if `TRUE`,
#'   these are changed to more technical names avoiding special characters and
#'   are prefixed by the name of the classification scheme.
#'   `NULL` (by default) preserves previous names if `cc` is inherited from
#'   `classified` (fall backs to `FALSE` if not already set).
#'
#' @return [`classcodes`] object.
#' @family classcodes
#' @export
#' @example man/examples/set_classcodes.R
set_classcodes <- function(
  cc, classified = NULL, regex = NULL,
  start = TRUE, stop = FALSE, tech_names = NULL) {

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

  if (!is.null(tech_names)) {
    already_tn <- attr(obj, "tech_names")
    if (!tech_names && !is.null(already_tn) && already_tn) {
      stop("classcodes object has technical names. ",
           "Either re-specify the classcodes object ",
           "or change/drop the `tech_names` argument!", call. = FALSE)
    } else if (tech_names && is.null(already_tn)) {

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

      # indicate that tech_names are used in order to not add again
      attr(obj, "tech_names") <- TRUE
    }
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
