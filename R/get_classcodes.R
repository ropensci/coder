#' Get classcodes object
#'
#' @param x classcodes specification as either a name or a classcodes object,
#' or a classcodes object itself.
#' @param from object that classcodes could be inherited from
#' @param regex name of column with regular expressions to use for
#'   classification, either with or without prefix \code{regex_}
#'
#' @return \code{\link{classcodes}} object.
#' @family classcodes
#' @export
get_classcodes <- function(x, from = NULL, regex = "regex") {

  # Possible inherited classcodes
  inh <- attr(from, "classcodes")

  obj <-
    if      (is.classcodes(x)) {
      x
    } else if (is.character(x) && exists(x, envir = .GlobalEnv)) {
      get(x)
    } else if (is.character(x) &&
               x %in% utils::data(package = "coder")$results[, "Item"]) {
      utils::data(list = x, package = "coder", envir = environment())
      get(x, envir = environment())
    } else if (is.null(x) && is.classcodes(inh)) {
      inh
    } else if (is.null(x) &&
               inh %in% utils::data(package = "coder")$results[, "Item"]) {
      utils::data(list = inh, package = "coder", envir = environment())
      get(inh, envir = environment())
    } else {
      stop("No classcodes object found!")
    }

  obj <- as.classcodes(obj)

  # identify regex column from regex attributes
  objrgs <- attr(obj, "regexpr")
  regex <- objrgs[objrgs == regex | endsWith(objrgs, regex)]
  if (length(regex) != 1) stop("Column with regular expression not found!")
  # Change "regex" column to the one specified
  obj$regex <- obj[[regex]]
  # Remove all alternative regexs and keep only rows with regex
  obj[!is.na(obj[[regex]]), !grepl("regex_", names(obj))]
}
