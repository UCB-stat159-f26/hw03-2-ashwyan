test_that("female files: opponent age is derived from the birth date", {
  m <- female_matches()
  # Anne Miller: born 1977-01-19, match 1995-10-30
  expected <- as.numeric(as.Date("1995-10-30") - as.Date("1977-01-19")) / 365.25
  expect_equal(m$opponent_age[1], expected)
  expect_equal(m$opponent_age[1], 18.78, tolerance = 0.01)
})

test_that("male files: the age in the file is used as it is", {
  raw <- extract_columns(parse_career_js(male_js))
  m <- build_match_table(raw, as.Date("1986-06-03"), "Rafael Nadal", female = FALSE)
  expect_equal(m$opponent_age, c(22.264202601, 24.2902121834, 18.7597535934))
})

test_that("player age and age difference are computed correctly", {
  m <- female_matches()
  serena_age <- as.numeric(as.Date("1995-10-30") - as.Date("1981-09-26")) / 365.25
  expect_equal(m$player_age[1], serena_age)
  expect_equal(m$age_diff, m$player_age - m$opponent_age)
  expect_true(all(m$age_diff < 0))  # she was the younger one in all three
})

test_that("the table has the expected shape", {
  m <- female_matches()
  expect_named(m, c("player", "match_date", "tournament", "surface", "result",
                    "opponent", "player_age", "opponent_age", "age_diff"))
  expect_s3_class(m$result, "factor")
  expect_equal(levels(m$result), c("W", "L"))
  expect_false(is.unsorted(m$match_date))
  expect_equal(unique(m$player), "Serena Williams")
})

test_that("matches with an unknown opponent age are dropped", {
  raw <- extract_columns(parse_career_js(male_js))
  raw$opponent_raw[2] <- ""
  m <- build_match_table(raw, as.Date("1986-06-03"), "Rafael Nadal", female = FALSE)
  expect_equal(nrow(m), 2)
  expect_equal(m$opponent, c("Guillermo Platel", "Israel Matos Gil"))
})
