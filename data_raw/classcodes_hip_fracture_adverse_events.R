# This is a classcodes object for adverse events after THA after hip fracture
# The codes are decided by SHAR and based on
# "inst/Kopia av Definitiv lista diagnoskoder Frakturpatienter.xlxx"
# Note that white lines with no priority numbers are ignored!

# We first build a vector with all data.
# Each code block is one line in the classcodes object and
# each element within the blocks are: groupm regex and condition
x <-
  c(

    "hip",
    "^(G(57[02-4])|(97[89]))                                  |
       T((8((1\\d|8W)|(4([03-578][FX]?))|(8[89])))|(933))     |
       S(342|(7[34]\\d))                                      |
       M((96([89]|6F?))         |
         (00(0|[0289]F))        |
         (2(4[03-6]F)))
      $",
    "hbdia1_hdia",

    "hip",
    "^M((2(4[03-6])|56)|(86([01]F|6F?)))$",
    "late_hdia",

    "cvd",
    "^(I(
        (1[1-3]\\d)                                            |
        (2([0-468]\\w{1,2})|(5[346]))                          |
        (3([0238]\\w{1,2})|(1[2389])|(98))                     |
        (4[014-9]\\w{1,2})                                     |
        (5([02]\\d)|(1[1-46-9]))                               |
        (6([0123456]\\d)|(7[689])|(8[128]))                    |
        (7([249]|(0[289])|(1[1358])|(39)|(7[0-2689]))\\w{1,2}) |
        (8([0-2]\\d)|([57]0))                                  |
        (9(7[89]|8[138]|99))
      )) |
      (J(8[01]9))
      $",
    "hbdia1_hdia",


    "misc",
    "^(J((1([2-8]\\d))|(9(5[23589]|81))))                      |
      (K((2[5-7]\\d)|590))                                     |
      (L89\\w{1,2})                                            |
      (N(17\\d|390|99[089]))                                   |
      (R339)
      $",
    "hbdia1_hdia",


    "misc",
    "^(J2[0-2]\\d$)|(K29\\d)|(N991)$",
    "late_hdia"

  )


`%>%` <- dplyr::`%>%`
tha_fracture_ae_icd10 <-
  gsub("\\s", "", x) %>%
  matrix(ncol = 3, byrow = TRUE) %>%
  as.data.frame(stringsAsFactors = FALSE) %>%
  setNames(c("group", "regex", "condition"))


devtools::use_data(tha_fracture_ae_icd10, overwrite = TRUE)
