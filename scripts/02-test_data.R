#### Preamble ####
# Purpose: Cleans the downloaded Saudi Arabia survey data for married men on giving consent to wife working outside of home.
# Author: Tracy Yang, Alex Sun
# Date: 12 February 2024
# Contact: ycart.yang@mail.utoronto.ca; boyalexsun@gmail.com
# License: MIT
# Pre-requisites: None


#### Workspace setup ####
library(tidyverse)

#### Importing  ####
online_cleaned <-
  read_csv(
    file = here("data/analysis_data/online_cleaned.csv"))
main_cleaned <-
  read_csv(
    file = here("data/analysis_data/main_cleaned.csv"))
follow_cleaned <-
  read_csv(
    file = here("data/analysis_data/follow_cleaned.csv"))
sec_cleaned <-
  read_csv(
    file = here("data/analysis_data/sec_cleaned.csv"))\

#### Testing Data ####
## Online Cleaned Tests ##
online_cleaned$c_outside_self |> unique() |> length() == 2
online_cleaned$c_outside_self |> max() == 1
online_cleaned$c_outside_self |> min() == 0

# Main Cleaned Tests ##

main_cleaned$education |> max() == 9
main_cleaned$education |> min() == 3
main_cleaned$age |> min() == 18
main_cleaned$outside_self |> unique() == 2
main_cleaned$condition2 |> unique() == 2
main_cleaned$college_deg |> class() == "numeric"
main_cleaned$employed_now |> min() == 0
main_cleaned$outside_wedge |> min() == -29

# Follow-up tests
follow_cleaned$emply_prev |> unique() == 2
follow_cleaned$emply_now |> unique() == 2
follow_cleaned$condition2 |> unique() == 2
follow_cleaned$condition2 |> class() == "numeric"

# Online survey tests
sec_cleaned$discuss_freq |> max() == 5
sec_cleaned$discuss_freq |> min() == 1
sec_cleaned$discuss_freq |> unique() |> length() == 5
