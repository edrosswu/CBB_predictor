# Base win probability formula
off_eff1 = float(df1.AdjOE.iloc[0])
def_eff1 = float(df1.AdjDE.iloc[0])
efg1 = float(df1['EFG%'].iloc[0])
drb1 = float(df1.DRB.iloc[0])
adj_tempo1 = float(df1['AdjT'].iloc[0])  # Adjusted Tempo (optional)
luck1 = float(df1['Luck'].iloc[0])  # Luck factor (optional)

off_eff2 = float(df2.AdjOE.iloc[0])
def_eff2 = float(df2.AdjDE.iloc[0])
efg2 = float(df2['EFG%'].iloc[0])
drb2 = float(df2.DRB.iloc[0])
adj_tempo2 = float(df2['AdjT'].iloc[0])  # Adjusted Tempo (optional)
luck2 = float(df2['Luck'].iloc[0])  # Luck factor (optional)

# Calculate team 1's expected performance (influence by offense, defense, and tempo)
performance1 = (off_eff1 * 1.5 + def_eff2 * 1.2 + efg1 * 1.3 + drb1 * 1.1 + adj_tempo1 * 0.8 + luck1 * 0.5)
# Calculate team 2's expected performance (same formula)
performance2 = (off_eff2 * 1.5 + def_eff1 * 1.2 + efg2 * 1.3 + drb2 * 1.1 + adj_tempo2 * 0.8 + luck2 * 0.5)

# Calculate win probabilities based on performance
win_pct1 = performance1 / (performance1 + performance2)
win_pct2 = performance2 / (performance1 + performance2)

# Normalize by seed (only small adjustment)
seed_factor1 = 1 - (0.01 * seed1)  # Seed is less influential
seed_factor2 = 1 - (0.01 * seed2)  # Adjust seed importance

# Final adjustment with seed factor
win_pct1 = win_pct1 * seed_factor1
win_pct2 = win_pct2 * seed_factor2

# Adjusted final win probabilities
total_win_pct = win_pct1 / (win_pct1 + win_pct2)
team2_prob = total_win_pct
team1_prob = 1 - total_win_pct
