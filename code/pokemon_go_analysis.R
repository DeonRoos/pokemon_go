# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ #

# Authors: Ross Kwok & Deon Roos
# Purpose: Analysis of pokemon go evolutions to try and understand how CP is dictated
## E.g. What is the code/equation that devs use to determine CP after evolving
## Data entry is much faster after devs added a "preview" of final CP for an evolution
## Sample is of an individual pokemon
## NB that a single pokemon can have multiple obs
## E.g. if purified can have pre- post purification CP levels
## E.g. if starting CP is boosted
# Ongoing work - just for fun in personal time.

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ #

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
df$patch <- factor(df$patch)
df$pokemon <- factor(df$pokemon)
df$type <- factor(df$type)
df$type_2 <- factor(df$type_2)
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
               x = starting_cp,
               fill = cost_evolve)) +
  geom_abline(intercept = 0, slope = 2, 
              linetype = 2, linewidth = 1) +
  geom_jitter(pch = 21, colour = "black", alpha = 0.3,
              size = 2, height = 0, width = 5) +
  scale_fill_viridis_c(option = "C", direction = -1) +
  coord_fixed() +
  labs(y = "Final CP",
       x = "Starting CP",
       fill = "Cost to\nevolve",
       caption = "Dashed line shows a 1:2 return\n(e.g. 100 starting cp to 200 final cp)")

# Little test model to see how close abline is to estimated fit of simple model
coef(lm(final_cp ~ starting_cp, data = df))[2] # Ca. 1.5

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
ggplot(df, aes(y = final_cp,
               x = patch)) +
  geom_boxplot() +
  geom_jitter(height = 0, width = 0.1, alpha = 0.3) +
  labs(y = "Final CP",
       x = "'Patch'")

## vs starting CP, type and type2
ggplot(df, aes(y = final_cp,
               x = starting_cp,
               colour = num_evo)) +
  geom_point(alpha = 0.3) +
  facet_grid(type_2 ~ type) +
  labs(y = "Final CP",
       x = "Starting CP") +
  theme_bw()

### Post evolve CP -------------------------------------------------------------

## As density plot/histogram
ggplot(df, aes(x = cp_diff)) +
  geom_density() +
  geom_vline(xintercept = mean(df$cp_diff), 
             linetype = 2) +
  labs(x = "CP difference",
       y = "Density",
       caption = "Dashed line shows mean")

## vs starting CP
ggplot(df, aes(y = cp_diff,
               x = starting_cp,
               fill = cost_evolve)) +
  # geom_abline(intercept = coef(lm(cp_diff ~ starting_cp, data = df))[1], slope = coef(lm(cp_diff ~ starting_cp, data = df))[2], 
  #             linetype = 2, linewidth = 1) +
  geom_abline(intercept = 0, slope = 1, 
              linetype = 2, linewidth = 1) +
  geom_jitter(pch = 21, colour = "black", alpha = 0.3,
              size = 2, height = 0, width = 5) +
  scale_fill_viridis_c(option = "C", direction = -1) +
  coord_fixed() +
  labs(y = "CP difference",
       x = "Starting CP",
       fill = "Cost to\nevolve",
       caption = "Dashed line shows slope estimate")

# Little test model to see how close abline is to estimated fit of simple model
 # Ca. 0.4

## vs cost to evolve
ggplot(df, aes(y = cp_diff,
               x = cost_evolve)) +
  geom_jitter(height = 0, width = 5, alpha = 0.3) +
  labs(y = "CP difference",
       x = "Cost to evolve")

## vs player level
ggplot(df, aes(y = cp_diff,
               x = player_level)) +
  geom_point(aes(colour = player), 
             show.legend = TRUE) +
  labs(y = "CP difference",
       x = "Player level",
       colour = "Player")

## vs evolve stone
ggplot(df, aes(y = cp_diff,
               x = evolve_stone)) +
  geom_boxplot() +
  geom_jitter(height = 0, width = 0.1, alpha = 0.3) +
  labs(y = "CP difference",
       x = "Evolve stone required")

