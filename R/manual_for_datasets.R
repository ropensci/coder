#' Classcodes for Elixhauser based on ICD-codes
#'
#' A \code{\link{classcodes}} object to use with \code{\link{classify}}.
#'
#' Solid tumors are subordinate to metastatic cancer. A patient with both
#' conditions will still be classified as such, although a possible (weighted)
#' index value will only account for the metastatic cancer. The same is true for
#' "diabetes uncomplicated", which is subordinate of "diabetes complicated".
#' See Elixhauser et al. (1998).
#'
#' @format A data frame with 31 rows and 8 variables:
#' \describe{
#'   \item{group}{comorbidity groups}
#'   \item{regex}{regular expressions identifying ICD-10 codes of each group.
#'     Corresponds to column 'ICD-10' in table 2 of Quan et al. (2005).}
#'   \item{regex_short}{regular expressions identifying only the first three
#'   characters of ICD-10 codes of each group. This alternative version was
#'   added only to use in emergency when only the first three digits are available.
#'   It is not an official version and we do not recommend to use it!}
#'   \item{regex_icd9cm}{Corresponds to column 'Elixhauser's Original ICD-9-CM'
#'     in table 2 of Quan et al. (2005).}
#'   \item{regex_icd9cm_ahrqweb}{Corresponds to column
#'     'Elixhauser AHRQ-Web ICD-9-CM' in table 2 of Quan et al. (2005).}
#'   \item{regex_icd9cm_enhanced}{Corresponds to column 'Enhanced ICD-9-CM'
#'     in table 2 of Quan et al. (2005).}
#'   \item{sum_all}{all weights = 1 (thus no weights)}
#'   \item{sum_all_ahrq}{as \code{sum_all} excluding "cardiac arrhythmia.
#'     Compare to \code{regex_icd9cm_ahrqweb} which does not
#'     consider this condition.}
#'   \item{walraven}{weights suggested by Walraven et al. (2009)}
#'   \item{sid29}{weights suggested by Thompson et al. (2015)
#'     based on all conditions except cardiac arrhythmia}
#'   \item{sid30}{weights suggested by Thompson et al. (2015)
#'     based on all conditions}
#'  \item{ahrq_mort}{weights for in-hospital mortality suggested by
#'    Moore et al. (2017)}
#'  \item{ahrq_readm}{weights for readmissions suggested by
#'    Moore et al. (2017)}
#' }
#'
#' @references
#'
#' Quan Hude et al. (2005). Coding algorithms for defining
#'   comorbidities in ICD-9-CM and ICD-10 administrative data.
#'   Medical care, 1130-1139.
#'   \url{www.jstor.org/stable/3768193}
#'
#' Walraven, C. Van, Austin, P. C., Jennings, A., Quan, H., Alan, J., Walraven,
#'   C. Van, … Jennings, A. (2009).
#'   A Modification of the Elixhauser Comorbidity Measures Into a Point System
#'   for Hospital Death Using Administrative Data.
#'   Medical Care, 47(6), 626–633.
#'
#' Thompson, N. R., Fan, Y., Dalton, J. E., Jehi, L., Rosenbaum, B. P.,
#'   Vadera, S., & Griffith, S. D. (2015).
#'   A new Elixhauser-based comorbidity summary measure to predict in-hospital
#'   mortality. Med Care, 53(4), 374–379.
#'   http://doi.org/10.1097/MLR.0000000000000326
#'
#' Moore, B. J., White, S., Washington, R., Coenen, N., & Elixhauser, A. (2017).
#'   Identifying Increased Risk of Readmission and In-hospital Mortality Using
#'   Hospital Administrative Data.
#'   Medical Care, 55(7), 698–705. http://doi.org/10.1097/MLR.0000000000000735
#'
#' @family default classcodes
"elixhauser"



