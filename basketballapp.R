library(shiny)
library(tidyverse)
library(shinydashboard)
library(rvest)
library(stringr)
library(scrutiny)

getdata <- function(x){
  today <- Sys.Date()
  today <- gsub("-", "", today)
  espn <- "https://www.espn.com/mens-college-basketball/schedule/_/date/"
  final <- paste(espn, today, sep="")
  myurl <- read_html(final) # read our webpage as html
  myurl <- html_table(myurl)  # convert to an html table for ease of use
  
  to.parse <- myurl[[1]]  # pull the first item in the list
  df <- as.data.frame(to.parse)
  colnames(df)[1] <- "Away"
  colnames(df)[2] <- "Home_Temp"
  mydata <- df[-c(3:5)]
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
  df2 <- mydata[,c(1,3,2,4,5)]
  df2
}

getdata()

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

