#### Preamble ####
# Purpose: Downloads and saves the data from [...UPDATE THIS...]
# Author: Rohan Alexander [...UPDATE THIS...]
# Date: 11 February 2023 [...UPDATE THIS...]
# Contact: rohan.alexander@utoronto.ca [...UPDATE THIS...]
# License: MIT
# Pre-requisites: [...UPDATE THIS...]
# Any other information needed? [...UPDATE THIS...]


#### Workspace setup ####)
library(tidyverse)
library(haven)
# [...UPDATE THIS...]

#### Download data ####
raw_wwoh_data <-
  read_dta(
    file = "data/raw_data/01_main_exp_clean.dta"
  )

#### Save data ####
# [...UPDATE THIS...]
# change the_raw_data to whatever name you assigned when you downloaded it.
#write_csv(the_raw_data, "data/raw_data/01_main_exp_clean.dta") 

         
