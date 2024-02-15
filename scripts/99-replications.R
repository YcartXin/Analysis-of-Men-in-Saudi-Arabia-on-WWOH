#### Preamble ####
# Purpose: Replication of three graphs in original paper.
# Author: Tracy Yang, Alex Sun
# Date: 12 February 2024
# Contact: ycart.yang@mail.utoronto.ca; boyalexsun@gmail.com
# License: MIT
# Pre-requisites: 01-data_cleaning.R

#### Workspace setup ####
library(tidyverse)

#### Load data ####
main_cleaned <-
  read_csv(
    file = here("data/analysis_data/main_cleaned.csv"))
sec_cleaned <-
  read_csv(
    file = here("data/analysis_data/sec_cleaned.csv"))


#### Replication of Table 2 Summary Statistics Table ####
#| echo: false
#| label: tbl-summ
#| tbl-cap: Summary Statistics on Men Who Participated in the Main Experiment
summary_stats <- main_cleaned |>
  group_by(condition2) |>
  summarize(
    Observations = n(),
    Age = mean(age, na.rm =TRUE),
    Children = mean(children, na.rm = TRUE),
    "College(%" = sum(college_deg, na.rm = TRUE)/n()*100,
    "Employed(%)" = sum(employed_now, na.rm = TRUE)/n()*100,
  ) |>
  bind_rows()|>
  mutate(group = c("Control", "Treatment"))

summary_stats |> kable()

summary_all <- main_cleaned |>
  summarize(
    Total = n(),
    Age = mean(age, na.rm =TRUE),
    Children = mean(children, na.rm = TRUE),
    "College" = sum(college_deg, na.rm = TRUE)/n()*100,
    "Employed(%)" = sum(employed_now, na.rm = TRUE)/n()*100)

summary_all |> kable()

#### Replication of Figure 2 Wedges in Perceptions of Others’ Beliefs: Main Experiment ####
#| echo: false
#| label: fig-time
#| fig-cap: Density Histogram of Percentage Wedge on Difference Between Beliefs and Actual Calculation
histogram <- main_cleaned |>
  mutate(percentage_wedge = outside_wedge/30*100)

p <- ggplot(histogram, aes(x = percentage_wedge)) + 
  geom_histogram(aes(y = after_stat(density)), binwidth = 8, fill = "green", alpha = 0.6, color = "black") + 
  labs(
    x = "Percentage Wedge Value",
    y = "Density") + 
  theme_minimal() +
  theme(plot.caption = element_text(hjust = 0, face = "italic", size = 10),
        plot.caption.position = "plot") +
  scale_x_continuous(limits = c(-100, 100))

print(p)

#### Replication of Figure 8 Panel A. Frequency of discussion on WWOH  ####
chart <- sec_cleaned |>
  mutate(freq = case_when(
    discuss_freq == 1 ~ "Very Often",
    discuss_freq == 2 ~ "Often",
    discuss_freq == 3 ~ "Sometimes",
    discuss_freq == 4 ~ "Rarely",
    discuss_freq == 5 ~ "Very Rarely"))

chart |>
  ggplot(mapping = aes(x = freq)) +
  geom_bar() +
  theme_minimal() +
  labs(x = "Age group", y = "Number of observations")

