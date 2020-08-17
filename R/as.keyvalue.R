#' Make keyvalue object from classcodes object
#'
#' S3-method for generic [decoder::as.keyvalue()]
#'
#' @param x classcodes object
#' @inheritParams summary.classcodes
#' @param ... arguments passed to [summary.classcodes()]
#'
#' @importFrom decoder as.keyvalue
#' @export
#' @family helper
#' @examples
#' # List all codes with corresponding classes as recognized by the Elixhauser
#' # comorbidity classification according to the Swedish version of the
#' # international classification of diseases version 10 (ICD-10-SE)
#' as.keyvalue(elixhauser, "icd10se")
as.keyvalue.classcodes <- function(x, coding, ...) {
  decoder::as.keyvalue(summary(x, coding, ...)$codes_vct)
}
