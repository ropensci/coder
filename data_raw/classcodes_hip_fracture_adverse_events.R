# The codes are decided by SHAR and based on
# "inst/Kopia av Definitiv lista diagnoskoder Frakturpatienter.xlxx"

x <-
  c(
    "F05\\d?",
    "G(
       57[02-4]                                              |
       97[89]
    )",
    "I(
      1[1-3]\\d                                              |
      2([0-46]\\w{1,2}|5[346]|8[89])                         |
      3([0238]\\w{1,2}|1[2389]|98)                           |
      4[014-9]\\w{1,2}                                       |
      5([02]\\d|1[1-46-9])                                   |
      6([0-6]\\d|7[689]|8[128])                              |
      7(
        0(2[ACX]?|[89])                                      |
        1[01358]                                             |
        [249]\\d                                             |
        39[A-CWX]?                                           |
        7[0-2689]
      )                                                      |
      8([0-2]\\d|[57]0)                                      |
      9(7[89]|8[138]|99)
    )",
    "J(
      1([2-8]\\d)                                            |
      2[0-2]\\d                                              |
      8[01]9                                                 |
      9(5[23589]|81)
    )",
    "K(
      2[5-79]\\d                                             |
      590
    )",
    "L89\\w{1,2}",
    "M(
      00(0F?|[289]F)                                         |
      2(4([0356]|4F?)|56)                                    |
      86([01]F|6F?)                                          |
      96([89]|6F)
    )",
    "N(
      17\\d                                                  |
      390                                                    |
      99[0189]
    )",
    "R(339|410)",
    "S(
      \\d2\\d*                                               |
      342                                                    |
      730                                                    |
      74\\d
    )",
    "T(
      8((1(\\d|8W))|(4([03-578][FX]?))|(8[89]))              |
      933
    )"
  )

tha_fracture_ae_icd10 <-
  as.classcodes(
    data.frame(
      group = "hip fracture ae",
      regex = paste0("^", paste(gsub("\\s", "", x), collapse = "|"), "$"),
      stringsAsFactors = FALSE
    )
  )

devtools::use_data(tha_fracture_ae_icd10, overwrite = TRUE)

