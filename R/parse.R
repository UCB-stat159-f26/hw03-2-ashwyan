# Private helpers that turn raw Tennis Abstract text into a clean data frame.
# These are pure functions (no internet), so they are what the tests cover.

# "serena williams", "Serena Williams" and "SerenaWilliams" -> "SerenaWilliams"
normalize_player_name <- function(name) {
  if (!is.character(name) || length(name) != 1 || is.na(name) || !nzchar(trimws(name))) {
    stop("`player_name` must be a single, non-empty string.", call. = FALSE)
  }
  words <- strsplit(iconv(trimws(name), to = "ASCII//TRANSLIT"), "[[:space:]]+")[[1]]
  capitalized <- paste0(toupper(substring(words, 1, 1)), substring(words, 2))
  gsub("[^A-Za-z-]", "", paste(capitalized, collapse = ""))
}

# Strip the JavaScript wrapper (`var morematchmx = ...;`) and read the rows.
parse_career_js <- function(js_text) {
  start <- regexpr("[[", js_text, fixed = TRUE)
  end <- max(gregexpr("]", js_text, fixed = TRUE)[[1]])
  if (start < 0 || end < start) stop("Unexpected format: no match rows found.", call. = FALSE)
  jsonlite::fromJSON(substring(js_text, start, end), simplifyVector = FALSE)
}

# Pull the fields we need out of the list of rows (all values are text).
extract_columns <- function(rows) {
  field <- function(i) {
    vapply(rows, function(r) if (length(r) >= i) as.character(r[[i]]) else NA_character_, character(1))
  }
  data.frame(
    match_date = as.Date(field(1), "%Y%m%d"), tournament = field(2), surface = field(3),
    result = field(5), opponent = field(12), opponent_raw = field(17), stringsAsFactors = FALSE
  )
}

# Women's files hold the opponent's birth date (YYYYMMDD), men's files the age.
is_female_file <- function(opponent_raw) {
  filled <- opponent_raw[!is.na(opponent_raw) & nzchar(opponent_raw)]
  length(filled) > 0 && mean(grepl("^[0-9]{8}$", filled)) > 0.5
}

years_between <- function(from, to) as.numeric(to - from) / 365.25

# Opponent age in years on the match date, for either kind of file.
opponent_age_years <- function(raw, female) {
  if (female) return(years_between(as.Date(raw$opponent_raw, "%Y%m%d"), raw$match_date))
  suppressWarnings(as.numeric(raw$opponent_raw))
}

# The clean table: ages of the player and opponent and their difference.
build_match_table <- function(raw, dob, player, female) {
  out <- data.frame(
    player = player, match_date = raw$match_date, tournament = raw$tournament,
    surface = raw$surface, result = factor(raw$result, levels = c("W", "L")),
    opponent = raw$opponent, player_age = years_between(dob, raw$match_date),
    opponent_age = opponent_age_years(raw, female), stringsAsFactors = FALSE
  )
  out$age_diff <- out$player_age - out$opponent_age
  sort_and_drop_unknown(out)
}

# Drop matches with an unknown date, result or opponent age; sort by date.
sort_and_drop_unknown <- function(matches) {
  known <- stats::complete.cases(matches[c("match_date", "result", "opponent_age")])
  matches <- matches[known, ]
  matches[order(matches$match_date), ]
}

# Read the date of birth and full name from a player file or page, if it is the right player.
read_player_page <- function(html, player_key) {
  if (is.null(html)) return(NULL)
  grab <- function(pattern) regmatches(html, regexec(pattern, html))[[1]][2]
  name <- grab("var fullname\\s*=\\s*'([^']*)'")
  dob <- grab("var dob\\s*=\\s*([0-9]{8})")
  same <- tolower(gsub("[^A-Za-z]", "", name)) == tolower(gsub("[^A-Za-z]", "", player_key))
  if (is.na(name) || is.na(dob) || !same) return(NULL)
  list(name = name, dob = as.Date(dob, "%Y%m%d"))
}
