
# Store all available codes to use for summary.classcodes
icd10 <- as.character(decoder:::icd10$key)
devtools::use_data(icd10, internal = TRUE)
