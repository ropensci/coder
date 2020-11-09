# Add Elixhauser based on all registered ICD10-codes
categorize(ex_people, codedata = ex_icd10, cc = "elixhauser",
 id = "name", code = "icd10")

# Add Charlson categories and two versions of a calculated index.
# Only include recent hospital visits within 30 days before surgery,
# and use technical variable names to clearly identify the new columns.
categorize(ex_people, codedata = ex_icd10, cc = "charlson",
 id = "name", code = "icd10",
 index = c("quan_original", "quan_updated"),
 codify_args =
   list(date = "surgery", days = c(-30, -1), code_date = "admission"),
 cc_args = list(tech_names = TRUE)
)