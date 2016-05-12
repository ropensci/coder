#' Classify elements
#'
#' @param x object with elements to classify
#' @param by classification scheme of type \code{classcodes} to classify by
#' @param code name (as character) of variable in \code{x} containing codes to classify
#' @param id name (as character) of variable in \code{x} to
#' group id (for example a patient id)
#' @param drop drop cases that does not belong to any class
#'
#' @return Boolean matrix with one row for each element/row of \code{x} and columns
#' for each class with corresponding class names (according to the
#' \code{\link{classcodes}} object).
#'
#' Note that row order is
#' not preserved for \code{classify.data.frame}.
#'
#' Row names identify origin (as specified id argument \code{id} for
#' \code{classify.data.frame} or simply as \code{x} itself for
#' \code{classify.default}.
#'
#' @export
#' @name classify
#'
#' @examples
#' # Classify individual ICD10-codes by Elixhauser
#' classify(c("C80", "I20", "XXX"), by = "elix_icd10")
#'
#' # Classify patients by Charlson
#' codify(ex_people, ex_icd10, id = "name", date = "surgery") %>%
#' classify("charlson_icd_10")
classify <- function(x, by, ...) UseMethod("classify")

#' @export
#' @rdname classify
classify.default <- function(x, by, ...) {
  .by <- by
  by <- get_classcodes(by)
  y <- vapply(by$regex, grepl, logical(length(x)), as.character(x))
  if (length(x) == 1) y <- as.matrix(t(y))
  colnames(y) <- by$group
  rownames(y) <- x
  attr(y, "classcodes") <- .by
  y
}

#' @export
#' @rdname classify
classify.data.frame <- function(x, by, id = NULL, code = "code", drop = FALSE, ...) {

  .by <- by
  by <- get_classcodes(by)

  # Adjust column names of x
  id <-
    if (is.null(id) & !is.null(attr(x, "id"))) attr(x, "id")
    else if (is.character(id)) id
    else if (is.null(id) & "id" %in% names(x)) "id"
    else stop("Argument 'id' must be specified!")
  stopifnot(all(c(id, code) %in% names(x)))
  nms <- names(x)
  nms[nms == id]   <- "id"
  nms[nms == code] <- "code"
  names(x) <- nms

  # Special tratment for codes not belonging to any class (for speed up)
  # Make FALSE matrix for all these cases
  # and for NA cases, which should remain NA
  i_nocl           <- !is.na(x$code) & !grepl(paste(by$regex, collapse = "|"), x$code)
  i_na             <- is.na(x$code)
  if (!drop) {
    nocl           <- matrix(FALSE, sum(i_nocl), nrow(by))
    rownames(nocl) <- x$id[i_nocl]

    nacl           <- matrix(NA, sum(i_na), nrow(by))
    rownames(nacl) <- x$id[i_na]

    nocl           <- rbind(nocl, nacl)
    colnames(nocl) <- by$group
  }
  x                <- x[!i_nocl & !i_na, ]

  # Classify all cases with at least one class
  y                <- classify(x$code, by = by)
  rownames(y)      <- x$id

  # Rejoin class cases and no class cases if earlier separated
  if (!drop) y     <- rbind(nocl, y)

  # Identify if unit has more than one code
  id               <- rownames(y)
  uni              <- !id %in% id[duplicated(id)]

  # Case for patients with only one code (for speed)
  clu              <- y[uni, ]
  rownames(clu)    <- id[uni]

  # Case for patients with multilpe (ICD) codes (slower but necessary)
  idx              <- as.factor(id[!uni])
  clm              <- apply(y[!uni, ], 2, Kmisc::tapply_, idx, any)

  # Combine data from cases with one and more classes
  res <- rbind(clu, clm)
  attr(res, "classcodes") <- .by
  res
}
