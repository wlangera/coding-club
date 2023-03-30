library(tidyverse)

## CHALLENGE 1

# Read dataset about year of first observation of IAS in Belgium from 1950.
ias_be <- read_tsv(
  file = "./data/20230330/20230330_ias_first_observed_BE.txt",
  na = ""
)

# geom_bar() makes the height of the bar proportional to the number of cases in
# each group
# geom_col() makes the height of the bar represent values in the data
ias_be %>%
  filter(first_observed >= 1980) %>%
  ggplot() +
    geom_bar(aes(x = cut(first_observed, length(unique(first_observed)) / 5)),
             fill = "cornflowerblue", colour = "firebrick") +
    labs(x = "year of introduction", y = "number of taxa")


## Challenge 2

# IAS data at regional level
ias_regions <- read_tsv(
  "./data/20230330/20230330_ias_first_observed_regions.txt",
  na = ""
)

# 1
ias_regions %>%
  ggplot() +
    geom_bar(aes(x = first_observed, fill = locationId), colour = "black") +
    labs(x = "year of introduction", y = "number of taxa", fill = "location")

# 2
ias_regions %>%
  ggplot() +
    geom_bar(aes(x = first_observed, fill = locationId), position = "dodge") +
    labs(x = "year of introduction", y = "number of taxa", fill = "location")

# 3
ias_regions %>%
  ggplot() +
    geom_bar(aes(x = first_observed, fill = locationId), position = "dodge") +
    facet_wrap(~kingdom, scales = "free_y") +
    labs(x = "year of introduction", y = "number of taxa", fill = "location")

# 4
ias_regions %>%
  mutate(
    kingdom = factor(kingdom,
                     levels = c("Animalia", "Plantae", "Fungi", "Chromista"),
                     ordered = TRUE)
  ) %>%
  ggplot() +
    geom_bar(aes(x = first_observed, fill = locationId), position = "dodge") +
    facet_wrap(~kingdom, scales = "free_y") +
    labs(x = "year of introduction", y = "number of taxa", fill = "location")

# alternative solution
ias_regions %>%
  group_by(kingdom) %>%
  mutate(n = n()) %>%
  ungroup() %>%
  mutate(kingdom = reorder(kingdom, n, decreasing = TRUE)) %>%
  ggplot() +
    geom_bar(aes(x = first_observed, fill = locationId), position = "dodge") +
    facet_wrap(~kingdom, scales = "free_y") +
    labs(x = "year of introduction", y = "number of taxa", fill = "location")

# 5
ias_regions %>%
  group_by(kingdom) %>%
  mutate(n = n()) %>%
  ungroup() %>%
  mutate(kingdom = reorder(kingdom, n, decreasing = TRUE)) %>%
  ggplot() +
    geom_bar(aes(x = first_observed, fill = locationId), position = "dodge") +
    facet_grid(kingdom~locationId, scales = "free_y") +
    labs(x = "year of introduction", y = "number of taxa", fill = "location")



## CHALLENGE 3: Categorical variables

ias_path <- read_tsv("./data/20230330/20230330_ias_pathways.txt", na = "")

# 1
library(INBOtheme)

ias_path %>%
  ggplot() +
    geom_bar(aes(x = pathway, fill = kingdom),
             position = position_dodge2(padding = 0.1)) +
    labs(y = "number of taxa") +
    coord_flip()

# 2
# code for the 2nd exercise
bin <- 10

ias_path %>%
  mutate(bins_first_observed_label = floor(.data$first_observed / bin) * bin
  ) %>%
  mutate(bins_first_observed_label = paste(
    as.character(.data$bins_first_observed_label),
    "-",
    as.character(.data$bins_first_observed_label + bin - 1)
  )) %>%
  group_by(pathway, bins_first_observed_label) %>%
  mutate(n = n()) %>%
  ggplot(aes(x = bins_first_observed_label, y = n, colour = pathway)) +
    geom_point(shape = 1, size = 3) +
    geom_line(aes(group = pathway)) +
    labs(x = "time period", y = "number of taxa")


## BONUS CHALLENGE

ggplot(ToothGrowth, aes(x = factor(dose), y = len, color = supp)) +
  geom_boxplot() +
  geom_point(aes(group = supp),
             position = position_jitterdodge(jitter.width = 0.5)) +
  labs(x = "dose", y = "length")


