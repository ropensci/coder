# All classcodes from Excel file

rm(list = ls())

xl_path <- "data-raw/classcodes.xlsx"

# Read all classcodes from excel-file and give attributes
tibble::tibble(
  names = readxl::excel_sheets(xl_path)
) %>%
mutate(
  data  = map(names, ~ readxl::read_excel(xl_path, .))
) %>%
separate(names, c("name", "coding"), sep = "_") %>%
mutate(
  classcode = map2(data, coding, as.classcodes) %>%
              set_names(paste(name, coding, sep = "_"))
) %>%
{attach(.$classcode)} # Must be able to refer to each object by name in use_data



# hip.fracture.ae_icd10 ---------------------------------------------------

# There are some additional ICD-10 codes used for hip fractures.
# https://registercentrum.blob.core.windows.net/shpr/r/-rsrapport-2017-S1xKMzsAwX.pdf
# p. 149
hip.fracture.ae_icd10 <-
  hip.ae_icd10 %>%
  mutate(
    regex = if_else(
      group == "DM1 other",
      paste0(gsub(")$", "", regex, fixed = TRUE), "|N3(0[0899]|Y90))$"),
      regex
    )
  ) %>%
  as.classcodes("icd10")


# Save all datasets. Must be referred by name directly (could use rlang maybe)
usethis::use_data(
  ex.carbrands_excars,
  charlson_icd10,
  elix_icd10,
  elix.short_icd10,
  hip.ae_icd10,
  hip.ae_kva,
  knee.ae_icd10,
  knee.ae_kva,
  hip.fracture.ae_icd10,
  cps_icd10,
  rxriskv_atc,
  rxriskv.modified_atc,
  overwrite = TRUE
)

rm(list = ls())