#' Classcodes for Charlson comorbidity based on ICD-codes
#'
#' A \code{\link{classcodes}} object to use with \code{\link{classify}}
#'
#' @format A data frame with 17 rows and 8 variables:
#' \describe{
#'   \item{group}{comorbidity groups}
#'   \item{description}{Verbal description of codes as described by
#'     Deyo et al. (1992).}
#'   \item{regex}{regular expressions identifying ICD-10 codes of each group as
#'   decoded from Quan et al. 2005. Note that this classification was not
#'   originally used with all weights! To simply use this classification table
#'   with weights other than \code{quan_original} and \code{quan_updated} might
#'   therefore lead to different results than originally intended for each
#'   index.}
#'   \item{regex_icd9cm_deyo}{Codes from table 1 column "Deyo's ICD-9-CM"
#'     in Quan et al. (2005).
#'     Procedure code 38.48 for peripheral vascular disease ignored.}
#'   \item{regex_icd9cm_enhanced}{Codes from table 1 column "Enhanced ICD-9-CM"
#'     in Quan et al. (2005).}
#'   \item{regex_icd10_rcs}{Codification by Armitage (2010).
#'     Note that Peptic ulcer disease is not included.
#'     All liver diseases (including mild) are included in
#'     "moderate or severe liver disease".
#'     All diabetes is included in "diabetes complication"}
#'   \item{regex_icd8_brusselaers}{Back translated version from ICD-10 to
#'     ICD-8 by Brusselaers et al. (2017).
#'     "Moderate and severe liver disease" contains all liver disease and
#'     "diabetes complication" contains all diabetes.}
#'   \item{regex_icd9_brusselaers}{Back translated version from ICD-10 to
#'   ICD-9 by Brusselaers et al. (2017).
#'     "Moderate and severe liver disease" contains all liver disease and
#'     "diabetes complication" contains all diabetes.}
#'   \item{charlson}{original weights as suggested by Charlson et al. (1987)*}
#'   \item{deyo_ramano}{weights suggested by Deyo and Romano*}
#'   \item{dhoore}{weights suggested by D'Hoore*}
#'   \item{ghali}{weights suggested by Ghali*}
#'   \item{quan_original}{weights suggested by Quan (2005)}
#'   \item{quan_updated}{weights suggested by Quan (2011)}
#' }
#'
#' * Weights decoded from Yurkovich et al. (2015).
#'
#' @references
#'  Armitage, J. N., & van der Meulen, J. H. (2010).
#'    Identifying co-morbidity in surgical patients using administrative data
#'    with the Royal College of Surgeons Charlson Score.
#'    British Journal of Surgery, 97(5), 772–781.
#'    \url{http://doi.org/10.1002/bjs.6930}
#'
#'  Brusselaers N, Lagergren J. (2017)
#'    The Charlson Comorbidity Index in Registry-based Research.
#'    Methods Inf Med 2017;56:401–6. doi:10.3414/ME17-01-0051.
#'
#'
#'  Deyo, R. A., Cherkin, D. C., & Ciol, M. A. (1992).
#'    Adapting a clinical comorbidity index for use with ICD-9-CM
#'    administrative databases.
#'    Journal of Clinical Epidemiology, 45(6), 613–619.
#'    \url{https://doi.org/10.1016/0895-4356(92)90133-8}
#'
#' Quan Hude et al. (2005). Coding algorithms for defining
#'   comorbidities in ICD-9-CM and ICD-10 administrative data.
#'   Medical care, 1130-1139.
#' \url{www.jstor.org/stable/3768193}
#'
#' Yurkovich, M., Avina-Zubieta, J. A., Thomas, J., Gorenchtein, M., & Lacaille,
#'   D. (2015). A systematic review identifies valid comorbidity indices derived
#'   from administrative health data.
#'   Journal of clinical epidemiology, 68(1), 3-14.
#'
#' @family default classcodes
"charlson"




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
#' @references
#'
#' Stawicki, Stanislaw P., et al.
#'   "Comorbidity polypharmacy score and its clinical utility: A pragmatic
#'   practitioner's perspective." Journal of emergencies, trauma, and shock 8.4
#'   (2015): 224.
#'   \url{http://www.ncbi.nlm.nih.gov/pmc/articles/PMC4626940/}
#'
#' @family default classcodes
"cps"


#' Classcodes for adverse events after knee and hip arthroplasty based on ICD-10
#' and KVA codes
#'
#' \code{\link{classcodes}} objects to use with \code{\link{classify}}
#'
#' ICD-10 group names are prefixed by two letters as given by the references.
#' Two groups (DB and DM) are split into two due to different conditions.
#'
#' @section Hip fractures:
#' AE codes for hip fractures are based on codes for elective cases but with
#' some additional codes for DM 1 (N300, N308, N309 and N390).
#'
#' @section Conditions:
#' Special conditions apply to all categories.
#' Those require non-standard modifications
#' of the classcodes data prior to categorization.
#'
#' \describe{
#'  \item{hbdia1_hdia}{\code{TRUE} if the code was
#'  given as any type of diagnose during hospital visit for index operation,
#'  or as main diagnose for later visits, otherwise \code{FALSE}}
#'  \item{late_hdia}{\code{TRUE} if the code was
#'  given as main diagnose at a later visit after the index operation,
#'  otherwise \code{FALSE}}
#'  \item{post_op}{\code{TRUE} if the code was
#'  given at a later visit after the index operation, otherwise \code{FALSE}}
#' }
#'
#' @format Data frame with 3 columns:
#' \describe{
#'   \item{group}{Different types of adverse events (see reference section)}
#'   \item{regex}{regular expressions identifying ICD-10 codes for each group}
#'  \item{regex_fracture}{regular expressions for fracture patients.
#'    Essentially the same as \code{regex} but with some additional codes for group "DM1 other"}
#'  \item{regex_kva}{regular expressions identifying KVA codes}
#'   \item{condition}{special conditions are used, see below.}
#' }
#'
#' @references
#'
#'   Magnéli M, Unbeck M, Rogmark C, Rolfson O, Hommel A, Samuelsson B, et al.
#'     Validation of adverse events after hip arthroplasty:
#'     a Swedish multi-centre cohort study.
#'     BMJ Open. 2019 Mar 7;9(3):e023773.
#'     Available from: \url{http://www.ncbi.nlm.nih.gov/pubmed/30850403}
#'
#' @source
#' Knee (p. 83): \url{http://www.myknee.se/pdf/SVK-2016_1.1.pdf}.
#' Hip (p. 149): \url{https://registercentrum.blob.core.windows.net/shpr/r/-rsrapport-2017-S1xKMzsAwX.pdf}
#'
#' @name ae
#' @family default classcodes
#' @seealso hip_ae_hailer
"knee_ae"

