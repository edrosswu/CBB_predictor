library(shiny)
library(tidyverse)
library(shinydashboard)
library(rvest)
library(stringr)
library(scrutiny)
library(DT)
library(shinyWidgets)
library(reactable)

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
  df2
}

getsched()

getbart <- function(x){
  barturl <- read_html("https://barttorvik.com/trank.php#")
  bart <- html_table(barturl)
  bart.parse <- bart[[1]]  # pull the first item in the list
  dfbart <- as.data.frame(bart.parse)
  names(dfbart) <- c('Rk', 'Team', 'Conf', 'G', 'Rec', 'AdjOE', 'AdjDE', 'Barthag', 'EFG', 'EFGD', 'TOR', 'TORD', 'ORB', 'DRB', 'FTR', 'FTRD', '2P', '2PD', '3P', '3PD', '3PR', '3PRD', 'Tempo', 'WAB')
  dfbart <- dfbart[-c(1),]
  dfbart <- dfbart[-grep('Rk', dfbart$Rk), ]
  dfbart$Team <- sub("\\s*\\t*\\(.*$", "", dfbart$Team)
 
  print(dfbart[1:30,])
}
getbart()

ui <- dashboardPage(skin = "blue",
                    dashboardHeader(title = "CBB Score Predictor"),
                    dashboardSidebar(
                      sidebarMenu(
                        #used to build out pages
                        menuItem("Home Page", tabName = "dashboard", icon = icon("home")),
                        menuItem("Schedule", tabName = "games", icon = icon("basketball")),
                        menuItem("Barttorvik", tabName = "bart", icon = icon("chart-line")),
                        menuItem("About Us", tabName = "about", icon = icon("person"))
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
                                column(12, reactableOutput("schedule_plot"), style = "padding-top: 50px;")
                              ))
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
}


shinyApp(ui = ui, server = server)
