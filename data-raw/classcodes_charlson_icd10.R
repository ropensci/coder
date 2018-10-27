charlson_icd10 <- readxl::read_excel("data-raw/classcodes_charlson.xlsx") %>%
  as.classcodes(
    coding = "icd10",
    description = "Comorbidity based on Charlson"
  )
usethis::use_data(charlson_icd10, overwrite = TRUE)
