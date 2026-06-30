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

