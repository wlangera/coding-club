library(tidyverse)
library(sf)
library(rgbif)

## Challenge 1

# download GBIF occurrences of Chinese mitten crab (Eriocheir sinensis) in
# Belgium with valid coordinates
key <- "0043019-181108115102211"
crab_zipfile <- occ_download_get(key,
                                 path = "../data/20190226",
                                 overwrite = TRUE)

# unzip only occurrence file
crab_occs <- paste0(key, ".csv")
unzip(zipfile = crab_zipfile, files = crab_occs, exdir = "../data/20190226/.")

# read file in R as data.frame
crab_df <- read_tsv(paste0("../data/20190226/", crab_occs))

# unzip reference grids
unzip(zipfile = file.path(getwd(), "data/20190226", "20190226_utm10_bel.zip"),
      exdir = file.path(getwd(), "data/20190226", "20190226_utm10_bel"))

# read reference grid
be_10km <- file.path(getwd(), "data/20190226", "20190226_utm10_bel",
                      "be_10km.shp")
utm10bel <- st_read(be_10km)
st_layers(be_10km)

# create sf data.frame
spatial_crab_df <- st_as_sf(crab_df,
                            coords = c("decimalLongitude", "decimalLatitude"),
                            crs = 4326)

# compare crs of occurrences and grid
st_crs(utm10bel)
st_crs(spatial_crab_df)

## Challenge 2
# 1. How many occurrences of Chinese mitten crab in each cell SINCE 2015?

crabcounts <-
  utm10bel %>%
  st_join(spatial_crab_df %>%
            # hint: use the CRS of the POLYGONS!
            st_transform(crs = st_crs(utm10bel)),
          left = FALSE) %>%
  filter(year >= 2015) %>%
  group_by(CELLCODE) %>%
  summarise(number_occ = n()) %>%
  st_drop_geometry

crabcounts

# 2. Find the 5 cells with the highest number of occurrences.

crabcounts %>%
  arrange(desc(number_occ)) %>%
  slice(1:5)


