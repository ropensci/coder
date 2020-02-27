#' Set classcodes object
#'
#' @param cc \code{\link{classcodes}} object or name of such
#' @param classified object that classcodes could be inherited from
#' @param regex name of column with regular expressions to use for
#'   classification, either with or without prefix \code{regex_}.
#'   \code{NULL} (default) uses the first classcodes column with prefix "regex".
#'   This should be a sensible choice for default classcodes object included in the package.
#' @param start,stop should codes start/end with the specified regular expressions?
#'   If \code{TRUE}, column "regex" is prefixed/suffixed by "^"/"$".
#' @param tech_names should technical column names be used? If \code{FALSE},
#'   colnames are taken directly from group names of \code{by}, if \code{TRUE},
#'   these are changed to more technical names avoiding special characters and
#'   are prefixed by the name of the classification scheme.
#'
#' @return \code{\link{classcodes}} object.
#' @family classcodes
#' @export
set_classcodes <- function(
  cc, classified = NULL, regex = NULL,
  start = TRUE, stop = FALSE, tech_names = FALSE) {

  # Possible inherited classcodes
  inh <- attr(classified, "classcodes")

  obj <-
    if (is.classcodes(cc)) {
      cc
    } else if (is.character(cc) && exists(cc, envir = .GlobalEnv)) {
      get(cc)
    } else if (is.character(cc) &&
               cc %in% utils::data(package = "coder")$results[, "Item"]) {
      utils::data(list = cc, package = "coder", envir = environment())
      get(cc, envir = environment())
    } else if (is.null(cc) && is.classcodes(inh)) {
      inh
    } else if (is.null(cc) &&
               inh %in% utils::data(package = "coder")$results[, "Item"]) {
      utils::data(list = inh, package = "coder", envir = environment())
      get(inh, envir = environment())
    } else {
      stop("No classcodes object found!")
    }

  obj <- as.classcodes(obj)

  if (tech_names) {
    obj$group <- clean_text(cc, paste(regex, obj$group, sep = "_"))
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
  # Change "regex" column to the one specified
  obj$regex <- obj[[regex]]
  # Remove all alternative regexs and keep only rows with regex
  obj <- obj[!is.na(obj[[regex]]), !grepl("regex_", names(obj))]

  # Add prefix/suffix if specified
  obj$regex <-
    if (start & !stop) {
      paste0("^(", obj$regex, ")")
    } else if (!start & stop) {
      paste0("(", obj$regex, ")$")
    } else if (start & stop) {
      paste0("^(", obj$regex, ")$")
    } else {
      obj$regex
    }

  obj
}
