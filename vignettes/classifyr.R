
# Installera och ladda
# devtools::install_github("eribul/coder")
library(coder)

# Läs på
help(package = "coder")
browseVignettes("coder")

ex_people; ?ex_people
ex_icd10; ?ex_icd10

?codify
?classify
?index

# Find patients with adverse events after hip surgery
ex_peopple %>%
codify(
  ex_icd10,
  id   = "name",
  date = "surgery",
  days = c(-365, 0)
) %>%
classify("hip_adverse_events_icd10") %>%
index()


# Genväg för kompletternig
add("elix_icd10", to = ex_people, from = ex_icd10,
  id = "name", date = "surgery")