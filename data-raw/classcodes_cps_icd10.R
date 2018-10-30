cps_icd10 <- tibble::frame_data(

  ~group,              ~regex,                                 ~only_ordinary,
  "ordinary", "^[[:upper:]][0-9]{2}.?[0-9]{0,2}[[:upper:]]?$",              1,
  "special",  "^U[ABP][0-9]{2,4}$",                                         0

) %>%
coder::as.classcodes(
  coding = "icd10",
  description = "comorbidity-polypharmacy score (CPS)"
)

usethis::use_data(cps_icd10, overwrite = TRUE)