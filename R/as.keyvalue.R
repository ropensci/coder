#' Make keyvalue object from classcodes object
#'
#' S3-method for generic [decoder::as.keyvalue()]
#'
#' @param x classcodes object
#' @inheritParams summary.classcodes
#'
#' @return
#'   Object of class `keyvalue` where `key` is the subset of codes from
#'   `object$key`identified by the regular expression from `x` and where
#'   `value` is the corresponding `x$group`. Hence, note that the original
#'   `object$value` is not used in the output.
#'
#' @importFrom decoder as.keyvalue
#' @export
#' @family helper
#' @examples
#' # List all codes with corresponding classes as recognized by the Elixhauser
#' # comorbidity classification according to the Swedish version of the
#' # international classification of diseases version 10 (ICD-10-SE)
#' head(decoder::as.keyvalue(elixhauser, "icd10se"))
#'
#' # Similar but with the American ICD-10-CM instead
#' # Note that the `value` column is similar as above
#' # (with names from `x$group`) and not
#' # from `object$value`
#' head(decoder::as.keyvalue(elixhauser, "icd10cm"))
#'
#' # Codes identified by regular expressions based on ICD-9-CM and found in
#' # the Swedish version of ICD-9 used within the national cancer register
#' # (thus, a subset of the whole classification).
#' head(
#'   decoder::as.keyvalue(
#'     elixhauser, "icd9",
#'     cc_args = list(regex = "icd9cm")
#'   )
#' )
as.keyvalue.classcodes <- function(x, coding, cc_args = list()) {
  decoder::as.keyvalue(summary(x, coding, cc_args = cc_args)$codes_vct)
}
