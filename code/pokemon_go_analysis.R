# Authors: Ross Kwok & Deon Roos
# Purpose: Analysis of pokemon go evolutions to try and understand how CP is dictated
# Ongoing work - just for fun in personal time.


# Packages: --------------------------------------------------------------------
library(googlesheets4) # For loading in the data from google sheets
library(ggplot2)       # For data visualiations
library(lme4)          # For mixed effect linear models
library(mgcv)          # For non-linear models
library(ggeffects)     # For quick model figures

# Load the data from googlesheets (requires authorisation): --------------------
df <- read_sheet("https://docs.google.com/spreadsheets/d/1EWzGk_qDK8ommXYz2jxYvFSSEzj9Wal976dWRwR4_0w/edit?usp=sharing",
                 sheet = "Data", trim_ws = TRUE)

# Minor data tidy up: ----------------------------------------------------------
# Treat following as factors
df$player <- factor(df$player)
df$num_evo <- factor(df$number_evolutions) # Could be treated as number
df$patch <- factor(df$new)
df$pokemon <- factor(df$pokemon)
df$type <- factor(df$type)
df$type_2 <- factor(df$type_2)
df$patch <- factor(df$patch)
# Log difference growth rate in cp
df$cp_lambda <- log(df$final_cp) - log(df$starting_cp)
# Changing text shorthand for full word
df$evolve_stone <- factor(ifelse(df$evolve_stone == "y", "Yes", "No"))
df$special <- factor(ifelse(df$special == "y", "Yes", "No"))


# Set ggplot theme: ------------------------------------------------------------
theme_set(theme_classic())

# Plots of raw data: -----------------------------------------------------------

## Below are purely exploratory figures

### Starting CP ----------------------------------------------------------------

## As density plot/histogram
ggplot(df, aes(x = starting_cp)) +
  geom_density() +
  geom_vline(xintercept = mean(df$starting_cp), 
             linetype = 2) +
  labs(x = "Starting CP",
       y = "Density",
       caption = "Dashed line shows mean")

## vs cost to evolve
ggplot(df, aes(y = starting_cp,
               x = cost_evolve)) +
  geom_jitter(height = 0, width = 5, alpha = 0.3) +
  labs(y = "Starting CP",
       x = "Cost to evolve")

## vs player level
ggplot(df, aes(y = starting_cp,
               x = player_level)) +
  geom_point(aes(colour = player), 
             show.legend = TRUE) +
  labs(y = "Starting CP",
       x = "Player level",
       colour = "Player")

## vs evolve stone
ggplot(df, aes(y = starting_cp,
               x = evolve_stone)) +
  geom_boxplot() +
  geom_jitter(height = 0, width = 0.1, alpha = 0.3) +
  labs(y = "Starting CP",
       x = "Evolve stone required")

## vs player level
ggplot(df, aes(y = starting_cp,
               x = reorder(pokemon, -starting_cp))) +
  geom_boxplot() +
  labs(y = "Starting CP",
       x = "Pokemon") +
  theme(axis.text.x = element_text(angle = 90, 
                                   vjust = 0.5, 
                                   hjust = 1))

## vs patch
### Note that the exact versions are unknown for older data
ggplot(df, aes(y = starting_cp,
               x = patch)) +
  geom_boxplot() +
  geom_jitter(height = 0, width = 0.1, alpha = 0.3) +
  labs(y = "Starting CP",
       x = "'Patch'")

### Post evolve CP -------------------------------------------------------------

## As density plot/histogram
ggplot(df, aes(x = final_cp)) +
  geom_density() +
  geom_vline(xintercept = mean(df$final_cp), 
             linetype = 2) +
  labs(x = "Final CP",
       y = "Density",
       caption = "Dashed line shows mean")

## vs starting CP
ggplot(df, aes(y = final_cp,
               x = starting_cp)) +
  geom_abline(intercept = 0, slope = 2, 
              linetype = 2, linewidth = 1) +
  geom_jitter(height = 0, width = 5, alpha = 0.3) +
  labs(y = "Final CP",
       x = "Starting CP",
       caption = "Dashed line shows a 1:2 return\n(e.g. 100 starting cp to 200 final cp)")

## vs cost to evolve
ggplot(df, aes(y = final_cp,
               x = cost_evolve)) +
  geom_jitter(height = 0, width = 5, alpha = 0.3) +
  labs(y = "Final CP",
       x = "Cost to evolve")

## vs player level
ggplot(df, aes(y = final_cp,
               x = player_level)) +
  geom_point(aes(colour = player), 
             show.legend = TRUE) +
  labs(y = "Final CP",
       x = "Player level",
       colour = "Player")

## vs evolve stone
ggplot(df, aes(y = final_cp,
               x = evolve_stone)) +
  geom_boxplot() +
  geom_jitter(height = 0, width = 0.1, alpha = 0.3) +
  labs(y = "Final CP",
       x = "Evolve stone required")

## vs player level
ggplot(df, aes(y = final_cp,
               x = reorder(pokemon, -final_cp))) +
  geom_boxplot() +
  labs(y = "Final CP",
       x = "Pokemon") +
  theme(axis.text.x = element_text(angle = 90, 
                                   vjust = 0.5, 
                                   hjust = 1))

## vs patch
### Note that the exact versions are unknown for older data
ggplot(df, aes(y = starting_cp,
               x = patch)) +
  geom_boxplot() +
  geom_jitter(height = 0, width = 0.1, alpha = 0.3) +
  labs(y = "Final CP",
       x = "'Patch'")

## vs starting CP, type and type2
ggplot(df, aes(y = final_cp,
               x = starting_cp)) +
  geom_jitter(height = 0, width = 5, alpha = 0.3) +
  facet_grid(type_2 ~ type) +
  labs(y = "Final CP",
       x = "Starting CP") +
  theme_bw()

# Analysis: --------------------------------------------------------------------

# What determines final CP? ----------------------------------------------------

# Modelled as a Normal distribution generalised additive model
# Allows non-linear relationships between final_cp and covariate
# covariates included in `s()` are allowed to be non-linear
# With k = X controlling how "wiggly" relationship can be (higher k = more wiggly)
# s(bs = "re") allows for the relationships to vary between pokemon, but only the
# variation that pokemon causes (only variation, not mean)
m1 <- gam(final_cp ~ s(starting_cp, k = 5) + 
            num_evo * evolve_stone + 
            s(cost_evolve, k = 5) + 
            s(player_level, k = 5) +
            s(pokemon, bs = "re"), 
          data = df)

# Model summary
# Note we're not checking assumptions etc.
summary(m1)

# Plot the predictions from the model
# Red dots = raw data
plot(ggpredict(m1), add.data = TRUE)

# What determines the difference in CP from start to final CP? -----------------

m2 <- gam(cp_diff ~ s(starting_cp, k = 5) + 
            num_evo * evolve_stone + 
            s(cost_evolve, k = 5) + 
            s(player_level, k = 5) +
            s(pokemon, bs = "re"), 
          data = df)

summary(m2)
plot(ggpredict(m2), add.data = TRUE)

# How does type influence difference in CP? ------------------------------------

m3 <- lm(cp_diff ~ type, 
         data = df)

summary(m3)

plot(ggpredict(m3), add.data = TRUE)
