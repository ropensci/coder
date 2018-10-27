elix_icd10 <- tibble::frame_data(
 ~group,                            ~regex,                                                                 ~walraven,
 "congestive heart failure",        "^(I(099|1(10|3[02])|255|4(2[05-9]|3)|50)|P290)",                             7,
 "cardiac arrhythmias",             "^(I(44[1-3]|456|459|4[7-9])|R00[018]|T821|Z[49]50)",                          5,
 "valvular disease",                "^(A520|I(0[5-8]|09[18]|3[4-9])|Q23[0-3]|Z95[2-4])",                           -1,
 "pulmonary circulation disorder", "^I(2([67]|8[089]))",                                                            4,
 "peripheral vascular disorder",    "^(I7([01]|3[189]|71|9[02])|K55[189]|Z95[89])",                                 2,
 "hypertension uncomplicated",      "^I10[0-9]",                                                            0,
 "hypertension complicated",        "^I1[1-35]",                                                                  0,
 "paralysis",                       "^G(041|114|8(0[12]|[12]|3[0-49]))",                                          7,
 "other neurological disorders",    "^(G(1[0-3]|2([012]|5[45])|3(1[289]|[25-7])|4[01]|93[14])|R470|R56)",         6,
 "chronic pulmonary disease",       "^((I27[89])|(J(4[0-7]|6([0-7]|84)|70[13])))",                                      3,
 "diabetes uncomplicated",          "^E1[0-4][019]",                                                              0,
 "diabetes complicated",            "^E1[0-4][23-8]",                                                             0,
 "hypothyroidism",                  "^E(0[0-3]|890)",                                                              0,
 "renal failure",                   "^(I(120|131)|N(1[89]|250)|Z(49[012]|9(40|92)))",                                  5,
 "liver disease",                   "^(B18|I(8(5|64)|982)|K7(0|1[13457]|[234]|6[02-9])|Z944)",                      11,
 "peptic ulcer disease",            "^K2[5-8][79]",                                                               0,
 "AIDS/HIV",                        "^B2[0124]",                                                                  0,
 "lymphoma",                        "^C(8[1-58]|9(6|0[02]))",                                                      9,
 "metastatic cancer",               "^C(7[7-9]|80)",                                                              12,
 "solid tumor",                     "^C([01]|2[0-6]|3[0-47-9]|4[0135-9]|5[0-8]|6|7[0-6]|97)",                4,
 "rheumatoid arthritis",            "^(L94[013]|M(0[568]|12[03]|3(0|1[0-3]|[2-5])|4(5|6[189])))",                  0,
 "coagulopathy",                    "^D6([5-8]|9[13-6])",                                                         3,
 "obesity",                         "^E66",                                                                      -4,
 "weight loss",                     "^(E4[0-6]|R63?4)",                                                          6,
 "fluid electrolyte disorders",     "^E(222|8[67])",                                                               5,
 "blood loss anemia",               "^D500",                                                                     -2,
 "deficiency anemia",               "^D5(0[89]|[123])",                                                          -2,
 "alcohol abuse",                   "^(F10|E52|G621|I426|K(292|70[039])|T51|Z(502|7(14|21)))",                        0,
 "drug abuse",                      "^(F1[1-689]|Z7(15|22))",                                                      -7,
 "psychoses",                       "^F(2[0-589]|3([01]2|15))",                                                    0,
 "depression",                      "^F(204|3(1[345]|[23]|41)|4[13]2)",                                        -3
) %>%
mutate(sum_all = 1) %>% # Simple sum index
coder::as.classcodes(
  coding = "icd10",
  description = "Comorbidity based on Elixhauser"
)

usethis::use_data(elix_icd10, overwrite = TRUE)
