
#' Make codebook for classcodes object
#' @inheritParams summary.classcodes
#' @param file name of Excel file for data export
#' @inheritDotParams summary.classcodes
#'
#' @return List of data frames describing relationship
#' between groups and individual codes
#' @export
#'
#' @examples
#' # All codes from ICD-10-SE used by Elixhauser
#' codebook(elixhauser, "icd10")
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
  all_codes <- as.keyvalue(object, coding, ...)
  all_codes <- merge(kv, all_codes, by = "key")
  names(all_codes) <- c("code", "description", "group")

  # Readme tab explaining column names from other tabs
  readme <-
    data.frame(
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

  # Export to Excel file if file specified
  if (!is.null(file)) {
    writexl::write_xlsx(cb, file)
    invisible(cb)
  } else {
    cb
  }
}
