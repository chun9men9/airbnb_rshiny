
library(leaflet)
shinyServer(function(input, output, session) {

  ## Overview ###########################
  #
  ## NYC Interactive Map ##############################
  # reactivate map info
  
  mapdf <- reactive({
    if (input$radio==1){
     airbnb_map_df %>%
       filter(boro==input$select_boro,
        price >= input$slider_price[1] &
        price <= input$slider_price[2])
    } else if (input$radio==2){
       airbnb_map_df %>%
         filter(subway_line==input$select_line,
                subway_dist>=input$slider_distance[1] &
               subway_dist<=input$slider_distance[2],   
                price >= input$slider_price[1] &
                  price <= input$slider_price[2])
     }
  })
  
 
  # create the map
  output$map <- renderLeaflet({
    leaflet() %>% 
      addProviderTiles(providers$Stamen.TonerLite,
                       options = providerTileOptions(noWrap = TRUE)) %>%
      addPolygons(data=airbnb_nbhood_map, 
                  weight = 2, 
                  fillColor = ~pal(airbnb_nbhood_map@data$crime_density),
                  opacity = 1,
                  color = "black",
                  dashArray = "3",
                  fillOpacity = 0.7,
                  popup=~paste('<b><font color="Black">',
                               'Neighborhood:', Name,'<br/>',
                               'Crime Level:', crime_level, '<br/>')
                  )%>%
      addCircles(lng=subway_df$long,
                 lat=subway_df$lat,
                 color=c('Green'),
                 opacity=1,
                 fillOpacity = TRUE,
                label = subway_df$subway_name) %>%
      #addLegend(position = "bottomleft", pal = groupColors, values = room, opacity = 1,title = "Room Type") %>% 
      setView(lng = -73.9772, lat = 40.7527, zoom = 12)
      
  })
  
  observe({
    proxy <- leafletProxy("map",data = mapdf()) %>% #dont forget ()
      clearMarkers() %>%
      addMarkers(~long,~lat, 
                 popup=~paste('<b><font color="Black">',
                              'Room Type:', room_type,'<br/>',
                              'Price: $', price,'<br/>',
                              'Nearest Subway:', subway_name,'<br/>',
                              'Subway Distance (m):', subway_dist, '<br/>'))
  })
  
     
  
  ## Boroughs Profiles #######################
  
  output$graph_violin <- renderPlot({
    airbnb_map_df%>%filter(room_type==input$price_room)%>%
    ggplot(aes(x = reorder(boro,price,median),  price, color = boro)) +
      ggtitle("Price/Night") +  theme_few()  +theme(plot.title = element_text(face="bold", size=22))+ geom_boxplot() + geom_violin(aes(fill = boro), alpha = 0.3)
  })
  output$graph_density <- renderPlot({
    ggplot(airbnb_plot_df%>%filter(boro %in% c(input$select_density)))+
      geom_density(aes(x=avg_subwaydist, fill=boro, alpha=0.3))+
      ggtitle('Density Plots of Subway Distances')+
      ylab('Density') + xlab('Subway Distance (meters)') +
      theme(legend.position = c(0.9, 0.4),plot.title = element_text(face="bold", size=22))+
      coord_cartesian(xlim=c(0,input$slider_density),expand=TRUE)
  })
  output$graph_bubble <- renderGvis({
    gvisBubbleChart(airbnb_boro_df, idvar="boro", 
                                  xvar="Avg_Subway_Distance", yvar="Crime_Density",
                                  colorvar="boro", sizevar="Number_of_Listings",
                                  options=list(
                                  width = 800,
                                  height = 600,
                                  left=20,
                                  title="Combined Factors\nSubway Distances, Crime Density 
                                  & Number of Listings",
                                  titleTextStyle="{ fontSize:22}",
                                  hAxis='{minValue:-50,maxValue:8500}',
                                  vAxes="[{title:'Crime Density (# cases/sq.m))'}]",
                                  hAxes="[{title:'Subway Distance, Average (meters)'}]"
                      ))
    
  })
  output$graph_diverbar <- renderPlot({
    abs_avg_price=mean(airbnb_map_df$price)
    breaks_y=seq(0,600,100)-abs_avg_price
    labels_y=seq(0,600,100)
    #names(breaks_x)=as.character(breaks_x+mean(airbnb_map_df$price))
    ggplot(airbnb_norm_df%>%filter(boro==input$boro_bar), aes(x=reorder(nbhood,norm_price), y=norm_price)) +
      geom_bar(stat='identity', aes(fill=polarity)) +coord_flip() + 
      xlab('') + ylab('Average Prices ($)') +
      ggtitle("Average Prices by Neighborhood") +  
      scale_y_continuous(breaks=breaks_y,labels = labels_y)+
      theme(legend.position = 'none', plot.title = element_text(face="bold", size=22)) 
    
  })
  output$graph_waffle <- renderPlot({
    #boro_waffle_df=airbnb_waffle_df%>%filter(boro=='Bronx')%>%select(crime_level,n_nbhood)
    waffle_vec=airbnb_waffle_df[airbnb_waffle_df$boro==input$boro_waffle,"n_nbhood"]
    names(waffle_vec)=airbnb_waffle_df[airbnb_waffle_df$boro==input$boro_waffle,"crime_level"]
    waffle(rows=5, waffle_vec, keep=TRUE,
           xlab='1 SQUARE = 1 NEIGHBORHOOD', 
           title="Borough Crime Density Composition",
           #colors=heat.colors(12)[c(10,8,6,3)]) +
           colors=c('cadetblue1','darkorchid','chocolate2','firebrick2')) + #'cadetblue1'
      theme(plot.title = element_text(face="bold", size=22))
  })
  


})#function