
# Prepare some codified data with ICD-10 codes during 1 year (365 days)
# before surgery
x <-
  codify(
    ex_people,
    ex_icd10,
    id        = "name",
    code      = "icd10",
    date      = "surgery",
    days      = c(-365, 0),
    code_date = "admission"
  )

# Classify those patients by the Charlson comorbidity indices
cl <- classify(x, "charlson")

# Calculate (weighted) index values
head(index(cl))                  # Un-weighted sum/no of conditions for each patient
head(index(cl, "quan_original")) # Weighted index (Quan et al. 2005; see `?charlson`)
head(index(cl, "quan_updated"))  # Weighted index (Quan et al. 2011; see `?charlson`)

# Tabulate index for all patients.
# As expected, most patients are healthy and have index = 0/NA,
# where NA indicates no recorded hospital visits
# found in `ex_icd10` during codification.
# In practice, those patients might be assumed to have 0 comorbidity as well.
table(index(cl, "quan_original"), useNA = "always")

# If `cl` is a matrix without additional attributes (as imposed by `codify()`)
# an explicit classcodes object must be specified by the `cc` argument
cl2 <- as.matrix(cl)
head(index(cl2, cc = "charlson"))
