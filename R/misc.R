#' Get classcodes object
#'
#' @param x classcodes specification as either a name or a classcodes object,
#' or a classcodes object itself.
#' @param from object that classcodes could be inherited from
#'
#' @return \code{\link{classcodes}} object or \code{NULL} if no object found.
get_classcodes <- function(x, from = NULL) {

  # Possible inherited classcodes
  inh <- attr(from, "classcodes")

  if      (is.classcodes(x)) {
    x
  } else if (is.character(x) && exists(x, envir = .GlobalEnv)) {
    get(x)
  } else if (is.character(x) &&
           x %in% utils::data(package = "classifyr")$results[, "Item"]) {
    utils::data(list = x, package = "classifyr", envir = environment())
    return(get(x, envir = environment()))
  } else if (is.null(x) && is.classcodes(inh)) {
    inh
  } else if (is.null(x) &&
           inh %in% utils::data(package = "classifyr")$results[, "Item"]) {
    utils::data(list = inh, package = "classifyr", envir = environment())
    return(get(inh, envir = environment()))
  } else {
    stop("No classcodes object found!")
  }
}

# ifelse if package exists or not
ifep <- function(pkg, yes, no)
  if (suppressWarnings(requireNamespace(pkg, quietly = TRUE))) yes else no


# to use instead of dplyr::bind_rows if dplyr not available
rbind.fill <- function(...) {

  dots <- list(...)

  NAs <- function(a, b) {
    missing     <- setdiff(names(b), names(a))
    z           <- matrix(NA, nrow(a), length(missing))
    colnames(z) <- missing
    as.data.frame(z, stringsAsFactors = FALSE)
  }

  switch(as.character(length(dots)),
    "0" = NULL,
    "1" = dots[[1]],
    "2" = rbind(
            cbind(dots[[1]], NAs(dots[[1]], dots[[2]])),
            cbind(dots[[2]], NAs(dots[[2]], dots[[1]]))
          ),
    Recall(Recall(dots[[1]]), do.call(Recall, dots[-1]))
  )
}

# Functions to aid testing for functionality without suggested packages
stop_suggests <- function()
  suppressMessages(
    trace(
      "requireNamespace",
      quote(res <- FALSE),
      print = FALSE,
      at = length(body(requireNamespace))
    )
)

start_suggests <- function()
  suppressMessages(untrace("requireNamespace"))



.onAttach <- function(libname, pkgname) {
  s <- c("dplyr", "Kmisc")
  available <- vapply(s, requireNamespace, logical(1), quietly = TRUE)
  if (!all(available))
    packageStartupMessage(
      "Note that functions from package 'classifyr' could work considerably ",
      "faster if installing suggested packages! Currently missing: \n * ",
      paste(s[!available], collapse = "\n * "))
}

#' @import data.table
NULL

