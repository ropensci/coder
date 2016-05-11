charlson_icd10 <- tibble::frame_data(
    ~group, ~regex,
    "myocardial_infraction",            "^(I2([12]|52))",
    "congestive_heart_failure",         "^(I099|I1(10|3[02])|I255, I4(2[05-9]|3)|I50|P290)",
    "peripheral_vascualr_disease",      "^(I7([01]|3[189]|71|9[02])|K55[189]|Z95[89])",
    "cerebrovascula_disease",           "^(G4[56]|H340|I6)",
    "dementia",                         "^(F0([0-3]|51)|G3(0|11))",
    "chronic_pulmonary_disease",        "^(I27[89]|J4[0-7]|J6([0-7]|84)|J70[13])",
    "rheumatic_disease",                "^(M0[56]|M3(15|[2-4]|5[13]|60))",
    "peptic_ulcer_disease",             "^(K2[5-8])",
    "mild_liver_disease",               "^(B18|K7(0[0-39]|1[3457]|[34]|6[023489])|Z944)",
    "diabetes_no_complication",         "^(E1[0-4][01689])",
    "diabetes_complication",            "^(E1[0-4][2-57])",
    "hemiplegia_or_paraplegia",         "^(G041|G114|G8(0[12]|[12]|3[0-49]))",
    "renal_disease",                    "^(I120|I131|N0(3[2-7]|5[2-7])|N1[89]|N250|Z49[012]|Z940|Z992)",
    "malingnacy",                       "^(C[01]|C2[0-6]|C3[0-47-9]|C4[0135-9]|C5[0-8]|C6|C7[0-6]|C8[1-58]|C9[0-7])",
    "moderate_or_severe_liver_disease", "^(I8(5[09]|64)|I982|K7(04|[12]1|29|6[5-7]))",
    "matastasic_solid_tumor",           "^(C7[7-9]|C80)",
    "adis_hiv",                         "^(B2[0124])"
  ) %>%
  icdswe::as.classcodes()