# codebook() --------------------------------------------------------------
\dontrun{
# Export codebook (to temporary file) with all codes identified by the
# Elixhauser comorbidity classification based on ICD-10-CM
codebook(elixhauser, "icd10cm", file = tempfile("codebook", fileext = ".xlsx"))

# All codes from ICD-9-CM Disease part used by Elixhauser enhanced version
codebook(elixhauser, "icd9cmd",
  cc_args = list(regex = "icd9cm_enhanced",
  file = tempfile("codebook", fileext = ".xlsx"))
)

# The codebook returns a list with three objects.
# Access a dictionary table with translates of each code to text:
codebook(charlson, "icd10cm")$all_codes
}

# print.codebook() --------------------------------------------------------

# If argument `file` is unspecified, a preview of each sheet of the codebook is
# printed to the screen
(cb <- codebook(charlson, "icd10cm"))

# The preview can be modified by arguments to the print-method
print(cb, n = 20)


# codebooks() -------------------------------------------------------------

# Combine codebooks based on different versions of the regular expressions
# and export to a single (temporary) Excel file
c1 <- codebook(elixhauser, "icd10cm")
c2 <- codebook(elixhauser, "icd9cmd",
  cc_args = list(regex = "icd9cm_enhanced")
  )

codebooks(
  elix_icd10 = c1, elix_icd9cm = c2,
  file = tempfile("codebooks", fileext = ".xlsx")
)

