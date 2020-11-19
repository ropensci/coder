#' Summarizing a classcodes object
#'
#' Classification schemes are formalized by regular expressions within the
#' classcodes objects. These are computationally effective but sometimes hard to
#' interpret. Use this function to list all codes identified for each
#' group.
#'
#' @param object classcodes object
#' @param coding either a vector with codes from the original classification,
#'   or a name (character vector of length one) of a keyvalue object from package
#'   "decoder" (for example "icd10cm" or "atc")
#' @param ...
#' - `summary.classcodes()`: ignored
#' - `print.summary.classcodes()`: arguments passed to `tibble:::print.tbl()`
#' @param cc_args List of named arguments passed to [set_classcodes()]
#' @param x output from `summary.classcodes()`
#'
#' @return
#'
#' Methods primarily called for their side effects (printing to the screen) but
#' with additional invisable objects returned:
#'
#' - `summary.classcodes()`: list with input arguments `object` and `coding`
#'   unchanged, as well as a data frame (`summary`) with columns for groups
#'   identified (`group`); the number of codes to be recognized for each group
#'   (`n`) and individual codes within each group (`codes`).
#' - `print.summary.classcodes()`: argument `x` unchanged
#'
#' @export
#' @family classcodes
#' @name summary.classcodes
#' @example man/examples/summary.classcodes.R
summary.classcodes <- function(object, coding, ..., cc_args = list()) {

  cl <-
    if (is.character(coding) && length(coding) == 1) {
      decoder_data(coding)$key
    } else {
      coding
    }

  # Classify each such code according to the classcodes object
  cl <- classify(cl, object, cc_args = cc_args)
  # Kep only the ones that are relevant according to the classification scheme
  cl <- as.data.frame(cl[rowSums(cl) > 0,])

  # Idfentify wich groups the individual codes relate to
  indx <- apply(cl, 1, which, useNames = FALSE)
  indx <- c(lapply(indx, stats::setNames, NULL), recursive = TRUE)
  nms <- object$group[indx]

  # Paste all individual codes as comma separated list
  codes <-
    vapply(split(indx, nms), function(x) paste(names(x), collapse = ", "), "")
  codes_vct <- lapply(split(indx, nms), function(x) names(x))

  # Result data frame
  res <-
    data.frame(
      group            = names(codes),
      n                = c(table(nms)),
      codes            = codes,
      row.names        = seq_along(codes),
      stringsAsFactors = FALSE
    )

  structure(
    list(object = object, summary = tibble::as_tibble(res),
         coding = coding, codes_vct = codes_vct),
    class = "summary.classcodes"
  )
}

#' @rdname summary.classcodes
#' @export
print.summary.classcodes <- function(x, ...) {
  writeLines("\nSummary of classcodes object\n")
  writeLines("Recognized codes per group:\n")
  print(x$summary, ...)
  writeLines("\n Use function visualize() for a graphical representation.")
  invisible(x)
}
