# Load packages
library(tidyverse)

# Read in data
birds <- read_tsv("./data/20240130/20240130_bird_rings.txt")
sc_names <- read_csv("./data/20240130/20240130_scientificnames.txt")
sc_names <- sc_names$scientific_name


## Challenge 1
# Look at data
glimpse(birds)

#color_ring: column containing the color rings
#metal_ring: column containing the metal rings

#1.Get the length of the metal rings.
sort(unique(str_length(birds$metal_ring)))

#2. Do the color rings start with a "C"?
str_starts(birds$color_ring, "C")
all(str_starts(birds$color_ring, "C"))

#3. Do the color rings end with a "R"?
str_ends(birds$color_ring, "R")
all(str_ends(birds$color_ring, "R"))

#4. Are the color rings uppercase?
str_detect(birds$color_ring, "[a-z]", negate = TRUE)
all(str_detect(birds$color_ring, "[a-z]", negate = TRUE))

# without regex
birds$color_ring == str_to_upper(birds$color_ring)

#5. Solve all the anomalies found in (4) by setting all color rings uppercase.
birds <- birds %>%
  mutate(color_ring = str_to_upper(color_ring))
all(str_detect(birds_cleaned$color_ring, "[a-z]", negate = TRUE))

#6. Filter
birds %>%
  filter(str_length(metal_ring) == 6,
         str_starts(color_ring, "C"),
         str_ends(color_ring, "R"))


## Challenge 2
#1. Create a new column called color_ring_complete containing color ring
# information in this format:
# background_color+inscription_color+"("+color_ring+")", e.g. RW(FJAC)
birds <- birds %>%
  mutate(color_ring_complete = str_glue("{background_color}{inscription_color}",
                                        "({color_ring})"))

#2. Are the color rings 4-letter only long and is the third letter an "A"?
# 4 letters long
str_equal(str_length(birds$color_ring), 4)

# third letter
str_starts(birds$color_ring, "[a-zA-Z]{2}A")

# 4 letters AND third letter A
str_detect(birds$color_ring, "^[a-zA-Z]{2}A[a-zA-Z]$")

#3. Do the color rings contain at least a digit?
str_detect(birds$color_ring, "\\d")

#4. Create a new column called digit containing the first digit, if any,
# as a number.
birds <- birds %>%
  mutate(digit = as.numeric(str_match(color_ring, "\\d")[,1]))

#better
as.numeric(str_extract(birds$color_ring, "\\d"))

#5. By combining dplyr and stringr, select the birds whose color rings satisfy
# the condition in (2).
birds %>%
  filter(str_equal(str_length(color_ring), 4),
         str_starts(birds$color_ring, ".{2}A"))



