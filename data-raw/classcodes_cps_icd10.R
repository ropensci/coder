cps_icd10 <- tibble::frame_data(

  ~group,              ~regex,                                             ~only_ordinary,
  "ordinary", "^[[:upper:]][[:digit:]]{2}.?[[:digit:]]{0,2}[[:upper:]]?$",  1,
  "special",  "^U[ABP][[:digit:]]{2,4}$",                                   0

) %>%
coder::as.classcodes(
  coding = "icd10",
  description = "comorbidity-polypharmacy score (CPS)"
)

devtools::use_data(cps_icd10, overwrite = TRUE)