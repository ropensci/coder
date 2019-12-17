#' Classify elements
#'
#' This is the main functions of the package, performing the actual
#' classification of cases. It is often used with output from
#' \code{\link{codify}} as input and is sometimes followed by the
#' \code{\link{index}} function. These three function could easily be chained
#' together if using the magrittr pipe (\code{\%>\%}).
#'
#'  Note that row order is not preserved for \code{classify.data.frame} due to
#'  performance reasons (the function is intended to work with large data sets
#'  where sorting is computationally expensive).
#'
#'  Row names does however identify origin (as specified by \code{id} for
#'  \code{classify.data.frame} or simply as \code{x} itself for
#'  \code{classify.default}. It should therefore be possible to manually
#'  reorder the output to maintain original order.
#'
#'
#' @param codified object with elements to classify (often the output from
#'   \code{\link{codify}})
#' @inheritParams set_classcodes
#' @param ... arguments passed between methods
#' @param code name (as character) of variable in \code{x} containing codes to
#'   classify
#' @param id name (as character) of variable in \code{x} to group id (for
#'   example a patient id).
#' @param cc_args List with named arguments passed to \code{\link{set_classcodes}}
#'
#'
#' @return Boolean matrix with one row for each element/row of \code{x} and
#'   columns for each class with corresponding class names (according to the
#'   \code{\link{classcodes}} object).
#'
#' @seealso \code{\link{as.data.frame.classified}} for a convenience function to
#' convert the output of \code{classify} to a data frame with id column instead
#' of row names.
#'
#' @export
#' @name classify
#'
#' @examples
#' # Classify individual ICD10-codes by Elixhauser
#' classify(c("C80", "I20", "unvalid_code"), "elixhauser")
#'
#' # Classify patients by Charlson for comorbidities during
#' # one year before surgery
#' x <- codify(ex_people, ex_icd10, id = "name",
#'   date = "surgery", days = c(-365, 0))
#' y <- classify(x, "charlson")
#'
#' # Use tha RCS classification instead and use technical column names
#' y <- classify(x, "charlson", cc_args = list(regex = "icd10_rcs", tech_names = TRUE))
#'
#' # It is possible to convert the outpot of classify to a data frame with
#' # id column instead of row names
#' as.data.frame(y)
#' @family verbs
classify <- function(codified, cc, ..., cc_args = list()) UseMethod("classify")

# Help function to evaluate possible extra conditions from a classcodes object
# Three posibilites exists
# 1. The condition is just TRUE or NA => no evaluation needed,
#    should be included
# 2. Evaluation depends on other variables of x => evaluate
# 3. dependent variables missing => stop
eval_condition <- function(cond, x) {
  if (is.na(cond))
    !logical(nrow(x))
  else
    tryCatch(
      eval(parse(text = cond), envir = x),
        error = function(e)
          stop("Classification is conditioned on variables ",
               "not found in the data set!", call. = FALSE)
    )
}

#' @export
#' @rdname classify
classify.default <- function(codified, cc, ..., cc_args = list()) {
  cc_args$cc <- .cc <- cc
  cc  <- do.call(set_classcodes, cc_args)
  y   <- vapply(cc$regex, grepl, logical(length(codified)), x = as.character(codified))
  if (length(codified) == 1)
    y <- as.matrix(t(y))

  structure(
    y,
    dimnames   = list(codified, cc$group),
    classcodes = .cc,
    id         = "id",
    class      = c("classified", "matrix")
  )
}

#' @export
#' @rdname classify
classify.data.frame <- function(codified, cc, ..., id = NULL, code = "code", cc_args = list()) {

  warning("'classify' does not preserve row order (use 'categorize' to do so!)")

  cc_args$cc <- cc_name <- cc
  cc <- do.call(set_classcodes, cc_args)

  # The id column can be identified in multiple ways
  id <-
    if (is.null(id) & !is.null(attr(codified, "id"))) attr(codified, "id")
    else if (is.character(id)) id
    else if (is.null(id) & "id" %in% names(codified)) "id"
    else stop("Argument 'id' must be specified!")
  if (!id %in% names(codified))
    stop(id, " should specify case id but is not a column of x!")
  if (!code %in% names(codified))
    stop(code, " should specify codes but is not a column of x!")

  # Rename columns in x to standard names
  names(codified)[names(codified) == code] <- "code"

  # Special tratment for codes not belonging to any class (for speed up)
  # Make FALSE matrix for all these cases
  # and for NA cases, which should remain NA
  i_nocl           <- !is.na(codified$code) &
                      !grepl(paste(cc$regex, collapse = "|"), codified$code)
  i_na             <- is.na(codified$code)
  nocl             <- matrix(FALSE, sum(i_nocl), nrow(cc))
  rownames(nocl)   <- codified[[id]][i_nocl]

  nacl             <- matrix(NA, sum(i_na), nrow(cc))
  rownames(nacl)   <- codified[[id]][i_na]

  nocl             <- rbind(nocl, nacl)
  colnames(nocl)   <- cc$group
  codified                <- codified[!i_nocl & !i_na, ]

  # Classify all cases with at least one class
  y                <- classify(codified$code, cc)
  if ("condition" %in% names(cc))
    y <- y & vapply(cc$condition, eval_condition, logical(nrow(codified)), x = codified)
  rownames(y)      <- codified[[id]]

  # Rejoin class cases and no class cases
  y                <- rbind(nocl, y)

  # Identify if unit has more than one code
  ids              <- rownames(y)
  uni              <- !ids %in% ids[duplicated(ids)]

  # Case for patients with only one code (for speed)
  clu              <- y[uni, , drop = FALSE]
  rownames(clu)    <- ids[uni]

  # Case for patients with multilpe (ICD) codes (slower but necessary)
  idx              <- as.factor(ids[!uni])
  # tply is a simplified and therefore faster version of tapply
  tply             <- function(X) unlist(lapply(split(X, idx), any))
  clm              <- apply(y[!uni, , drop = FALSE], 2, tply)
  # apply returns a vector in casae we have only one patient.
  # We then lose the rowname and have to turn it back
  if (is.vector(clm)) {
    clm <- matrix(clm, 1, dimnames = list(idx[1]))
  }

  # Combine data from cases with one and more classes
  out <- rbind(clu, clm)

  structure(
    out,
    classcodes = cc_name,
    id         = id,
    class      = c("classified", "matrix")
  )
}
