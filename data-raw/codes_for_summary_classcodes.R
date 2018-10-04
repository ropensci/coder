
# Store all available codes to use for summary.classcodes
icd10 <- as.character(decoder:::icd10$key)
ex_allcars <- rownames(mtcars) # Example data

kva <- read.delim("data-raw/kva.txt", FALSE, skip = 4)$V1


devtools::use_data(
  icd10,
  ex_allcars,
  kva,

  internal = TRUE,
  overwrite = TRUE
)
