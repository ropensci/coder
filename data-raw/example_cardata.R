set.seed(123)
N <- 1e3

ex_cars <-
  data.frame(
    id        = sample(randomNames::randomNames(N),   N, replace = TRUE),
    code      = rownames(mtcars)[sample(nrow(mtcars), N, replace = TRUE)],
    code_date = Sys.Date() - sample(N)
  )

ex_carbrands <-
  as.classcodes(data.frame(
    group = c("Mazda", "Mer-Ben", "Ford", "Fiat", "Toyota", "Volksw", "Geely"),
    regex = c(
      "Mazda", "Merc", "Ford|Lincoln", "Chrysler|Fiat|Dodge|Ferrari|Maserati",
      "Toyota", "Porsche", "Volvo|Lotus")
  ),
  coding = "ex_allcars",
  description = "Example data of car brand names and their producers."
)

usethis::use_data(ex_cars, ex_carbrands, overwrite = TRUE)
