#' Calculate index based on classification scheme
#'
#' (Weighted) sum of all identified classes for each case.
#' Index weights for subordinate hierarchical classes
#' (as identified by `attr(cc, "hierarchy")`) are excluded in presence of
#' superior classes if index specified with argument `index`.
#'
#' @param classified output from [classify()]
#' @param index name of column with 'weights' from corresponding
#'   [`classcodes`] object. Can be `NULL` if the index is just a
#'   count of relevant classes.
#' @param cc [`classcodes`] object. Can be `NULL` if information
#'   already present as attribute of `classified` (which is often the case)
#'   and/or if index calculated without weights.
#'
#' @param ... used internally
#'
#' @return Named numeric index vector with names corresponding to
#'   `rownames(x)`
#' @example man/examples/index.R
#' @name index_fun
NULL

# Use strange names to avoid name collision with index.html used by pkgdown!
#' @rdname index_fun
#' @export
#' @family verbs
index <- function(classified, ...) {
  UseMethod("index")
}


#' @export
#' @rdname index_fun
index.data.frame <- function(classified, ...) {
  message("column '", names(classified)[1], "' used as id!")
  y <- as.matrix(classified[-1])
  dimnames(y)[1] <- classified[1]
  index(y, cc = attr(classified, "classcodes"), ...)
}


#' @rdname index_fun
#' @export
index.matrix <- function(classified, index = NULL, cc = NULL, ...) {

  # Find classcodes object (NULL is valid if no weights supplied)
  cc <- suppressMessages(set_classcodes(cc, classified))

  # clean text to compare colnames if tech_names used
  regularize <- function(x) {
    gsub("\\W", "_", tolower(x), perl = TRUE)
  }
  # index is either the simple rowsum or made by
  # vector multiplication of weights
  out <-
    if (is.null(index)) {
      message("index calculated as number of relevant categories")
      rowSums(classified)
    } else if (!index %in% names(cc) & !any(endsWith(names(cc), index))) {
      stop(gettextf("'%s' is not a column of the classcodes object!", index))
    } else if (!all(vapply(regularize(cc$group),
      function(y)
        any(grepl(y, regularize(colnames(classified)))), logical(1)))) {
      stop("Data non consistent with specified classcodes!")
    } else {
      index <- names(cc)[names(cc) == index |
                         names(cc) == paste0("index_", index)]
      ind <- cc[[index]]
      ind[is.na(ind)] <- 0
      c(classified %*% ind)
    }

  # Adjust for hierarchical classes
  hierarchy <- attr(cc, "hierarchy")
  if (!is.null(hierarchy) & exists("ind")) {
    # For each pair of hierarchical classes
    for (hi in attr(cc, "hierarchy")) {
      # Identify cases with both classes
      both <- rowSums(cols(hi, classified), na.rm = TRUE) == 2
      # Find index weights corresponding to those classes
      diag_inx <- ind[vapply(clean(hi), grep, 1, clean(cc$group))]
      # Subtract lowest abs index numb for cases with both hierarchical classes
      out <- ifelse(both, out - sort(abs(diag_inx))[1], out)
    }
  }

  names(out) <- rownames(classified)
  out
}
