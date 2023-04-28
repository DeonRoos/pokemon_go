![Pokemon_Go](https://user-images.githubusercontent.com/107560653/235102831-6254b0e1-d5b6-4394-9b7e-eae4d81dc4be.png)

A repository for [Tom Price](https://twitter.com/thomasnprice), [Ross Kwok](https://twitter.com/KwokRTK93) and [Deon Roos](https://twitter.com/DeonRoos88) to mess around with programming and statistics using data collected from Pokemon Go. The toy question loosely revolves around trying to determine the developer choices in a game whereby characters (pokemon) can be "evolved" to gain additional power. Clearly the developers included some rules (i.e. equations) to govern this process which is what, playfully, we are trying to understand.

> This repository is purely used as a test bed for R, git, md, statistical analysis and related activities.

## Repository guide

* `code` folder contains:
  + `pokemon_go_analysis.R` - An `R` script with visualisations and test analyses.
  + `prof_oak_analysis.Rmd` - An `Rmd` (R markdown) script with interactive visualisations and more focussed analyses.
  + `prof_oak_analysis.html` - The knit `Rmd` file to html.

## Data entry

To enter data, please go to [this](https://docs.google.com/spreadsheets/d/1EWzGk_qDK8ommXYz2jxYvFSSEzj9Wal976dWRwR4_0w/edit?usp=sharing) Googlesheets document.

Data includes:

* `player` (Player name)
* `player_level` (Player level)
* `pokemon`	(Pokemon being evolved)
* `type` (Primary type of pokemon being evolved)
* `type_2` (Secondary type of pokemon being evolved)
* `special`	(No (n), yes (y) [yes includes shiny, purified, region variant, reward, lucky, etc.])
* `starting_star_rating` (Star rating of pokemon prior to evolving [0 to 4 stars])
* `number_evolutions` (Number of evolutions required for final form [max is 2])
* `evolution_transition` (Transitioning from 1st to 2nd (1), 2nd to 3rd (2), etc.)
* `cost_evolve` (Cost, in candies, to evolve pokemon [includes discount from purifying])
* `evolve_stone` (Requires stone to evolve? yes [y] no [n])
* `starting_cp`	(Combat Power [CP] of pokemon prior to evolving)
* `final_cp` (CP of pokemon post evolution)
* `cp_diff` (CP difference between evolution)
* `patch` (Version of Pokemon Go [0 is "old" version from ca. 2019 and earlier, 1 is "new" version from ca. 2023 and on])

With thanks to Sarah, Cristian and Alex for providing data.

## Summary of data

![poke_summary](https://user-images.githubusercontent.com/107560653/235106670-8a20c31e-50c8-4daa-b0d8-d51e6b6fde74.png)

## Package dependencies

The various scripts within this repository make use of the following `R` packages (these should be installed and loaded to work on the various scripts):
* `googlesheets4` - For loading in the data from googlesheets (requires googlesheets account)
* `ggplot2` - For data visualiations
* `lme4`- For mixed effect linear models
* `mgcv` - For non-linear models
* `ggeffects`- For quick model figures
* `tidyverse`- For data manipulation
* `plotly` - For interactive plots
