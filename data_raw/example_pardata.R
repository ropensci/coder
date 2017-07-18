# We use real data from PAR

load("Z:\\SHPR\\SZILARD\\Beslutstöd\\\\Output\\Old\\data for calculating the Comorb indices_2015-11-03.RData")

x <- as.codedata(oppen, sluten)

# Take random sample of each column and combine into example data set
ex_pardata <-
 x[, lapply(.SD, function(x) sample(x, 1e3, TRUE))][
 , id := randomNames::randomNames(.N)
 ][]

devtools::use_data(ex_pardata, overwrite = TRUE)
