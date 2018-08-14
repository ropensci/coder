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
#' @return Data frame with columns:
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
#' # List all groups with at most 10 codes
#' x <- summary(elix_icd10)
#' x[x$n < 10, ]
summary.classcodes <- function(object, ...) {
  if (is.null(attr(object, "coding"))) {
    stop("Unknown coding. Specify by argument 'coding' in 'as.classcodes'")
  }

  # Identify all possible codes for the relevant coding
  cl <- get(tolower(attr(object, "coding")))
  # Classify each such code according to the classcodes object
  cl <- classify(cl, object, tech_names = TRUE)
  # Kep only the ones that are relevant according to the classification scheme
  cl <- as.data.frame(cl[rowSums(cl) > 0,])

  # Idfentify wich groups the individual codes relate to and get grpup names for these
  indx <- apply(cl, 1, which, useNames = FALSE)
  indx <- c(lapply(indx, stats::setNames, NULL), recursive = TRUE)
  nms <- object$group[indx]

  # Paste all individual codes as comma separated list
  codes <-
    vapply(split(indx, nms), function(x) paste(names(x), collapse = ", "), "")

  # Result data frame
  data.frame(
    group = names(codes),
    n     = c(table(nms)),
    codes = codes,
    row.names = seq_along(codes),
    stringsAsFactors = FALSE
  )
}
