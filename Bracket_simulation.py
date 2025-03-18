from urllib.request import Request, urlopen
import os
from bs4 import BeautifulSoup
import pandas as pd
import numpy as np
import random
from shiny import App, ui, render, reactive
import matplotlib.pyplot as plt
import shiny.express as sx

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
headers = [th.getText() for th in soup.find_all('tr', limit=2)[1].find_all('th')]
headers2 = ['Rk', 'Team', 'Conf', 'W-L', 'NetRtg', 'ORtg', 't1', 'DRtg', 't2', 'AdjT', 't3', 'Luck', 't5', 'SOS_NetRtg', 't6', 'SOS_ORtg', 't8', 'SOS_DRtg', 't9', 'NCSOS_NetRtg', 't10']
headers3 = [str(i) for i in range(262)]


# get rows from table
rows = soup.find_all('tr')[2:]
rows_data = [[td.getText() for td in rows[i].find_all('td')]
                    for i in range(len(rows))]

rows2 = soup2.find_all('tr')[2:]
rows_data2 = [[td.getText() for td in rows2[i].find_all('td')]
                    for i in range(len(rows2))]

rows3 = soup3.find_all('tr')[2:]
rows_data3 = [[td.getText() for td in rows3[i].find_all('td')]
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
bart = bart[bart["Team"].str.contains("✅")]

# Step 2: Remove number, seed, and check mark
bart["Team"] = bart["Team"].str.replace(r"\d+\sseed,?\s✅", "", regex=True).str.strip()
kp = kp.drop_duplicates()
kp = kp.drop(labels=40, axis=0)

#change path 
headers4 = ['Seed', 'Team']
south = pd.read_csv(r"/Users/evanrosswurm/Downloads/south_region.csv")
south = pd.DataFrame(south, columns=headers4)
east = pd.read_csv(r"/Users/evanrosswurm/Downloads/east_region.csv")
east = pd.DataFrame(east, columns=headers4)
west = pd.read_csv(r"/Users/evanrosswurm/Downloads/west_region.csv")
west = pd.DataFrame(west, columns=headers4)
midwest = pd.read_csv(r"/Users/evanrosswurm/Downloads/midwest_region.csv")
midwest = pd.DataFrame(midwest, columns=headers4)
full = pd.read_excel(r"/Users/evanrosswurm/Downloads/bracket.xlsx")
full = pd.DataFrame(full, columns=headers4)
south["Seed"] = south["Seed"].astype(int)
south["Team"] = south["Team"].astype(str)
east["Seed"] = east["Seed"].astype(int)
east["Team"] = east["Team"].astype(str)
west["Seed"] = west["Seed"].astype(int)
west["Team"] = west["Team"].astype(str)
midwest["Seed"] = midwest["Seed"].astype(int)
midwest["Team"] = midwest["Team"].astype(str)
full["Seed"] = full["Seed"].astype(int)
full["Team"] = full["Team"].astype(str)
midwest.loc[midwest['Seed'] == 10, 'Team'] = "Utah St."


def matchup(team1, team2):    # defensive efficiencies (higher values are worse)
    df1 = bart[bart["Team"] == team1]
    if team2 == "Utah St.":
        print("Ran Successfully")
        df2 = bart[bart["Team"] == "Utah St."]
        df_seed2 = full[full["Team"] == "Utah St."]
    else:
        df2 = bart[bart["Team"] == team2]
        df_seed2 = full[full["Team"] == team2]
    df_seed1 = full[full["Team"] == team1]
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
        return winner, team1_prob, seed1
    else:
        return winner, team2_prob, seed2


def run_tournament(df):
    """Run the tournament until only one team remains."""
    round_results = []  # To store round-by-round results
    
    while len(df) > 1:
        winners = []  # Store winners of this round
        win_probs = []  # Store win probabilities
        round_info = []  # Store round-specific information
        
        # Pair up teams
        for i in range(0, len(df), 2):
            if i + 1 < len(df):  # Ensure a valid pair
                team_temp1 = df.iloc[i]
                team_temp2 = df.iloc[i + 1]
                team1 = str(team_temp1["Team"])
                team2 = str(team_temp2["Team"])
                # Determine winner
                winner, win_prob, win_seed = matchup(team1, team2)
                if winner == team1:
                    winners.append(team_temp1)
                    win_probs.append(win_prob)
                    round_info.append(f"{win_seed} {team1} wins with {win_prob:.2%} probability")
                else:
                    winners.append(team_temp2)
                    win_probs.append(win_prob)
                    round_info.append(f"{win_seed} {team2} wins with {win_prob:.2%} probability")
        
        # Create new dataframe for the next round
        df = pd.DataFrame(winners)
        df["Win Probability"] = win_probs
        
        round_results.append(round_info)  # Store the round's results
        round_results.append("\n")
    
    return df, round_results


# Define UI
app_ui = ui.page_fluid(
    ui.layout_sidebar(
        ui.sidebar(
            ui.input_action_button("sim", "Simulate Tournament")
        ),
        ui.layout_column_wrap(
            ui.card(
                ui.card_header("South Region Round Results"),
                ui.output_text_verbatim("south_bracket"),
                ui.output_text_verbatim("south_round_results"),
                ui.output_text_verbatim("south")
            ),
            ui.card(
                ui.card_header("East Region Round Results"),
                ui.output_text_verbatim("east_bracket"),
                ui.output_text_verbatim("east_round_results"),
                ui.output_text_verbatim("east")
            ),
            width=1/2
        ),
        ui.card(
            ui.card_header("Final Four"),
            ui.output_text_verbatim("final_four"),
            ui.output_text_verbatim("final_four_results"),
            ui.output_text_verbatim("champ")

        ),
        ui.layout_column_wrap(
            ui.card(
                ui.card_header("West Region Round Results"),
                ui.output_text_verbatim("west_bracket"),
                ui.output_text_verbatim("west_round_results"),
                ui.output_text_verbatim("west")

            ),
            ui.card(
                ui.card_header("Midwest Region Round Results"),
                ui.output_text_verbatim("midwest_bracket"),
                ui.output_text_verbatim("midwest_round_results"),
                ui.output_text_verbatim("midwest")
            ),
            width=1/2
        )
    )
)

# Define server
def server(input, output, session):
    # You need to define df somewhere in your actual code
    # For this example, I'll create a placeholder
    # df should have columns for "Team" and "Seed" at minimum
    
    
    @reactive.calc
    @reactive.event(input.sim)
    def simulate_regions():
        
        
        # Run tournaments for each region and capture round results
        south_winner, south_round_results = run_tournament(south)
        east_winner, east_round_results = run_tournament(east)
        midwest_winner, midwest_round_results = run_tournament(midwest)
        west_winner, west_round_results = run_tournament(west)
        
        # Combine winners for Final Four
        final_four_df = pd.concat([south_winner, east_winner, midwest_winner, west_winner], ignore_index=True)
        final_four_winner, final_four_results = run_tournament(final_four_df)
        return {
            "south": south,
            "east": east,
            "midwest": midwest,
            "west": west,
            "south_winner": south_winner,
            "east_winner": east_winner,
            "midwest_winner": midwest_winner,
            "west_winner": west_winner,
            "final_four_winner": final_four_winner,
            "final_four": final_four_df,
            "south_round_results": south_round_results,
            "east_round_results": east_round_results,
            "midwest_round_results": midwest_round_results,
            "west_round_results": west_round_results,
            "final_four_results": final_four_results
        }

    
    @output
    @render.text
    def south_bracket():
        results = simulate_regions()
        temp = results["south"]
        return f"South Region:\n{temp[['Seed', 'Team']].to_string(index=False)}"       
    
    @output
    @render.text
    def east_bracket():
        results = simulate_regions()
        temp = results["east"]
        return f"East Region:\n{temp[['Seed', 'Team']].to_string(index=False)}"       
    
    @output
    @render.text
    def midwest_bracket():
        results = simulate_regions()
        temp = results["midwest"]
        return f"Midwest Region:\n{temp[['Seed', 'Team']].to_string(index=False)}"       
    
    @output
    @render.text
    def west_bracket():
        results = simulate_regions()
        temp = results["west"]
        return f"West Region:\n{temp[['Seed', 'Team']].to_string(index=False)}"       

    @output
    @render.text
    def south():
        results = simulate_regions()
        winner = results["south_winner"]
        return f"🏆 South Region Winner:\n {winner.iloc[0]['Team']}"
    
    @output
    @render.text
    def east():
        results = simulate_regions()
        winner = results["east_winner"]
        return f"🏆 East Region Winner:\n {winner.iloc[0]['Team']}"
    
    @output
    @render.text
    def midwest():
        results = simulate_regions()
        winner = results["midwest_winner"]
        return f"🏆 Midwest Region Winner:\n {winner.iloc[0]['Team']}"
    
    @output
    @render.text
    def west():
        results = simulate_regions()
        winner = results["west_winner"]
        return f"🏆 West Region Winner:\n {winner.iloc[0]['Team']}"
    
    @output
    @render.text
    def champ():
        results = simulate_regions()
        winner = results["final_four_winner"]
        return f"🏆 National Champion:\n {winner.iloc[0]['Team']}"
    
    @output
    @render.text
    def final_four():
        results = simulate_regions()
        final_four_df = results["final_four"]
        return f"Final Four Teams:\n{final_four_df[['Team']].to_string(index=False)}"
    
    @output
    @render.text
    def final_four_results():
        results = simulate_regions()
        round_results = results["final_four_results"]
        # Flatten and join all round results into a string
        return "\n".join([item for sublist in round_results for item in sublist])
    
    @output
    @render.text
    def south_round_results():
        results = simulate_regions()
        round_results = results["south_round_results"]
        # Flatten and join all round results into a string
        return "\n".join([item for sublist in round_results for item in sublist])
    
    @output
    @render.text
    def east_round_results():
        results = simulate_regions()
        round_results = results["east_round_results"]
        # Flatten and join all round results into a string
        return "\n".join([item for sublist in round_results for item in sublist])
    
    @output
    @render.text
    def west_round_results():
        results = simulate_regions()
        round_results = results["west_round_results"]
        # Flatten and join all round results into a string
        return "\n".join([item for sublist in round_results for item in sublist])
    
    @output
    @render.text
    def midwest_round_results():
        results = simulate_regions()
        round_results = results["midwest_round_results"]
        # Flatten and join all round results into a string
        return "\n".join([item for sublist in round_results for item in sublist])

# Create and run the app
app = App(app_ui, server)
app.run()
