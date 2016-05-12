# Include some par data in correct format

library(dplyr)
load("Z:\\SHPR\\SZILARD\\Beslutstöd\\Data\\data for calculating the Comorb indices_2015-11-03.RData")

oppen   <- icdswe::as.pardata(oppen)
sluten  <- icdswe::as.pardata(sluten)
pardata <- icdswe::as.codedata(oppen, sluten) %>%
  dplyr::filter(
    date >= "2001-01-01",
    # Remove some codes that doesn't seem to be ICD10
    grepl("^[[:alpha:]][[:digit:]]{3}$", as.character(code))) %>%
  dplyr::mutate(code = droplevels(code))

# object.size(pardata) / 2 ^ 20

devtools::use_data(pardata, overwrite = TRUE)



# Vi sparar även ner SHPR-data men det är bara för att kunna används som
# lite exempeldata under processen.
# Är inte meningen att denna data sedan ska finnas med i paketet!
names(shpr_operation) <- tolower(names(shpr_operation))
shpr_operation <-
  shpr_operation %>%
  mutate(sida = as.factor(sida),
         opnr = as.factor(opnr),
         lpnr = as.factor(lpnr),
         oppdat = as.Date(oppdat, format = "%Y/%m/%d")) %>%
  filter(oppdat >= "2002-01-01")

object.size(shpr_operation) / 2 ^ 20

devtools::use_data(shpr_operation, overwrite = TRUE)
