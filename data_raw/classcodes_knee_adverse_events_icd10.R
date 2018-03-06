knee_adverse_events_icd10 <- tibble::frame_data(

  ~group,                       ~regex,                                                                                                                          ~condition,
  "DA surgical complications",  "^((G(97[89]))|(M(96(6G|[89])))|(T8((1([02-9]|8W))|(4([03-578]G?)|9)|(8[89]))))$",                                            "hbdia1_hdia",
  "DB1 knee related",           "^((G57[34])|(M((00(0G?|[289]G))|(2(2[01]|36|44G))|(6(21|6[23])G)|843G))|(S(342|(8(([013]0)|(3(1|4[LM]|5[RSX]))|4[01])))))$", "hbdia1_hdia",
  "DB2 knee related",           "^M(2(35|4[056]|56)|659G|8(66G?|((6[01])|95)G))$",                                                                            "late_hdia"  ,
  "DC CVD"          ,           "^((I((2(6[09]))|4((6[019])|90)|649|77[0-2]|819|97[89]|((2[14]|6[0-35-6]|7[24]|82)[[:alnum:]]*)))|(J8[01]9)|(T811))$",        "hbdia1_hdia",
  "DM1 other"       ,
    "^((I80[[:alnum:]]*)|(J((1[3-8][[:alnum:]]*)|9((5[23589])|81)))|(K2[5-7][[:alnum:]]*)|(L89[[:alnum:]]*)|(N(99[089]|(17[[:alnum:]]*)))|R339)$",            "hbdia1_hdia",
  "DM2 other"      ,           "^((J2[0-2][[:alnum:]]*)|(K((590)|(29[[:alnum:]]*)))|(N991))$",                                                                "late_hdia"

) %>%
  coder::as.classcodes()

devtools::use_data(knee_adverse_events_icd10, overwrite = TRUE)
