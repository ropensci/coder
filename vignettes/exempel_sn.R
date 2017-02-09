# shpr_operation
load("Z:\\SHPR\\SZILARD\\Beslutstöd\\\\Output\\Old\\data for calculating the Comorb indices_2015-11-03.RData")
rm(oppen, sluten)

# oppen, sluten
load("Z:/SHPR/SZILARD/Beslutstöd/Data/par_data2017_02_09.RData")

# NPR
load("Z:/SHPR/SZILARD/Beslutstöd/Data/par_data_structured 2017_02_09.RData")

library(dplyr)

# har pardataset oppen, sluten
patients <-
  shpr_operation %>%
  sample_n(1e4) %>%
  mutate(
    dt = as.Date(OppDat)
  )

# npr <-
#   pardata %>%
#   rename(
#     id   = lpnr,
#     date = INDATUM,
#     dia  = id,
#     code = icd10
#   ) %>%
#   as.codedata()

npr <-
  as.pardata(oppen, sluten) %>%
  as.codedata()



ICD10 <- c('I828', 'I822', 'I823', 'I260', 'I269', 'I819', 'I829', 'I801', 'I802', 'I808')

cl <-
  data.frame(
    group = ICD10,
    regex = ICD10
) %>%
  as.classcodes()


# Genväg
y <- add(cl, patients, npr, id = "lpnr", date = "dt", days = c(0, 90))
