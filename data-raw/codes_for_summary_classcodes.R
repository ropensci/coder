
# Store all available codes to use for summary.classcodes
icd10      <- as.character(decoder:::icd10$key)
ex_allcars <- rownames(mtcars) # Example data

kva <- read.delim("data-raw/kva.txt", FALSE, skip = 4)$V1

# List from http://www.wido.de/amtl_atc-code.html
# http://www.wido.de/fileadmin/wido/downloads/zip-Arzneimittel/wido_arz_amtlicher_atc-index_2018_1217.zip
atc <-
  readxl::read_excel("data-raw/Amtliche Fassung des ATC-Index 2018.xlsx", "amtlicher-Index alphabet_2018") %>%
  dplyr::filter(grepl("^\\w{7}", `ATC-Code`, perl = TRUE)) %>%
  {.$`ATC-Code`}



usethis::use_data(
  icd10,
  ex_allcars,
  kva,
  atc,

  internal = TRUE,
  overwrite = TRUE
)
