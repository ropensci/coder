#' Classcodes for Elixhauser based on ICD-codes
#'
#' Solid tumors are subordinate to metastatic cancer. A patient with both
#' conditions will still be classified as such but a possible (weighted)
#' index value will only account for metastatic cancer. The same is true for
#' "diabetes uncomplicated", which is subordinate of "diabetes complicated".
#' See Elixhauser et al. (1998).
#'
#' Note that "DRG screen" as proposed in table 1 of Elixhauser et al. (1998)
#' is not handled by the coder package. This should instead be considered as
#' an additional pre- or post-processing step!
#'
#' @format A data frame with 31 rows and 8 variables:
#' \describe{
#'   \item{group}{comorbidity groups}
#'   \item{icd10}{regular expressions identifying ICD-10 codes of
#'     each group. Corresponds to column 'ICD-10' in table 2
#'     of Quan et al. (2005).}
#'   \item{icd10_short}{regular expressions identifying only the first
#'      three characters of ICD-10 codes of each group. This alternative version
#'      was added only to use in emergency when only the first three digits are
#'      available. It is not an official version and we do not recommend to
#'      use it!}
#'   \item{icd9cm}{Corresponds to column 'Elixhauser's Original ICD-9-CM'
#'     in table 2 of Quan et al. (2005).}
#'   \item{icd9cm_ahrqweb}{Corresponds to column
#'     'Elixhauser AHRQ-Web ICD-9-CM' in table 2 of Quan et al. (2005).}
#'   \item{icd9cm_enhanced}{Corresponds to column 'Enhanced ICD-9-CM'
#'     in table 2 of Quan et al. (2005).}
#'   \item{sum_all}{all weights = 1 (thus no weights)}
#'   \item{sum_all_ahrq}{as `sum_all` excluding "cardiac arrhythmia.
#'     Compare to `icd9cm_ahrqweb` which does not
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
#' Elixhauser A, Steiner C, Harris DR, Coffey RM (1998).
#'   Comorbidity Measures for Use with Administrative Data.
#'   Med Care. 1998;36(1):8–27.
#'
#' Moore, B. J., White, S., Washington, R., Coenen, N., & Elixhauser, A. (2017).
#'   Identifying Increased Risk of Readmission and In-hospital Mortality Using
#'   Hospital Administrative Data.
#'   Medical Care, 55(7), 698–705.
#'
#' Quan Hude et al. (2005). Coding algorithms for defining
#'   comorbidities in ICD-9-CM and ICD-10 administrative data.
#'   Medical care, 1130-1139.
#'
#' Thompson, N. R., Fan, Y., Dalton, J. E., Jehi, L., Rosenbaum, B. P.,
#'   Vadera, S., & Griffith, S. D. (2015).
#'   A new Elixhauser-based comorbidity summary measure to predict in-hospital
#'   mortality. Med Care, 53(4), 374–379.
#'
#' Walraven, C. Van, Austin, P. C., Jennings, A., Quan, H., Alan, J., Walraven,
#'   C. Van, … Jennings, A. (2009).
#'   A Modification of the Elixhauser Comorbidity Measures Into a Point System
#'   for Hospital Death Using Administrative Data.
#'   Medical Care, 47(6), 626–633.
#'
#'
#' @family default classcodes
"elixhauser"



