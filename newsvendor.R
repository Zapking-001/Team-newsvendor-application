# Newsvendor Model: Umbrella Stocking - Complete R Analysis
# Data collection from Kaggle, cleaning, and optimization
# Pritham Prajwin V | BSD-BG-2512 | ISI Bangalore 2025-26

library(tidyverse)
library(ggplot2)

 
# STEP 1: DATA COLLECTION & LOADING

# Download from: https://www.kaggle.com/datasets/nelgiriyewithana/indian-weather-repository-daily-snapshot/version/231/data
# Alternative: wget/curl the CSV directly
# For this demo, we assume data is downloaded as 'weather_data.csv'

# If downloading via R (requires kaggle CLI setup):
# system('kaggle datasets download -d nelgiriyewithana/indian-weather-repository-daily-snapshot')
# unzip('indian-weather-repository-daily-snapshot.zip')

# Load raw data
weather_raw <- read.csv('weather_data.csv', stringsAsFactors = FALSE)
 
# STEP 2: DATA CLEANING & FILTERING
 

weather <- weather_raw %>%
  filter(location_name == "Bangalore") %>%
  mutate(date = as.Date(last_updated),
         precip_mm = as.numeric(precip_mm),
         month = lubridate::month(date),
         season = case_when(
           month %in% c(7,8,9) ~ "Peak Monsoon",
           month %in% c(6,10,11) ~ "Shoulder",
           TRUE ~ "Dry Season"
         )) %>%
  select(date, precip_mm, month, season) %>%
  arrange(date) %>%
  drop_na(precip_mm) %>%
  filter(precip_mm < 150)

 
# STEP 3: RAINFALL-TO-DEMAND MAPPING (Poisson Model)
 

weather <- weather %>%
  mutate(demand_dist = case_when(
    precip_mm < 2 ~ "Dry",
    precip_mm < 10 ~ "Light",
    precip_mm < 30 ~ "Moderate",
    TRUE ~ "Heavy"
  ),
  lambda = case_when(
    demand_dist == "Dry" ~ 5,
    demand_dist == "Light" ~ 25,
    demand_dist == "Moderate" ~ 55,
    demand_dist == "Heavy" ~ 90
  ),
  demand_est = rpois(n(), lambda))

 
# STEP 4: SEASONAL DEMAND STATISTICS
 

seasonal_stats <- weather %>%
  group_by(season) %>%
  summarise(
    n_days = n(),
    mu = mean(demand_est),
    sigma = sd(demand_est),
    pct_rainy = mean(precip_mm >= 2) * 100,
    .groups = 'drop'
  ) %>%
  arrange(factor(season, levels = c("Peak Monsoon", "Shoulder", "Dry Season")))

 
# STEP 5: NEWSVENDOR OPTIMIZATION
 

c_u <- 70
c_o <- 50
CR <- c_u / (c_u + c_o)

optimal_Q <- function(mu, sigma, CR) {
  round(mu + sigma * qnorm(CR))
}

expected_cost <- function(Q, mu, sigma, c_u, c_o) {
  z <- (Q - mu) / sigma
  std_loss <- dnorm(z) - z * (1 - pnorm(z))
  c_u * sigma * std_loss + c_o * sigma * (z + std_loss)
}

seasonal_results <- seasonal_stats %>%
  mutate(
    Q_star = optimal_Q(mu, sigma, CR),
    opt_cost = mapply(expected_cost, Q_star, mu, sigma, c_u, c_o),
    naive_cost = mapply(expected_cost, 50, mu, sigma, c_u, c_o),
    daily_savings = naive_cost - opt_cost,
    seasonal_savings = daily_savings * n_days
  ) %>%
  select(season, mu, sigma, Q_star, daily_savings, seasonal_savings)

 
# STEP 6: VISUALIZATION - COST CURVE (Peak Monsoon)
 

peak_data <- weather %>% filter(season == "Peak Monsoon")
mu_peak <- mean(peak_data$demand_est)
sigma_peak <- sd(peak_data$demand_est)
Q_star_peak <- optimal_Q(mu_peak, sigma_peak, CR)

Q_range <- seq(10, 150, by = 1)
costs <- sapply(Q_range, function(Q) expected_cost(Q, mu_peak, sigma_peak, c_u, c_o))

p1 <- ggplot(data.frame(Q = Q_range, Cost = costs), aes(x = Q, y = Cost)) +
  geom_line(size = 1.2, color = "#1B2A4A") +
  geom_point(aes(x = Q_star_peak, y = expected_cost(Q_star_peak, mu_peak, sigma_peak, c_u, c_o)),
             size = 4, color = "#C9A84C") +
  geom_vline(xintercept = Q_star_peak, linetype = "dashed", color = "#C9A84C", size = 1) +
  annotate("text", x = Q_star_peak + 5, y = expected_cost(Q_star_peak, mu_peak, sigma_peak, c_u, c_o) - 200,
           label = paste0("Q* = ", Q_star_peak), fontface = "bold", size = 4) +
  labs(title = "Expected Cost vs. Stocking Quantity\n(Peak Monsoon, Jul-Sep)",
       x = "Stocking quantity Q (units)",
       y = "Expected daily cost ₹/C(Q)") +
  theme_minimal() +
  theme(plot.title = element_text(hjust = 0.5, size = 12, face = "bold"))

ggsave("plot_cost_curve.png", p1, width = 10, height = 6, dpi = 300)

 
# STEP 7: VISUALIZATION - SENSITIVITY ANALYSIS
 

CR_range <- seq(0.1, 0.95, by = 0.01)
Q_star_range <- mu_peak + sigma_peak * qnorm(CR_range)

p2 <- ggplot(data.frame(CR = CR_range, Q = Q_star_range), aes(x = CR, y = Q)) +
  geom_line(size = 1.2, color = "#1B2A4A") +
  geom_point(aes(x = CR, y = Q_star_peak), size = 4, color = "#C9A84C") +
  geom_vline(xintercept = CR, linetype = "dashed", color = "#C9A84C", size = 1) +
  geom_hline(yintercept = Q_star_peak, linetype = "dotted", color = "#C9A84C", alpha = 0.5) +
  annotate("text", x = CR + 0.05, y = Q_star_peak + 5,
           label = paste0("Our point\nQ*=", Q_star_peak, ", CR=", round(CR, 3)),
           fontface = "bold", size = 3.5) +
  labs(title = "Sensitivity: Q* as a Function of Cost Structure",
       x = "Critical ratio CR = c_u/(c_u + c_o)",
       y = "Optimal Q* (units)") +
  theme_minimal() +
  theme(plot.title = element_text(hjust = 0.5, size = 12, face = "bold"))

ggsave("plot_sensitivity.png", p2, width = 10, height = 6, dpi = 300)

 
# STEP 8: FINAL RESULTS
 

print(seasonal_results)
print(paste("Critical Ratio (CR):", round(CR, 4)))
