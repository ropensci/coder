# Prepare a classcodes object for the Charlson comorbidity classification
# based on the default regular expressions
set_classcodes(charlson)   # by object
set_classcodes("charlson") # by name

# Same as above but based on regular expressions for ICD-8 (see `?charlson`)
set_classcodes(charlson, regex = "icd8_brusselaers")

# Only recognize codes if no other characters are found after the relevant codes
# Hence if the code vector stops with the code
set_classcodes(charlson, stop = TRUE)

# Accept code vectors with strings which do not necessarily start with the code.
# This is useful if the code might appear in the middle of a longer character
# string or if a common prefix is used for all codes.
set_classcodes(charlson, start = FALSE)

# Use technical names to clearly describe the origin of each group.
# Note that the `cc` argument must be specified by a character string
# since this name is used as part of the column names
x <- set_classcodes("charlson", tech_names = TRUE)
x$group
