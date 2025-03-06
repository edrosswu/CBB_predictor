library(shiny)
library(tidyverse)
library(shinydashboard)
library(rvest)
library(stringr)
library(scrutiny)
library(DT)
library(shinyWidgets)
library(reactable)
library(dplyr)
library(sqldf)
library(ggplot2)
library(tidyr)
library(hrbrthemes)
library(GGally)
library(viridis)

getsched <- function(x){
  today <- Sys.Date()
  today <- gsub("-", "", today)
  espn <- "https://www.espn.com/mens-college-basketball/schedule/_/date/"
  final <- paste(espn, today, sep="")
  myurl <- read_html(final) # read webpage as html
  myurl <- html_table(myurl)  # convert to an html table for ease of use
  
  to.parse <- myurl[[1]]  # pull the first item in the list
  df <- as.data.frame(to.parse)
  colnames(df)[1] <- "Away"
  colnames(df)[2] <- "Home_Temp"
  mydata <- df[-c(4:5)]
  home_split <- str_split_fixed(mydata$Home_Temp, " ", 2)
  home_split <- substr(home_split[,2], 2, nchar(home_split[,2]))
  home_split <- gsub("^\\d+\\s+", "", home_split)

  mydata$Home <- home_split
  mydata$Away <- gsub("^\\d+\\s+", "", mydata$Away)
  odds_split <- str_split_fixed(mydata$`ODDS BY`, "O/U:", 2)
  mydata$Line <- gsub("Line:", "", trimws(odds_split[,1]))
  mydata$OU <- trimws(odds_split[,2])
  
  # Remove original ODDS BY column
  mydata$`ODDS BY` <- NULL
  mydata$`Home_Temp` <- NULL
  df2 <- mydata[,c(1,4,2,3,5,6)]
  colnames(df2)[3] <- "Time"
  colnames(df2)[4] <- "Location"
  df2$Home[df2$Home == "South Carolina Upstate"] <- "USC Upstate"
  df2$Away[df2$away == "South Carolina Upstate"] <- "USC Upstate"
  return(df2)
}

getbart <- function(x){
  barturl <- read_html("https://barttorvik.com/trank.php#")
  bart <- html_table(barturl)
  bart.parse <- bart[[1]]  # pull the first item in the list
  dfbart <- as.data.frame(bart.parse)
  names(dfbart) <- c('Rk', 'Team', 'Conf', 'G', 'Rec', 'AdjOE', 'AdjDE', 'Barthag', 'EFG', 'EFGD', 'TOR', 'TORD', 'ORB', 'DRB', 'FTR', 'FTRD', '2P', '2PD', '3P', '3PD', '3PR', '3PRD', 'Tempo', 'WAB')
  dfbart <- dfbart[-c(1),]
  dfbart <- dfbart[-grep('Rk', dfbart$Rk), ]
  dfbart$Team <- sub("\\s*\\t*\\(.*$", "", dfbart$Team)
  i <- c(1, 4:24)
  dfbart$Rk <- as.numeric(as.character(dfbart$Rk))
  dfbart$AdjOE <- as.numeric(as.character(dfbart$AdjOE))
  dfbart$AdjDE <- as.numeric(as.character(dfbart$AdjDE))
  dfbart$Barthag <- as.numeric(as.character(dfbart$Barthag))
  dfbart$EFG <- as.numeric(as.character(dfbart$EFG))
  dfbart$EFGD <- as.numeric(as.character(dfbart$EFGD))
  dfbart$TOR <- as.numeric(as.character(dfbart$TOR))
  dfbart$TORD <- as.numeric(as.character(dfbart$TORD))
  dfbart$ORB <- as.numeric(as.character(dfbart$ORB))
  dfbart$DRB <- as.numeric(as.character(dfbart$DRB))
  dfbart$FTR <- as.numeric(as.character(dfbart$FTR))
  dfbart$FTRD <- as.numeric(as.character(dfbart$FTRD))
  dfbart$`2P` <- as.numeric(as.character(dfbart$`2P`))
  dfbart$`2PD` <- as.numeric(as.character(dfbart$`2PD`))
  dfbart$`3P` <- as.numeric(as.character(dfbart$`3P`))
  dfbart$`3PD` <- as.numeric(as.character(dfbart$`3PD`))
  dfbart$`3PR` <- as.numeric(as.character(dfbart$`3PR`))
  dfbart$`3PRD` <- as.numeric(as.character(dfbart$`3PRD`))
  dfbart$Tempo <- as.numeric(as.character(dfbart$Tempo))
  dfbart$WAB <- as.numeric(as.character(dfbart$WAB))

  return(dfbart)
}