#' @rdname ae
"hip_ae"


#' Classcodes for infection and dislocation after hip arthroplasty based on ICD-10
#' and KVA codes
#'
#' \code{\link{classcodes}} objects to use with \code{\link{classify}}.
#'
#' @format Data frame with 3 columns:
#' \describe{
#'   \item{group}{Infection or dislocation}
#'   \item{regex}{regular expressions based on ICD-10}
#'  \item{regex_kva}{regular expressions based on KVA codes}
#' }
#'
#' @seealso ae
#' @family default classcodes
"hip_ae_hailer"


#' Classcodes for RxRisk V based on ATC codes
#'
#' \code{\link{classcodes}} object to use with \code{\link{classify}}.
#' Provided mostly as proof-of-concept. Codes have not been externally
#'   validated and desired implementation might differ over time and by country.
#'
#' @format Data frames with 39 rows and 6 variables:
#' \describe{
#'   \item{group}{medical condition}
#'   \item{regex}{ATC codes from table 1 in Pratt et al. 2018
#'    (ignoring PBS item codes and extra conditions).}
#'   \item{regex_garland}{Modified version by Anne
#'   Garland to resemble medical use in Sweden 2016 (Unpublished).}
#'  \item{regex_caughey}{From appendix 1 in Caughey et al. 2010}
#'  \item{pratt}{Mortality weights from table 1 in Pratt et al. 2018}
#'  \item{sum_all}{Unweighted count of all conditions.}
#' }
#'
#' @references
#' Caughey GE, Roughead EE, Vitry AI, McDermott RA, Shakib S, Gilbert AL.
#'   Comorbidity in the elderly with diabetes:
#'   Identification of areas of potential treatment conflicts.
#'   Diabetes Res Clin Pract 2010;87:385–93.
#'   doi:10.1016/j.diabres.2009.10.019.
#'
#' Pratt NL, Kerr M, Barratt JD, Kemp-Casey A, Kalisch Ellett LM,
#'   Ramsay E, et al.
#'   The validity of the Rx-Risk Comorbidity Index using medicines mapped to
#'   the Anatomical Therapeutic Chemical (ATC) Classification System.
#'   BMJ Open 2018;8.
#'   doi:10.1136/bmjopen-2017-021122.
#'
#' @family default classcodes
"rxriskv"



################################################################################
#                                                                              #
#                              Example data sets                               #
#                                                                              #
################################################################################


#' Example data for can registry
#'
#' Example data for fictive people and their car ownership.
#'
#' @format Data frames with 1,000 rows and 3 variables:
#' \describe{
#'   \item{id}{random person names}
#'   \item{code}{random car models}
#'   \item{code_date}{random dates for car ownership}
#' }
#'
#' @family example data
"ex_cars"


#' Example classcodes object for classification of car brands by their producer
#'
#' @format Data frames with 11 rows and 2 variables:
#' \describe{
#'   \item{group}{Car makers}
#'   \item{regex}{Regular expressions identifying car brands}
#' }
#'
#' @family example data
"ex_carbrands"




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
#' @family example data
"ex_people"



#' Example data for random codes assigned to random people
#'
#' Example data for fictive ICD-10-diagnoses to use for testing and
#' in examples.
#'
#' @format Data frames with 1,000 rows and 4 variables:
#' \describe{
#'   \item{id}{Random names corresponding to column \code{name} in dataset
#'     \code{ex_people}}
#'   \item{date}{random dates corresponding to registered (comorbidity) codes}
#'   \item{code}{(comorbidity) codes as given by ICD-10}
#'   \item{hdia}{boolean marker if corresponding code is the main diagnose of
#'     the hospital visit (randomly assigned to 10 percent of the codes)}
#' }
#' @family example data
"ex_icd10"
