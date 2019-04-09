library(tidyverse)
library(stringr)
library(lubridate)
library(rgdal)


read_gpx <- function(list) {
  
  allgpx <- list
  
  col <- rgdal::readOGR(dsn = allgpx[1], layer="waypoints",verbose = F) %>% 
    as.tibble() %>% 
    select(time,name,desc,contains("coords")) %>% 
    rename("lon"=coords.x1,
           "lat"=coords.x2) %>% 
    mutate(time=lubridate::ymd_hms(time),
           id=allgpx[1])
  
  # loop
  alltrk <- col[FALSE,]
  for (i in 1:length(allgpx)) {
    #gpx.wpt <- rgdal::readOGR(dsn = allgpx[i], layer="waypoints")
    #gpx.wpt
    gpx.trk <- rgdal::readOGR(dsn = allgpx[i], layer="waypoints",verbose = F) %>% 
      as.tibble() %>% 
      select(time,name,desc,contains("coords")) %>% 
      rename("lon"=coords.x1,
             "lat"=coords.x2) %>% 
      mutate(time=lubridate::ymd_hms(time),
             name=stringr::str_to_lower(name),
             desc=stringr::str_to_lower(desc),
             id=allgpx[i])
    
    alltrk <- alltrk %>% dplyr::union(gpx.trk) %>% arrange(name)
  }
  
  return(alltrk)
  
}