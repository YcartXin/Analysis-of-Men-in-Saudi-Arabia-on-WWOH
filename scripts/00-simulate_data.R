#### Preamble ####
# Purpose: Simulates possible data of married men in Saudi Arabia on giving consent to their wife working outside of home as well as their speculation on others' opinions.
# Author: Tracy Yang, Alex Sun
# Date: 12 February 2024
# Contact: ycart.yang@mail.utoronto.ca; boyalexsun@gmail.com
# License: MIT
# Pre-requisites: None


#### Workspace setup ####
library(tidyverse)

#### Simulate data ####
set.seed(11)

age <- round(runif(500, min = 18, max = 35))
consent_own <- c(1, 0)
consent_spec <- c(0:29)
educ <- c(1,0)

simulated_data <- tibble(age, consent_self = sample(
  consent_own, 500, replace = TRUE),
  consent_speculation = sample(consent_spec, 500, replace = TRUE),
  education = sample(educ, 500, replace = TRUE)
  )

#### Testing Simulated Data ####
simulated_data$age |> max() == 35
simulated_data$consent_self |> unique() |> length() == 2
simulated_data$consent_speculation |> length() == 500
simulated_data$education |> class() == "numeric"

