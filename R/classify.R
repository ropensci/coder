#' Classify cases based on classcodes
#'
#' @inheritParams set_classcodes
#' @param codified output from \code{\link{codify}})
#' @param code,id name of code/id columns (in \code{codified}).
#' @param cc_args List with named arguments passed to \code{\link{set_classcodes}}
#' @param ... arguments passed between methods
#'
#' @return Boolean matrix with one row for each element/row of \code{codified}
#'   and columns for each class with corresponding class names (according to the
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
#'   date = "event", days = c(-365, 0))
#' y <- classify(x, "charlson")
#'
#' # Use tha RCS classification instead and use technical column names
#' y <- classify(x, "charlson",
#'   cc_args = list(regex = "icd10_rcs", tech_names = TRUE))
#'
#' # It is possible to convert the output of classify to a data frame with
#' # id column instead of row names
#' as.data.frame(y)
#' @family verbs
classify <- function(codified, cc, ..., cc_args = list()) UseMethod("classify")


# Evaluate extra conditions -----------------------------------------------

eval_condition <- function(cond, x) {
  st <- function(e)
    stop("Classification is conditioned on variables ",
         "not found in the data set!", call. = FALSE)
  if (is.na(cond)) !logical(nrow(x))
  else tryCatch(eval(parse(text = cond), envir = x), error = st)
}


# Find id from object -----------------------------------------------------

find_id <- function(obj, id = NULL, code = NULL) {
  id <-
    if (is.null(id) & !is.null(attr(obj, "id"))) attr(obj, "id")
    else if (is.character(id)) id
    else if (is.null(id) & "id" %in% names(obj)) "id"
    else stop("Argument 'id' must be specified!")

  if (!id %in% names(obj))
    stop(id, " should specify case id but is not a column of x!")
  if (!code %in% names(obj))
    stop(code, " should specify codes but is not a column of x!")
  if (!is.character(obj[[id]]))
    stop("Id column '", id, "' must be of type character!")

  id
}


# Default method ----------------------------------------------------------

#' @export
#' @rdname classify
classify.default <- function(codified, cc, ..., cc_args = list()) {
  cc_args$cc <- .cc <- cc
  cc  <- do.call(set_classcodes, cc_args)
  y   <- vapply(
    cc$regex, grepl, logical(length(codified)), x = as.character(codified))

  structure(
    if (length(codified) == 1) as.matrix(t(y)) else y,
    dimnames   = list(codified, cc$group),
    classcodes = .cc,
    id         = "id",
    class      = c("classified", "matrix")
  )
}


# Data frame method -------------------------------------------------------

#' @export
#' @rdname classify
classify.data.frame <- function(
  codified, cc, ..., id = NULL, code = "code", cc_args = list()) {

  # Warning if not called from categorize
  if (!any(grepl("(coder)?categorize",
                 vapply(sys.calls(), function(x) deparse(x[[1]])[[1]], "")))) {
    warning("'classify' does not preserve row order ('categorize' does!)")
  }

  cc_args$cc <- cc_name <- cc
  cc <- do.call(set_classcodes, cc_args)
  id <- find_id(codified, id, code)
  names(codified)[names(codified) == code] <- "code"

  # Codes without class (treated separately for speed): FALSE matrix
  i_nocl           <- !is.na(codified$code) &
                      !grepl(paste(cc$regex, collapse = "|"), codified$code)
  i_na             <- is.na(codified$code)
  nocl             <- matrix(FALSE, sum(i_nocl), nrow(cc))
  rownames(nocl)   <- codified[[id]][i_nocl]
  nacl             <- matrix(NA, sum(i_na), nrow(cc))
  rownames(nacl)   <- codified[[id]][i_na]
  nocl             <- rbind(nocl, nacl)
  colnames(nocl)   <- cc$group
  codified         <- codified[!i_nocl & !i_na, ]

  # Classify all cases with at least one class
  y                <- classify(codified$code, cc)
  if ("condition" %in% names(cc)) {
    y <- y & vapply(cc$condition, eval_condition,
                    logical(nrow(codified)), x = codified)
  }
  rownames(y)      <- codified[[id]]
  y                <- rbind(nocl, y) # Rejoin with no class cases

  # Identify if unit has more than one code
  ids              <- rownames(y)
  uni              <- !ids %in% ids[duplicated(ids)]

  # Cases with only one code (separate for speed)
  clu              <- y[uni, , drop = FALSE]
  rownames(clu)    <- ids[uni]

  # Cases with multiple codes (slower but necessary)
  idx              <- as.factor(ids[!uni])
  # tply is a simplified and therefore faster version of tapply
  tply             <- function(X) unlist(lapply(split(X, idx), any))
  clm              <- apply(y[!uni, , drop = FALSE], 2, tply)
  # apply returns a vector in case we have only one case
  # We then lose the row name and have to turn it back
  if (is.vector(clm)) {
    clm <- matrix(clm, 1, dimnames = list(idx[1]))
  }

  structure(
    rbind(clu, clm),
    classcodes = cc_name,
    id         = id,
    class      = c("classified", "matrix")
  )
}


# Convert output to data.frame --------------------------------------------

#' Convert output matrix from classify to data frame or data.table
#'
#' @param x output from \code{\link{classify}}
#' @param ... ignored
#' @return data frame with:
#' \itemize{
#'   \item{first column named as "id" column specified as input
#'     to \code{\link{classify}} and with data from \code{row.names(x)}}
#'   \item{all columns from \code{classified}}
#'   \item{no row names}
#' }
#'
#' @export
#' @family classcodes
as.data.frame.classified <- function(x, ...) {
  y            <- NextMethod()
  id           <- attr(x, "id")
  y[[id]]      <- row.names(x)
  row.names(y) <- NULL
  y            <- y[, c(id, setdiff(names(y), id))]
  attr(y, "classcodes") <- attr(x, "classcodes")
  y
}


# Convert output to data.table --------------------------------------------

#' @export
#' @rdname as.data.frame.classified
as.data.table.classified <- function(x, ...) {
  structure(
    as.data.table(as.data.frame(x, ...)),
    classcodes = attr(x, "classcodes")
  )
}
