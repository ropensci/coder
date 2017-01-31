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
#' @param x object with elements to classify (often the output from
#' \code{\link{codify}})
#' @param by classification scheme of type \code{classcodes} to classify by
#' @param code name (as character) of variable in \code{x} containing codes to
#'   classify
#' @param id name (as character) of variable in \code{x} to group id (for
#'   example a patient id)
#' @param ... used to pass arguments between methods
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
#' classify(c("C80", "I20", "unvalid_code"), by = "elix_icd10")
#'
#' # Classify patients by Charlson for comorbidities during
#' # one year before surgery
#' x <- codify(ex_people, ex_icd10, id = "name",
#'   date = "surgery", days = c(-365, 0))
#' (y <- classify(x, "charlson_icd10"))
#'
#' # It is possible to convert the outpot of classify to a data frame with
#' # id column instead of row names
#' as.data.frame(y)
classify <- function(x, by, ...) UseMethod("classify")

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
classify.default <- function(x, by, ...) {
  .by <- by
  by  <- get_classcodes(by)
  y   <- vapply(by$regex, grepl, logical(length(x)), x = as.character(x))
  if (length(x) == 1)
    y <- as.matrix(t(y))
  structure(
    y,
    dimnames   = list(x, by$group),
    classcodes = .by,
    id         = "id",
    class      = c("classified", "matrix")
  )
}

#' @export
#' @rdname classify
classify.data.frame <-
  function(x, by, id = NULL, code = "code", ...) {

  .by <- by
  by <- get_classcodes(by)

  # The id column can be identified in multiple ways
  id <-
    if (is.null(id) & !is.null(attr(x, "id"))) attr(x, "id")
    else if (is.character(id)) id
    else if (is.null(id) & "id" %in% names(x)) "id"
    else stop("Argument 'id' must be specified!")
  if (!id %in% names(x))
    stop(id, " should specify case id but is not a column of x!")
  if (!code %in% names(x))
    stop(code, " should specify codes but is not a column of x!")

  # Rename columns in x to standard names
  names(x)[names(x) == code] <- "code"

  # Special tratment for codes not belonging to any class (for speed up)
  # Make FALSE matrix for all these cases
  # and for NA cases, which should remain NA
  i_nocl           <- !is.na(x$code) &
                      !grepl(paste(by$regex, collapse = "|"), x$code)
  i_na             <- is.na(x$code)
  nocl             <- matrix(FALSE, sum(i_nocl), nrow(by))
  rownames(nocl)   <- x[[id]][i_nocl]

  nacl             <- matrix(NA, sum(i_na), nrow(by))
  rownames(nacl)   <- x[[id]][i_na]

  nocl             <- rbind(nocl, nacl)
  colnames(nocl)   <- by$group
  x                <- x[!i_nocl & !i_na, ]

  # Classify all cases with at least one class
  y                <- classify(x$code, by = by)
  if ("condition" %in% names(by))
    y <- y & vapply(by$condition, eval_condition, logical(nrow(x)), x = x)
  rownames(y)      <- x[[id]]

  # Rejoin class cases and no class cases
  y                <- rbind(nocl, y)

  # Identify if unit has more than one code
  ids              <- rownames(y)
  uni              <- !ids %in% ids[duplicated(ids)]

  # Case for patients with only one code (for speed)
  clu              <- y[uni, ]
  rownames(clu)    <- ids[uni]

  # Case for patients with multilpe (ICD) codes (slower but necessary)
  idx              <- as.factor(ids[!uni])
  tapplyfun        <- ifep("Kmisc", Kmisc::tapply_, tapply)
  clm              <- apply(y[!uni, ], 2, tapplyfun, idx, any)

  # Combine data from cases with one and more classes
  structure(
    rbind(clu, clm),
    classcodes = .by,
    id         = id,
    class      = c("classified", "matrix")
  )
}
