#### Preamble ####
# Purpose: Cleans the downloaded Saudi Arabia survey data for married men on giving consent to wife working outside of home.
# Author: Tracy Yang, Alex Sun
# Date: 12 February 2024
# Contact: ycart.yang@mail.utoronto.ca; boyalexsun@gmail.com
# License: MIT
# Pre-requisites: None

#### Workspace setup ####
library(tidyverse)
library(janitor)
library(dplyr)
library(haven)

#### Clean data ####
mainexp_raw_data <- read_dta("data/raw_data/01_main_exp_clean.dta")
online_raw_data <- read_dta("data/raw_data/03_1st_online_svy_clean.dta")

#taking out NA data from age variable as well as single men in the survey.
main_cleaned <- raw_data |> clean_names() |> na.omit(age)|> mutate(
  age_groups = case_when(
  age <= 23 ~ 1,
  age >= 30 ~ 3,
  TRUE ~ 2)) |> filter(married == 1)

online_cleaned
#### Save data ####
write_csv(cleaned_data, "data/analysis_data/cleaned_data.csv")
