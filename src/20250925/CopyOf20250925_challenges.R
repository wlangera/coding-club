library(tidyverse)
library(rgbif)

# CHALLENGE 0 ####

# 1. You do not always need map()
height_giraffe <- runif(n = 5, min = 4.3, max = 5.7)
floor(height_giraffe)

# 2. But you do sometimes
# height of 5 giraffes
height_giraffe <- runif(n = 5, min = 4.3, max = 5.7)
# weight of 5 giraffes
weight_giraffe <- rnorm(n = 5, mean = 1192, sd = 300)
# data.frame with height and weight
df_giraffe <- tibble(height = height_giraffe,
                     weight = weight_giraffe)

colMeans(df_giraffe)
map(df_giraffe, mean)
map(df_giraffe, median)

# 3. More difficult example
# Height of 5 giraffes
height_giraffe <- runif(n = 6, min = 4.3, max = 5.7)
# Weight of 5 giraffes
weight_giraffe <- rnorm(n = 6, mean = 1192, sd = 300)
# GPS tracker ID
gps_tracker_giraffe <- c("B0G", "TRT", "4FB", "U7H", "31L", "O9Q")
# Giraffes nicknames
nicknames_giraffe <- sample(
  c("Oberon", "Raïsa", "Dirk", "Emma", "Damiano", "Rhea")
)
# List with weight, height and GPS tracker IDs. Use nicknames as list element names.
giraffes <- tibble::tibble("weight" = weight_giraffe,
                           "height" = height_giraffe,
                           "gpsID" = gps_tracker_giraffe) %>%
  transpose %>%
  set_names(nicknames_giraffe)
giraffes

bmi <- function(weight, height) weight / height^2

map(giraffes, function(giraffe) {
  bmi(giraffe$weight, giraffe$height)
})


# CHALLENGE 1 ####

species_df <- dplyr::tibble(
  species = c("Procyon lotor", "Nasua narica", "Muntiacus reevesis"),
  taxonKey = c(5218786, 2433536, 2440946)
)

# Get occurrence data for the given species in the
# Netherlands (country code "NL")
data_nl <- rgbif::occ_search(
  taxonKey = species_df$taxonKey,
  country = "NL",
  year = "1950,2025",
  hasCoordinate = TRUE,
  occurrenceStatus = "PRESENT",
  limit = 100000 # High enough
)
data_nl$`5218786`$data
data_nl$`2433536`$data
data_nl$`2440946`$data

## 1.1 ####
names(data_nl) <-  species_df$species
names(data_nl)

## 1.2 ####
map(data_nl, function(taxon) {
  nrow(taxon$data)
})

## 1.3 ####
map_int(data_nl, function(taxon) {
  nrow(taxon$data)
})

## 1.4 ####
map(data_nl, function(taxon) {
  taxon$data
}) %>%
  list_rbind() # why not bind_rows?

## 1.5 ####
countries <- c("NL", "AT", "ES", "DK")

get_gbif_occurrences <- function(taxon_keys, country_code) {
  rgbif::occ_search(
    taxonKey = taxon_keys,
    country = country_code,
    year = "1950,2025",
    hasCoordinate = TRUE,
    occurrenceStatus = "PRESENT",
    limit = 100000 # High enough
  )
}

data_countries <- map(
  countries,
  get_gbif_occurrences,
  taxon_keys = species_df$taxonKey
)

data_nl_og <- rgbif::occ_search(
  taxonKey = species_df$taxonKey,
  country = "NL",
  year = "1950,2025",
  hasCoordinate = TRUE,
  occurrenceStatus = "PRESENT",
  limit = 100000 # High enough
)

waldo::compare(data_countries[[1]], data_nl_og)

## 1.6 ####
# The input was not named
names(data_countries) <- countries

# Also rename second level
data_countries <- map(data_countries, function(country){
  names(country) <- species_df$species
  country
})

head(data_countries$NL$`Procyon lotor`$data)

# CHALLENGE 2 ####

## 2.1 ####
spec_records <- map(data_countries, function(country){
  map_vec(country, function(taxon) {
    data <- taxon$data
    if (is.null(data)) return(0)
    nrow(data)
  })
})
spec_records

## 2.2 ####
reduce(spec_records, sum)

## 2.3 ####
plot_records <- function(data, country, species) {
  if (is.null(data)) return(paste("No data for", species, "in", country))
  p <- ggplot2::ggplot(data = data) +
    ggplot2::geom_bar(ggplot2::aes(x = year)) +
    ggplot2::xlab("Year") +
    ggplot2::ylab("Number of records") +
    ggplot2::ggtitle(paste(species, country, sep = " - "))

  return(p)
}

map(data_list, function(country) {
  map(country, function(taxon) {
    data <- taxon$data
    species <- unique(data$species)
    country <- unique(data$countryCode)
    plot_records(data, species, country)
  })
})

# Use for loop
plot_records2 <- function(data_list, country, species) {
  plot_data <- data_list[[country]][[species]]$data
  if (is.null(plot_data)) return(paste("No data for", species, "in", country))
  p <- ggplot2::ggplot(data = plot_data) +
    ggplot2::geom_bar(ggplot2::aes(x = year)) +
    ggplot2::xlab("Year") +
    ggplot2::ylab("Number of records") +
    ggplot2::ggtitle(paste(species, country, sep = " - "))

  return(p)
}

for (country in names(data_list)) {
  for (species in names(data_list[[country]])) {
    print(plot_records2(data_list, country, species))
  }
}

## 2.4 ####
data_path <- file.path("src", "20250925")
map(data_list, function(country) {
  map(country, function(taxon) {
    data <- taxon$data
    if (!is.null(data)) {
      key <- unique(data$speciesKey)
      species <- unique(data$species)
      country <- unique(data$countryCode)
      file_name <- paste0(
        "20250925_gbif_", key, "_", species, "_", country, ".csv"
      )

      paste0("Writing '", file_name, "'.")
      write_csv(data, file.path(data_path, file_name))
    }
  })
})

## 2.5 ####
data_countries_df <- map(data_list, function(country) {
  map(country, function(taxon) {
    if (!is.null(taxon$data)) return(taxon$data)
  })
}) %>%
  list_c() %>%
  list_rbind()

head(data_countries_df)

# INTERMEZZO ####


a <- list(z = 1, b = NULL, c = 3)
purrr::compact(a)

purrr::list_c(a)



# CHALLENGE 3 ####

data_countries_df <- readr::read_csv(
  "./data/20250925/20250925_gbif_occs.csv",
  na = ""
)

data_nested <- data_countries_df %>%
  dplyr::group_by(species) %>%
  tidyr::nest()
data_nested

## 3.1 ####
ggplot2::ggplot(data_nested$data[[1]]) +
ggplot2::geom_bar(ggplot2::aes(x = year, fill = country)) +
  ggplot2::xlab("Year") +
  ggplot2::ylab("Number of records")


##3.2 ####


