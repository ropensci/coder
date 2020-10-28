
# summary.classcodes() ----------------------------------------------------

# Summarize all ICD-10-CM codes identified by the Elixhauser
# comorbidity classification
# See `?decoder::icd10cm` for details
summary(elixhauser, coding = "icd10cm")

# Is there a difference if instead considering the Swedish ICD-10-SE?
# See `?decoder::icd10se` for details
summary(elixhauser, coding = "icd10se")

# Which ICD-9-CM diagnostics codes are recognized by Charlson according to
# Brusselears et al. 2017 (see `?charlson`)
summary(
  charlson, coding = "icd9cmd",
  cc_args = list(regex = "icd9_brusselaers")
)


# print.summary.classcodes() ----------------------------------------------

# Print all 31 lines of the summarized Elixhauser classcodes object
print(
  summary(elixhauser, coding = "icd10cm"),
  n = 31
)

