library(tidyverse)
library(patchwork) # challenge 1
library(ggforce)   # challenge 2
library(gganimate) # challenge 3
library(plotly)    # challenge 3

## preliminary code to run

# read datasets
ias_be <- read_tsv("./data/20230425/20230425_ias_first_observed_BE.txt",
                   na = ""
)

ias_regions <- read_tsv(
  "./data/20230425/20230425_ias_first_observed_regions.txt",
  na = ""
)

ias_pathways <- read_tsv("./data/20230425/20230425_ias_pathways_count.txt",
                         na = "")

area_biotopes <- read_csv(
  "./data/20230425/20230425_area_biotopes.txt", na = "",
  col_types = cols(year = col_integer())
)

# create basic plots

# number of IAS observed for the first time within time interval of 5 years at
# national level
ias_first_obs_be <-
  ggplot(ias_be) +
  geom_histogram(aes(x = first_observed),
                 binwidth = 5,
                 position = "dodge"
  )
ias_first_obs_be

# number of IAS observed for the first time within time interval of 5 years at
# regional level
ias_first_obs_reg <-
  ggplot(ias_regions) +
  geom_histogram(aes(x = first_observed, fill = locationId),
                 binwidth = 5,
                 position = "dodge"
  )
ias_first_obs_reg


# number of IAS introduced per pathway and time interval (bin width = 5 years)
# from 1950
ias_first_obs_paths <- ggplot(ias_pathways) +
  geom_point(mapping = aes(x = first_observed,
                           y = n,
                           color = pathway),
             shape = 1,
             size = 3) +
  geom_line(mapping = aes(x = first_observed,
                          y = n,
                          # group argument tells R  which points have to be linked together to form a line
                          group = pathway,
                          color = pathway)) +
  labs(x = "year of introduction", y = "number of taxa") +
  theme(axis.text.x = element_text(angle = 70, vjust = 0.5))

ias_first_obs_paths


## CHALLENGE 1
# Solution Ward
# 1
ias_first_obs_be + ias_first_obs_reg

# 2
ias_first_obs_be / ias_first_obs_reg

# 3
ias_first_obs_reg_facets <- ias_first_obs_reg +
  facet_wrap(~locationId) +
  theme(legend.position = "bottom")

ias_first_obs_be / ias_first_obs_reg_facets

# 4
ias_first_obs_be_facets <- ias_first_obs_be +
  facet_wrap(~kingdom)

ias_first_obs_reg_facets2 <- ias_first_obs_reg_facets +
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust = 1))

(ias_first_obs_be / ias_first_obs_reg_facets2) | ias_first_obs_be_facets

# 5
tab <- ias_regions %>%
  count(locationId) %>%
  arrange(locationId)

ias_first_obs_reg_facets2 + gridExtra::tableGrob(tab)

## CHALLENGE 2



## CHALLENGE 3A



## CHALLENGE 3B


