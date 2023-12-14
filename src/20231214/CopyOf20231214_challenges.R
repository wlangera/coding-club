library(tidyverse)
library(sf) # to deal with spatial vector data
library(qgisprocess)
library(terra) # to deal with raster data
library(mapview)   # optional: to easily create maps for visualization purposes

# Read `20231214_watersurfaces_hab.gpkg` using sf package
water <- sf::st_read("./data/20231214/20231214_watersurfaces_hab.gpkg",
                     layer = "watersurfaces_hab_polygons"
)

mapview(water)

# Read `20231214_habitatsprings.geojson`
hab_springs <- sf::st_read("./data/20231214/20231214_habitatsprings_flanders.geojson")

mapview(hab_springs)

## CHALLENGE 0
qgis_providers()

input <- sf::read_sf(system.file("shape/nc.shp", package = "sf"))

mapview(input)

result <- qgis_run_algorithm(
  "native:buffer",
  INPUT = input,
  DISTANCE = 1,
  DISSOLVE = TRUE
)
result
#> <Result of `qgis_run_algorithm("native:buffer", ...)`>
#> List of 1
#>  $ OUTPUT: 'qgis_outputVector' chr "C:\\Users\\WARD_L~1\\AppData\\Local\\Temp\\Rtmp00fnyU\\file79b8649561d8\\file79b81dced31.gpkg"

output_sf <- sf::st_as_sf(result)
plot(sf::st_geometry(output_sf))

mapview(output_sf)


## CHALLENGE 1
# 1.
qgis_get_argument_specs(algorithm = "native:buffer")
qgis_show_help(algorithm = "native:buffer")

result2 <- qgis_run_algorithm(
  "native:buffer",
  INPUT = input,
  DISTANCE = 1,
  DISSOLVE = FALSE
)
output_sf2 <- sf::st_as_sf(result2)

mapview(output_sf2)

#> Buffer per rij en bij DISOLVE = TRUE gaat hij eerst alles joinen tot 1
#> geometry

# 2.
qgis_algorithms() %>%
  filter(provider == "native",
         grepl("shortest", algorithm)) %>%
  select(provider, algorithm, algorithm_title)

# the same:
qgis_search_algorithms("shortest", provider = "native") %>%
  select(provider, algorithm, algorithm_title)

qgis_get_argument_specs(algorithm = "native:shortestline") %>%
  select(name, description)
qgis_show_help(algorithm = "native:shortestline")

springs_to_water <- qgis_run_algorithm(
  "native:shortestline",
  SOURCE = hab_springs,
  DESTINATION = water
)
springs_to_water_sf <- sf::st_as_sf(springs_to_water)
mapview(springs_to_water_sf)

# 3.
water_to_springs <- qgis_run_algorithm(
  "native:shortestline",
  SOURCE = water,
  DESTINATION = hab_springs
)
water_to_springs_sf <- sf::st_as_sf(water_to_springs)
mapview(water_to_springs_sf)

# 4.
qgis_run_algorithm(
  "native:shortestline",
  SOURCE = water,
  DESTINATION = hab_springs
  ) |>
  st_as_sf() |>
  mapview()

# also possible:
water |>
  qgis_run_algorithm_p(
    "native:shortestline",
    DESTINATION = hab_springs
  ) |>
  st_as_sf() |>
  mapview()

## INTERMEZZO

# Example

library(tictoc) # install it first, if needed

tic("buffer via sf")
buffer_via_sf <- sf::st_buffer(water, nQuadSegs = 5000, dist = 100)
toc()
#> buffer via sf: 25.95 sec elapsed

tic("buffer via qgisprocess")
buffer_via_qgisprocess <- qgis_run_algorithm(
  INPUT = water,
  algorithm = "native:buffer",
  SEGMENTS = 5000,
  DISTANCE = 100
)
toc()
#> buffer via qgisprocess: 22.75 sec elapsed

## CHALLENGE 2
# 1.
qgis_search_algorithms(algorithm = "count",
                       provider = "native") %>%
  select(provider, algorithm, algorithm_title)

qgis_get_argument_specs(algorithm = "native:countpointsinpolygon") %>%
  select(name, description)
qgis_show_help(algorithm = "native:countpointsinpolygon")

ludwigia_grandiflora <- st_read(paste0("./data/20231214/",
                                       "20231214_ludwigia_grandiflora.geojson"))

ludwigia_in_water <- qgis_run_algorithm(
  "native:countpointsinpolygon",
  POLYGONS = water,
  POINTS = ludwigia_grandiflora
  ) |>
  st_as_sf()

mapview(ludwigia_in_water)

# 2.
ludwigia_in_water_ind <- qgis_run_algorithm(
  "native:countpointsinpolygon",
  POLYGONS = water,
  POINTS = ludwigia_grandiflora,
  WEIGHT = "individualCount"
  ) |>
  st_as_sf()

mapview(ludwigia_in_water_ind)

waldo::compare(ludwigia_in_water, ludwigia_in_water_ind)

# 3.
qgis_get_argument_specs(algorithm = "native:buffer") %>%
  select(name, description)
qgis_show_help(algorithm = "native:buffer")

# following does not work:
# Error in `processx::run("cmd.exe", c("/c", "call", path, args), ...)`:
# ! System command 'cmd.exe' failed
# QGIS version too old (?)
buffer_springs <- hab_springs |>
  mutate(dynamic_buf = sqrt(area_m2 / pi)) |>
  qgis_run_algorithm_p(
    "native:buffer",
    DISTANCE = "dynamic_buf"
  ) |>
  st_as_sf()

mapview(buffer_springs)


## CHALLENGE 3

temperature <- terra::rast("./data/20231214/20231214_tdiff_tmax_tmin_january.tif")
temperature
# show first layer by default
mapview::mapview(temperature, maxpixels = 6998400) # it can take some seconds

land_use <- terra::rast("./data/20231214/20231214_land_use_nara_2016_100m.tif")
land_use
mapview::mapview(land_use, maxpixels = 3434753) #it can take some seconds

prot_areas <- sf::st_read("./data/20231214/20231214_natura2000_protected_areas.gpkg")
prot_areas
mapview::mapview(prot_areas)


