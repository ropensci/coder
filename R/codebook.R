#' Make codebook for classcodes object
#' @inheritParams summary.classcodes
#' @param file name of Excel file for data export
#' @inheritDotParams summary.classcodes
#'
#' @return List of data frames describing relationship
#' between groups and individual codes
#' @seealso codebooks
#' @export
#' @family classcodes
#' @examples
#' # All codes from ICD-10-CM used by Elixhauser
#' codebook(elixhauser, "icd10cm")
#'
#' # All codes from ICD-9-CM Disease part used by Elixhauser enhanced version
#' codebook(elixhauser, "icd9cmd",
#'   cc_args = list(regex = "regex_icd9cm_enhanced")
#' )
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

  cb <- list(readme = readme, summary = s, all_codes = all_codes)
  fileif(cb, file)
}

#' Print codebook
#'
#' Print a preview of sheets otherwise exported to Excel
#'
#' @param x object of class [codebook]
#' @param ... arguments passed to `tibble:::print.tbl()`
#'
#' @return `x` (invisible)
#'
#' @export
#' @examples
#' codebook(charlson, "icd10cm")
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


#' Combine codebooks for classcodes objects
#'
#' @param ... named output from [codebook()]
#' @param file name of Excel file for data export
#'
#' @return Concatenated list with output from [codebook()].
#' Only one 'README' object is kept however and renamed as such.
#' @export
#' @seealso codebook
#' @family classcodes
#' @examples
#' c1 <- codebook(elixhauser, "icd10cm")
#' c2 <- codebook(elixhauser, "icd9cmd",
#'   cc_args = list(regex = "regex_icd9cm_enhanced")
#'   )
#' codebooks(elix_icd10 = c1, elix_icd9cm = c2)
codebooks <- function(..., file = NULL) {
  cbs <- unlist(list(...), FALSE)
  rdm <- grep(".readme", names(cbs))
  cbs <- cbs[-rdm[-1]] # Rm all readmes except the first
  names(cbs) <- gsub("(.*)(\\.readme)", "README", names(cbs))
  fileif(cbs, file)
}


# Helper to export to file ----------------------------------------------------
fileif <- function(x, file = NULL) {
  out <- structure(x, class = "codebook")
  if (!is.null(file)) {
    writexl::write_xlsx(x, file)
    invisible(out)
  } else {
    out
  }
}
