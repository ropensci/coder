# For some patient data (ex_people) and related hospital visit code data
# with ICD 10-codes (ex_icd10), add the Elixhauser comorbidity
# conditions based on all registered ICD10-codes
categorize(
   x            = ex_people,
   codedata     = ex_icd10,
   cc           = "elixhauser",
   id           = "name",
   code         = "icd10"
)


# Add Charlson categories and two versions of a calculated index
# ("quan_original" and "quan_updated").
categorize(
   x            = ex_people,
   codedata     = ex_icd10,
   cc           = "charlson",
   id           = "name",
   code         = "icd10",
   index        = c("quan_original", "quan_updated")
)


# Only include recent hospital visits within 30 days before surgery,
categorize(
   x            = ex_people,
   codedata     = ex_icd10,
   cc           = "charlson",
   id           = "name",
   code         = "icd10",
   index        = c("quan_original", "quan_updated"),
   codify_args  = list(
      date      = "surgery",
      days      = c(-30, -1),
      code_date = "admission"
   )
)



# Multiple versions -------------------------------------------------------

# We can compare categorization by according to Quan et al. (2005); "icd10",
# and Armitage et al. (2010); "icd10_rcs" (see `?charlson`)
# Note the use of `tech_names = TRUE` to distinguish the column names from the
# two versions.

# We first specify some common settings ...
ind <- c("quan_original", "quan_updated")
cd  <- list(date = "surgery", days = c(-30, -1), code_date = "admission")

# ... we then categorize once with "icd10" as the default regular expression ...
categorize(
   x            = ex_people,
   codedata     = ex_icd10,
   cc           = "charlson",
   id           = "name",
   code         = "icd10",
   index        = ind,
   codify_args  = cd,
   cc_args      = list(tech_names = TRUE)
) %>%

# .. and once more with `regex = "icd10_rcs"`
categorize(
   codedata     = ex_icd10,
   cc           = "charlson",
   id           = "name",
   code         = "icd10",
   index        = ind,
   codify_args  = cd,
   cc_args      = list(regex = "icd10_rcs", tech_names = TRUE)
)



# column names ------------------------------------------------------------

# Default column names are based on row names from corresponding classcodes
# object but are modified to be syntactically correct.
default <-
   categorize(ex_people, codedata = ex_icd10, cc = "elixhauser",
              id = "name", code = "icd10")

# Set `check.names = FALSE` to retain original names:
original <-
  categorize(
    ex_people, codedata = ex_icd10, cc = "elixhauser",
    id = "name", code = "icd10",
    check.names = FALSE
   )

# Or use `tech_names = TRUE` for informative but long names (use case above)
tech <-
  categorize(ex_people, codedata = ex_icd10, cc = "elixhauser",
    id = "name", code = "icd10",
    cc_args = list(tech_names = TRUE)
  )

# Compare
tibble::tibble(names(default), names(original), names(tech))
