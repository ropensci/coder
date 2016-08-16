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

  if      (is.classcodes(x))
    x
  else if (is.character(x))
    get(x)
  else if (is.null(x) & is.classcodes(inh))
    inh
  else if (is.null(x) & is.character(inh))
    get(inh)
}

# Help function to possibly install suggested packages
suggest_install <- function(pkg) {
  if (!requireNamespace(pkg, quietly = TRUE)) {
    if (interactive()) {
      cat("The speed of this call can be increased considerably if using the",
          "suggested (but currently not installed)", pkg, "package.",
          "Would you like to install this package to increase speed? (y/n)")
      ans <- readLines(con = stdin(), n = 1)
      switch(tolower(ans),
        y = utils::install.packages(pkg),
        n = message("Using slow method ..."),
        message("Answer not corresponding to 'y/n'! Using slow method ..."))
    } else {
      message("The speed of this function call could be considerably ",
              "increased if installing suggested package ", pkg)
    }
  }

  invisible(requireNamespace(pkg, quietly = TRUE))
}

# ifelse if package exists or not
ifep <- function(pkg, yes, no)
  if (requireNamespace(pkg, quietly = TRUE)) yes else no


# to use instead of dplyr::bind_rows if dplyr not available
rbind.fill <- function(...) {

  dots <- list(...)

  NAs <- function(a, b) {
    missing <- setdiff(names(b), names(a))
    z <- matrix(NA, nrow(a), length(missing))
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



.onAttach <- function(libname, pkgname) {
  s <- c("dplyr", "Kmisc", "fastmatch")
  available <- vapply(s, requireNamespace, logical(1), quietly = TRUE)
  if (!all(available))
    packageStartupMessage(
      "Note that functions from package 'classifyr' could work considerably ",
      "faster if installing suggested packages! Currently missing: ",
      paste(s[!available], collapse = ", "))
}