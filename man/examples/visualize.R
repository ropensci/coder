
# The default behavior is to open a visualization in the default web browser
\dontrun{

 # How is depression classified according to Elixhauser?
 visualize("elixhauser", "depression")

 # Compare the two diabetes groups according to Charlson
 visualize("charlson",
   c("diabetes without complication", "diabetes complication"))

 # Is this different from the "Royal College of Surgeons classification?
 # Yes, there is only one group for diabetes
 visualize("charlson",
   c("diabetes without complication", "diabetes complication"),
   regex = "rcs"
 )

 # Show all groups from Charlson
 visualize("charlson")

 # It is also possible to visualize an arbitrary regular expression
 # from a character string
 visualize("I2([12]|52)")
}

 # The URL is always returned (invisable) but the visual display can
 # also be omitted
url <- visualize("hip_ae", show = FALSE)
url