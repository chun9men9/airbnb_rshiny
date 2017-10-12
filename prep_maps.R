library(leaflet)
library(dplyr)
setwd("C:/Users/cmlim/Desktop/Data Vis Shiny App/PrepData_airbnb_rshiny")
#Contains functions get_longlat_nbhood() and get_nbhood_area()
source('./nbhood_functions.R')

load('airbnb_map_df.Rda')
load('crime_df.Rda')
#### MAPS : NEIGHBORHOOD MAPS #####
airbnb_nbhood_map=get_longlat_nbhood(airbnb_map_df$lat,airbnb_map_df$long,'map')

#Add Crime Density to Shapefile Data Frame
temp_map_df=left_join(airbnb_nbhood_map@data, crime_df, by=c('County'='county','Name'='nbhood'))
#Impute NAs with 0s
temp_map_df[is.na(temp_map_df)] <- 0
airbnb_nbhood_map@data=temp_map_df

save(airbnb_nbhood_map, file='airbnb_nbhood_map.Rda')
#save(airbnb_nbhood_popup, file='airbnb_nbhood_popup.Rda')

###############################
#        COMPLETED!!          #
###############################
#Preparation for Maps :
# >Neighborhood Maps
# >Neighborhood Pop Ups