#' Classcodes for Charlson comorbidity based on ICD-codes
#'
#' @format A data frame with 17 rows and 8 variables:
#'
#'   - `group:` comorbidity groups
#'   - `description:` Verbal description of codes as described by
#'     Deyo et al. (1992).
#'   - `icd10:` regular expressions identifying ICD-10 codes of each
#'   group as decoded from Quan et al. 2005. Note that this classification was
#'   not originally used with all weights! To simply use this classification
#'   table with weights other than `quan_original` and `quan_updated`
#'   might therefore lead to different results than originally intended for each
#'   index.
#'   - `icd9cm_deyo:`Codes from table 1 column "Deyo's ICD-9-CM"
#'     in Quan et al. (2005).
#'     Procedure code 38.48 for peripheral vascular disease ignored.
#'   - `icd9cm_enhanced:` Codes from table 1 column "Enhanced ICD-9-CM"
#'     in Quan et al. (2005).
#'   - `icd10_rcs:` Codification by Armitage (2010).
#'     Note that Peptic ulcer disease is not included.
#'     All liver diseases (including mild) are included in
#'     "moderate or severe liver disease".
#'     All diabetes is included in "diabetes complication"
#'  - `icd10_swe:` Swedish version using ICD-10 by Ludvigsson et al. (2021).
#'     Note that chronic pulmonary disease is combined (separated as chronic and other in the article).
#'     Note that mild kidney disease combined with `R18`should also count as moderate or severe kidney disease 
#'     (not implemented so must be handled manually). 
#'   - `icd8_brusselaers:` Back translated version from ICD-10 to
#'     ICD-8 by Brusselaers et al. (2017).
#'     "Moderate and severe liver disease" contains all liver disease and
#'     "diabetes complication" contains all diabetes.
#'   - `icd9_brusselaers:` Back translated version from ICD-10 to
#'   ICD-9 by Brusselaers et al. (2017).
#'     "Moderate and severe liver disease" contains all liver disease and
#'     "diabetes complication" contains all diabetes.
#'   - `charlson:` original weights as suggested by Charlson et al.
#'      (1987)*
#'   - `deyo_ramano:` weights suggested by Deyo and Romano*
#'   - `dhoore:` weights suggested by D'Hoore*
#'   - `ghali:` weights suggested by Ghali*
#'   - `quan_original:` weights suggested by Quan (2005)
#'   - `quan_updated:` weights suggested by Quan (2011)
#'
#' * Weights decoded from Yurkovich et al. (2015).
#'
#' @references
#'  Armitage, J. N., & van der Meulen, J. H. (2010).
#'    Identifying co-morbidity in surgical patients using administrative data
#'    with the Royal College of Surgeons Charlson Score.
#'    British Journal of Surgery, 97(5), 772–781.
#'
#'  Brusselaers N, Lagergren J. (2017)
#'    The Charlson Comorbidity Index in Registry-based Research.
#'    Methods Inf Med 2017;56:401–6.
#'
#'
#'  Deyo, R. A., Cherkin, D. C., & Ciol, M. A. (1992).
#'    Adapting a clinical comorbidity index for use with ICD-9-CM
#'    administrative databases.
#'    Journal of Clinical Epidemiology, 45(6), 613–619.
#'
#' Ludvigsson, J. F., Appelros, P., Askling, J., Byberg, L., Carrero, J.-J., Ekström, A. M., Ekström, M., Smedby, K. E., Hagström, H., James, S., Järvholm, B., Michaelsson, K., Pedersen, N. L., Sundelin, H., Sundquist, K., Sundström, J. 
#'   Adaptation of the Charlson Comorbidity Index for Register-Based Research in Sweden. 
#'   CLEP 2021, 13, 21–41. https://doi.org/10.2147/CLEP.S282475.
#' 
#' Quan Hude et al. (2005). Coding algorithms for defining
#'   comorbidities in ICD-9-CM and ICD-10 administrative data.
#'   Medical care, 1130-1139.
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
#' @format A data frame with 2 rows and 2 variables:
#' \describe{
#'   \item{group}{comorbidity groups, either "ordinary" for most ICD-10-codes or
#'   "special" for codes beginning with "UA", "UB" and "UP"}
#'   \item{icd10}{regular expressions identifying ICD-10 codes of each
#'     group}
#'   \item{only_ordinary}{index weights, 1 for ordinary and 0 for special}
#' }
#' @references
#'
#' Stawicki, Stanislaw P., et al.
#'   "Comorbidity polypharmacy score and its clinical utility: A pragmatic
#'   practitioner's perspective." Journal of emergencies, trauma, and shock 8.4
#'   (2015): 224.
#'
#' @family default classcodes
"cps"


#' Classcodes for adverse events after knee and hip arthroplasty
#'
#' ICD-10 group names are prefixed by two letters as given by the references.
#' Two groups (DB and DM) are split into two due to different conditions.
#'
#' @section Hip fractures:
#' Adverse events (AE) codes for hip fractures are based on codes for elective
#' cases but with some additional codes for DM 1 (N300, N308, N309 and N390).
#'
#' @section Conditions:
#' Special conditions apply to all categories.
#' Those require non-standard modifications
#' of the classcodes data prior to categorization.
#'
#' \describe{
#'  \item{hbdia1_hdia}{`TRUE` if the code was
#'  given as any type of diagnose during hospital visit for index operation,
#'  or as main diagnose for later visits, otherwise `FALSE`}
#'  \item{late_hdia}{`TRUE` if the code was
#'  given as main diagnose at a later visit after the index operation,
#'  otherwise `FALSE`}
#'  \item{post_op}{`TRUE` if the code was
#'  given at a later visit after the index operation, otherwise `FALSE`}
#' }
#'
#' @format Data frame with 3 columns:
#' \describe{
#'   \item{group}{Different types of adverse events (see reference section)}
#'   \item{icd10}{regular expressions identifying ICD-10 codes for each
#'     group}
#'  \item{icd10_fracture}{regular expressions for fracture patients.
#'    Essentially the same as `regex` but with some additional codes for
#'    group "DM1 other"}
#'  \item{kva}{regular expressions identifying KVA codes}
#'   \item{condition}{special conditions are used, see below.}
#' }
#'
#' @references
#'
#'   Magneli M, Unbeck M, Rogmark C, Rolfson O, Hommel A, Samuelsson B, et al.
#'     Validation of adverse events after hip arthroplasty:
#'     a Swedish multi-centre cohort study.
#'     BMJ Open. 2019 Mar 7;9(3):e023773.
#'
#' @name ae
#' @family default classcodes
#' @seealso hip_ae_hailer
"knee_ae"

