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



