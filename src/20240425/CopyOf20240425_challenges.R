library(tidyverse)


## CHALLENGE 1
# load data
obs <- readr::read_csv("./data/20240425/20240425_observations.csv")

# preview data
glimpse(obs)

# 1. Display first 8 rows; display the last 8 rows.
slice_head(obs, n = 8) # first
slice_tail(obs, n = 8) # last

# 2. Select columns observationLevel, eventStart, eventEnd and scientificName
obs %>%
  select("observationLevel", "eventStart", "eventEnd", "scientificName")

# 3. Display the distinct values of observationLevel as a data.frame with one
# column, observationLevel. How many different values of observationLevel are
# there?
obs %>%
  distinct(.data$observationLevel)

# how many?
obs %>%
  distinct(.data$observationLevel) %>%
  nrow()

# 4. How to remove observations with observationLevel = "media"? How to remove
# observations with observationLevel = "media" and empty scientificName?
obs %>%
  filter(.data$observationLevel != "media")

obs %>%
  filter(.data$observationLevel != "media",
         !is.na(.data$scientificName))

# 5. Add a new column called is_classified_by_human which is TRUE if
# classificationMethod is equal to "human". Add a new column month with the
# month of the observation (eventStart). Tip: use lubridate's month() and year()
# functions.

obs %>%
  mutate(is_classified_by_human = .data$classificationMethod == "human",
         month = month(.data$eventStart))

# 6. Move the column count after behavior.
obs %>%
  relocate("count", .after = "behavior")

# 7. Move all columns starting with "individual." before observationLevel
obs %>%
  relocate(starts_with("individual"), .before = "observationLevel")

# 8. Is the following statement true of false: Observations with
# observationLevel = "event" have no mediaID, i.e. mediaID is NA.
obs %>%
  filter(.data$observationLevel == "event") %>%
  pull("mediaID") %>%
  # are they all NA?
  is.na() %>%
  all()


## CHALLENGE 2 - Summaries







## CHALLENGE 3 - Two-table verbs

media <- read_csv("./data/20240425/20240425_media.csv", na = "")

# Preview
glimpse(media)







## BONUS CHALLENGE 1 - dplyr + tidyr = love

ias <- read_csv("./data/20240425/20240425_ias_plants.csv", na = "")

# Preview
glimpse(ias)




## BONUS CHALLENGE 2 - dplyr + stringr = love

a <- tibble::tibble(
  name = c("Damiano", "Amber", "Rhea", "Dirk", "Emma", "Raïsa"),
  my_favorite_number_string = c("104", "023", "7", "666", "3", "9")
)
a





## BONUS CHALLENGE 3 - dplyr + tidyverse packages = love

si_data <- readr::read_csv(
  file = "./data/20240425/20240425_si_species_per_year_cell.csv"
)





## BOUNS CHALLENGE 4 - dealing with lists? purrr!

library(jsonlite) # install it first, if needed
datapackage_json <-
  jsonlite::read_json("https://raw.githubusercontent.com/inbo/etn/main/inst/assets/datapackage.json")


