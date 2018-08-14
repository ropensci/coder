hip_adverse_events_icd10_old <- tibble::frame_data(

    ~group,              ~regex,                                                          ~condition,    ~sos,   ~shar,
    "vascular disease" , "^(I|(J(81|1[358]))|R33)",                                      "hdia",            1,       1,
    "GI"               , "^(K((2([56]|7[0-6]))|923))",                                   "hdia",            0,       1,
    "others"           , "^((T((8((1[034])|4[05]))|933))|L899|S730|M24[34]|I(803|269))",  NA,               1,       1

    ) %>%
  coder::as.classcodes(coding = "icd10")

devtools::use_data(hip_adverse_events_icd10_old, overwrite = TRUE)
