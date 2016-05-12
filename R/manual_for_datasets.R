#' Classcodes for Elixhauser based on ICD-10 codes
#'
#' A \code{\link{classcodes}} object to use with \code{\link{classify}}
#'
#' @format A data frame with 31 rows and 2 variables:
#' \describe{
#'   \item{group}{comorbidity groups}
#'   \item{regex}{regular expressions identifying ICD-10 codes of each group}
#' }
#' @source Quan Hude et. al. (2005). Coding algorithms for defining comorbidities
#' in ICD-9-CM and ICD-10 administrative data. Medical care, 1130-1139.
#' \url{www.jstor.org/stable/3768193}
"elix_icd10"



#' Classcodes for Charlson based on ICD-10 codes
#'
#' A \code{\link{classcodes}} object to use with \code{\link{classify}}
#'
#' @format A data frame with 17 rows and 2 variables:
#' \describe{
#'   \item{group}{comorbidity groups}
#'   \item{regex}{regular expressions identifying ICD-10 codes of each group}
#' }
#' @source Quan Hude et. al. (2005). Coding algorithms for defining comorbidities
#' in ICD-9-CM and ICD-10 administrative data. Medical care, 1130-1139.
#' \url{www.jstor.org/stable/3768193}
"charlson_icd10"




#' Classcodes for the comorbidity-polypharmacy score (CPS) based on ICD-10 codes
#'
#' A \code{\link{classcodes}} object to use with \code{\link{classify}}
#'
#' @format A data frame with 2 rows and 2 variables:
#' \describe{
#'   \item{group}{comorbidity groups, either "ordinary" for most ICD-10-codes or
#'   "special" for codes beginning with "UA", "UB" and "UP"}
#'   \item{regex}{regular expressions identifying ICD-10 codes of each group}
#'   \item{w}{index weights, 1 for ordinary and 0 for special}
#' }
#' @source Stawicki, Stanislaw P., et al.
#' "Comorbidity polypharmacy score and its clinical utility: A pragmatic
#' practitioner's perspective." Journal of emergencies, trauma, and shock 8.4 (2015): 224.
#' \url{http://www.ncbi.nlm.nih.gov/pmc/articles/PMC4626940/}
"cps_icd10"





#' Classcodes for adverse events after hip arthoplasty based on ICD-10 codes
#'
#' A \code{\link{classcodes}} object to use with \code{\link{classify}}
#'
#' @format A data frame with 2 rows and 3 variables:
#' \describe{
#'   \item{group}{either "vascular desease" or "luxation"}
#'   \item{regex}{regular expressions identifying ICD-10 codes of each group}
#'   \item{condition}{"vascular desease" is conditioned on ICD-10 code originating from
#'   main diagnosis (variable "hdia")}
#' }
"hip_adverse_events_icd10"