#' @importFrom dplyr %>%
#' @export
dplyr::`%>%`


#' Get classcodes object
#'
#' @param x classcodes specification as either a name o a classcodes object,
#' or a classcodes object itself.
#' @param from object that classcodes could be inherited from
#'
#' @return \code{\link{classcodes}} object or \code{NULL} if no object found.
get_classcodes <- function(x, from = NULL) {

  # Possible inherited classcodes
  inh <- attr(from, "classcodes")

  if      (is.classcodes(x))
    x
  else if (is.character(x))
    get(x)
  else if (is.null(x) & is.classcodes(inh))
    inh
  else if (is.null(x) & is.character(inh))
    get(inh)
  else
    NULL
}
