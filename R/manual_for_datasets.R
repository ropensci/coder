#' Classcodes for Elixhauser based on ICD-10 codes
#'
#' A \code{\link{classcodes}} object to use with \code{\link{classify}}
#'
#' @format A data frame with 31 rows and 2 variables:
#' \describe{
#'   \item{group}{comorbidity groups}
#'   \item{regex}{regular expressions identifying ICD-10 codes of each group}
#' }
#' @source Quan Hude et. al. (2005). Coding algorithms for defining
#'   comorbidities in ICD-9-CM and ICD-10 administrative data.
#'   Medical care, 1130-1139.
#' \url{www.jstor.org/stable/3768193}
"elix_icd10"



#' Classcodes for Charlson based on ICD-10 codes
#'
#' A \code{\link{classcodes}} object to use with \code{\link{classify}}
#'
#' @format A data frame with 17 rows and 8 variables:
#' \describe{
#'   \item{group}{comorbidity groups}
#'   \item{regex}{regular expressions identifying ICD-10 codes of each group as
#'   decoded from Quan et al. 2005. Note that this classification was not
#'   originally used with all wheights! To simply use this classification table
#'   with weights other than \code{quan_original} and \code{quan_updated} might
#'   therefore not lead to different results than originally intended for each
#'   index.}
#'   \item{charlson}{original wweights as suggested by Charlson et al. 1987*}
#'   \item{deyo_ramano}{weights suggested by Deyo and Romano*}
#'   \item{dhoore}{weights suggested by D'Hoore*}
#'   \item{ghali}{weights suggested by Ghali*}
#'   \item{quan_original}{weights suggested by Quan 2005}
#'   \item{quan_updated}{weights suggested by Quan 2011}
#' }
#'
#' * Weights decoded from Yurkovich et al. 2015.
#'
#' NOTE! Regular expressisions for leukemia and lymphoma not yet implemented!
#'
#' @source Quan Hude et. al. (2005). Coding algorithms for defining
#'   comorbidities in ICD-9-CM and ICD-10 administrative data.
#'   Medical care, 1130-1139.
#' \url{www.jstor.org/stable/3768193}
#'
#' Yurkovich, M., Avina-Zubieta, J. A., Thomas, J., Gorenchtein, M., & Lacaille,
#' D. (2015). A systematic review identifies valid comorbidity indices derived
#' from administrative health data.
#' Journal of clinical epidemiology, 68(1), 3-14.
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
#'   \item{only_ordinary}{index weights, 1 for ordinary and 0 for special}
#' }
#' @source Stawicki, Stanislaw P., et al.
#' "Comorbidity polypharmacy score and its clinical utility: A pragmatic
#' practitioner's perspective." Journal of emergencies, trauma, and shock 8.4
#' (2015): 224.
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
#'   \item{condition}{"vascular desease" is conditioned on ICD-10 code
#'     originating from main diagnosis (variable "hdia")}
#'   \item{shar}{weights as defined by the Swedish Hip Arthroplasty Register}
#'   \item{sos}{weights as defined by
#'     The (Swedish) National Board of Health and Welfare "Socialstyrelsen"}
#' }
"hip_adverse_events_icd10"




#' Classcodes for RxRiskV (original and modified)
#'
#' \code{\link{classcodes}} object to use with \code{\link{classify}}
#'
#' @format Data frames with 39 rows and 2 variables:
#' \describe{
#'   \item{group}{desease group}
#'   \item{regex}{regular expressions identifying ATC codes of each group}
#' }
#' @name rxriskv
"rxriskv_icd10"

#' @rdname rxriskv
"rxriskv_modified_icd10"



#' Example data for random people
#'
#' Example data for fictive people to use for testing and in examples.
#'
#' @format Data frames with 100 rows and 2 variables:
#' \describe{
#'   \item{name}{random person names}
#'   \item{surgery}{random dates for performed surgery on each patient}
#' }
#'
#' @seealso ex_icd10
"ex_people"



#' Example data for random codes assigned to random people
#'
#' Example data for fictive ICD-10-diagnoses to use for testing and
#' in examlpes.
#'
#' @format Data frames with 1,000 rows and 4 variables:
#' \describe{
#'   \item{id}{Random names corresponding to column \code{name} in dataset
#'     \code{ex_people}}
#'   \item{date}{random dates corresponding to registered (comorbidity) codes}
#'   \item{code}{(comorbidty) codes as given by ICD-10}
#'   \item{hdia}{boolean marker if coresponding code is the main diagnose of
#'     the hospital visit (randomly assigned to 10 percent of the codes)}
#' }
#' @seealso ex_people
"ex_icd10"
