#' @import data.table
NULL


#' Decide if large objects should be copied
#'
#' @param x object (potentially of large size)
#' @param .copy Should the object be copied internally by [data.table::copy()]?
#' `NA` (by default) means that objects smaller than 1 GB are copied.
#' If the size is larger, the argument must be set explicitly. Set `TRUE`
#' to make copies regardless of object size. This is recommended if enough RAM
#' is available. If set to `FALSE`, calculations might be carried out
#' but the object will be changed by reference.
#'
#' @return Either `x` unchanged, or a fresh copy of `x`.
#' @keywords internal
copybig <- function(x, .copy = NA) {
  # Copy x if < 1 GB
  # Require explicit specification for large objects
  # To calculate object size is slow and therefor only done if needed
  if (isTRUE(.copy) ||
    (is.na(.copy) && !(big_x <- utils::object.size(x) > 2 ^ 30))) {
    x2 <- data.table::copy(x)
    setnames(x2, names(x), copy(names(x)))
    return(x2)
  } else if (is.na(.copy) && big_x) {
    stop("Object is > 1 GB. Set argument 'copy' to TRUE' or FALSE ",
         "to declare wether it should be copied or changed by reference!")
  } else {
    return(x)
  }
}

#' Convert SPSS date to valid date
#'
#' Dates from SPSS are stored as seconds from 1582-10-14.
#' We convert to days from 1970-01-01
#'
#' @param x SPSS date
#' @return Date
#' @family helper
#' @keywords internal
spss2date <- function(x) {
  as.Date(x / 86400, origin = "1582-10-14")
}


clean <- function(x) gsub("\\W", "_", tolower(x), perl = TRUE)

#' Make clean text with only lowercase alphanumeric characters and "_"
#'
#' @param x_name Name of object to use as prefix
#' @param x character vector
#'
#' @return character vector of the same length as \code{x}
#' @keywords internal
clean_text <- function(x_name, x) {
  if (!is.character(x_name)) {
    stop("Object ", deparse(substitute(x_name)),
         " must be refferred by name if 'tech_names = TRUE'!",
         call. = FALSE
    )
  }
   paste(x_name, clean(x), sep = "_")
}


#' Return all columns from x with names matching "find"
#'
#' @param find character vector with names to match
#' @param x matrix
#' @keywords internal
cols <- function(find, x) {
  find <- clean(find)
  nms <- clean(colnames(x))
  x[, c(lapply(find, grep, nms), recursive = TRUE), drop = FALSE]
}

# Get data from decoder package
decoder_data <- function(x) {
  dts <- utils::data(package = "decoder")$results[, "Item"]
  if (x %in% dts) {
    e <- environment()
    utils::data(list = x, package = "decoder", envir = e)
    get0(x, e)
  } else {
    stop("'coding' should be one of: ", paste(dts, collapse = ", "))
  }
}




print_tibble <- function(x, ..., n = 10) {
  if (!is.null(n)) {
    writeLines(
      paste0("\nThe printed data is of class: ",
             paste(class(x), collapse = ", "),
             ". It has ", nrow(x), " rows.",
             "\nIt is here previewed as a tibble",
             "\nUse `print(x, n = NULL)` to print as is ",
             "(or use `n` to specify the number of rows to preview)!\n\n"
      )
    )
    print(tibble::as_tibble(utils::head(x, n)))
  } else {
    NextMethod()
  }
}