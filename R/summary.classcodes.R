#' Summarizing a classcodes object
#'
#' Classification schemes are formalized by regular expressions within the
#' classcodes objects. These are computationally effective but sometimes hard to
#' grasp. Use this function to present all individual codes identified for each
#' group in the classification.
#'
#' @param object classcodes object
#' @param ... ignored
#'
#' @return Data frame (nivisable) with columns:
#' \describe{
#'   \item{group}{Groups identified by \code{object}.}
#'   \item{n}{The number oif codes to be recognized for each group.}
#'   \item{codes}{Individual codes within each group.}
#' }
#' @export
#' @seealso \code{\link{visualize}} for a graphical representation of the
#'   classcodes objects.
#' @family classcodes
#'
#' @examples
#' summary(ex_carbrands)
summary.classcodes <- function(object, ...) {
  if (is.null(attr(object, "coding"))) {
    stop("Unknown coding. Specify by argument 'coding' in 'as.classcodes'")
  }

  # Identify code value set as specified
  cl <- try(get(tolower(attr(object, "coding"))))

  # Make summary table if such code value set exist
  if (class(cl) == "try-error") {
    res <- NULL
  } else {

    # Classify each such code according to the classcodes object
    cl <- classify(cl, object, tech_names = TRUE)
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
        group = names(codes),
        n     = c(table(nms)),
        codes = codes,
        row.names = seq_along(codes),
        stringsAsFactors = FALSE
      )
  }

  structure(list(object = object, summary = res), class = "summary.classcodes")
}

#' Print summary for classcodes object
#'
#' @param x object of class \code{\link{summary.classcodes}}
#' @param ... ignored
#'
#' @return Nothing. This function is called for its side effects
#' @export
#'
#' @examples
#' print(summary(ex_carbrands))
print.summary.classcodes <- function(x, ...) {

  # List of indices used by the object
  indices <- attr(x$object, "indices")
  indices <-
    if (is.null(indices))
       "(Sum of categories)"
    else paste(indices, collapse = ", ")

  # Print message
  if (!is.null(attr(x$object, "description")))
    cat("\n", attr(x$object, "description"), "\n")
  cat("\nBased on coding:", attr(x$object, "coding"), "\n")
  cat("Indices:", indices, "\n\n")
  if (!is.null(x$summary)) {
    cat("Recognized codes per group:\n\n")
    print(x$summary, right = FALSE, justify = "left", row.names = FALSE)
  }
  cat("\n Use function visualize() for a graphical representation.\n\n")
}
