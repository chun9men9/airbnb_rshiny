library(shiny)
library(googleVis)
library(rgdal)
library(leaflet)
library(dplyr)
library(plotly)
library(htmltools)
library(ggthemes)
library(waffle)
#setwd("C:/Users/cmlim/Desktop/Data Vis Shiny App/Airbnb")

load('airbnb_map_df.Rda')
load('subway_df.Rda')
load('crime_df.Rda')
load('airbnb_nbhood_map.Rda')

#Crime Density Color Schemes
bins=quantile(airbnb_nbhood_map@data$crime_density,c(0,0.5,0.7,0.85,1))
pal <- colorBin("YlOrRd", domain = airbnb_nbhood_map@data$crime_density, bins = bins)
crime_level=cut(airbnb_nbhood_map@data$crime_density,bins,include.lowest=T)
levels(crime_level)=c('Very Low','Low','Moderate','High','Very High')

airbnb_nbhood_map@data$crime_level=crime_level

#Prepare Plots Dataframe
airbnb_plot_df=airbnb_map_df%>%
  group_by(nbhood,county,boro)%>%
  summarise(n_listings=n(), avg_price=sum(price)/n(), avg_subwaydist=sum(subway_dist)/n() )
airbnb_plot_df=inner_join(airbnb_plot_df,crime_df, by=c('nbhood','county'))

#Add Price Normalizing metrics
airbnb_norm_df=airbnb_plot_df%>%
  mutate(norm_price=avg_price-mean(airbnb_map_df$price),
         polarity=avg_price>mean(airbnb_map_df$price))
#Add Crime Levels
bins=quantile(airbnb_plot_df$crime_density,c(0,0.5,0.7,0.8,1))
crime_level=cut(airbnb_plot_df$crime_density,bins,include.lowest=T)
levels(crime_level)=c('Very Low (0%-50%)','Low (50%-70%)','Moderate(70%-80%)','High (80%-100%')
airbnb_plot_df$crime_level=crime_level

airbnb_boro_df=airbnb_plot_df%>%group_by(boro)%>%
  summarise(Number_of_Listings=sum(n_listings), 
            Crime_Density=mean(crime_density), 
            Avg_Subway_Distance=mean(avg_subwaydist),
            Avg_Price=mean(avg_price))

#Prepare Plots for Waffle Chart
airbnb_waffle_df=airbnb_plot_df%>%group_by(crime_level,boro)%>%summarise(n_nbhood=n())
airbnb_waffle_df= as.data.frame(airbnb_waffle_df)
#airbnb_price_df=airbnb_map_df%>%filter(room_type=='Private room')


boro <- c("Bronx" = "Bronx",
          "Brooklyn" = "Brooklyn",
          "Manhattan"="Manhattan",
          "Queens" = "Queens",
          "Staten Island" = "Staten Island")

room <- c("Entire home/apt"= "Entire home/apt",
          "Private room" ="Private room",
          "Shared room" ="Shared room")
line <- c("4 Avenue"=              "4 Avenue",
"42nd St Shuttle"=       "42nd St Shuttle",
"6 Avenue"=              "6 Avenue",
"63rd Street"=           "63rd Street",
"8 Avenue"=              "8 Avenue",
"Archer Av"=             "Archer Av",
"Astoria"=               "Astoria",
"Brighton"=              "Brighton",
"Broadway"=              "Broadway",
"Broadway Jamaica"=      "Broadway Jamaica",
"Broadway-7th Ave"=      "Broadway-7th Ave",
"Canarsie"=              "Canarsie",
"Clark"=                 "Clark",
"Concourse"=             "Concourse",
"Coney Island"=          "Coney Island",
"Crosstown"=             "Crosstown",
"Culver"=                "Culver",
"Dyre Av"=               "Dyre Av",
"Eastern Parkway"=       "Eastern Parkway",
"Flushing"=              "Flushing",
"Franklin"=              "Franklin",
"Fulton"=                "Fulton",
"Jerome"=                "Jerome",
"Lenox"=                 "Lenox",
"Lexington"=             "Lexington",
"Liberty"=               "Liberty",
"Myrtle"=                "Myrtle",
"Nassau"=                "Nassau",
"New Lots"=              "New Lots",
"Nostrand"=              "Nostrand",
"Pelham"=                "Pelham",
"Queens Boulevard"=      "Queens Boulevard",
"Rockaway"=              "Rockaway",
"Sea Beach"=             "Sea Beach",
"West End"=              "West End",
"White Plains Road"=     "White Plains Road")





