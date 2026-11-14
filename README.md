# tennisage

An R package that downloads the career matches of a professional tennis player from
[Tennis Abstract](https://www.tennisabstract.com) and plots the age gap with every opponent,
like the New York Times graphic about Serena Williams (HW2), without annotations.
It works for women and men.

## Installation

```r
# install.packages("pak")
pak::pak("UCB-stat159-f26/hw03-2-ashwyan")

# or
devtools::install_github("UCB-stat159-f26/hw03-2-ashwyan")
```

## Usage

```r
library(tennisage)

# Serena Williams data and plot
serena <- get_player_matches("serena williams")
plot_age_gap(serena)

# Rafael Nadal data and plot
rafa <- get_player_matches("Rafael Nadal")
plot_age_gap(rafa)

# A player that does not exist gives a clear error:
get_player_matches("GastonSanchez")
#> Error: No career data found for player 'GastonSanchez'. Check the spelling, e.g. "Serena Williams".
```

Names can be written `"serena williams"`, `"Serena Williams"` or `"SerenaWilliams"`.

## Functions

| Function | What it does |
|---|---|
| `get_player_matches(player_name)` | Downloads the career data and returns a clean data frame, one row per match |
| `plot_age_gap(matches)` | Scatter plot of the player's age (x) against the age difference with the opponent (y) |

The data frame has the columns `player`, `match_date`, `tournament`, `surface`, `result`
(`W` or `L`), `opponent`, `player_age`, `opponent_age` and `age_diff` (`player_age - opponent_age`, in
years). Ages are in years on the day of the match. Matches whose opponent's age is unknown are dropped.

## How it works

1. The name is turned into the key used by the site (`"serena williams"` becomes `SerenaWilliams`).
2. The file `jsmatches/<Key>Career.js` is downloaded. If it does not exist, the player is unknown.
3. The JavaScript wrapper is removed and the rows are read as JSON.
4. Women's files contain the opponent's date of birth, so the opponent's age is computed from it.
   Men's files already contain the opponent's age, which is used as it is. The package tells the two
   apart by the format of that column.
5. The player's own date of birth is not in the career file. It is read from the player's
   page. The page's name is checked against the name requested, because the men's page shows a
   default player (not an error) when it is given a woman's name.

The date in the data is the start of the tournament, so ages are off by up to two weeks for later
rounds.

## Tests

```r
devtools::test()
```

The tests never use the internet. They cover the cleaning functions with the mock female and male
files from the assignment, and a mock player page.
