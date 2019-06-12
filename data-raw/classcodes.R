# All classcodes from Excel file

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
    description = paste("Comorbidity based on", name),
    classcode = pmap(list(data, coding, description),
                     ~as.classcodes(..1, ..2, ..3)) %>%
                set_names(paste(name, coding, sep = "_"))
  ) %>%
  {attach(.$classcode)} # Must be able to refer to each object by name in use_data

# Save all datasets. Must be referred by name directly (could use rlang maybe)
usethis::use_data(
  charlson_icd10,
  elix_icd10,
  hip.ae_icd10,
  hip.ae_kva,
  knee.ae_icd10,
  knee.ae_kva,
  overwrite = TRUE
)
