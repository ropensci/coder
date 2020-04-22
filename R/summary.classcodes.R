#' Summarizing a classcodes object
#'
#' Classification schemes are formalized by regular expressions within the
#' classcodes objects. These are computationally effective but sometimes hard to
#' grasp. Use this function to present all individual codes identified for each
#' group in the classification.
#'
#' @param object classcodes object
#' @param coding either a vector with codes from the original classification,
#'   or a name (character vector of length one) keyvalue object from package
#'   "decoder" (for example "icd10cm" or "atc")
#' @param ... ignored
#' @param cc_args List of named arguments passed to \code{\link{set_classcodes}}
#'
#' @return List (invisible) with objects:
#'
#' \itemize{
#'   \item{\code{object}: input \code{object}}
#'   \item{\code{summary}: a data frame with columns:
#'      \itemize{
#'     \item{\code{group}: Groups identified by \code{object}.}
#'     \item{\code{n}: The number of codes to be recognized for each group.}
#'     \item{\code{codes}: Individual codes within each group.}
#'     }
#'   }
#'   \item{\code{coding}: input \code{coding}}
#' }
#' @export
#' @seealso \code{\link{visualize}} for a graphical representation of the
#'   classcodes objects.
#' @family classcodes
#'
#' @examples
#' summary(elixhauser, coding = "icd10cm")
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
    list(object = object, summary = res, coding = coding, codes_vct = codes_vct),
    class = "summary.classcodes"
  )
}

#' Print summary for classcodes object
#'
#' @param x object of class \code{\link{summary.classcodes}}
#' @param n_print maximum characters to print from the \code{codes} column
#' @param ... ignored
#'
#' @return Nothing. This function is called for its side effects
#' @export
#' @family classcodes
#' @examples
#' print(summary(elixhauser, coding = "icd10cm"))
print.summary.classcodes <- function(x, n_print = 50, ...) {

  # List of indices used by the object
  indices <- attr(x$object, "indices")
  indices <-
    if (is.null(indices))
       "(Sum of categories)"
    else paste(indices, collapse = ", ")

  # Print message
  cat("Indices:", indices, "\n\n")
  if (!is.null(x$summary)) {
    cat("Recognized codes per group:\n\n")
    x$summary$codes <-
      ifelse(
        nchar(x$summary$codes) <= n_print,
        x$summary$codes,
        paste(substr(x$summary$codes, 1, n_print), "...")
      )
    print(x$summary, right = FALSE, justify = "left", row.names = FALSE)
  }
  cat("\n Use function visualize() for a graphical representation.\n\n")
}
