# Codify all patients from `ex_people` with their ICD-10 codes from `ex_icd10`
x <- codify(ex_people, ex_icd10, id = "name", code = "icd10")
x

# Only consider codes if recorded at hospital admissions within one year prior
# to surgery
codify(
  ex_people,
  ex_icd10,
  id        = "name",
  code      = "icd10",
  date      = "surgery",
  code_date = "admission",
  days      = c(-365, 0)   # admission during one year before surgery
)

# Only consider codes if recorded after surgery
codify(
  ex_people,
  ex_icd10,
  id        = "name",
  code      = "icd10",
  date      = "surgery",
  code_date = "admission",
  days      = c(1, Inf)     # admission any time after surgery
)


# Dirty code data ---------------------------------------------------------

# Assume that codes contain unwanted "dirty" characters
# Those could for example be a dot usd by ICD-10 (i.e. X12.3 instead of X123)
dirt <- c(strsplit(c("½!#¤%&/()=?`,.-_"), split = ""), recursive = TRUE)
rdirt <- function(x) sample(x, nrow(ex_icd10), replace = TRUE)
sub <- function(i) substr(ex_icd10$icd10, i, i)
ex_icd10$icd10 <-
  paste0(
    rdirt(dirt), sub(1),
    rdirt(dirt), sub(2),
    rdirt(dirt), sub(3),
    rdirt(dirt), sub(4),
    rdirt(dirt), sub(5)
  )
head(ex_icd10)

# Use `alnum = TRUE` to ignore non alphanumeric characters
codify(ex_people, ex_icd10, id = "name", code = "icd10", alnum = TRUE)



# Big data ----------------------------------------------------------------

# If `data` or `codedata` are large compared to available
# Random Access Memory (RAM) it might not be possible to make internal copies
# of those objects. Setting `.copy = FALSE` might help to overcome such problems

# If no copies are made internally, however, the input objects (if data tables)
# would change in the global environment
x2 <- data.table::as.data.table(ex_icd10)
head(x2) # Look at the "icd10" column (with dirty data)

# Use `alnum = TRUE` combined with `.copy = FALSE`
codify(ex_people, x2, id = "name", code = "icd10", alnum = TRUE, .copy = FALSE)

# Even though no explicit assignment was specified
# (neither for the output of codify(), nor to explicitly alter `x2`,
# the `x2` object has changed (look at the "icd10" column!):
head(x2)

# Hence, the `.copy` argument should only be used if necessary
# and  if so, with caution!


# print.codify() ----------------------------------------------------------

x # Preview first 10 rows as a tibble
print(x, n = 20) # Preview first 20 rows as a tibble
print(x, n = NULL) # Print as data.table (ignoring the 'classified' class)
