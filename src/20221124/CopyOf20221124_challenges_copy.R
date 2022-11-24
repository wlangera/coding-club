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
# 1. Read in file
tmin_max <- rast(paste0(data_path, "20221124_wc2.1_10m_tmin_tmax_01.tif"))

#2. How many layers does it contain? What are their names? What is the CRS?
# The extent? The resolution?
tmin_max

# 3. Rename the layers: wc2.1_10m_tmin_01 to tmin_01, wc2.1_10m_tmax_01 to
# tmax_01.
names(tmin_max) <- c("tmin_01", "tmax_01")

# 4. Plot the raster
plot(tmin_max)

# 5. Calculate the difference tmax - tmin and store it as a new raster called
# tdiff_tmax_tmin. How is called the layer? Rename it as tdiff_01
tdiff_tmax_tmin <- tmin_max$tmax_01 - tmin_max$tmin_01
tdiff_tmax_tmin
plot(tdiff_tmax_tmin)

names(tdiff_tmax_tmin) <- "tdiff_01"

# 6. Save the one layer raster tdiff_tmax_tmin as a new GeoTIFF (*.tif) file:
# 20221124_tdiff_tmax_tmin_01.tif

writeRaster(tdiff_tmax_tmin,
            paste0(data_path, "20221124_tdiff_tmax_tmin_01.tif"))

# 7. Add minimum and maximum temperature as two extra layers to tdiff_tmax_tmin
tdiff_tmax_tmin <- c(tdiff_tmax_tmin, tmin_max)

# 8. Save the three layer raster: overwrite 20221124_tdiff_tmax_tmin_01.tif
writeRaster(tdiff_tmax_tmin,
            paste0(data_path, "20221124_tdiff_tmax_tmin_01.tif"),
            overwrite = TRUE)

# 9. After loading country boundaries as polygons (code provided!), calculate
# the minimum and maximum values of all layers in tdiff_tmax_tmin for each
# country. The output is a data.frame. Tip: use exactextractr::exact_extract()
# and find the right summary operations

# Load country boundaries as spatial polygons (sf package)
w <- sf::st_as_sf(geodata::world(resolution = 5, level = 0, path = tempdir()))
w
plot(w)

min_max_temp <- exactextractr::exact_extract(tdiff_tmax_tmin, w,
                                             c("minority", "majority"))

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
