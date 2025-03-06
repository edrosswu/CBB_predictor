from urllib.request import Request, urlopen
from bs4 import BeautifulSoup
import pandas as pd
import numpy as np
import random

url = "https://barttorvik.com/#"
url2 = "https://kenpom.com/"
url3 = "http://www.bracketmatrix.com/"

temp1 = {"User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36"}
temp2 = {"User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36"}
temp3 = {"User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36"}
req1 = Request(url, headers=temp1)
html = urlopen(req1).read()
req2 = Request(url2, headers=temp2)
html2 = urlopen(req2).read()
req3 = Request(url3, headers=temp3)
html3 = urlopen(req3).read()

        
# create beautiful soup object from HTML
soup = BeautifulSoup(html, features="lxml")
soup2 = BeautifulSoup(html2, features = "lxml")
soup3 = BeautifulSoup(html3, features = "lxml")


# use getText()to extract the headers into a list
headers = [th.getText() for th in soup.findAll('tr', limit=2)[1].findAll('th')]
headers2 = ['Rk', 'Team', 'Conf', 'W-L', 'NetRtg', 'ORtg', 't1', 'DRtg', 't2', 'AdjT', 't3', 'Luck', 't5', 'SOS_NetRtg', 't6', 'SOS_ORtg', 't8', 'SOS_DRtg', 't9', 'NCSOS_NetRtg', 't10']
headers3 = [str(i) for i in range(125)]

# get rows from table
rows = soup.findAll('tr')[2:]
rows_data = [[td.getText() for td in rows[i].findAll('td')]
                    for i in range(len(rows))]

rows2 = soup2.findAll('tr')[2:]
rows_data2 = [[td.getText() for td in rows2[i].findAll('td')]
                    for i in range(len(rows2))]

rows3 = soup3.findAll('tr')[2:]
rows_data3 = [[td.getText() for td in rows3[i].findAll('td')]
                    for i in range(len(rows3))]

bart = pd.DataFrame(rows_data, columns = headers)
kp = pd.DataFrame(rows_data2, columns = headers2)
bm = pd.DataFrame(rows_data3, columns = headers3)
bart["Team"] = bart["Team"].str.replace('vs.', '()', regex=True)
bart["Team"] = bart["Team"].str.replace(r"\s*\(.*", "", regex=True)
bart = bart.drop_duplicates()
bart = bart.drop(labels=25, axis=0)
bart = bart.astype({
    "Team": str,
    "AdjOE": float,
    "AdjDE": float,
    "Barthag": float,
    "EFG%": float,
    "EFGD%": float,
    "TOR": float,
    "TORD": float,	
    "ORB": float,
    "DRB": float,
    "FTR": float,
    "FTRD": float,
    "2P%": float,
    "2P%D": float,
    "3P%": float,
    "3P%D": float,
    "3PR": float,
    "3PRD": float,
    "Adj T.": float,
    "WAB": float
    })  
kp = kp.drop_duplicates()
kp = kp.drop(labels=40, axis=0)
bm = bm.rename(columns={"0":"Seed", "1":"Team", "2":"Conf"})
bm = bm.drop(labels=0, axis = 0)
bm = bm.iloc[:, [0, 1 ,2]]
bm = bm.iloc[:68]
bm["Seed"] = bm["Seed"].astype(int)
bm["Team"] = bm["Team"].astype(str)
bm["Conf"] = bm["Conf"].astype(str)
bm.loc[bm["Team"] == "Central Connecticut State", "Team"] = "Central Connecticut"
bm.loc[bm["Team"] == "Iowa State", "Team"] = "Iowa St."
bm.loc[bm["Team"] == "Omaha", "Team"] = "Nebraska Omaha"
bm.loc[bm["Team"] == "St. Mary's (CA)", "Team"] = "Saint Mary's"
bm.loc[bm["Team"] == "San Diego State", "Team"] = "San Diego St."
bm.loc[bm["Team"] == "Southeast Missouri State", "Team"] = "Southeast Missouri St."
bm.loc[bm["Team"] == "Michigan State", "Team"] = "Michigan St."
bm.loc[bm["Team"] == "McNeese State", "Team"] = "McNeese St."
bm.loc[bm["Team"] == "Ohio State", "Team"] = "Ohio St."
bm.loc[bm["Team"] == "Norfolk State", "Team"] = "Norfolk St."
bm.loc[bm["Team"] == "Arkansas State", "Team"] = "Arkansas St."
bm.loc[bm["Team"] == "Mississippi State", "Team"] = "Mississippi St."
bm.loc[bm["Team"] == "Utah State", "Team"] = "Utah St."
bm.loc[bm["Team"] == "Boise State", "Team"] = "Boise St."
mat = bm
east = pd.DataFrame(columns=["Seed", "Team"])
west = pd.DataFrame(columns=["Seed", "Team"])
midwest = pd.DataFrame(columns=["Seed", "Team"])
south = pd.DataFrame(columns=["Seed", "Team"])

