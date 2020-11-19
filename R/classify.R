#' Classify cases based on classcodes
#'
#' @inheritParams set_classcodes
#' @param codified output from [codify()]
#' @param code,id name of code/id columns (in `codified`).
#' @param cc_args List with named arguments passed to
#'   [set_classcodes()]
#' @param ... arguments passed between methods
#'
#' @return Boolean matrix with one row for each element/row of `codified`
#'   and columns for each class with corresponding class names (according to the
#'   [`classcodes`] object).
#'
#' @seealso [as.data.frame.classified()] for a convenience function to
#' convert the output of [classify()] to a data frame with id column instead
#' of row names.
#'
#' @export
#' @name classify
#' @example man/examples/classify.R
#' @family verbs
classify <- function(codified, cc, ..., cc_args = list()) {
  UseMethod("classify")
}

# Default method ----------------------------------------------------------

#' @export
#' @rdname classify
classify.default <- function(codified, cc, ..., cc_args = list()) {
  .cc <- cc

  if (!is.null(cc_args) | !is.classcodes(cc)) {
    ccargs <- cc_args
    ccargs$cc <- cc
    cc  <- do.call(set_classcodes, ccargs)
  }

  y <-
    vapply(
      cc[[attr(cc, "regexpr")]],
      grepl,
      logical(length(codified)),
      x = as.character(codified)
    )

  structure(
    if (length(codified) == 1) as.matrix(t(y)) else y,
    dimnames   = list(codified, cc$group),
    classcodes = .cc,
    id         = "id",
    class      = c("classified", "matrix")
  )
}


# codified ----------------------------------------------------------------

#' @export
#' @rdname classify
classify.codified <- function(codified, ...) {

  if (methods::hasArg("id") || methods::hasArg("code")) {
    stop("Arguments `id` and `code` should not be specified in `classify` if
         already set by a previous call to `codify`!")
  }

  classify.data.table(
    codified, ...,
    id = attr(codified, "id"), code = attr(codified, "code")
  )
}


# data.frame --------------------------------------------------------------

#' @export
#' @rdname classify
classify.data.frame <- function(codified, ...) {
  classify(as.data.table(codified), ...)
}


# data.table --------------------------------------------------------------

#' @export
#' @rdname classify
classify.data.table <- function(
  codified, cc, ..., id, code, cc_args = list()) {

  if (!is.character(codified[[id]]))
    stop("Id column '", id, "' must be of type character!")

  # Warning if not called from categorize
  if (!any(grepl("(coder)?categorize",
                 vapply(sys.calls(), function(x) deparse(x[[1]])[[1]], "")))) {
    warning(
      "'classify()' does not preserve row order ('categorize()' does!)"
      , call. = FALSE
    )
  }

  cc_name <- cc
  # Do not reset cc if already set from categorize
  if (!is.null(cc_args) | !is.classcodes(cc)) {
    ccargs <- cc_args
    ccargs$cc <- cc
    cc <- do.call(set_classcodes, ccargs)
  }
  names(codified)[names(codified) == code] <- "code"

  # Codes without class (treated separately for speed): FALSE matrix
  i_nocl           <- !is.na(codified$code) &
                      !grepl(paste(cc[[attr(cc, "regexpr")]],
                                   collapse = "|"), codified$code)
  i_na             <- is.na(codified$code)
  nocl             <- matrix(FALSE, sum(i_nocl), nrow(cc))
  rownames(nocl)   <- codified[[id]][i_nocl]
  nacl             <- matrix(NA, sum(i_na), nrow(cc))
  rownames(nacl)   <- codified[[id]][i_na]
  nocl             <- rbind(nocl, nacl)
  colnames(nocl)   <- cc$group
  codified         <- codified[!i_nocl & !i_na, ]

  # Classify all cases with at least one class
  y                <- classify(codified$code, cc, cc_args = NULL)
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


# Evaluate extra conditions -----------------------------------------------

eval_condition <- function(cond, x) {
  e <- simpleError(
    "Classification is conditioned on variables not found in the data set!")
  if (is.na(cond)) !logical(nrow(x))
  else tryCatch(eval(parse(text = cond), envir = x), error = function(e) stop(e))
}


# Convert output to data.frame --------------------------------------------

#' Convert output from classify() to matrix/data.frame/data.table
#'
#' @param x output from [classify()]
#' @param ... ignored
#' @return data frame/data table with:
#'
#' - first column named as "id" column specified as input
#'   to [classify()] and with data from `row.names(x)`
#' - all columns from `classified`
#' - no row names
#'
#' or simply the input matrix without additional attributes
#'
#' @export
#' @family classcodes
#' @examples
#' x <- classify(c("C80", "I20", "unvalid_code"), "elixhauser")
#'
#' as.matrix(x)
#' as.data.frame(x)
#' data.table::as.data.table(x)
#'
#' # `as_tibble()` works automatically due to internal use of `as.data.frame()`.
#' tibble::as_tibble(x)
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

#' @export
#' @rdname as.data.frame.classified
as.matrix.classified <- function(x, ...) {
  class(x) <- setdiff("classified", class(x))
  mostattributes(x) <- NULL
  x
}


# print classified --------------------------------------------------------

#' Printing classified data
#'
#' Preview first `n` rows as tibble
#'
#' @param x output from [classify()]
#' @param ... additional arguments passed to printing method for a `tibble`.
#'    `n` is the number of rows to preview. Set `n = NULL` to disable the `tibble`
#'    preview and print the object as is (a matrix).
#' @export
#' @family classcodes
#' @examples
#' # Preview all output
#'classify(c("C80", "I20", "unvalid_code"), "elixhauser")
#'
#'# Preview only the first row
#' print(classify(c("C80", "I20", "unvalid_code"), "elixhauser"), n = 1)
#'
#' # Print object as is (matrix)
#' print(classify(c("C80", "I20", "unvalid_code"), "elixhauser"), n = NULL)
print.classified <- function(x, ...) {
  print_tibble(x, ...)
}
