#Function to Extract NY Neighborhoods from Long/Lat
get_longlat_nbhood=function(lat_vec,long_vec, get='coord'){
  library(rgeos)
  library(sp)
  library(rgdal)
  zillow_map <- readOGR("ZillowNeighborhoods-NY.shp", layer="ZillowNeighborhoods-NY")
  
  nyhood_map <- zillow_map[zillow_map$City == "New York" , ]
  
  coord_df <- data.frame(long=long_vec,
                         lat=lat_vec)
  
  # Assignment modified according
  coordinates(coord_df) <- ~ long + lat
  
  proj4string(coord_df) <- proj4string(nyhood_map)
  proj4string(coord_df) <- CRS("+proj=longlat")
  coord_df <- spTransform(coord_df, proj4string(nyhood_map))
  coord_hood=over(coord_df, nyhood_map)
  if (get=='coord') {
    return(coord_hood)
  }else {
    return(nyhood_map)
  }
}

#Get Neighborhood Areas from Shapefile
get_nbhood_area=function(){
  library(raster)
  
  #read-in shapefile as SpatialPolygonsDataFrame
  shape <- shapefile("ZillowNeighborhoods-NY.shp")
  
  #run area calc and add output to attribute table as new column
  shape$Area_sqm <- area(shape)
  
  #if you need to know the coordinate reference system and distance units in order to interpret the results...
  #get the CRS
  crs(shape)
  nbhood_area=data.frame(county=shape$County,nbhood=shape$Name,area=shape$Area_sqm)
  return(nbhood_area)
}
