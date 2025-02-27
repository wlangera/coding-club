# CHALLENGE 1 functions

get_obs_2010 <- function(species) {
  # set scientific name to lowercase
  species <- tolower(species)
  # replace spaces with underscores
  species <- str_replace_all(
    species,
    pattern = " ",
    replacement = "_"
  )

  ## compose filename
  file_name <- paste0("20220630_", species, "_2010", ".txt")

  ## read file
  obs_2010 <- read_tsv(paste0("./data/20220630/",
                              file_name))
  return(obs_2010)
}

get_obs <- function(species, year) {
  # set scientific name to lowercase
  species <- tolower(species)
  # replace spaces with underscores
  species <- str_replace_all(
    species,
    pattern = " ",
    replacement = "_"
  )

  ## compose filename
  file_name <- paste0("20220630_", species, "_", year, ".txt")

  ## read file
  obs <- read_tsv(paste0("./data/20220630/",
                         file_name))
  return(obs)
}

# Extra 1:
# use require() within a function to be sure you load all packages you need
get_obs <- function(
    species,
    year
) {
  require(readr)
  require(stringr)

  ## set scientific name to lowercase
  species <- tolower(species)
  ## replace spaces with underscores
  species <- str_replace_all(
    species,
    pattern = " ",
    replacement = "_"
  )

  ## compose filename
  file_name <- paste0("20220630_", species, "_", year, ".txt")

  ## read file
  obs <- read_tsv(paste0("./data/20220630/",
                                  file_name))

  return(obs)
}

# Extra 2: use assertthat() to check the passed arguments
get_obs <- function(
    species,
    year
) {
  require(readr)
  require(stringr)
  require(assertthat)

  # check arguments species and year
  assert_that(is.character(species))
  assert_that(is.numeric(year))

  ## set scientific name to lowercase
  species <- tolower(species)
  ## replace spaces with underscores
  species <- str_replace_all(
    species,
    pattern = " ",
    replacement = "_"
  )

  ## compose filename
  file_name <- paste0("20220630_", species, "_", year, ".txt")

  ## read file
  obs <- read_tsv(paste0("./data/20220630/",
                         file_name))

  return(obs)
}


# Extra 3: in case you would like to specify a different root folder for your
# input data
get_obs_extra <- function(species, year, root_folder) {
  # set scientific name to lowercase
  species <- tolower(species)
  # replace spaces with underscores
  species <- str_replace_all(
    species,
    pattern = " ",
    replacement = "_"
  )

  ## compose filename
  file_name <- paste0("20220630_", species, "_", year, ".txt")

  ## read file using the specified root folder
  obs <- read_tsv(paste0(root_folder,
                         file_name))
  return(obs)
}

## CHALLENGE 2 functions

clean_data <- function(
  df,
  max_coord_uncertain = 1000,
  issues_to_discard = c("ZERO_COORDINATE",
                        "COORDINATE_OUT_OF_RANGE",
                        "COORDINATE_INVALID",
                        "COUNTRY_COORDINATE_MISMATCH"),
  occurrenceStatus_to_discard = c("absent","excluded")) {
  cleaned_df <-
    df %>%
    filter(coordinateUncertaintyInMeters < max_coord_uncertain |
             is.na(coordinateUncertaintyInMeters)) %>%
    filter(!issue %in% issues_to_discard) %>%
    filter(!occurrenceStatus %in% occurrenceStatus_to_discard)
  return(cleaned_df)
}

assign_eea_cell <- function(df, longitude_colname, latitude_colname) {
  #' if the function is composed of multiple steps but you think there is still
  #' no  need to split them in multiple functions, maybe you would like to
  #' provide some feedback about the progress of the function using `message()`
  message("Reprojection...")
  df <- df %>%
    mutate(x = !!sym(longitude_colname),
           y = !!sym(latitude_colname))
  df <- st_as_sf(df, coords = c("x", "y"), crs = 4326)
  df <-  st_transform(df, crs = 3035)
  coords <- st_coordinates(df) %>%
    as_tibble() %>%
    rename(x_3035 = X,
           y_3035= Y)
  df <-
    df %>%
    bind_cols(coords)
  message("Reprojection completed")

  message("Assign EEA cell code...")
  df <-
    df %>%
    mutate(eea_cell_code = paste0(
      "1km",
      "E", floor(x_3035/1000),
      "N", floor(y_3035/1000))) %>%
    select(-c(x_3035, y_3035))
  message("EEA cell code sucessfully assigned.")
  return(df)
}

get_n_obs_per_cell <- function(df) {
  n_obs_per_cell <-
    df %>%
    as_tibble() %>%
    group_by(eea_cell_code) %>%
    count()
  return(n_obs_per_cell)
}

add_n_obs_to_eea_grid  <- function(n_obs_per_cell, grid_cells) {
  # add number of observations via inner_join (cells with no obs automatically
  # excluded)
  be_grid_n_obs_ha_2010 <-
    grid_cells %>%
    inner_join(n_obs_per_cell,
               by = c("CELLCODE" = "eea_cell_code")
    )
}

## INTERMEZZO 2

# Here below an example of Roxygen documentation of a function applied to
# `get_n_obs_per_cell()`. The backbone of such documentation is automatically
# created by clicking on Code -> Insert Roxygen Skeleton


