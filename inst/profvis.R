x <- pardata[2:1e5, ]; x$lpnr <- droplevels(x$lpnr)

profvis::profvis({
  apa <- classify(x)
})