gethome <- function(x){
  homeurl <- read_html("https://barttorvik.com/?year=2025&sort=&hteam=&t2value=&conlimit=All&state=All&begin=20241101&end=20250501&top=0&revquad=0&quad=5&venue=H&type=All&mingames=0#")
  home <- html_table(homeurl)
  home.parse <- home[[1]]
  dfhome <- as.data.frame(home.parse)
  names(dfhome) <- c('Rk', 'Team', 'Conf', 'G', 'Rec', 'AdjOE', 'AdjDE', 'Barthag', 'EFG', 'EFGD', 'TOR', 'TORD', 'ORB', 'DRB', 'FTR', 'FTRD', '2P', '2PD', '3P', '3PD', '3PR', '3PRD', 'Tempo', 'WAB')
  dfhome <- dfhome[-c(1),]
  dfhome <- dfhome[-grep('Rk', dfhome$Rk), ]
  dfhome$Team <- sub("\\s*\\t*\\(.*$", "", dfhome$Team)
  dfhome$Rk <- as.numeric(as.character(dfhome$Rk))
  dfhome$AdjOE <- as.numeric(as.character(dfhome$AdjOE))
  dfhome$AdjDE <- as.numeric(as.character(dfhome$AdjDE))
  dfhome$homehag <- as.numeric(as.character(dfhome$Barthag))
  dfhome$EFG <- as.numeric(as.character(dfhome$EFG))
  dfhome$EFGD <- as.numeric(as.character(dfhome$EFGD))
  dfhome$TOR <- as.numeric(as.character(dfhome$TOR))
  dfhome$TORD <- as.numeric(as.character(dfhome$TORD))
  dfhome$ORB <- as.numeric(as.character(dfhome$ORB))
  dfhome$DRB <- as.numeric(as.character(dfhome$DRB))
  dfhome$FTR <- as.numeric(as.character(dfhome$FTR))
  dfhome$FTRD <- as.numeric(as.character(dfhome$FTRD))
  dfhome$`2P` <- as.numeric(as.character(dfhome$`2P`))
  dfhome$`2PD` <- as.numeric(as.character(dfhome$`2PD`))
  dfhome$`3P` <- as.numeric(as.character(dfhome$`3P`))
  dfhome$`3PD` <- as.numeric(as.character(dfhome$`3PD`))
  dfhome$`3PR` <- as.numeric(as.character(dfhome$`3PR`))
  dfhome$`3PRD` <- as.numeric(as.character(dfhome$`3PRD`))
  dfhome$Tempo <- as.numeric(as.character(dfhome$Tempo))
  dfhome$WAB <- as.numeric(as.character(dfhome$WAB))
  return(dfhome)
}

