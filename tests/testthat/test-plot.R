test_that("plot_age_gap returns a ggplot with one point per match", {
  p <- plot_age_gap(female_matches())
  expect_s3_class(p, "ggplot")
  expect_equal(nrow(p$data), 3)
  expect_match(p$labels$title, "Serena Williams's Professional Matches, Age 14 to 15")
})

test_that("the plot renders without error", {
  expect_no_error(ggplot2::ggplot_build(plot_age_gap(female_matches())))
})

test_that("plot_age_gap rejects bad input", {
  expect_error(plot_age_gap(data.frame(x = 1)), "get_player_matches")
  expect_error(plot_age_gap(female_matches()[0, ]), "non-empty")
  expect_error(plot_age_gap("Serena"), "get_player_matches")
})

test_that("y axis labels read like the original graphic", {
  expect_equal(age_gap_labels(c(-20, -10, 0, 10, 20), 20),
               c("-20", "-10", "Same age", "+10", "+20 years"))
})
