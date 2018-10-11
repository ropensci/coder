elix_icd10 <- tibble::frame_data(
 ~group,                            ~regex,                                                                 ~walraven,
 "congestive heart failure",        "^(I099|I1(10|3[02])|I255|I4(2[05-9]|3)|I50|P290)",                             7,
 "cardiac arrhythmias",             "^(I44[1-3]|I456|I459|I4[7-9]|R00[018]|T821|Z[49]50)",                          5,
 "valvular disease",                "^(A520|I0[5-8]|I09[18]|I3[4-9]|Q23[0-3]|Z95[2-4])",                           -1,
 "pulmonary circulation disorder", "^(I2([67]|8[089]))",                                                            4,
 "peripheral vascular disorder",    "^(I7([01]|3[189]|71|9[02])|K55[189]|Z95[89])",                                 2,
 "hypertension uncomplicated",      "^(I10[[:digit:]])",                                                            0,
 "hypertension complicated",        "^(I1[1-35])",                                                                  0,
 "paralysis",                       "^(G041|G114|G8(0[12]|[12]|3[0-49]))",                                          7,
 "other neurological disorders",    "^(G1[0-3]|G2[012]|G25[45]|G31[289]|G3[25-7]|G4[01]|G93[14]|R470|R56)",         6,
 "chronic pulmonary disease",       "^(I27[89]|J4[0-7]|J6([0-7]|84)|J70[13])",                                      3,
 "diabetes uncomplicated",          "^(E1[0-4][019])",                                                              0,
 "diabetes complicated",            "^(E1[0-4][23-8])",                                                             0,
 "hypothyroidism",                  "^(E0[0-3]|E890)",                                                              0,
 "renal failure",                   "^(I120|I131|N1[89]|N250|Z49[012]|Z940|Z992)",                                  5,
 "liver disease",                   "^(B18|I8(5|64)|I982|K7(0|1[13457]|[234]|6[02-9])|Z944)",                      11,
 "peptic ulcer disease",            "^(K2[5-8][79])",                                                               0,
 "AIDS/HIV",                        "^(B2[0124])",                                                                  0,
 "lymphoma",                        "^(C8[1-58]|C96|C90[02])",                                                      9,
 "metastatic cancer",               "^(C7[7-9]|C80)",                                                              12,
 "solid tumor",                     "^(C[01]|C2[0-6]|C3[0-47-9]|C4[0135-9]|C5[0-8]|C6|C7[0-6]|C97)",                4,
 "rheumatoid arthritis",            "^(L94[013]|M0[568]|M12[03]|M3(0|1[0-3]|[2-5])|M4(5|6[189]))",                  0,
 "coagulopathy",                    "^(D6[5-8]|D69[13-6])",                                                         3,
 "obesity",                         "^(E66)",                                                                      -4,
 "weight loss",                     "^(E4[0-6]|R634|R64)",                                                          6,
 "fluid electrolyte disorders",     "^(E222|E8[67])",                                                               5,
 "blood loss anemia",               "^(D500)",                                                                     -2,
 "deficiency anemia",               "^(D50[89]|D5[123])",                                                          -2,
 "alcohol abuse",                   "^(F10|E52|G621|I426|K292|K70[039]|T51|Z502|Z714|Z721)",                        0,
 "drug abuse",                      "^(F1[1-689]|Z715|Z722)",                                                      -7,
 "psychoses",                       "^(F2[0-589]|F3([01]2|15))",                                                    0,
 "depression",                      "^(F204|F31[345]|F3[23]|F341|F4[13]2)",                                        -3
) %>%
coder::as.classcodes(
  coding = "icd10",
  description = "Comorbidity based on Elixhauser"
)

devtools::use_data(elix_icd10, overwrite = TRUE)