#' @rdname ae
"hip_ae"


#' Classcodes for infection and dislocation after hip arthroplasty
#'
#' @format Data frame with 3 columns:
#' \describe{
#'   \item{group}{Infection or dislocation}
#'   \item{icd10}{regular expressions based on ICD-10}
#'  \item{kva}{regular expressions based on NOMESCO/KVA codes}
#' }
#'
#' @seealso ae
#' @family default classcodes
"hip_ae_hailer"


#' Classcodes for RxRisk V based on ATC codes
#'
#' Note that desired implementation might differ over time and by country.
#'
#' @format Data frames with 46 rows and 6 variables:
#' \describe{
#'   \item{group}{medical condition}
#'   \item{pratt}{ATC codes from table 1 in Pratt et al. 2018
#'    (ignoring PBS item codes and extra conditions).}
#'   \item{garland}{Modified version by Anne
#'   Garland to resemble medical use in Sweden 2016 (Unpublished).}
#'  \item{caughey}{From appendix 1 in Caughey et al. 2010}
#'  \item{pratt}{Mortality weights from table 1 in Pratt et al. 2018}
#'  \item{sum_all}{Unweighted count of all conditions.}
#' }
#'
#' @references
#' Caughey GE, Roughead EE, Vitry AI, McDermott RA, Shakib S, Gilbert AL.
#'   Comorbidity in the elderly with diabetes:
#'   Identification of areas of potential treatment conflicts.
#'   Diabetes Res Clin Pract 2010;87:385–93.
#'
#' Pratt NL, Kerr M, Barratt JD, Kemp-Casey A, Kalisch Ellett LM,
#'   Ramsay E, et al.
#'   The validity of the Rx-Risk Comorbidity Index using medicines mapped to
#'   the Anatomical Therapeutic Chemical (ATC) Classification System.
#'   BMJ Open 2018;8.
#'
#' @family default classcodes
"rxriskv"



################################################################################
#                                                                              #
#                              Example data sets                               #
#                                                                              #
################################################################################


#' Example data for random people
#'
#' Example data for fictive people to use for testing and in examples.
#'
#' @format Data frames with 100 rows and 2 variables:
#' \describe{
#'   \item{name}{random person names}
#'   \item{surgery}{random dates for a relevant event}
#' }
#'
#' @family example data
"ex_people"


#' Example data for random ATC codes
#'
#' Example data for fictive people to use for testing and in examples.
#'
#' @format Data frames with 100 rows and 2 variables:
#' \describe{
#'   \item{name}{random person names}
#'   \item{atc}{Random codes from the Anatomic Therapeutic Chemical
#'   classification (ATC) system.}
#'   \item{prescription}{random dates of prescription of medications with
#'   corresponding ATC codes}
#' }
#'
#' @family example data
"ex_atc"


#' Example data for random codes assigned to random people
#'
#' Example data for fictive ICD-10-diagnoses to use for testing and
#' in examples.
#'
#' @source
#'   https://github.com/jackwasey/icd.data
#'   https://ustur.wsu.edu/about-us/
#'
#' @format Data frames with 1,000 rows and 4 variables:
#' \describe{
#'   \item{id}{Random names corresponding to column `name` in dataset
#'     \code{ex_people}}
#'   \item{date}{random dates corresponding to registered (comorbidity) codes}
#'   \item{code}{ICD-10 codes from the `uranium_pathology`
#'   dataset in the `icd.data` package by Jack Wasey originating from the
#'   United States Transuranium and Uranium Registries,
#'   published in the public domain.}
#'   \item{hdia}{boolean marker if corresponding code is the main diagnose of
#'     the hospital visit (randomly assigned to 10 percent of the codes)}
#' }
#' @family example data
"ex_icd10"
