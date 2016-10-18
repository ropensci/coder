charlson_icd10 <- tibble::frame_data(
   ~group,                             ~regex,
    "myocardial_infraction",            "^(I2([12]|52))",
    "congestive_heart_failure",         "^(I099|I1(10|3[02])|I255, I4(2[05-9]|3)|I50|P290)",
    "peripheral_vascular_disease",      "^(I7([01]|3[189]|71|9[02])|K55[189]|Z95[89])",
    "cerebrovascular_disease",           "^(G4[56]|H340|I6)",
    "dementia",                         "^(F0([0-3]|51)|G3(0|11))",
    "chronic_pulmonary_disease",        "^(I27[89]|J4[0-7]|J6([0-7]|84)|J70[13])",
    "rheumatic_disease",                "^(M0[56]|M3(15|[2-4]|5[13]|60))",
    "peptic_ulcer_disease",             "^(K2[5-8])",
    "mild_liver_disease",               "^(B18|K7(0[0-39]|1[3457]|[34]|6[023489])|Z944)",
    "diabetes_no_complication",         "^(E1[0-4][01689])",
    "hemiplegia_or_paraplegia",         "^(G041|G114|G8(0[12]|[12]|3[0-49]))",
    "renal_disease",                    "^(I120|I131|N0(3[2-7]|5[2-7])|N1[89]|N250|Z49[012]|Z940|Z992)",
    "diabetes_complication",            "^(E1[0-4][2-57])",
    "malingnancy",                      "^(C[01]|C2[0-6]|C3[0-47-9]|C4[0135-9]|C5[0-8]|C6|C7[0-6]|C8[1-58]|C9[0-7])",
    "leukemia",                         "^not yet implemented!!!$",
    "lymphoma",                         "^Needs to be implemented!!!$",
    "moderate_or_severe_liver_disease", "^(I8(5[09]|64)|I982|K7(04|[12]1|29|6[5-7]))",
    "metastasic_solid_tumor",           "^(C7[7-9]|C80)",
    "aids_HIV",                         "^(B2[0124])"
  ) %>%
  dplyr::mutate(
    charlson      = c(1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 2, 2, 2, 2, 2, 2, 3, 6, 6),
    deyo_ramano   = c(1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 1, 1, 1),
    dhoore        = c(1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
    ghali         = c(1, 4, 2, 1, 0, 0, 0, 0, 0, 0, 0, 3, 0, 0, 0, 0, 0, 0, 0),
    quan_original = c(1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 2, 2, 2, 2, 0, 0, 3, 6, 6),
    quan_updated  = c(0, 2, 0, 0, 2, 1, 1, 0, 2, 0, 2, 1, 1, 2, 0, 0, 4, 6, 4)
  ) %>%
 classifyr::as.classcodes()

devtools::use_data(charlson_icd10, overwrite = TRUE)
