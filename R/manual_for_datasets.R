#' Classcodes for Elixhauser based on ICD-10 codes
#'
#' A \code{\link{classcodes}} object to use with \code{\link{classify}}
#'
#' @format A data frame with 31 rows and 8 variables:
#' \describe{
#'   \item{group}{comorbidity groups}
#'   \item{regex}{regular expressions identifying ICD-10 codes of each group}
#'   \item{sum_all}{all weights = 1. This is included for convenience when
#'   calculating several indices simultainisly}
#'   \item{sum_all_ahrq}{as \code{sum_all} exluding "cardiac arrythmias"}
#'   \item{walraven}{weights suggested by Walraven et al (2009)}
#'   \item{sid29}{weights suggested by Thompson et al. (2015)
#'     based on all conditions except cardian arryrtmias}
#'   \item{sid30}{weights suggested by Thompson et al. (2015)
#'     based on all conditions}
#'  \item{ahrq_mort}{weights for in-hospital mortality suggested by
#'    Moore et al. (2017)}
#'  \item{ahrq_readm}{weights for readmissions suggested by
#'    Moore et al. (2017)}
#' }
#' @source
#'
#' Quan Hude et al. (2005). Coding algorithms for defining
#'   comorbidities in ICD-9-CM and ICD-10 administrative data.
#'   Medical care, 1130-1139.
#'   \url{www.jstor.org/stable/3768193}
#'
#' Walraven, C. Van, Austin, P. C., Jennings, A., Quan, H., Alan, J., Walraven,
#'   C. Van, … Jennings, A. (2009).
#'   A Modification of the Elixhauser Comorbidity Measures Into a Point System
#'   for Hospital Death Using Administrative Data. Medical Care, 47(6), 626–633.
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
"elix_icd10"



#' Classcodes for Charlson based on ICD-10 codes
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
#'   \item{regex_rcs}{Alternative codes seggested by Armitage (2010).
#'     Note that Peptic ulcer disease is not included.
#'     All liver diseases (including mild) are included in
#'     "moderate or severe liver disease".
#'     All diabetes is included in "diabetes complication"}
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
#' @source
#'  Armitage, J. N., & van der Meulen, J. H. (2010).
#'    Identifying co-morbidity in surgical patients using administrative data
#'    with the Royal College of Surgeons Charlson Score.
#'    British Journal of Surgery, 97(5), 772–781.
#'    \url{http://doi.org/10.1002/bjs.6930}
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
#' @family default classcodes
"cps_icd10"


#' Classcodes for adverse events after knee and hip arthroplasty based on ICD-10 and KVA codes
#'
#' \code{\link{classcodes}} objects to use with \code{\link{classify}}
#'
#' Group names are prefixed by two letters as given by the reference.
#' Two groups (DB and DM) are split into two due to different conditions.
#'
#' @section Conditions:
#' Special conditions are used (see the reference):
#'
#' \describe{
#'  \item{hbdia1_hdia}{\code{TRUE} if the code was
#'  given as any type of diagnose at first visit after TKA/THA, or as main diagnose
#'  for later visits, otherwise \code{FALSE}}
#'  \item{late_hdia}{\code{TRUE} if the code was
#'  given as main diagnose at a later visit after TKA/THA, otherwise \code{FALSE}}
#'  \item{post_op}{\code{TRUE} if the code was
#'  given at a later visit after TKA/THA, otherwise \code{FALSE}}
#' }
#'
#' @format Data frame with 3 columns:
#' \describe{
#'   \item{group}{Different types of adverse events (see reference section)}
#'   \item{regex}{regular expressions identifying ICD-10 codes of each group}
#'   \item{condition}{two special conditions are used, see below.}
#' }
#'
#' @references Codes for knee taken from p. 83 of the annual report 2016 from knee
#' arthroplasty register \url{http://www.myknee.se/pdf/SVK-2016_1.1.pdf}.
#' \code{hip.ae_icd10} is a modified version for hips based on
#' \code{knee.ae_icd10}.
#'
#' @aliases hip.ae_icd10 hip.ae_kva knee.ae_kva
#' @family default classcodes
"knee.ae_icd10"




#' Classcodes for adverse events after THA after hip fracture
#' based on ICD-10 codes
#'
#' This classcodes object was developed by the Swedish Hip Arthroplasty Register.
#' The work was initiated for fracture data but the result might be feasible
#' also for non fracture data.
#'
#' A \code{\link{classcodes}} object to use with \code{\link{classify}}
#'
#'
#' @format A data frame with 1 row and 2 variables:
#' \describe{
#'   \item{group}{We only have one group of adverse events}
#'   \item{regex}{regular expression identifying ICD-10 codes}
#' }
#'
#' @seealso Companion codes based on Atgardskoder (KVA codes)
#' \code{\link{hip_fracture_ae_kva}}.
#'
#' @references Codes partly inspired by p. 83 of the annual report 2016 from knee
#' arthroplasty register \url{http://www.myknee.se/pdf/SVK-2016_1.1.pdf}
#'
#' @family default classcodes
"hip_fracture_ae_icd10"


#' Classcodes for adverse events after THA after hip fracture
#' based on Atgardskoder (KVA codes)
#'
#' This classcodes object was developed by the Swedish Hip Arthroplasty Register.
#' The work was initiated for fracture data but the result might be feasible
#' also for non fracture data.
#'
#' A \code{\link{classcodes}} object to use with \code{\link{classify}}
#'
#'
#' @format A data frame with 1 row and 2 variables:
#' \describe{
#'   \item{group}{We only have one group of adverse events}
#'   \item{regex}{regular expression identifying KVA codes}
#' }
#'
#' @seealso Companion codes based on ICD-10 \code{\link{hip_fracture_ae_icd10}}.
#'
#' @family default classcodes
"hip_fracture_ae_kva"


#' Classcodes for RxRiskV (original and modified)
#'
#' \code{\link{classcodes}} object to use with \code{\link{classify}}
#'
#' @format Data frames with 39 rows and 2 variables:
#' \describe{
#'   \item{group}{disease group}
#'   \item{regex}{regular expressions identifying ATC codes of each group}
#' }
#' @name rxriskv
#' @family default classcodes
"rxriskv_atc"

#' @rdname rxriskv
"rxriskv_modified_atc"



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
