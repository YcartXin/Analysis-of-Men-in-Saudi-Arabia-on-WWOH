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
follow_raw_data <- read_dta("data/raw_data/02_follow_up_clean.dta")
online_raw_data <- read_dta("data/raw_data/03_1st_online_svy_clean.dta")
sec_raw_data <- read_dta("data/raw_data/04_2nd_online_svy_clean.dta")

#taking out NA data from age variable as well as single men in the survey.
main_cleaned <- mainexp_raw_data |> clean_names() |> 
  na.omit(age)|> mutate(
  age_groups = case_when(
  age <= 23 ~ 1,
  age >= 30 ~ 3,
  TRUE ~ 2)) |> filter(married == 1)

follow_cleaned <- follow_raw_data |> clean_names() |> 
  na.omit(age) |>
  select(employed_3mos_out_fl, employed_now_out_fl) |> na.omit() 

online_cleaned <- online_raw_data |> clean_names() |> 
  select(c_outside_self)|>
  na.omit()

#### Save data ####
write_csv(main_cleaned, "data/analysis_data/main_cleaned.csv")
write_csv(follow_cleaned, "data/analysis_data/follow_cleaned.csv")
write_csv(online_cleaned, "data/analysis_data/online_cleaned.csv")

