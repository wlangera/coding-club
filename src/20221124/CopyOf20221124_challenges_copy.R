library(tidyverse)
library(terra)
library(sf)
library(exactextractr)
library(geodata)

data_path <- "./data/20221124/"

## CHALLENGE 1
# 1. Read in file
lu_nara_2016 <- rast(paste0(data_path, "20221124_lu_nara_2016_100m.tif"))

# 2. Which layers (names) does it contain? What is the crs? The extent?
# The resolution? What are the minmax values of the raster?
lu_nara_2016

# 3. plot
plot(lu_nara_2016)

# 4. Read `20211125_lu_nara_legend.csv` (code is provided!) so that you can set
# the color table associated with `lu_nara_2016`.
legend <- read_csv(paste0(data_path, "20221124_lu_nara_legend.txt"),
  col_types = cols(
    id = col_double(),
    land_use = col_character(),
    color = col_character()
  ))
legend

plot(lu_nara_2016, type = "classes", col = legend$color,
     levels = legend$land_use)

lu_nara_2016_merge <- merge(lu_nara_2016, legend)

# 5. Calculate the most and least occurring land use category in each of the
# Natura2000 protected areas (read these areas using the provided code).
# Tip: use exactextractr::exact_extract() and find the right
# [summary operations](https://isciences.gitlab.io/exactextractr/#summary-operations)
natura2000 <- st_read("./data/20211125/20211125_protected_areas_Lambert72.gpkg",
                      layer = "ps_hbtrl")
plot(natura2000)

min_max_lu <- exactextractr::exact_extract(lu_nara_2016, natura2000,
                                           c("minority", "majority"))



## CHALLENGE 2


# Load country boundaries as spatial polygons (sf package)
w <- sf::st_as_sf(geodata::world(resolution = 5, level = 0, path = tempdir()))
w
plot(w)



## BONUS CHALLENGE 1




# 2. Let's do something similar working with continuous rasters. Calculate a
# dataframe with min max and mean altitude for each Belgian province using
#`exact_extract()`. How to include the province name in the output? (code to get
#the data is provided in R script!). Tip:
#https://isciences.gitlab.io/exactextractr/#basic-usage

# Pull province boundaries for Belgium
belgium <- st_as_sf(raster::getData('GADM', country='BE', level=2))

# Pull gridded altitude world data
alt <- raster::getData('worldclim', var='alt', res=10)
