cps_icd10 <- tibble::frame_data(

  ~group,              ~regex,                                             ~w,
  "ordinary", "^[[:upper:]][[:digit:]]{2}.?[[:digit:]]{0,2}[[:upper:]]?$",  1,
  "special",  "^U[ABP][[:digit:]]{2,4}$"                                   ,0

) %>%
  icdswe::as.classcodes()