getaway <- function(x){
  awayurl <- read_html("https://barttorvik.com/?year=2025&sort=&hteam=&t2value=&conlimit=All&state=All&begin=20241101&end=20250501&top=0&revquad=0&quad=5&venue=A&type=All&mingames=0#")
  away <- html_table(awayurl)
  away.parse <- away[[1]]
  dfaway <- as.data.frame(away.parse)
  names(dfaway) <- c('Rk', 'Team', 'Conf', 'G', 'Rec', 'AdjOE', 'AdjDE', 'Barthag', 'EFG', 'EFGD', 'TOR', 'TORD', 'ORB', 'DRB', 'FTR', 'FTRD', '2P', '2PD', '3P', '3PD', '3PR', '3PRD', 'Tempo', 'WAB')
  dfaway <- dfaway[-c(1),]
  dfaway <- dfaway[-grep('Rk', dfaway$Rk), ]
  dfaway$Team <- sub("\\s*\\t*\\(.*$", "", dfaway$Team)
  dfaway$Rk <- as.numeric(as.character(dfaway$Rk))
  dfaway$AdjOE <- as.numeric(as.character(dfaway$AdjOE))
  dfaway$AdjDE <- as.numeric(as.character(dfaway$AdjDE))
  dfaway$awayhag <- as.numeric(as.character(dfaway$Barthag))
  dfaway$EFG <- as.numeric(as.character(dfaway$EFG))
  dfaway$EFGD <- as.numeric(as.character(dfaway$EFGD))
  dfaway$TOR <- as.numeric(as.character(dfaway$TOR))
  dfaway$TORD <- as.numeric(as.character(dfaway$TORD))
  dfaway$ORB <- as.numeric(as.character(dfaway$ORB))
  dfaway$DRB <- as.numeric(as.character(dfaway$DRB))
  dfaway$FTR <- as.numeric(as.character(dfaway$FTR))
  dfaway$FTRD <- as.numeric(as.character(dfaway$FTRD))
  dfaway$`2P` <- as.numeric(as.character(dfaway$`2P`))
  dfaway$`2PD` <- as.numeric(as.character(dfaway$`2PD`))
  dfaway$`3P` <- as.numeric(as.character(dfaway$`3P`))
  dfaway$`3PD` <- as.numeric(as.character(dfaway$`3PD`))
  dfaway$`3PR` <- as.numeric(as.character(dfaway$`3PR`))
  dfaway$`3PRD` <- as.numeric(as.character(dfaway$`3PRD`))
  dfaway$Tempo <- as.numeric(as.character(dfaway$Tempo))
  dfaway$WAB <- as.numeric(as.character(dfaway$WAB))
  return(dfaway)
}

getwinperc <- function(x){
  sched <- getsched()
  dfhome <- gethome()
  row_index <- which(dfhome$Team == "Houston")
  row_index
  #So the thing won't work currently for teams that have a game today which isn't very helpful. Need to find a way to remove that to be ablet to search these teams
  dfaway <- getaway()
  sched$win_pct <- NA
  for (i in 1:nrow(sched)) {
    away <- sched$Away[i]
    home <- sched$Home[i]
    statsh <- subset(dfhome, Team == "USC Upstate")
    statsa <- subset(dfaway, Team == "Charleston Southern")
    class(dfhome$Team)
    
    print(statsa)
    print(statsh)
    dfhome[dfhome$Team == "USC Upstate",]
    dfaway[dfaway$Team == "Charleston Southern",]
    
    
    # Calculate team 1's expected winning percentage
    win_a <- (((statsa$AdjOE) * 11.5) / (((statsa$AdjOE) * 11.5) + ((statsa$AdjDE) * 11.5)))
    # Calculate team 2's expected winning percentage
    win_h <- (statsh$AdjOE * 11.5) / ((statsh$AdjOE * 11.5) + (statsh$AdjDE * 11.5))
    # Adjust for turnover rate and effective field goal percentage
    adj_a <- win_a * (1-statsa$TOR) * (statsa$EFG) * (1-statsa$DRB)
    adj_h <- win_h * (1-statsh$TOR) * (statsh$EFG) * (1-statsh$DRB)
    # Calculate the total expected winning percentage of the game
    sched$win_pct[i] <- adj_a / (adj_a + (adj_h))
  }
  head(sched)
}

