# Optimizing Umbrella Inventory for a Street Vendor in Bangalore
## A Stochastic Newsvendor Approach

**Group Project Report** | Optimization and Numerical Methods | BSDS, 1st Year (2025–26)

---

## 📌 Problem Statement

A street umbrella vendor in Bangalore faces a daily inventory decision under uncertainty: how many umbrellas should they stock each morning before knowing whether it will rain?

**The Challenge:**
- **Stock too many**: Unsold inventory ties up capital and may get damaged
- **Stock too few**: Demand exceeds supply, vendor loses revenue and goodwill

The vendor faces asymmetric costs:
- **Underage cost (c_u)**: ₹70/unit (lost profit per missed sale)
- **Overage cost (c_o)**: ₹50/unit (loss per unsold unit after salvage)

**Research Question:** What is the optimal number of umbrellas to stock each day to minimize expected total cost under rainfall uncertainty?

---

## 🎯 Solution: The Newsvendor Model

The **Newsvendor Model** is the classical framework for single-period stochastic inventory decisions. It applies here because:

1. A single, irrevocable decision must be made before demand is observed
2. Leftover stock and shortfalls carry different per-unit costs
3. Demand follows a known probability distribution (driven by daily rainfall)

### Critical Ratio Formula

$$CR = \frac{c_u}{c_u + c_o} = \frac{70}{120} = 0.5833$$

**Interpretation:** Stock at the 58.3rd percentile of demand, not the median. Because understocking costs more (₹70 > ₹50), it's rational to lean above the median.

### Optimal Order Quantity

$$Q^* = \hat{\mu}_D + \hat{\sigma}_D \cdot \Phi^{-1}(CR)$$

where:
- $\hat{\mu}_D$ = mean daily demand (units)
- $\hat{\sigma}_D$ = standard deviation of demand
- $\Phi^{-1}$ = inverse normal CDF (quantile function)

---

## 📊 Results

### Seasonal Optimal Quantities

| Season | Period | Mean Demand (μ) | Q* |
|--------|--------|-----------------|-----|
| **Peak Monsoon** | Jul–Sep | 71.3 | **78** |
| **Shoulder** | Jun, Oct–Nov | 62.5 | **70** |
| **Dry** | Dec–May | 16.0 | **21** |

### Economic Impact

Compared to naive "always stock 50" strategy:
- **Daily savings (peak monsoon)**: ₹406
- **Seasonal savings (6 months)**: ₹72,000
- **Cost reduction**: 27%

---

## 📈 Visualizations

### Graph 1: Expected Cost vs. Stocking Quantity
Shows the convex bowl shaped by asymmetric costs. Left arm steeper (c_u > c_o). Minimum at Q* = 78.

### Graph 2: Sensitivity Analysis
Q* as a function of critical ratio. Decision support tool: if salvage price improves, Q* increases proportionally.

Both graphs are interactive on GitHub with hover tooltips and zoom functionality.

---

## 💻 Implementation

### Python (63 lines) - Analytical Solution
```python
import numpy as np
from scipy.stats import norm

c_u, c_o = 70, 50
CR = c_u / (c_u + c_o)  # 0.5833

mu_peak, sigma_peak = 71.3, 31.0
Q_star = mu_peak + sigma_peak * norm.ppf(CR)  # 78 units
.
.
.
```

### R (150 lines) - Complete Data Pipeline
```r
library(tidyverse)
library(ggplot2)

# Step 1: Load & clean from Kaggle
weather <- read.csv('weather_data.csv') %>%
  filter(location_name == "Bangalore") %>%
  drop_na(precip_mm) %>%
  filter(precip_mm < 150)

# Step 2: Map rainfall to demand (Poisson)
weather <- weather %>%
  mutate(season = case_when(
           month %in% c(7,8,9) ~ "Peak Monsoon",
           month %in% c(6,10,11) ~ "Shoulder",
           TRUE ~ "Dry Season"),
         lambda = case_when(
           precip_mm < 2 ~ 5,
           precip_mm < 10 ~ 25,
           precip_mm < 30 ~ 55,
           TRUE ~ 90),
         demand_est = rpois(n(), lambda))
.
.
.
```

**Both implementations:**
- ✓ Analytical formula for instant results (Python)
- ✓ Complete data pipeline from Kaggle (R)
- ✓ Rainfall-to-demand mapping (Poisson model)
- ✓ Seasonal analysis (1800+ daily records)
- ✓ Publication-quality visualizations
- ✓ Verified against numerical optimization

---

## 📚 Mathematical Foundation

### Convexity Proof

The expected cost function is convex in Q:

$$\frac{d^2}{dQ^2}E[C] = (c_u + c_o) f_D(Q) \geq 0 \quad \forall Q \geq 0$$

This guarantees a unique global minimum at:

$$F_D(Q^*) = \frac{c_u}{c_u + c_o}$$

Solved analytically via the quantile function: $Q^* = F_D^{-1}(CR)$

---

## 📋 Key Assumptions

1. **Single-period model**: No inventory carryover to next day
2. **Normal demand approximation**: Justified by Shapiro-Wilk test (W=0.973, p≈0.08)
3. **Fixed cost parameters**: Estimated from market research
4. **Rainfall-driven demand**: Poisson model calibrated to rainfall intensity

---

## ⚠️ Limitations

- **Simulated demand, not real sales data**: Demand mapped from rainfall via Poisson, not actual vendor transactions
- **Normal tail failure**: On extreme rain days (R > 100 mm), normal approximation underestimates by 10–20 units
- **Single-period assumption**: Real vendors carry over stock; this model does not
- **Fixed costs**: Different vendors face different prices; critical ratio shifts accordingly

---

## 🚀 Future Extensions

1. **Multi-period dynamic model**: Allow inventory carryover with Bayesian demand updates
2. **Two-product extension**: Umbrella + raincoat with shared budget constraint
3. **Real-time forecasting**: Integrate IMD hourly forecasts for intraday decisions
4. **Empirical validation**: Partner with real vendors to collect transaction data

---

## 📖 References

1. Arrow, K.J., Harris, T., & Marschak, J. (1951). Optimal inventory policy. *Econometrica*, 19(3), 250–272.
2. Porteus, E.L. (2002). *Foundations of Stochastic Inventory Theory*. Stanford University Press.
3. Nahmias, S., & Olsen, T.L. (2015). *Production and Operations Analysis* (7th ed.). Waveland Press.
4. Boyd, S., & Vandenberghe, L. (2004). *Convex Optimization*. Cambridge University Press.

---

## 🎓 Course Information

- **Course**: Optimization and Numerical Methods
- **Institution**: Indian Statistical Institute, Bangalore
- **Year**: 2025–26
- **Instructor**: Prof. Kaushik Jana
- **Teaching Assistant**: Gahin Maiti
- **Student**: Pritham Prajwin V (BSD-BG-2512)

---

## 🔗 Resources

- **GitHub Repository**: https://github.com/Zapking-001/Team-newsvendor-application
- **Interactive Website**: https://Zapking-001.github.io/Team-newsvendor-application/
- **Dataset**: [Indian Weather Repository (Kaggle)](https://www.kaggle.com/datasets/nelgiriyewithana/indian-weather-repository-daily-snapshot)

---

## 📜 License


---

**April 2026** | Publication-Ready Analysis
