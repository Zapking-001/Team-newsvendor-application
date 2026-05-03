# ⚡ Quick Start (30 Seconds)

## Clone & Run (Python)

```bash
# Clone
git clone https://github.com/Zapking-001/Team-newsvendor-application.git
cd Team-newsvendor-application

# Install dependencies
pip install -r requirements.txt

# Run analysis
python newsvendor.py
```

## Or Use R

```bash
# Install R packages (first time only)
Rscript -e "install.packages(c('tidyverse', 'ggplot2'))"

# Download data from Kaggle:
# https://www.kaggle.com/datasets/nelgiriyewithana/indian-weather-repository-daily-snapshot
# Extract: weather_data.csv

# Run analysis
Rscript newsvendor_final.R
```

## Expected Output (Either Language)

```
Seasonal Results:
  Peak Monsoon:     Q* = 78 units, Daily savings: ₹406
  Shoulder months:  Q* = 70 units
  Dry Season:       Q* = 21 units

Critical Ratio: 0.5833
Graphs: plot_cost_curve.png, plot_sensitivity.png
```

## The Data & The Formula

**Data Source:** Kaggle Indian Weather Repository (1800+ daily records for Bangalore)

**Demand Model:** Rainfall → Poisson demand
- Dry (R < 2mm): Poi(5)
- Light (2-10mm): Poi(25)  
- Moderate (10-30mm): Poi(55)
- Heavy (R ≥ 30mm): Poi(90)

**Optimization Formula:**

$$Q^* = \mu + \sigma \times \Phi^{-1}(CR)$$

where CR = 0.5833 (stock at 58.3rd percentile)

$$Q^* = 71.3 + 31.0 \times 0.210 = 78 \text{ units}$$

## Key Results

| Metric | Value |
|--------|-------|
| **Optimal Q** (Peak) | 78 units |
| **Daily Savings** | ₹406 |
| **Seasonal Savings** (6 mo) | ₹72,000 |

## Requirements

**Python:**
- Python 3.7+
- numpy, scipy, matplotlib
```bash
pip install -r requirements.txt
```

**R:**
- R 3.6+
- tidyverse, ggplot2
```r
install.packages(c("tidyverse", "ggplot2"))
```

## Next Steps

1. **Read** README.md for full mathematical derivation & seasonal analysis
2. **View** index.html for interactive website with embedded graphs
3. **Present** Newsvendor_Model_Presentation.pptx (13 professional slides)
4. **Explore** GitHub repo for all source code, data processing, and visualizations

---

**Both Python & R implementations:**
✓ Collect real data from Kaggle  
✓ Clean & validate weather data  
✓ Calculate seasonal demand statistics  
✓ Optimize Q* using critical ratio formula  
✓ Generate publication-quality graphs  
✓ Show economic impact (₹72,000 seasonal savings)
