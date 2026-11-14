# Private helpers that talk to tennisabstract.com.
# Nothing in this file is exported, and none of it is called by the tests.

base_url <- "https://www.tennisabstract.com"

# Download a page; return its text, or NULL if the server says "not found".
fetch_text <- function(url) {
  resp <- tryCatch(perform_request(url), error = function(e) {
    stop("Could not reach tennisabstract.com: ", conditionMessage(e), call. = FALSE)
  })
  if (httr2::resp_status(resp) != 200) return(NULL)
  httr2::resp_body_string(resp)
}

# One polite request: identify ourselves and retry if the site says "slow down" (429).
perform_request <- function(url) {
  httr2::request(url) |>
    httr2::req_user_agent("tennisage R package (STAT 159 homework)") |>
    httr2::req_retry(max_tries = 3, is_transient = function(r) httr2::resp_status(r) == 429) |>
    httr2::req_error(is_error = function(r) FALSE) |>
    httr2::req_perform()
}

# Download the raw career JS file of a player, e.g. key "SerenaWilliams".
fetch_career_js <- function(player_key) {
  js <- fetch_text(sprintf("%s/jsmatches/%sCareer.js", base_url, player_key))
  if (is.null(js) || !grepl("morematchmx", js, fixed = TRUE)) {
    stop(sprintf("No career data found for player '%s'. Check the spelling, e.g. \"Serena Williams\".",
                 player_key), call. = FALSE)
  }
  js
}

# Find the player's date of birth and full name. The small file
# jsmatches/<Key>.js defines both for women and men; the player pages are a
# fallback. A source only counts if its name matches the requested player,
# because the men's page shows a default player when given an unknown name.
fetch_player_info <- function(player_key, female) {
  for (url in player_info_urls(player_key, female)) {
    info <- read_player_page(fetch_text(url), player_key)
    if (!is.null(info)) return(info)
  }
  stop(sprintf("Found matches for '%s' but not the player's date of birth.", player_key), call. = FALSE)
}

# Places that may hold the birth date, best first.
player_info_urls <- function(player_key, female) {
  pages <- c("wplayer-classic.cgi", "player-classic.cgi")
  if (!female) pages <- rev(pages)
  c(sprintf("%s/jsmatches/%s.js", base_url, player_key),
    sprintf("%s/cgi-bin/%s?p=%s&f=ACareerqq", base_url, pages, player_key))
}
