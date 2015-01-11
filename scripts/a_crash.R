# This script imports crashes from the UK, subsets them to high severity crashes, finds clusters of crashes and exports to kml

require (sp)
require (rgdal)
require (fossil)
require (plyr)

#2005 to 2012 crash data in the UK
fileIn = "./Input/Accidents0512.csv"

# read in data
input12 = read.csv (fileIn, stringsAsFactors = FALSE, comment.char = "",  
                    colClasses = c ("character", "NULL", "NULL", 
                                    "numeric", "numeric", "NULL",
                                    "character", "NULL", "NULL", 
                                    "character", "NULL", "character", #date, dow, time
                                    "numeric", "NULL", "numeric", 
                                    "numeric", "NULL", "numeric", 
                                    "NULL", "NULL", "NULL", #Junction detail
                                    "NULL", "NULL", "NULL", 
                                    "numeric", "numeric", "numeric", # Light conditions
                                    "NULL", "NULL", "NULL", 
                                    "NULL", "NULL")) 

# exclude rows where there are no lat or long coordinates
input12 = na.omit (input12)

# exclude points outside area of interest
input12 = input12 [input12$Latitude < 52 & input12$Latitude > 51, ]
input12 = input12 [input12$Longitude > -2, ]

#subset to high severity crashes
severity = input12 [input12$Accident_Severity == 1, ]
kmlPoint (severity, "high severity crashes_uk.kml", "high severity")

#subset to crashes in the rain (fatal)
rain = input12 [input12$Weather_Conditions == 2 | input12$Weather_Conditions == 5, ]
rain = rain [rain$Accident_Severity == 1, ]
kmlPoint (rain, "crashes during rain.kml", "rain")



#### FIND CLUSTERS ####
DIST = 0.5
NUM_RECORDS = 10000

latLong = cbind( severity$Latitude, severity$Longitude)
latLong = head(latLong, NUM_RECORDS)
d = earth.dist(latLong, FALSE)

#keep only the points separated by less than 500m
d = round (d, 2)
d = ifelse (d < DIST, d, 0)
d = d/d
# find the number of nearby crashes
nearbycrash = colSums (d, na.rm = TRUE, dims = 1)
x = c (1:sqrt(length(d)))
Latitude = latLong[,1]
Longitude = latLong[,2]
x = cbind (x, nearbycrash, Latitude, Longitude)
x = as.data.frame(x)
# remove crashes with no nearby crashes
x = x [x$nearbycrash > 1,]
rm(d, Latitude, Longitude, nearbycrash)


# plot kml points
kmlPoint (x, "high severity clusters.kml", "clusters")


# function to product kmlPoint file
kmlPoint = function (SPDF, fileName, layer) {
  # set coordinates and projection
  coordinates(SPDF) = c("Longitude", "Latitude")
  proj4string(SPDF) = CRS("+proj=longlat +ellps=WGS84 +datum=WGS84")
  
  # Write to KML file
  writeOGR(SPDF, dsn = paste0("./Output/",fileName), overwrite_layer = TRUE, layer = layer, driver="KML", dataset_options = "NameField=IID")
}
