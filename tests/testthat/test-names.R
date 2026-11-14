test_that("different spellings of a name give the same key", {
  expect_equal(normalize_player_name("serena williams"), "SerenaWilliams")
  expect_equal(normalize_player_name("Serena Williams"), "SerenaWilliams")
  expect_equal(normalize_player_name("SerenaWilliams"), "SerenaWilliams")
  expect_equal(normalize_player_name("  rafael   nadal "), "RafaelNadal")
})

test_that("hyphens are kept and punctuation is removed", {
  expect_equal(normalize_player_name("jo-wilfried tsonga"), "Jo-wilfriedTsonga")
  expect_equal(normalize_player_name("Sam Querrey."), "SamQuerrey")
})

test_that("bad input gives a clear error", {
  expect_error(normalize_player_name(""), "non-empty")
  expect_error(normalize_player_name(NA_character_), "non-empty")
  expect_error(normalize_player_name(c("a", "b")), "single")
  expect_error(normalize_player_name(42), "single")
})
