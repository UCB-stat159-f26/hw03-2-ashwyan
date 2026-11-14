#' Get the career matches of a tennis player
#'
#' Downloads the career data of a player from tennisabstract.com and returns a
#' clean data frame with the ages of the player and of every opponent on the day
#' of each match. Works for women and men.
#'
#' @param player_name Name of the player, e.g. `"Serena Williams"`,
#'   `"serena williams"` or `"SerenaWilliams"`.
#'
#' @return A data frame with one row per match and columns `player`,
#'   `match_date`, `tournament`, `surface`, `result` (factor, `W` or `L`),
#'   `opponent`, `player_age`, `opponent_age` and `age_diff`
#'   (`player_age - opponent_age`, in years). Matches whose opponent's age is
#'   unknown are dropped.
#'
#' @details The date in the data is the start date of the tournament, so ages are
#'   off by up to two weeks for later rounds. An unknown player name gives an
#'   error saying that no data was found.
#'
#' @examples
#' \dontrun{
#' serena <- get_player_matches("serena williams")
#' rafa <- get_player_matches("Rafael Nadal")
#' get_player_matches("GastonSanchez")  # error: no career data found
#' }
#' @export
get_player_matches <- function(player_name) {
  key <- normalize_player_name(player_name)
  raw <- extract_columns(parse_career_js(fetch_career_js(key)))
  female <- is_female_file(raw$opponent_raw)
  info <- fetch_player_info(key, female)
  build_match_table(raw, info$dob, info$name, female)
}
