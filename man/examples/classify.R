

# classify.default() ------------------------------------------------------

# Classify individual ICD10-codes by Elixhauser
classify(c("C80", "I20", "unvalid_code"), "elixhauser")



# classify.codified() -----------------------------------------------------

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

# Classify those patients by the Charlson and Elixhasuer comorbidity indices
classify(x, "charlson")        # classcodes object by name ...
classify(x, coder::elixhauser) # ... or by the object itself


# -- start/stop --
# Assume that a prefix "ICD-10 = " is used for all codes and that some
# additional numbers are added to the end
x$icd10 <- paste0("ICD-10 = ", x$icd10)

# Set start = FALSE to identify codes which are not necessarily found in the
# beginning of the string
classify(x, "charlson", cc_args = list(start = FALSE))


# -- regex --
# Use a different version of Charlson (as formulated by regular expressions
# according to the Royal College of Surgeons (RCS) by passing arguments to
# `set_classcodes()` using the `cc_args` argument
y <-
  classify(
    x,
    "charlson",
    cc_args = list(regex = "icd10_rcs")
  )


# -- tech_names --
# Assume that we want to compare the results using the default ICD-10
# formulations (from Quan et al. 2005) and the RCS version and that the result
# should be put into the same data frame. We can use `tech_names = TRUE`
# to distinguish variables with otherwise similar names
cc <- list(tech_names = TRUE) # Prepare sommon settings
compare <-
  merge(
  classify(x, "charlson", cc_args = cc),
  classify(x, "charlson", cc_args = c(cc, regex = "icd10_rcs"))
)
names(compare) # long but informative and distinguishable column names



# classify.data.frame() / classify.data.table() ------------------------

# Assume that `x` is a data.frame/data.table without additional attributes
# from `codify()` ...
xdf <- as.data.frame(x)
xdt <- data.table::as.data.table(x)

# ... then the `id` and `code` columns must be specified explicitly
classify(xdf, "charlson", id = "name", code = "icd10")
classify(xdt, "charlson", id = "name", code = "icd10")
