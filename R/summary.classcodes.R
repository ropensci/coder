#' Summarizing a classcodes object
#'
#' Classification schemes are formalized by regular expressions within the
#' classcodes objects. These are computationally effective but sometimes hard to
#' grasp. Use this function to present all individual codes identified for each
#' group in the classification.
#'
#' @param object classcodes object
#' @param coding name (as character) of classification used for coding
#'   (for example "icd10" or "atc")
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
#' summary(elixhauser, coding = "icd10")
summary.classcodes <- function(object, coding, ..., cc_args = list()) {

  # Identify code value set as specified
  cl <- try(get(coding), TRUE)

  # Make summary table if such code value set exist
  if (class(cl) == "try-error") {
    res <- NULL
  } else {

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

    # Result data frame
    res <-
      data.frame(
        group            = names(codes),
        n                = c(table(nms)),
        codes            = codes,
        row.names        = seq_along(codes),
        stringsAsFactors = FALSE
      )
  }

  structure(list(object = object, summary = res, coding = coding), class = "summary.classcodes")
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
#' print(summary(elixhauser, coding = "icd10"))
print.summary.classcodes <- function(x, n_print = 50, ...) {

  # List of indices used by the object
  indices <- attr(x$object, "indices")
  indices <-
    if (is.null(indices))
       "(Sum of categories)"
    else paste(indices, collapse = ", ")

  # Print message
  cat("\nBased on coding:", x$coding, "\n")
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
