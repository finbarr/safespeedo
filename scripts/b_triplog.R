# this script takes simulated latitude and longitude coordinates and calculates the distance (using haversine formula)

require (fossil)


fileIn = "./Input/lots of points.csv"

# read in trip
trip = read.csv (fileIn, stringsAsFactors = FALSE)

# Calculate the distance between points using haversine formula
trip$distFromPrevious = deg.dist(trip$Longitude, trip$Latitude, trip$befLon, trip$befLat) * 1000

# write out trip
write.csv (trip, "./Output/lots of points.csv")