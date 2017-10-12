library(dplyr)
library(geosphere)
load('subway_df.Rda')
load('airbnb_map_df.Rda')
subway_id=c()
subway_dist=c()
for (rownum in 1:nrow(airbnb_map_df)){
  #Loop through all Airbnb Rows(Listings)
    #Find distance of each Airbnb Listing at rownum to all Subway Stations
    alldist=distHaversine(p1=airbnb_map_df[rownum,c('long','lat')], p2=subway_df[,c('long','lat')])
    #Save Subway ID of Nearest Station into 'id' column of Airbnb Data Frame  
    subway_id[rownum]=subway_df[which(alldist==min(alldist)),'subway_id']
    #Save Distance of Nearest Station into 'subway_dist' column of Airbnb Data Frame
    subway_dist[rownum]=min(alldist)
}

airbnb_map_df$subway_id=subway_id
airbnb_map_df$subway_dist=round(subway_dist,digits=0) #Round to the nearest meter
airbnb_map_df=inner_join(airbnb_map_df,subway_df[,c('subway_name','subway_line','subway_id')],by='subway_id')
save(airbnb_map_df, file='airbnb_map_df.Rda')