ui <- dashboardPage(skin = "blue",
                    dashboardHeader(title = "CBB Score Predictor"),
                    dashboardSidebar(
                      sidebarMenu(
                        #used to build out pages
                        menuItem("Home Page", tabName = "dashboard", icon = icon("home")),
                        menuItem("Schedule", tabName = "games", icon = icon("basketball")),
                        menuItem("Barttorvik", tabName = "bart", icon = icon("chart-line")),
                        menuItem("Win Percentage", tabName = "win", icon = icon("check")),
                        menuItem("March Madness", tabName = "madness", icon = icon("explosion")),
                        menuItem("Team Details", tabName = "team", icon = icon("person"))
                      )
                    ),
                    dashboardBody(
                      tabItems(
                        #each page has its own page and links to the visuals within the page
                        tabItem(tabName = "games",
                                fluidRow(
                                  column(12, 
                                         tags$h2("Today's Games", style = "text-align: center;")
                                  )
                                ),
                                fluidRow(
                                  column(12, reactableOutput("schedule_plot"), style = "padding-top: 50px;")
                          
                        )
                      ), 
                      tabItem(tabName = "bart",
                              fluidRow(
                                column(12,
                                       tags$h2("Barttorvik", style = "text-align: center;")
                                       )
                              ),
                              fluidRow(
                                column(12, reactableOutput("bart_plot"), style = "padding-top: 50px;")
                              )
                      ),
                      tabItem(tabName = "win",
                              fluidRow(
                                column(12,
                                       tags$h2("Win Percentage", style = "text-align: center;"))
                              )),
                      tabItem(tabName = "team", 
                              fluidPage(
                                titlePanel("Select Team"),
                                textInput("team", "Team Name", value = "", width = NULL, placeholder = NULL),
                                actionButton("team_btn", "Submit"),
                                verbatimTextOutput("value"),
                                plotOutput("team_free_plot")
                              )
                              )
                    )
                    )
) 

