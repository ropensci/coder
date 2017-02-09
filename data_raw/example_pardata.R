# We use real data from PAR

load("Z:\\SHPR\\SZILARD\\Beslutstöd\\\\Output\\Old\\data for calculating the Comorb indices_2015-11-03.RData")

x <- as.pardata(oppen, sluten)

# Take random sample of each column and combine into example data set
ex_pardata <-
  x %>%
  purrr::map_df(~sample(., 1e3, TRUE)) %>%
  dplyr::mutate(
    lpnr = randomNames::randomNames(nrow(.))
 )
# %>%
# as.pardata() %>%
# as.codedata(
#   from = "1998-01-01",
#   to   = "2012-12-31"
# )

devtools::use_data(ex_pardata, overwrite = TRUE)
