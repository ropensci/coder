#' Categorize cases based on external data and classification scheme
#'
#' This is the main function of the package, which relies of a triad of objects:
#' (1) `data` with unit id:s and possible dates of interest;
#' (2) `codedata` for corresponding
#' units and with optional dates of interest and;
#' (3) a classification scheme ([`classcodes`] object; `cc`) with regular
#' expressions to identify and categorize relevant codes.
#' The function combines the three underlying steps performed by
#' [codify()], [classify()] and [index()].
#'  Relevant arguments are passed to those functions by
#'  `codify_args` and `cc_args`.
#'
#' @param x data set with mandatory character id column
#'   (identified by argument `id = "<col_name>"`),
#'   and optional [`Date`]  of interest
#'   (identified by argument `date = "<col_name>"`).
#'   Alternatively, the output from [codify()]
#' @param codedata external code data with mandatory character id column
#'   (identified by `id = "<col_name>"`),
#'   code column (identified by argument `code = "<col_name>"`)
#'   and optional [`Date`] column
#'   (identified by `codify_args = list(code_date = "<col_name>")`).
#'  @param id name of unique character id column found in both `x`and `codedata`.
#'  (where it must not be unique).
#'  @param code name of code column in `codedata`.
#' @param index
#'   Argument passed to [index()].
#'   A character vector of names of columns with index weights from the
#'   corresponding classcodes object (as supplied by the `cc`argument).
#'   See `attr(cc, "indices")` for available options.
#'   Set to `FALSE` if no index should be calculated.
#'   If `NULL`, the default, all available indices (from `attr(cc, "indices")`)
#'   are provided.
#' @param codify_args Lists of named arguments passed to [codify()]
#' @param ... arguments passed between methods
#' @param check.names
#'   Column names are based on `cc$group`, which might include
#'   spaces. Those names are changed to syntactically correct names by
#'   `check.names = TRUE`. Syntactically invalid, but grammatically correct
#'   names might be preferred for presentation of the data as achieved by
#'   `check.names = FALSE`. Alternatively, if `categorize` is called repeatedly,
#'   longer informative names might be created by `cc_args = list(tech_names = TRUE)`.
#' @param .data_cols used internally
#' @inheritParams classify
#'
#' @return Object of the same class as `x` with additional logical columns
#'  indicating membership of groups identified by the
#' `classcodes` object (the `cc` argument).
#' Numeric indices are also included if requested by the `index` argument.
#'
#' @export
#'
#' @example man/examples/categorize.R
#' @family verbs
#' @name categorize
categorize <- function(x, ...) UseMethod("categorize")


#' @export
#' @rdname categorize
categorize.data.frame <- function(x, ...) {
  data.frame(categorize(as.data.table(x), ...))
}

#' @export
#' @rdname categorize
categorize.tbl_df <- function(x, ...) {
  tibble::as_tibble(
    categorize(as.data.table(x), ...)
  )
}

#' @export
#' @rdname categorize
categorize.data.table <-
  function(x, ..., codedata, id, code, codify_args = list()) {

    # Store original row order for later sorting
    x$.original_order <- as.numeric(rownames(x))

    codify_args$x        <- x
    codify_args$codedata <- codedata
    codify_args$id       <- id
    codify_args$code     <- code
    cod                  <- do.call(codify, codify_args)

    categorize(cod, ..., id, .data_cols = names(x))
  }


#' @export
#' @rdname categorize
categorize.codified <- function(
  x, ..., cc, index = NULL, cc_args = list(), check.names = TRUE, .data_cols = NULL) {

  # Store original row order for later sorting
  # This is already done for the data.table method but is here set for
  # already codified data as well
  if (!".original_order" %in% names(x)) {
    x$.original_order <- as.numeric(rownames(x))
  }

  codified <- x
  id <- attr(codified, "id")

  if (is.null(.data_cols)) {
    warning(
      "Output might contain extra columns as left-overs from 'codedata'. ",
      "Those should be ignored!"
    )
    .data_cols <- setdiff(names(codified), c("code", "code_date", "in_period"))
  }
  # classify ----------------------------------------------------------------
  cc_args$cc  <- cc_name <- cc
  cc          <- do.call(set_classcodes, cc_args)
  cl          <- classify(codified, cc, cc_args = NULL) # NULL since cc set
  data        <- unique(codified, by = id)[, ...data_cols]
  data$id_chr <- as.character(data[[id]]) # To be able to merge
  out         <- merge(data, as.data.table(cl), by.x = "id_chr", by.y = id)
  id_chr      <- NULL # to avoid check note
  data[, id_chr := NULL] # Don't need it any more

  # index -------------------------------------------------------------------
  if (!identical(index, FALSE)) {
    index_inh <- attr(cc, "indices")
    index <-
      if (is.null(index) && !is.null(index_inh) && length(index_inh) > 0) {
        index_inh
      } else if (is.null(index)) {
        list(NULL)
      } else {
        index
      }
    indx        <- lapply(index, function(x) index(cl, index = x))
    indx        <- as.data.table(as.data.frame(indx), keep.rownames = id)
    ind_names   <- if (identical(index, list(NULL))) "index" else index
    if (!is.null(cc_args$tech_names) && cc_args$tech_names) {
      ind_names <-
        clean_text(
          cc_name,
          paste0(attr(cc, "regex_name"), "_index_",
            # we always want one "index_", not two if index name already prefixed
            gsub("index_", "", ind_names)
          )
        )
    }
    data.table::setnames(indx, setdiff(names(indx), id), ind_names)
    out <- merge(out, indx,  by.x = "id_chr", by.y = id)
  }

  # Make syntactically correct names
  if (check.names) {
    setnames(out, make.names(names(out)))
  }

  data.table::setorderv(out, ".original_order")
  .original_order <- NULL
  out[, .original_order := NULL]
  out[, id_chr := NULL][]
}
