#' codebook(s) for classcodes object
#'
#' [summary.classcodes()] and [visualize.classcodes()] are used to
#' summarize/visualize classcodes in R. A codebook, on the other hand,
#' is an exported summary
#' saved in an Excel spreadsheet to use in collaboration with non R-users.
#' Several codebooks might be combined into a single Excel document with
#' several sheets (one for each codebook).
#'
#'
#' @inheritParams summary.classcodes
#' @param x output from `codebook()`
#' @param file name/path to Excel file for data export
#' @param ... Additional arguments for each function:
#'
#' - `codebook()`: arguments passed to [summary.classcodes()]
#' - `codebooks()`: multiple named outputs from [codebook()]
#' - `print.codebook()`: arguments passed to `tibble:::print.tbl()`
#'
#' @return
#'
#' Functions are primarily called for their side effects (exporting data to
#' Excel or printing to screen). In addition:
#'
#' - `codebook()`returns list of data frames describing relationship
#'   between groups and individual codes
#' - `codebooks()` returns a concatenated list with output from `codebook()`.
#'   Only one 'README' object is kept however and renamed as such.
#' - `print.codebook()`returns `x` (invisible)
#'
#' @export
#' @family classcodes
#' @example man/examples/codebook.R
#' @name codebook
codebook <- function(object, coding, ..., file = NULL) {

  # Summary tab
  s  <- summary(object, coding, ...)$summary

  # All codes listed
  kv <- decoder_data(coding)
  all_codes <- suppressMessages(as.keyvalue(object, coding, ...))
  all_codes <- tibble::as_tibble(merge(kv, all_codes, by = "key"))
  names(all_codes) <- c("code", "description", "group")

  # Readme tab explaining column names from other tabs
  readme <-
    tibble::tibble(
      tab = c(rep("summary", ncol(s)), rep("all_codes", ncol(all_codes))),
      column = c(names(s), names(all_codes)),
      description = c(
        # Summary
        "Group to categorize by",
        "Number of identified codes contained in this group",
        "Comma separated list of individual codes in group",

        # all_codes
        "Individual code",
        "Description of individual code",
        "Group to categorize by"
      )
    )

  cb <- structure(
    list(readme = readme, summary = s, all_codes = all_codes),
    class = "codebook"
  )

  if (!is.null(file)) {
    writexl::write_xlsx(cb, file)
    message("codebook saved as ", file)
    invisible(cb)
  } else {
    cb
  }

}


#' @export
#' @rdname codebook
print.codebook <- function(x, ...) {
  message(
    "Coodebooks are prefarably exported to Excel using the `file` argument! ",
    "Use `summary.classcodes()` or `visualize()` for interactive summaries!")

  writeLines(
    "Preview of README sheet specifying columns in following sheets:\n")
  print(x$readme, ...)

  writeLines("\n\nPreview of summary sheet:\n")
  print(x$summary, ...)

  writeLines("\n\nPreview of all_codes:\n")
  print(x$all_codes, ...)

  invisible(x)
}


#' @rdname codebook
#' @export
codebooks <- function(..., file = NULL) {
  cbs <- unlist(list(...), FALSE)
  rdm <- grep(".readme", names(cbs))
  cbs <- cbs[-rdm[-1]] # Rm all readmes except the first
  names(cbs) <- gsub("(.*)(\\.readme)", "README", names(cbs))

  if (!is.null(file)) {
    writexl::write_xlsx(cbs, file)
    message("codebooks saved as ", file)
  } else {
    warning(
      "No file specified! List of codebooks (invisable) returned!",
      call. = FALSE
    )
  }
  invisible(cbs)
}