seed_order = [1, 16, 8, 9, 5, 12, 4, 13, 6, 11, 3, 14, 7, 10, 2, 15]
# Create a function to distribute seeds into the regional dataframes
def distribute_seeds(df, region_df, seed_order):
    selected_rows = []  # Temporary list to store selected rows
    
    for seed in seed_order:
        # Get teams for each seed
        teams_for_seed = df[df["Seed"] == seed]
        
        # If there are multiple teams for this seed, pick one randomly
        if not teams_for_seed.empty:
            selected_team = teams_for_seed.sample(n=1).iloc[0]  # Randomly select one row
            selected_rows.append(selected_team)  # Store the selected row
            df = df.drop(selected_team.name)  # Remove from main DataFrame
    
    # Concatenate selected rows into region_df
    region_df = pd.concat([region_df, pd.DataFrame(selected_rows)], ignore_index=True)

    return df, region_df

# Distribute seeds to each region (East, West, Midwest, South)
bm, east = distribute_seeds(bm, east, seed_order)
bm, west = distribute_seeds(bm, west, seed_order)
bm, midwest = distribute_seeds(bm, midwest, seed_order)
bm, south = distribute_seeds(bm, south, seed_order)


def matchup(team1, team2):    # defensive efficiencies (higher values are worse)
    df1 = bart[bart["Team"] == team1]
    df2 = bart[bart["Team"] == team2]
    df_seed1  = mat[mat["Team"] == team1]
    df_seed2 = mat[mat["Team"] == team2]
    off_eff1 = float(df1.AdjOE.iloc[0])
    def_eff1 = float(df1.AdjDE.iloc[0])
    to_rate1 = float(df1.TOR.iloc[0])
    efg1 = float(df1['EFG%'].iloc[0])
    drb1 = float(df1.DRB.iloc[0])
    seed1 = int(df_seed1.Seed.iloc[0])
    off_eff2 = float(df2.AdjOE.iloc[0])
    def_eff2 = float(df2.AdjDE.iloc[0])
    to_rate2 = float(df2.TOR.iloc[0])
    efg2 = float(df2['EFG%'].iloc[0])
    drb2 = float(df2.DRB.iloc[0])
    seed2 = int(df_seed2.Seed.iloc[0])

    # Calculate team 1's expected winning percentage
    win_pct1 = (((off_eff1) * 11.5) / (((off_eff1) * 11.5) + ((def_eff1) * 11.5)))
    # Calculate team 2's expected winning percentage
    win_pct2 = (off_eff2 * 11.5) / ((off_eff2 * 11.5) + (def_eff2 * 11.5))
    # Adjust for turnover rate and effective field goal percentage
    adj_win_pct1 = win_pct1 * (1-to_rate1) * (efg1) * (1-drb1) * seed1
    adj_win_pct2 = win_pct2 * (1-to_rate2) * (efg2) * (1-drb2) * seed2
    # Calculate the total expected winning percentage of the game
    total_win_pct = adj_win_pct1 / (adj_win_pct1 + (adj_win_pct2))
    team2_prob = total_win_pct
    team1_prob = 1 - total_win_pct
    winner = random.choices([team1, team2], weights=[team1_prob, team2_prob])[0]
    if winner == team1:
        return winner, team1_prob
    else:
        return winner, team2_prob


def run_tournament(df):
    """Run the tournament until only one team remains."""
    while len(df) > 1:
        winners = []  # Store winners of this round
        win_probs = []  # Store win probabilities
        
        # Pair up teams
        for i in range(0, len(df), 2):
            if i + 1 < len(df):  # Ensure a valid pair
                team_temp1 = df.iloc[i]
                team_temp2 = df.iloc[i + 1]
                team1 = str(team_temp1["Team"])
                team2 = str(team_temp2["Team"])
                # Determine winner
                winner, win_prob = matchup(team1, team2)
                if winner == team1:
                    winners.append(team_temp1)
                    win_probs.append(win_prob)  # Multiply past probability
                else:
                    winners.append(team_temp2)
                    win_probs.append(win_prob)  # Multiply past probability
        
        
        # Create new dataframe for the next round
        df = pd.DataFrame(winners)
        df["Win Probability"] = win_probs
        print("\nNext Round Teams:\n", df)  # Display teams advancing
        
    print("\n🏆 Region Winner:", df.iloc[0]["Team"])
    return df

# Display the regional dataframes
print("East Region:")
print(east)
w_east = run_tournament(east)

print("\nWest Region:")
print(west)

w_west = run_tournament(west)

print("\nMidwest Region:")
print(midwest)
w_midwest = run_tournament(midwest)

print("\nSouth Region:")
print(south)
w_south = run_tournament(south)


combined_df = pd.concat([w_east, w_west, w_midwest, w_south], ignore_index=True)
print("\nFinal Four:")
print(combined_df)
champ = run_tournament(combined_df)