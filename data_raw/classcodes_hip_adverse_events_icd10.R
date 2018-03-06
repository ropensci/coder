hip_adverse_events_icd10 <- tibble::frame_data(

  ~group,                       ~regex,                                                                                                                 ~condition,
  "DA surgical complications",  "^((G(97[89]))|(M(96(6F|[89])))|(T8((1([02-9]|8W))|(4([03578]F?)|[49])|(8[89]))))$",                                      "hbdia1_hdia",
  "DB1 hip related",           "^((G57[0-2])|(M((00(0F?|[289]F))|(24(3|4F?))))|(S7([24-6][0-9]{0,2}|30)))$",                                               "hbdia1_hdia",
  "DB2 hip related",           "^(M(24[056]F|6(10|21|6[23])F|8((43|6[01])F|66F?|95E)))$",                                                                 "late_hdia"  ,
  "DC CVD"          ,           "^((I((2(6[09]))|4((6[019])|90)|649|77[0-2]|819|97[89]|((2[14]|6[0-35-6]|7[24]|82)[[:alnum:]]*)))|(J8[01]9)|(T811))$", "hbdia1_hdia",
  "DM1 other"       ,
    "^((I80[[:alnum:]]*)|(J((1[3-8][[:alnum:]]*)|9((5[23589])|81)))|(K2[5-7][[:alnum:]]*)|(L89[[:alnum:]]*)|(N(99[089]|(17[[:alnum:]]*)))|R339)$",     "hbdia1_hdia",
  "DM2 other"      ,           "^((J2[0-2][[:alnum:]]*)|(K((590)|(29[[:alnum:]]*)))|(N991))$",                                                         "late_hdia"

) %>%
  coder::as.classcodes()

devtools::use_data(hip_adverse_events_icd10, overwrite = TRUE)
