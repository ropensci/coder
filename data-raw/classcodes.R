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
mutate(
  classcode = map(data, as.classcodes) %>%
              set_names(names)
) %>%
{attach(.$classcode)} # Must be able to refer to each object by name in use_data



# hip.fracture.ae_icd10 ---------------------------------------------------

# There are some additional ICD-10 codes used for hip fractures.
# https://registercentrum.blob.core.windows.net/shpr/r/-rsrapport-2017-S1xKMzsAwX.pdf
# p. 149
hip_fracture_ae <-
  hip_ae %>%
  mutate(
    regex = if_else(
      group == "DM1 other",
      paste0(gsub(")$", "", regex, fixed = TRUE), "|N3(0[0899]|Y90))$"),
      regex
    )
  ) %>%
  as.classcodes()


# Save all datasets. Must be referred by name directly (could use rlang maybe)
usethis::use_data(
  ex_carbrands,
  charlson,
  elixhauser,
  hip_ae,
  hip_ae_hailer,
  knee_ae,
  hip_fracture_ae,
  cps,
  rxriskv,
  overwrite = TRUE
)

rm(list = ls())
