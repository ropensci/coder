# The Elixhauser comorbidity classification is already a classcodes object
is.classcodes(coder::elixhauser)

# Strip its class attributes to use in examples
df <- as.data.frame(coder::elixhauser)

# Specify which columns store regular expressions and indices
# (assume no hierarchy)
elix <-
  as.classcodes(
    df,
    regex = c(
      "icd10",
      "icd10_short",
      "icd9cm",
      "icd9cm_ahrqweb",
      "icd9cm_enhanced"
    ),
    indices = c(
      "sum_all",
      "sum_all_ahrq",
      "walraven",
      "sid29",
      "sid30",
      "ahrq_mort",
      "ahrq_readm"
    ),
    hierarchy = NULL
  )
elix

# Specify hierarchy for patients with different types of cancer and diabetes
# See `?elixhauser` for details
as.classcodes(
  elix,
  hierarchy = list(
    cancer   = c("metastatic cancer", "solid tumor"),
    diabetes = c("diabetes complicated", "diabetes uncomplicated")
  )
)

# Several checks are performed to not allow any erroneous classcodes object
\dontrun{
  as.classcodes(iris)
  as.classcodes(iris, regex = "Species")
}