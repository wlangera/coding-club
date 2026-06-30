library(httr2)
library(tidyverse)

## Pseudocode example
# Create request
req <-
  # Basic httr2 request object
  request("https://my.beautiful.api.org/") %>% # End point
  # Add parameters and queries pairs
  req_url_query(name = "Damiano Oldoni")
req

# Get response
resp <- req %>% req_perform()

# Read data
result <- resp %>%
  resp_body_json()

## Challenge 1
# Use httr2 to request the same GBIF data we visualised on our web browser.
#1.
match1 <- "https://api.gbif.org/v1/species/match?name=Passer%20domesticus"
req1 <- request("https://api.gbif.org/v1/species/match") %>%
  req_url_query(name = "Passer domesticus")
req1$url == match1

# Get result
result1 <- req1 %>%
  req_perform() %>%
  resp_body_json()
result1

#2.
match2 <- "https://api.gbif.org/v1/species/search?rank=SPECIES&highertaxon_key=212&limit=1000"
req2 <- request("https://api.gbif.org/v1/species/search") %>%
  req_url_query(
    rank = "SPECIES",
    highertaxon_key = 212,
    limit = "1000"
  )
req2$url == match2

# Get result
result2 <- req2 %>%
  req_perform() %>%
  resp_body_json()

# Thank you ChatGPT
species_df <- map_dfr(result2$results, \(x) tibble(
  key = x$key,
  scientificName = x$scientificName,
  canonicalName = x$canonicalName,
  authorship = x$authorship,
  kingdom = x$kingdom,
  phylum = x$phylum,
  class = x$class,
  order = x$order,
  family = x$family,
  genus = x$genus,
  species = x$species,
  rank = x$rank,
  taxonomicStatus = x$taxonomicStatus,
  extinct = x$extinct,
  numOccurrences = x$numOccurrences
))
head(species_df)

#3.
match3 <- "https://api.gbif.org/v1/species/search?rank=SPECIES&highertaxon_key=212&limit=1000&offset=1000"
req3 <- request("https://api.gbif.org/v1/species/search") %>%
  req_url_query(
    rank = "SPECIES",
    highertaxon_key = 212,
    limit = "1000",
    offset = 1000
  )
req3$url == match3

#4.
match4 <- "https://api.gbif.org/v1/dataset/7888f666-f59e-4534-8478-3a10a3bfee45"
req4 <- request("https://api.gbif.org/v1/dataset/7888f666-f59e-4534-8478-3a10a3bfee45")
req4$url == match4

#5.
match5 <- "https://api.gbif.org/v1/occurrence/1229395815"
req5 <- request("https://api.gbif.org/v1/occurrence/1229395815")
req5$url == match5

#6.
match6 <- "https://api.gbif.org/v1/occurrence/download/0073188-260519110011954"
req6 <- request("https://api.gbif.org/v1/occurrence/download/0073188-260519110011954")
req6$url == match6

## Challenge 2
# The Royal Meteorological Institute (KMI) share a lot of data openly via WFS.

#1. Get the available AWS stations (aws:aws_station).
req_aws <- request("https://opendata.meteo.be/service/ows") %>%
  req_url_query(
    service = "wfs",
    version = "2.0.0",
    request = "getFeature",
    typenames = "aws_station",
    outputformat = "json"
  )

# Get result
result_aws <- sf::st_read(req_aws$url)
mapview::mapview(result_aws)

#2. Same data, but this time try to save it on disk as a CSV file directly.
data_path <- "./data/20260630"
dir.create(data_path, recursive = TRUE, showWarnings = FALSE)

req_aws2 <- request("https://opendata.meteo.be/service/ows") %>%
  req_url_query(
    service = "wfs",
    version = "2.0.0",
    request = "getFeature",
    typenames = "aws_station",
    outputformat = "csv"
  )

req_perform(req_aws2, path = file.path(data_path, "aws_stations.csv"))

#3. Get daily meteorological data from the station ZEEBRUGGE from 2026-01-01 and save it directly to disk as CSV file.
zeebrugge_code <- result_aws %>%
  filter(tolower(name) == "zeebrugge") %>%
  pull(code)

req_zeebrugge <- request("https://opendata.meteo.be/service/ows") %>%
  req_url_query(
    service = "wfs",
    version = "2.0.0",
    request = "getFeature",
    typenames = "synop_data",
    # kan mooier ...:
    CQL_FILTER = paste0("code=", zeebrugge_code,
                        " AND timestamp during 2026-01-01T00:00:00Z/P1D"),
    outputformat = "csv"
  )

req_perform(req_zeebrugge, path = file.path(data_path, "data_zeebrugge.csv"))

#4. Get hourly meteorological data from the station of Diepenbeek from 2026-01-15 for a duration of 8 days.
# Get the data as CSV without saving it to disk.
req_diepenbeek <- request("https://opendata.meteo.be/service/ows") %>%
  req_url_query(
    service = "wfs",
    version = "2.0.0",
    request = "getFeature",
    typenames = "synop_data",
    CQL_FILTER = "code=6418 AND timestamp during 2026-01-15T00:00:00Z/P8D",
    outputformat = "csv"
  )

result_diepenbeek <- req_perform(req_diepenbeek) %>%
  resp_body_raw() %>%
  read_csv()
head(result_diepenbeek)
