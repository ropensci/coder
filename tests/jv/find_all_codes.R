# JAg har fått en lista med koder från JV
# Jag vill nu kolla så att även jag har identifierat de koder hon anger
# Hon har dock blandat flera olika varianter, varför jag gör detsamma
#
# Jag borde förstås även kolla det omvända, dvs att jag inte har fler koder
# som inte borde finnas. Detta har dock inte gjorts då hennes koder är dels exakta,
# dels en nivå upp.
# Jag har heller inte kollat så rätt kod klassas i rätt kategori.


# Identify extra codes not specified in source ---------------------------------
extra <- function(codes, cc, regex) {
  tmp <-
    classify(codes, cc, cc_args = list(regex = regex)) %>%
    rowSums()
    names(tmp)[!as.logical(tmp)]
}

# Get data by sheet number and range
get_data <- function(i, range) {
  readxl::read_excel(
    "tests/jv/Kopia av Lista alla koder socialstyrelsen 2020-04-27.xlsx",
    i, range,
    col_names = c("key", "value"),
    col_types = c("text", "text")
  ) %>%
    mutate(key = gsub("\\.", "", key))
}

# List all codes recognized by cc and specific regex
codelist <- function(cc, codes, regex) {
  x <- summary(cc, codes, cc_args = list(regex = regex))
  unname(c(x$codes_vct, recursive = TRUE))
}

missing <- function(eb, jv) {
  eb[!eb %in% jv]
}


# ICD-9 Charlson ---------------------------------------------------------------
get_data(1, "A1:B384") %>%
  filter(!key %in% c("Procedure 3848", 471, 70, 41:44)) %>%
  select(key) %>%
  pluck(1) %>%
  extra("charlson", "regex_icd9_brusselaers") %>%
  extra("charlson", "regex_icd9cm_enhanced") %>%
  extra("charlson", "regex_icd9cm_deyo")
# OK!



# ICD-10 Charlson --------------------------------------------------------------
get_data(2, "A1:B330") %>%
  select(key) %>%
  pluck(1) %>%
  extra("charlson", "regex_icd10_rcs") %>%
  extra("charlson", "regex_icd10")
# OK!


# Elixhauser ICD-9 -------------------------------------------------------------

get_data(3, "A1:B599") %>%
  select(key) %>%
  filter(!key %in% 41:44) %>%
  pluck(1) %>%
  extra("elixhauser", "regex_icd9cm_enhanced") %>%
  extra("elixhauser", "regex_icd9cm") %>%
  extra("elixhauser", "regex_icd9cm_ahrqweb") %>%
  as_tibble()
  # OK!


# Elixhauser ICD-10 ------------------------------------------------------------

get_data(4, "A1:B399") %>%
  select(key) %>%
  pluck(1) %>%
  extra("elixhauser", "regex_icd10") %>%
  as_tibble()
# OK!


# ATC RX risk score ------------------------------------------------------------

get_data(5, "A1:B1348") %>%
  select(key) %>%
  filter(key != "D05AA") %>%           # en nivå för högt
  filter(!grepl("A02BX", key)) %>%     # Borde inte behövas!
  pluck(1) %>%
  extra("rxriskv", "regex_pratt") %>%
  as_tibble()
# OK!



# ICD 10 Oönskade händelser ----------------------------------------------------

get_data(6, "A1:B117") %>%
  select(key) %>%
  pluck(1) %>%
  extra("hip_ae", "regex_icd10_fracture") %>%
  as_tibble()
# OK!