x <- pardata[2:1e4, ]; x$id <- droplevels(x$id)

profvis::profvis({
  apa <- classify(x)
})



profvis::profvis(
  distill(icdswe::shpr_operation, icdswe::pardata, "lpnr", "oppdat") %>%
  classify("cps_icd10") %>%
  index()
)