## vs player level
ggplot(df, aes(y = cp_diff,
               x = reorder(pokemon, -cp_diff))) +
  geom_boxplot() +
  labs(y = "CP difference",
       x = "Pokemon") +
  theme(axis.text.x = element_text(angle = 90, 
                                   vjust = 0.5, 
                                   hjust = 1))

## vs patch
### Note that the exact versions are unknown for older data
ggplot(df, aes(y = cp_diff,
               x = patch)) +
  geom_boxplot() +
  geom_jitter(height = 0, width = 0.1, alpha = 0.3) +
  labs(y = "CP difference",
       x = "'Patch'")

## vs starting CP, type and type2
ggplot(df, aes(y = cp_diff,
               x = starting_cp,
               colour = num_evo)) +
  geom_point(alpha = 0.3) +
  facet_grid(type_2 ~ type) +
  labs(y = "CP difference",
       x = "Starting CP",
       colour = "Number of\nevolutions") +
  theme_bw()

# Analysis: --------------------------------------------------------------------

# What determines final CP? ----------------------------------------------------

# Modelled as a Normal distribution generalised additive model
# Allows non-linear relationships between final_cp and covariate
# covariates included in `s()` are allowed to be non-linear
# With k = X controlling how "wiggly" relationship can be (higher k = more wiggly)
# s(bs = "re") allows for the relationships to vary between pokemon, but only the
# variation that pokemon causes (only variation, not mean)
m1 <- gam(final_cp ~ s(starting_cp, by = num_evo, k = 3) + 
            evolve_stone + 
            s(cost_evolve, k = 5) + 
            s(player_level, k = 5) +
            s(pokemon, bs = "re"), 
          family = gaussian(link = "log"),
          data = df)

# Model summary
# Note we're not checking assumptions etc.
summary(m1)

# Plot the predictions from the model
# Red dots = raw data
plot(ggpredict(m1), add.data = TRUE)
plot(m1, 
     seWithMean = TRUE, 
     shift = coef(m1)[1], 
     shade = TRUE,
     shade.col = "lightblue",
     residuals = TRUE,
     pch = 16, 
     cex = 0.2,
     pages = 1)

# What determines the difference in CP from start to final CP? -----------------

m2 <- gam(cp_diff ~ s(starting_cp, by = num_evo, k = 3) + 
            evolve_stone + 
            s(cost_evolve, k = 5) + 
            s(player_level, k = 5) +
            s(pokemon, bs = "re"), 
          select = TRUE,
          data = df)

summary(m2)
plot(ggpredict(m2), add.data = TRUE)
plot(m2, 
     seWithMean = TRUE, 
     shift = coef(m2)[1], 
     shade = TRUE,
     shade.col = "lightblue",
     residuals = TRUE,
     pch = 16, 
     cex = 0.2,
     pages = 1)

# How does type influence difference in CP? ------------------------------------

m3 <- lm(cp_diff ~ type, 
         data = df)

summary(m3)

plot(ggpredict(m3), add.data = TRUE)

# Simple model to check interaction --------------------------------------------

m4 <- lm(final_cp ~ starting_cp : cost_evolve, 
         data = df)

summary(m4)

nu_data <- expand.grid(
  starting_cp = seq(from = min(df$starting_cp), to = max(df$starting_cp), length.out = 50),
  cost_evolve = seq(from = min(df$cost_evolve), to = max(df$cost_evolve), length.out = 50)
)

nu_data$fit <- predict(m4, newdata = nu_data)

df$resid <- df$final_cp - predict(m4)

ggplot() +
  geom_tile(data = nu_data, 
            aes(x = starting_cp, y = cost_evolve, fill = fit)) +
  geom_point(data = df, 
             aes(x = starting_cp, y = cost_evolve, colour = resid, size = abs(resid))) +
  scale_fill_viridis_c(option = "C") +
  scale_colour_gradient2() +
  scale_size(range = c(0.5, 3), limits = c(0, NA)) +
  labs(x = "Starting CP",
       y = "Cost to evolve",
       fill = "Predicted\nfinal CP",
       colour = "Difference in CP\nbetween final\nCP and prediction",
       size = "Absolute residual")
