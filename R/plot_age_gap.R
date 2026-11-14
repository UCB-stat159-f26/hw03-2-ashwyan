#' Plot the age gap of a player's career matches
#'
#' Scatter plot with the player's age on the x axis and the age difference with
#' the opponent on the y axis. Points above the line are matches against a
#' younger opponent. Blue points are wins and purple points are losses.
#'
#' @param matches A data frame returned by [get_player_matches()].
#'
#' @return A `ggplot` object (printed when called at the console).
#'
#' @examples
#' \dontrun{
#' plot_age_gap(get_player_matches("Serena Williams"))
#' }
#' @export
plot_age_gap <- function(matches) {
  check_match_columns(matches)
  limit <- ceiling(max(abs(matches$age_diff)) + 0.5)
  ggplot2::ggplot(matches, ggplot2::aes(player_age, age_diff, color = result)) +
    ggplot2::geom_hline(yintercept = 0, color = "grey40") +
    ggplot2::geom_point(alpha = 0.6, size = 1.8) +
    age_gap_scales(matches, limit) +
    ggplot2::labs(title = age_gap_title(matches), x = paste0(matches$player[1], "'s age"),
                  y = NULL, color = NULL,
                  caption = "Source: Tennis Abstract. Note: The date is the start of the tournament.") +
    age_gap_theme()
}

check_match_columns <- function(matches) {
  needed <- c("player", "player_age", "age_diff", "result")
  missing <- setdiff(needed, names(matches))
  if (!is.data.frame(matches) || length(missing) > 0 || nrow(matches) == 0) {
    stop("`matches` must be a non-empty data frame from get_player_matches().", call. = FALSE)
  }
}

age_gap_title <- function(matches) {
  sprintf("%s's Professional Matches, Age %d to %d", matches$player[1],
          floor(min(matches$player_age)), floor(max(matches$player_age)))
}

age_gap_scales <- function(matches, limit) {
  ages <- range(matches$player_age)
  top <- max(10, floor(limit / 10) * 10)
  list(
    ggplot2::scale_color_manual(values = c(W = "#3aa0c9", L = "#7b2d7b"), drop = FALSE,
      labels = c(W = "Match won", L = "Match lost")),
    ggplot2::scale_x_continuous(breaks = seq(floor(ages[1] / 2) * 2, ceiling(ages[2] / 2) * 2, 2),
      position = "top"),
    ggplot2::scale_y_continuous(limits = c(-limit, limit), breaks = seq(-top, top, 10),
      labels = function(v) age_gap_labels(v, top))
  )
}

# "-10", "Same age", "+10", ... and "+20 years" on the top tick.
age_gap_labels <- function(v, top) {
  labels <- ifelse(v > 0, sprintf("+%d", v), as.character(v))
  labels[v == 0] <- "Same age"
  labels[v == top] <- sprintf("+%d years", top)
  labels
}

age_gap_theme <- function() {
  ggplot2::theme_minimal() +
    ggplot2::theme(
      plot.background = ggplot2::element_rect(fill = "#1a1a1a", color = NA),
      panel.background = ggplot2::element_rect(fill = "white", color = NA),
      text = ggplot2::element_text(color = "grey85"),
      axis.text = ggplot2::element_text(color = "grey70"),
      legend.position = "top"
    )
}

# Column names used inside ggplot2::aes() (silences an R CMD check note).
utils::globalVariables(c("player_age", "age_diff", "result"))
