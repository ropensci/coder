x <- pardata[1:2000, ]; x$id <- droplevels(x$id)

profvis::profvis({
  apa <- classify(x, "elix_icd10")
})



profvis::profvis(
  distill(icdswe::shpr_operation, icdswe::pardata, "lpnr", "oppdat") %>%
  classify("cps_icd10") %>%
  index()
)
