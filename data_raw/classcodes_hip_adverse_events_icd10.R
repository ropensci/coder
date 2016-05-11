hip_adverse_events_icd10 <- tibble::frame_data(

    ~group,              ~regex,                                                  ~condition,
    "vascular deseases", "^(I|(J(81|1[358]))|R33|(K((2([56]|7[0-6]))|923)))",             "hdia",
    "luxation",          "^((T((8((1[034])|4[05]))|933))|L899|S730|M24[34]|I(803|269))", NA

    ) %>%
  icdswe::as.classcodes()