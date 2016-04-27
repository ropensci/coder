
# Make all INTERNAL data sets from data_raw

ignore_files <- c("make_internal_raw_data.R", "par_data.R", "example_data.R")
files <- file.path("data_raw", setdiff(dir("data_raw/"), ignore_files))
lapply(files, source)


devtools::use_data(

  hip_adverse_events_icd10,
  charlson_icd10,
  elix_icd10,
  cps_icd10,

  internal = TRUE,
  overwrite = TRUE
)