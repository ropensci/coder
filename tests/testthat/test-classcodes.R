test_that("classcodes", {
  expect_is(as.classcodes(elixhauser), "classcodes")
  expect_error(as.classcodes(iris))
  expect_true(is.classcodes(elixhauser))
  expect_false(is.classcodes(iris))
  expect_error(elixhauser[1,1:2], "Hierarchical conditions not found")
  expect_error(elixhauser[1,1])
  expect_silent({elixhauser[1,1] <- "hej"; elixhauser})
})



df <- as.data.frame(elixhauser)
cl <- as.classcodes(df, regex = attr(elixhauser, "regexprs"))

# Identify regex and indices by column prefixes
df2 <- data.frame(
  group = 0,
  regex_test = 1,
  index_test2 = 2
)
cl2 <- as.classcodes(df2)


test_that("regex", {
  expect_error(as.classcodes(df), "must have at least one column with")
  expect_equal(attr(cl, "regexprs"), attr(elixhauser, "regexprs"))
  expect_equal(attr(cl, "indices"), character(0))
  expect_equal(attr(cl2, "regexprs"), "test")
})


test_that("indices", {
  expect_error(
    as.classcodes(df, regex = attr(elixhauser, "regexprs"), indices = "hej"),
    "Column with indices not found in `x`: hej"
  )
  expect_equal(
    attr(
      as.classcodes(
        df, regex = attr(elixhauser, "regexprs"), indices = "sid29"),
      "indices"
    ),
    "sid29"
  )
  expect_equal(attr(cl2, "indices"), "test2")
})


# Objects with missing columns/attributes should not work
test_that("check_classcodes", {

  # No group
  ch <- as.data.frame(charlson)
  ch$group <- NULL
  expect_error(
    as.classcodes(ch, regex = "icd10"),
    "classcodes object must have a column named `group`!"
  )

  # Missing group
  ch <- as.data.frame(charlson)
  ch$group[1] <- NA
  expect_error(
    as.classcodes(ch, regex = "icd10"),
    "have missing values"
  )

  # Non-unique group
  ch <- as.data.frame(charlson)
  ch$group[2] <- ch$group[1]
  expect_error(
    as.classcodes(ch, regex = "icd10"),
    "must be unique!"
  )
})

test_that("print.classcodes", {
  expect_output(print(charlson), "Classcodes object")
  expect_output(
    print(charlson),
    "icd10, icd9cm_deyo, icd9cm_enhanced, icd10_rcs, icd10_swe, icd8_brusselaers"
  )
  expect_output(
    print(charlson),
    "charlson, deyo_ramano, dhoore, ghali, quan_original, quan_updated"
  )
  expect_output(
    print(elixhauser), "Hierarchy"
  )
})

test_that("as_tibble.classcodes", {
  expect_s3_class( as_tibble(charlson), "tbl_df")
})
