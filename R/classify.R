#' Classify elements
#'
#' @param x object with elements to classify
#' @param classcodes classification scheme of type \code{classcodes}
#' @param code name (as character) of variable in \code{x} containing codes to classify
#' @param by name (as character) of variable in \code{x} to
#' group by (for example a patient id)
#' @param drop drop cases that does not belong to any class
#'
#' @return Boolean matrix with one row for each element/row of \code{x} and columns
#' for each class with corresponding class names (according to the
#' \code{\link{classcodes}} object).
#'
#' Note that row order is
#' not preserved for \code{classify.data.frame}.
#'
#' Row names identify origin (as specified by argument \code{by} for
#' \code{classify.data.frame} or simply as \code{x} itself for
#' \code{classify.default}.
#'
#' @export
#' @name classify
#'
#' @examples
#' # Classify patients using Elixhauser based on ICD10-codes
#' classify(c("C80", "I20", "XXX"))
classify <- function(x, ...) UseMethod("classify")

#' @export
#' @rdname classify
classify.default <- function(x, classcodes = "elix_icd10", ...) {
  if (is.character(classcodes)) classcodes <- get(classcodes)
  y <- vapply(classcodes$regex, grepl, logical(length(x)), as.character(x))
  if (length(x) == 1) y <- as.matrix(t(y))
  colnames(y) <- classcodes$group
  rownames(y) <- x
  y
}

#' @export
#' @rdname classify
classify.data.frame <- function(x, classcodes = "elix_icd10", code = "icd", by = "lpnr", drop = FALSE, ...) {

  # Code is so far adopted to dfs with lpnr and icd
  # stopifnot(is.icd_data(x))
  x <- dplyr::rename_(x, code = code, by = by)

  if (is.character(classcodes)) classcodes <- get(classcodes)

  # Case for patients without any class
  i_nocl           <- !grepl(paste(classcodes$regex, collapse = "|"), x$code)
  if (!drop) {
    nocl_by        <- unique(x$by[i_nocl])
    n              <- length(nocl_by)
    nocl           <- matrix(FALSE, n, nrow(classcodes))
    rownames(nocl) <- nocl_by
    colnames(nocl) <- classcodes$group
  }
  x                <- x[!i_nocl, ]

  # Classify all cases with at least one class
  cl              <- classify(x$code, classcodes = classcodes)
  by              <- x$by
  uni             <- !by %in% by[duplicated(by)]

  # Case for patients with only one (ICD) code
  clu_by          <- as.character(by[uni])
  clu             <- cl[uni, ]
  rownames(clu)   <- clu_by

  # Case for patients with multilpe (ICD) codes
  clm_by          <- as.character(by[!uni])
  clm             <- apply(cl[!uni, ], 2, Kmisc::tapply_, as.factor(clm_by), any)

  # Combine data from all scenarios to one matrix
  y <- rbind(clu, clm)
  if (drop) y else rbind(nocl, y)
}
