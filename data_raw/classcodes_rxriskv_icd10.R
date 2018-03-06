rxriskv_icd10 <- tibble::frame_data(

  ~group,                                      ~regex,

  "alcohol dependence",                        '^(N07BB0[34])|(V03AA01)|(R05CB01)',
  "allergies",                                 '^R0[16]A[CDEX][0125][1-35-9]',
  "anti coagulation therapy",                  '^B01A[AB]0[1-6]',
  "anti platelet therapy",                     '^B01AC[0-3][0-4679]',
  "anxiety",                                   '^N05BA[01][1246]',
  "arrhythmia",                                '^C01[AB][A-D]0[1345]',
  "benign prostate hypertrophy",               '^G04CA0[23]',
  "bipolar disorder",                          '^N06AX',
  "chronic heart failure",                     '^C0[39][AC]{2}[01][0-79]',
  "dementia",                                  '^N04DA0[2-4]',
  "depression",                                '^N06A[ABGX][0-2][0-689]',
  "diabetes",                                  '^A10[AB][A-G][01][1-8]',
  "end stage renal disease",                   '^B03XA0[12]|A11CC0[1-4]',
  "epilepsy,	",                               'N^03A[ABD-GX][01][0-59]',
  "gastric oesophageal reflux disorder",       '^A02B[A-DX][05][1-6]',
  "glaucoma",                                  '^S01E[A-EX][05][1-5]',
  "gout",                                      '^M04A[A-C]01',
  "hepatitis C",                               '^J05AB54',
  "HIV",                                       '^J05A[EFGRX]0[1-9]',
  "hyperkalcemia",                             '^V03AE01',
  "hyperlipidemia",                            '^C10[AB][ABCX][01][1-579]',
  "hypertension",                              '^C0[239][A-EK][ABCX][01][1-9]',
  "hyperthyroidism",                           '^H03AA0[12]',
  "angina",                                    '^C01DA[01][248]',
  "ischaemic heart disease hypertension",      '^C0[78][ACDF][ABG][01][1-35-7]',
  "inflammatory bowel disease",                '^A07E[AC]0[1-4]',
  "malignancies",                              '^L01[A-DX][A-EX][0-35][[:digit:]]',
  "malnutrition",                              '^B05BA03',
  "osteoporosis pagets",                       '^M05B[AB]0[1-46-8]',
  "pain",                                      '^N02A[ABEFGX][05][12359]',
  "inflammation pain",                         '^M01A[BCEH][015][1-6]',
  "pancreatic insufficiency",                  '^A09AA02',
  "parkinsons disease",                        '^N04[AB][ACDX]0[1-79]',
  "psoriasis",                                 '^D05[AB][BX]0[12]|D05AA',
  "chronic airways disease",                   '^R03[A-D][ABCKL][01][0-46-9]',
  "smoking cessation",                         '^N07BA0[12]',
  "steroid responsive diseases",               '^H02AB[01][01246-9]',
  "transplant",                                '^L04AA[0-2][013468]',
  "tuberculosis",                              '^J04A[BCK]0[124]'

) %>%
coder::as.classcodes()

devtools::use_data(rxriskv_icd10, overwrite = TRUE)