#' Calculate number of observations per grid cell
#'
#' This function takes a data.frame with observations and the EEA cells they
#' belong to and returns a summary data.frame counting the number of
#' observations contained in each cell.
#'
#' @param df a data.frame containing at least a column called `eea_cell_code`,
#'   used for grouping
#'
#' @return a data.frame
#' @export
#'
#' @examples
get_n_obs_per_cell <- function(df) {
  n_obs_per_cell <-
    df %>%
    as_tibble() %>%
    group_by(eea_cell_code) %>%
    count()
  return(n_obs_per_cell)
}

# Create your own help function by using docstring and moving the Roxygen
# documentation inside the function

get_n_obs_per_cell <- function(df) {
  #' Calculate number of observations per grid cell
  #'
  #' This function takes a data.frame with observations and the EEA cells they
  #' belong to and returns a summary data.frame counting the number of
  #' observations contained in each cell.
  #'
  #' @param df a data.frame containing at least a column called `eea_cell_code`,
  #'   used for grouping
  #'
  #' @return a summary data.frame
  #' @export
  #'
  #' @examples
  require(docstring)
  n_obs_per_cell <-
    df %>%
    as_tibble() %>%
    group_by(eea_cell_code) %>%
    count()
  return(n_obs_per_cell)
}

## CHALLENGE 3 function

visualize_obs_cells <- function(sf_df,
                                species,
                                year,
                                palette = "YlOrRd",
                                fill_color_opacity = 1) {
  pal <- colorBin(palette = palette,
                  domain = sf_df$n)
  labels <- sprintf(
    "EEA cell: %s<br/>Species: %s<br/>Number of observations: %g",
    sf_df$CELLCODE,
    species,
    sf_df$n) %>%
    lapply(HTML)
  leaflet(st_transform(sf_df, crs = 4326)) %>%
    addTiles() %>%
    addPolygons(
      fillColor = ~pal(n),
      weight = 1,
      opacity = fill_color_opacity,
      color = "purple",
      fillOpacity = 0.7,
      highlightOptions = highlightOptions(weight = 2,
                                          color = "black",
                                          fillOpacity = 1,
                                          bringToFront = TRUE),
      label =  labels,
      labelOptions = labelOptions(
        style = list("font-weight" = "normal", padding = "3px 8px"),
        textsize = "15px",
        direction = "auto")) %>%
    addLegend(title = sprintf("%s (%s)<br>Number of observations",
                              species, year),
              pal = pal,
              values = ~n)
}


## BONUS CHALLENGE

make_report <- function(species,
                        year,
                        max_coord_uncertain = 1000,
                        issues_to_discard = c("ZERO_COORDINATE",
                                              "COORDINATE_OUT_OF_RANGE",
                                              "COORDINATE_INVALID",
                                              "COUNTRY_COORDINATE_MISMATCH"),
                        occurrenceStatus_to_discard = c("absent","excluded"),
                        longitude_colname,
                        latitude_colname,
                        grid_cells,
                        palette = "YlOrRd",
                        fill_color_opacity = 1) {
  df_all_data <- get_obs(species, year)
  df_cleaned_data <- clean_data(df = df_all_data,
                                max_coord_uncertain,
                                issues_to_discard,
                                occurrenceStatus_to_discard)
  df_with_cellcode <- assign_eea_cell(df = df_cleaned_data,
                                      longitude_colname = longitude_colname,
                                      latitude_colname = latitude_colname)
  df_n_obs_cell <- get_n_obs_per_cell(df = df_with_cellcode)
  df_cells_with_obs <- add_n_obs_to_eea_grid (grid_cells = grid_cells,
                                      n_obs_per_cell = df_n_obs_cell)
  leaflet_map <- visualize_obs_cells(sf_df = df_cells_with_obs,
                      species = species,
                      year = year,
                      palette = palette,
                      fill_color_opacity = fill_color_opacity)
  return(list(df = df_n_obs_cell, map = leaflet_map))
}

make_report_improved <- function(
    species,
    year,
    max_coord_uncertain = 1000,
    issues_to_discard = c("ZERO_COORDINATE",
                          "COORDINATE_OUT_OF_RANGE",
                          "COORDINATE_INVALID",
                          "COUNTRY_COORDINATE_MISMATCH"),
    occurrenceStatus_to_discard = c("absent","excluded"),
    longitude_colname,
    latitude_colname,
    grid_cells,
    palette = "YlOrRd",
    fill_color_opacity = 1) {
  df_all_data <- get_obs(species, year)
  df_cleaned_data <- clean_data(df = df_all_data,
                                max_coord_uncertain,
                                issues_to_discard,
                                occurrenceStatus_to_discard)
  # add a control on number of rows of df_cleaned_data
  if (nrow(df_cleaned_data > 0)) {
    df_with_cellcode <- assign_eea_cell(df = df_cleaned_data,
                                        longitude_colname = longitude_colname,
                                        latitude_colname = latitude_colname)
    df_n_obs_cell <- get_n_obs_per_cell(df = df_with_cellcode)
    df_cells_with_obs <- add_n_obs_to_eea_grid (grid_cells = grid_cells,
                                        n_obs_per_cell = df_n_obs_cell)
    leaflet_map <- visualize_obs_cells(sf_df = df_cells_with_obs,
                        species = species,
                        year = year,
                        palette = palette,
                        fill_color_opacity = fill_color_opacity)
    return(list(df = df_n_obs_cell, map = leaflet_map))
  } else {
    warning("All observations are judged imprecise or suspected.")
    return(NULL)
  }
}
