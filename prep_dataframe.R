setwd("C:/Users/cmlim/Desktop/Data Vis Shiny App/PrepData_airbnb_rshiny")
library(dplyr)
#Contains functions get_longlat_nbhood() and get_nbhood_area()
source('./nbhood_functions.R')

####   DATA FRAME : Airbnb Listings  ####
listings_df=read.csv("listings.csv")
#Select Columns of Interest
airbnb_map_df=listings_df%>%
  dplyr::select(lat=latitude,
         long=longitude,
         room_type,
         price,
         host_id,
         boro=neighbourhood_group_cleansed)


airbnb_nbhood_df=get_longlat_nbhood(airbnb_map_df$lat,airbnb_map_df$long,'coord')

airbnb_map_df$nbhood=airbnb_nbhood_df$Name
airbnb_map_df$county=airbnb_nbhood_df$County
rm(listings_df)

#Extract neighborhood area
nbarea_df=get_nbhood_area()

nbarea_df[duplicated(nbarea_df$nbhood),]
airbnb_map_df=inner_join(airbnb_map_df,nbarea_df,by=c('county','nbhood'))
airbnb_map_df$price=as.numeric(airbnb_map_df$price)
View(airbnb_map_df)
save(airbnb_map_df, file="airbnb_map_df.Rda")
#########################################

####   DATA FRAME: Subway   ######
subway_df=read.csv("NYC_Transit_Subway_Entrance_And_Exit_Data.csv")
subway_df=subway_df%>%
  dplyr::select(subway_division=Division,
         subway_line=Line,
         lat=`Station.Latitude`,
         long=`Station.Longitude`,
         subway_name=`Station.Name`)

subway_df=subway_df[!duplicated(subway_df),] #Remove duplicated Rows (due to elimination of Entrances)
subway_df$subway_id=seq.int(nrow(subway_df)) #Add Indexing for each Row
View(subway_df)
save(subway_df, file="subway_df.Rda")
#################################

##### DATA FRAME: Crime   #######
crime_df=read.csv("Crime_Map_.csv")

#Select Cases from 2007-2017
crime_df$year <- format(as.Date(crime_df$CMPLNT_FR_DT, format="%m/%d/%Y"),"%Y")
crime_df$year=as.numeric(crime_df$year)
crime_df=crime_df%>%filter(year>=2007)%>%
  dplyr::select(boro=BORO_NM, 
                lat=Latitude,
                long=Longitude)

#Clean Crime with NA Long/Lat
crime_rows_na=which( rowSums( is.na(crime_df) ) != 0 )
crime_cols_na=which( colSums( is.na(crime_df) ) != 0 )

colnames(crime_df)[crime_cols_na]
#Eliminate Rows with NA
crime_df=crime_df[-1*crime_rows_na,]
#Extract Neighborhoods from Lat/Long and insert column
crime_nbhood_df=get_longlat_nbhood(crime_df$lat,crime_df$long,'coord')

crime_df$nbhood=crime_nbhood_df$Name
crime_df$county=crime_nbhood_df$County
crime_df=crime_df%>%group_by(county,nbhood)%>%summarise(crime_count=n())

crime_df=inner_join(crime_df,nbarea_df,by=c('county','nbhood'))
crime_df=crime_df%>%mutate(crime_density=crime_count/area)%>%arrange(desc(crime_density))
View(crime_df)
save(crime_df,file="crime_df.Rda")

################################
#Matching Neighborhoods Airbnb - Crime
sum(unique(airbnb_map_df$nbhood) %in% unique(crime_df$nbhood))

#### DATA FRAME: AIRBNB #####
#Now that we have the Subway & Airbnb DF Ready
# - Match each Airbnb Listings to its Nearest Subway Station
# - including the Subway Distance in Meters 
source('./assign_nearest_subway.R')
#############################


##################################

###############################
#        COMPLETED!!          #
###############################
#Preparation for Data Frames : 
# > airbnb_map_df in './airbnb_map_df.Rda'
#   - Airbnb Listings + Neighborhoods + Nearest Subways
# >crime_df in './crime_df.Rda'
#   - Crimes + Neighborhoods
# >subway_df in './subway_df.Rda'
#   - Subway Stations + Long/Lat + Subway IDs


