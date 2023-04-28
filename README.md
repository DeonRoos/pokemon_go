# Pokemon Go

A repository for [Tom Price](https://twitter.com/thomasnprice), [Ross Kwok](https://twitter.com/KwokRTK93) and [Deon Roos](https://twitter.com/DeonRoos88) to mess around with programming and statistics using data collected from Pokemon Go and evolutions. The question loosely revolves around trying to determine the developer choices in a game whereby characters (pokemon) can be "evolved" to gain additional power. Clearly the developers included some rules (i.e. equations) to govern this process which is what, playfully, we are trying to understand.

> This repository is purely used as a test bed for various programming and statistics related activities.

## Data entry

Googlesheets document to upload the data is [here](https://docs.google.com/spreadsheets/d/1EWzGk_qDK8ommXYz2jxYvFSSEzj9Wal976dWRwR4_0w/edit?usp=sharing).

Data includes:

* player (Player name)
* player_level (Player level)
* pokemon	(Pokemon being evolved)
* type (Primary type of pokemon being evolved)
* type_2 (Secondary type of pokemon being evolved)
* special	(No (n), yes (y) [yes includes shiny, purified, region variant, reward, lucky, etc.])
* starting_star_rating (Star rating of pokemon prior to evolving [0 to 4 stars])
* number_evolutions (Number of evolutions required for final form [max is 2])
* evolution_transition (Transitioning from 1st to 2nd (1), 2nd to 3rd (2), etc.)
* cost_evolve (Cost, in candies, to evolve pokemon [includes discount from purifying])
* evolve_stone (Requires stone to evolve? yes [y] no [n])
* starting_cp	(Combat Power [CP] of pokemon prior to evolving)
* final_cp (CP of pokemon post evolution)
* cp_diff (CP difference between evolution)
* patch (Version of Pokemon Go [0 is "old" version from ca. 2019, 1 is "new" version from ca. 2023])

[<img alt="alt_text" width="40px" src="images/image.PNG" />](https://www.google.com/)
