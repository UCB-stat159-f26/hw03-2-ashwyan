test_that("the JS wrapper is stripped and every row is read", {
  expect_length(parse_career_js(female_js), 3)
  expect_length(parse_career_js(male_js), 3)
})

test_that("text without match rows is rejected", {
  expect_error(parse_career_js("var nothing = 1;"), "no match rows")
})

test_that("the right fields are extracted", {
  raw <- extract_columns(parse_career_js(female_js))
  expect_equal(nrow(raw), 3)
  expect_equal(raw$match_date, as.Date(c("1995-10-30", "1997-03-07", "1997-08-04")))
  expect_equal(raw$tournament, c("Canadian Open", "Indian Wells", "Manhattan Beach"))
  expect_equal(raw$surface, c("Carpet", "Hard", "Hard"))
  expect_equal(raw$result, c("L", "L", "L"))
  expect_equal(raw$opponent[1], "Anne Miller")
})

test_that("female and male files are told apart", {
  female <- extract_columns(parse_career_js(female_js))
  male <- extract_columns(parse_career_js(male_js))
  expect_true(is_female_file(female$opponent_raw))
  expect_false(is_female_file(male$opponent_raw))
  expect_false(is_female_file(character(0)))
})
