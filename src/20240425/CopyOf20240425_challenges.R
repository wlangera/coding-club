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
# 1. How many observations are there per deploymentID? Show it as a dataframe
# with two columns: deploymentID and n_obs.

obs %>%
  count(.data$deploymentID, name = "n_obs")

# 2. How many observations are there per deploymentID and observationLevel?

count_deploy_obslevel <- obs %>%
  count(.data$deploymentID, .data$observationLevel, name = "n_obs")
count_deploy_obslevel

# 3. Order the previous output per n_obs (descending order).

count_deploy_obslevel %>%
  arrange(desc(.data$n_obs))

# 4. Create a summary dataframe with the number of media-based observations
# (observationLevel = "media"), the number of event-based observations
# (observationLevel = "event") and the total number of observations per
# deploymentID. Notice that observationLevel is always filled in. The result
# should be a dataframe with 4 columns: deploymentID, n_obs_event, n_obs_media
# and n_obs. Tip: one way to solve this is by combining dplyr with tidyr.

obs %>%
  # count number of observations per deployment ID
  count(.data$deploymentID, .data$observationLevel) %>%
  # set to wide format
  pivot_wider(id_cols = "deploymentID",
              names_from = "observationLevel",
              values_from = "n",
              names_prefix = "n_obs_") %>%
  # sum observations across 2 columns
  rowwise() %>%
  mutate(n_obs = sum(c_across(c("n_obs_event", "n_obs_media"))))

# 5. For each month, year and deploymentID, return the eventStart of the first
# and the last event-based observation (observationLevel = event) if there are
# 3 or more event-based observations. Call these two columns first_event_obs and
# last_event_obs respectively.

obs %>%
  # get month and year using lubridate
  mutate(month = month(.data$eventStart),
         year = year(.data$eventStart)) %>%
  # only event-based observations
  filter(.data$observationLevel == "event") %>%
  # count number of observations per month, year, deploymentID
  group_by(.data$month, .data$year, .data$deploymentID) %>%
  mutate(n_obs = n()) %>%
  ungroup() %>%
  # only if there are 3 or more observations
  filter(.data$n_obs >= 3) %>%
  # get first and last observations per month, year, deploymentID
  group_by(.data$month, .data$year, .data$deploymentID) %>%
  summarise(first_event_obs = min(.data$eventStart),
            last_event_obs = max(.data$eventStart),
            .groups = "drop")

# shorter
obs %>%
  # get month and year using lubridate
  mutate(month = month(.data$eventStart),
         year = year(.data$eventStart)) %>%
  # only event-based observations
  filter(.data$observationLevel == "event") %>%
  # only if there are 3 or more observations
  filter(n() >= 3) %>%
  # get first and last observations per month, year, deploymentID
  group_by(.data$month, .data$year, .data$deploymentID) %>%
  summarise(first_event_obs = min(.data$eventStart),
            last_event_obs = max(.data$eventStart),
            .groups = "drop")

# 6. How can you return the same dataframe as in exercice 5 but now limiting us
# to the months with the highest number of event-based observations for each
# year and deploymentID?

obs %>%
  # get month and year using lubridate
  mutate(month = month(.data$eventStart),
         year = year(.data$eventStart)) %>%
  # only event-based observations
  filter(.data$observationLevel == "event") %>%
  # count number of observations per month, year, deploymentID
  group_by(.data$month, .data$year, .data$deploymentID) %>%
  mutate(n_obs = n()) %>%
  ungroup() %>%
  # only if there are 3 or more observations
  filter(.data$n_obs >= 3) %>%
  # keep only the months with the highest number of event-based observations
  group_by(.data$year, .data$deploymentID) %>%
  slice_max(.data$n_obs) %>%
  # get first and last observations per month, year, deploymentID
  group_by(.data$month, .data$year, .data$deploymentID) %>%
  summarise(first_event_obs = min(.data$eventStart),
            last_event_obs = max(.data$eventStart),
            .groups = "drop")


## CHALLENGE 3 - Two-table verbs
# load data
media <- read_csv("./data/20240425/20240425_media.csv", na = "")

# preview data
glimpse(media)

# 1. How to add the media information stored in media to the observations?

obs %>%
  full_join(media, by = join_by("mediaID"))

# 2. How are the columns ordered? Are the columns from observations on the left?
# Try to put them on the right.

media %>%
  full_join(obs, by = join_by("mediaID"))

# 3. Are there media not in observations, i.e. are there media that are not
# linked to any observation?

media %>%
  anti_join(obs, by = join_by("mediaID"))

# 4. Some observations have a missing value for column mediaID. Get rid of them
# while joining.

obs %>%
  right_join(media, by = join_by("mediaID"))

# 5. As deploymentID is present in both dataframes, it gets duplicated and the
# suffixes ".x" and ".y" are added. How to change the suffixes to "_obs" and
# "_media" while performing exercise 1?

obs %>%
  full_join(media, by = join_by("mediaID"), suffix = c("_obs", "_media"))

# 6. How to add the suffix only for the column deploymentID in media?

obs %>%
  full_join(media, by = join_by("mediaID"), suffix = c("", "_media"))

# 7. How can you avoid having this column twice?

obs %>%
  full_join(media, by = join_by("mediaID", "deploymentID"))


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


