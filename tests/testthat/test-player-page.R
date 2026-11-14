test_that("birth date and name are read from the right player's page", {
  info <- read_player_page(page_for("Serena Williams", "19810926"), "SerenaWilliams")
  expect_equal(info$name, "Serena Williams")
  expect_equal(info$dob, as.Date("1981-09-26"))
})

test_that("a page for a different player is refused", {
  # The men's page shows a default player when it gets an unknown name.
  expect_null(read_player_page(page_for("Benoit Paire", "19890508"), "SerenaWilliams"))
})

test_that("missing or broken pages are refused", {
  expect_null(read_player_page(NULL, "SerenaWilliams"))
  expect_null(read_player_page("<html>nothing here</html>", "SerenaWilliams"))
  expect_null(read_player_page("<script>var fullname = 'Serena Williams';</script>", "SerenaWilliams"))
})

test_that("the small player file (no spaces around =) is read", {
  js <- "    var fullname = 'Serena Williams';     var lastname = 'Williams';     var dob=19810926;     var ht=175;"
  info <- read_player_page(js, "SerenaWilliams")
  expect_equal(info$name, "Serena Williams")
  expect_equal(info$dob, as.Date("1981-09-26"))
})

test_that("a name with a hyphen or accent still matches its key", {
  js <- "var fullname = 'Jo-Wilfried Tsonga'; var dob=19850417;"
  expect_equal(read_player_page(js, "Jo-WilfriedTsonga")$dob, as.Date("1985-04-17"))
})

test_that("the small player file is tried first, then the right page for the gender", {
  female <- player_info_urls("SerenaWilliams", female = TRUE)
  male <- player_info_urls("RafaelNadal", female = FALSE)
  expect_match(female[1], "jsmatches/SerenaWilliams\\.js$")
  expect_match(female[2], "wplayer-classic")
  expect_match(male[2], "/player-classic")
})
