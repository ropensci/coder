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
    group = c(
      "Mazda",
      "Renault - Nissan",
      "Mercedes-Benz",
      "GM",
      "Ford",
      "Fiat",
      "Honda",
      "Toyota",
      "Volkswagen",
      "Geely"
    ),
    regex = c(
      "Mazda",
      "Datsun",
      "Merc",
      "Cadillac|Camaro|Pontiac",
      "Ford|Lincoln",
      "Chrysler|Fiat|Dodge|Ferrari|Maserati",
      "Honda",
      "Toyota",
      "Porsche",
      "Volvo|Lotus"
    )
  ),
  coding = "ex_allcars",
  description = "Example data of car brand names and their producers."
)


devtools::use_data(ex_cars, ex_carbrands, overwrite = TRUE)