server <- function(input, output, session) {
  #graphs and such go here, so like visuals and that kind of thing
  output$schedule_plot <- renderReactable({
    reactable(
      getsched()
    ) 
  })
  
  output$bart_plot <- renderReactable({
    reactable(
      getbart()
    )
  })
  output$win_plot <- renderReactable({
    reactable(
      getwinperc()
    )
  })
  observeEvent(input$team_btn, {
    schedule <- bigballR:::get_team_schedule(season="2024-25", team.name = input$team)
    pbp <- bigballR:::get_play_by_play(schedule$Game_ID)
    pbp_Purdue <- subset(pbp, Event_Team == input$team & isGarbageTime == FALSE & abs(Home_Score - Away_Score) <= 10)
    #Half_Status == 2 & Game_Seconds >= 2160 &
    
    made_Purdue <-subset(pbp_Purdue, Event_Result == "made")
    made_Purdue
    made_2 <- subset(made_Purdue, grepl("2pt", Event_Description, ignore.case = TRUE))
    made_3 <- subset(made_Purdue, grepl("3pt", Event_Description, ignore.case = TRUE))
    made_free <- subset(made_Purdue, grepl("freethrow", Event_Description, ignore.case = TRUE))
    missed_Purdue <- subset(pbp_Purdue, Event_Result == "missed")
    miss_2 <- subset(missed_Purdue, grepl("2pt", Event_Description, ignore.case = TRUE))
    miss_3 <- subset(missed_Purdue, grepl("3pt", Event_Description, ignore.case = TRUE))
    miss_free <- subset(missed_Purdue, grepl("freethrow", Event_Description, ignore.case = TRUE))
    
    m2 <- made_2 %>% 
      group_by(Player_1) %>%
      summarise(Count = n()) %>%
      arrange(desc(Count))
    
    m3 <- made_3 %>% 
      group_by(Player_1) %>%
      summarise(Count = n()) %>%
      arrange(desc(Count))
    
    m1 <- made_free %>% 
      group_by(Player_1) %>%
      summarise(Count = n()) %>%
      arrange(desc(Count))
    
    mi2 <- miss_2 %>% 
      group_by(Player_1) %>%
      summarise(Count = n()) %>%
      arrange(desc(Count))
    
    mi3 <- miss_3 %>% 
      group_by(Player_1) %>%
      summarise(Count = n()) %>%
      arrange(desc(Count))
    
    mi1 <- miss_free %>% 
      group_by(Player_1) %>%
      summarise(Count = n()) %>%
      arrange(desc(Count))
    
    query_1 <- sqldf("Select COALESCE(m1.Player_1, mi1.Player_1) AS Player, COALESCE(mi1.Count,0) AS Missed, COALESCE(m1.Count,0) AS Made FROM m1 FULL JOIN mi1 ON m1.Player_1 = mi1.Player_1")
    query_2 <- sqldf("Select COALESCE(m2.Player_1, mi2.Player_1) AS Player, COALESCE(mi2.Count,0) AS Missed, COALESCE(m2.Count,0) AS Made FROM m2 FULL JOIN mi2 ON m2.Player_1 = mi2.Player_1")
    query_3 <- sqldf("Select COALESCE(m3.Player_1, mi3.Player_1) AS Player, COALESCE(mi3.Count,0) AS Missed, COALESCE(m3.Count,0) AS Made FROM m3 FULL JOIN mi3 ON m3.Player_1 = mi3.Player_1")
    
    data_1 <- gather(query_1, key = "Type", value = "Total", Made, Missed)
    data_2 <- gather(query_2, key = "Type", value = "Total", Made, Missed)
    data_3 <- gather(query_3, key = "Type", value = "Total", Made, Missed)
    
    output$team_free_plot <- renderPlot({
      ggplot(data_1, aes(x = Player, y = Total, fill = factor(Type, levels = c("Missed", "Made")))) +
      geom_bar(stat = "identity") +
      theme_minimal() +
      coord_flip() +  # To flip the bars horizontally (optional)
      labs(title = paste0("Made vs Missed Free Throws for Players on ", input$team),
           x = "Player",
           y = "Total",
           fill = "Result") +
      scale_fill_manual(values = c("Made" = "gold", "Missed" = "black"))
    })
      
    ggplot(data_2, aes(x = Player, y = Total, fill = factor(Type, levels = c("Missed", "Made")))) +
      geom_bar(stat = "identity") +
      theme_minimal() +
      coord_flip() +  # To flip the bars horizontally (optional)
      labs(title = "Made vs Missed 2pt for Players",
           x = "Player",
           y = "Total",
           fill = "Result") +
      scale_fill_manual(values = c("Made" = "gold", "Missed" = "black"))
    
    ggplot(data_3, aes(x = Player, y = Total, fill = factor(Type, levels = c("Missed", "Made")))) +
      geom_bar(stat = "identity") +
      theme_minimal() +
      coord_flip() +  # To flip the bars horizontally (optional)
      labs(title = "Made vs Missed 3pt for Players",
           x = "Player",
           y = "Total",
           fill = "Result") +
      scale_fill_manual(values = c("Made" = "gold", "Missed" = "black"))
    
    
    #shot attempts by 4 min segment
    
    seg4 <- pbp %>%
      mutate(Segment = (Game_Seconds %/% 240) +1)
    
    seg4_shots <- subset(seg4, grepl("2pt|3pt", Event_Description, ignore.case = TRUE))
    Purdue_shots <- subset(seg4_shots, Event_Team == "St. John's (NY)")
    Purdue_shots <- subset(Purdue_shots, grepl("made|missed", Event_Result, ignore.case=TRUE))
    unique(Purdue_shots$Event_Type)
    unique(Purdue_shots$Event_Result)
    
    seg <- Purdue_shots %>% 
      group_by(Player_1, Segment) %>%
      summarise(Count = n()) %>%
      arrange(Player_1, Segment)
    
    seg$Segment <- as.character(seg$Segment)
    seg$Segment <- factor(seg$Segment, levels = c("1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11"))
    seg_filt <- seg %>%
      group_by(Player_1) %>%
      filter(sum(Count) >= 25) %>%  # Keep only players with summed Count >= 25
      ungroup()
    
    ggplot(seg_filt, aes(x = Player_1, y=Count, fill=Segment)) +
      geom_bar(stat = "identity", position= "dodge") +
      labs(title = "Shots by 4 minute segment", x = "Player", y = "Shots") +
      theme(axis.text.x = element_text(angle = 45, hjust = 1))
  })
 
}


shinyApp(ui = ui, server = server)
