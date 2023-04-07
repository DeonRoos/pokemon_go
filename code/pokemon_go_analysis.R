library(googlesheets4)

df <- read_sheet("https://docs.google.com/spreadsheets/d/1EWzGk_qDK8ommXYz2jxYvFSSEzj9Wal976dWRwR4_0w/edit?usp=sharing")

library(ggplot2)
theme_set(theme_classic())

df$cp_lambda <- log(df$final_cp) - log(df$starting_cp)

ggplot(df, aes(x = cost_evolve, y = cp_lambda, colour = factor(number_evolutions))) +
  geom_point() +
  geom_smooth(method = "lm")

ggplot(df, aes(x = starting_cp, y = final_cp, colour = factor(number_evolutions))) +
  geom_point() +
  geom_smooth(method = "lm")

df$num_evo <- factor(df$number_evolutions)
df$patch <- factor(df$new)
df$pokemon <- factor(df$pokemon)

library(lme4)
library(mgcv)
m1 <- gam(final_cp ~ s(starting_cp, k = 5) + 
            num_evo * evolve_stone + 
            s(cost_evolve, k = 5) + 
            s(player_level, k = 5) +
            s(pokemon, bs = "re"), data = df)

summary(m1)

library(ggeffects)
plot(ggpredict(m1))

m2 <- gam(cp_lambda ~ s(starting_cp) + num_evo * evolve_stone + s(cost_evolve, k = 5) + s(pokemon, bs = "re"), data = df)

summary(m2)

library(ggeffects)
plot(ggpredict(m2))
