
tha_fracture_ae_kva <-
  coder::as.classcodes(
    data.frame(
      group = "hip fracture ae kva",
      regex =
        gsub("\\s", "",
          "^NF([ACF-HJ-MS-UW]\\d{2}|Q09)|
            QD(A10|B\\d{2}|E35|G30)|
            TNF(05|10)
          $"
        ),
      stringsAsFactors = FALSE
    ),
    coding = "kva"
  )


devtools::use_data(tha_fracture_ae_kva, overwrite = TRUE)
