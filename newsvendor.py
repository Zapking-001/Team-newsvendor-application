"""

GROUP-24 : Optimizing Umbrella Inventory for a Street Vendor in Bangalore

"""

import numpy as np
import matplotlib.pyplot as plt
from scipy.stats import norm

# PARAMETERS
c_u = 70
c_o = 50
CR = c_u / (c_u + c_o)  # Critical ratio = 0.5833

# Peak monsoon demand parameters (from Bangalore rainfall data)
mu_peak = 71.3
sigma_peak = 31.0

# Shoulder and dry season parameters
mu_shoulder = 65.8
sigma_shoulder = 28.5

mu_dry = 15.2
sigma_dry = 7.1

# FUNCTION 1: Calculate Optimal Quantity (Analytical Solution)
def optimal_quantity(mu, sigma, critical_ratio):

    z = norm.ppf(critical_ratio)
    return mu + sigma * z

# FUNCTION 2: Expected Cost for a given Q
def expected_cost(Q, mu, sigma, c_u, c_o):

    z = (Q - mu) / sigma
    std_loss = norm.pdf(z) - z * (1 - norm.cdf(z))

    return c_u * sigma * std_loss + c_o * sigma * (z + std_loss)

# GENERATE DATA FOR PLOT 1: Cost Curve (Peak Monsoon)
Q_values = np.linspace(10, 150, 300)
costs = [expected_cost(Q, mu_peak, sigma_peak, c_u, c_o) for Q in Q_values]

Q_star_peak = optimal_quantity(mu_peak, sigma_peak, CR)
cost_star = expected_cost(Q_star_peak, mu_peak, sigma_peak, c_u, c_o)

# GENERATE DATA FOR PLOT 2: Sensitivity Analysis
CR_values = np.linspace(0.1, 0.95, 200)
Q_star_values = [optimal_quantity(mu_peak, sigma_peak, cr) for cr in CR_values]

# PLOT 1: Cost Curve
plt.figure(figsize=(10, 6))
plt.plot(Q_values, costs, linewidth=2.5, color='#1B2A4A', label='Expected Cost')
plt.plot(Q_star_peak, cost_star, 'o', markersize=12, color='#C9A84C', 
         markeredgecolor='#1B2A4A', markeredgewidth=2, label='Optimal Point')
plt.axvline(x=Q_star_peak, color='#C9A84C', linestyle='--', linewidth=1.5, alpha=0.7)

# Annotations
plt.text(50, 2300, f'steeper\n(₹{c_u}/unit)', fontsize=9, color='#1B2A4A', 
         bbox=dict(boxstyle='round,pad=0.4', facecolor='white', edgecolor='none', alpha=0.8))
plt.text(105, 2050, f'flatter\n(₹{c_o}/unit)', fontsize=9, color='#1B2A4A',
         bbox=dict(boxstyle='round,pad=0.4', facecolor='white', edgecolor='none', alpha=0.8))
plt.text(Q_star_peak + 3, cost_star - 200, f'Q* = {int(Q_star_peak)}', fontsize=10, 
         color='#1B2A4A', bbox=dict(boxstyle='round,pad=0.5', facecolor='#FBF3E2', 
         edgecolor='#C9A84C', linewidth=1.5))

plt.xlabel('Stocking quantity Q (units)', fontsize=11)
plt.ylabel('Expected daily cost ₹/C(Q)', fontsize=11)
plt.title('Expected Cost vs. Stocking Quantity\n(Peak Monsoon, Jul-Sep)', fontsize=12, fontweight='bold')
plt.grid(True, alpha=0.3, linestyle='-', linewidth=0.5)
plt.xlim(10, 150)
plt.ylim(1400, 3400)
plt.tight_layout()
plt.savefig('plot_cost_curve.png', dpi=300, bbox_inches='tight')
plt.close()

print(f"✓ Plot 1 saved: plot_cost_curve.png")
print(f"  Q* (Peak Monsoon) = {Q_star_peak:.1f} units (rounded: {int(Q_star_peak)})")
print(f"  Expected Cost at Q* = ₹{cost_star:.2f}")

# PLOT 2: Sensitivity Analysis
plt.figure(figsize=(10, 6))
plt.plot(CR_values, Q_star_values, linewidth=2.5, color='#1B2A4A')
plt.plot(CR, Q_star_peak, 'o', markersize=12, color='#C9A84C',
         markeredgecolor='#1B2A4A', markeredgewidth=2)

# Add guidelines
plt.axvline(x=CR, color='#C9A84C', linestyle='--', linewidth=1.5, alpha=0.7)
plt.axhline(y=Q_star_peak, color='#C9A84C', linestyle=':', linewidth=1.5, alpha=0.5)
plt.axvline(x=0.5, color='#2980B9', linestyle=':', linewidth=1.5, alpha=0.5, label='symmetric costs')

# Annotations
plt.text(0.5, 20, 'symmetric\ncosts', fontsize=9, color='#2980B9', 
         bbox=dict(boxstyle='round,pad=0.4', facecolor='white', edgecolor='none', alpha=0.8))
plt.text(CR + 0.02, Q_star_peak + 8, f'Our point\nQ* = {int(Q_star_peak)}, CR = {CR:.3f}', 
         fontsize=9, color='#1B2A4A', bbox=dict(boxstyle='round,pad=0.5', 
         facecolor='#FBF3E2', edgecolor='#C9A84C', linewidth=1.5))

plt.xlabel('Critical ratio CR = c_u/(c_u + c_o)', fontsize=11)
plt.ylabel('Optimal Q* (units)', fontsize=11)
plt.title('Sensitivity: Q* as a Function of Cost Structure', fontsize=12, fontweight='bold')
plt.grid(True, alpha=0.3, linestyle='-', linewidth=0.5)
plt.xlim(0.1, 0.95)
plt.ylim(15, 130)
plt.tight_layout()
plt.savefig('plot_sensitivity.png', dpi=300, bbox_inches='tight')
plt.close()

print(f"✓ Plot 2 saved: plot_sensitivity.png")

# SEASONAL ANALYSIS

Q_star_shoulder = optimal_quantity(mu_shoulder, sigma_shoulder, CR)
Q_star_dry = optimal_quantity(mu_dry, sigma_dry, CR)

print(f"\n{'='*60}")
print(f"SEASONAL OPTIMAL STOCKING QUANTITIES")
print(f"{'='*60}")
print(f"Peak Monsoon (Jul-Sep):    Q* = {int(Q_star_peak)} units")
print(f"Shoulder Months (Oct-Jun): Q* = {int(Q_star_shoulder)} units")
print(f"Dry Season (Apr-Jun):      Q* = {int(Q_star_dry)} units")
print(f"\nFormula: Q* = μ + σ × Φ^(-1)(CR), where CR = {CR:.4f}")
