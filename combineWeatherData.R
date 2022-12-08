wd1718 <- read.csv('./data/weatherData2017-18.csv')
wd1718 <- head(wd1718, -10)
wd1920 <- read.csv('./data/weatherData2019-20.csv')
wd1920 <- tail(wd1920, -3)
wd1920 <- head(wd1920, -10)
wd2122 <- read.csv('./data/weatherData2021-22.csv')
wd2122 <- tail(wd2122, -3)
wd2122 <- head(wd2122, -10)
allWeatherData <- rbind(wd1718, wd1920)
allWeatherData <- rbind(allWeatherData, wd2122)

allWeeklyAvgAQHI <- setNames(data.frame(matrix(ncol = 3, nrow = 0)), c("date", "AQHI", "StationName"))
for(station in c("Burnaby Kensington Park", "Burnaby South", "North Vancouver Mahon Park", "North Vancouver Second Narrows", "Vancouver International Airport #2")){
  stationData <- allWeatherData[, allWeatherData[1, ] == station | allWeatherData[1, ] == "Date"]
  stationData <- stationData[, stationData[2, ] %in% c("NO2", "O3", "PM25") | stationData[1, ] == "Date"]
  stationData[1, stationData[2,] == "NO2"] <- "NO2"
  stationData[1, stationData[2,] == "O3"] <- "O3"
  stationData[1, stationData[2,] == "PM25"] <- "PM25"
  names(stationData) <- stationData[1,]
  stationData = tail(stationData, -3)
  stationData$Date = as.Date(stationData$Date, "%m/%e/%Y")
  stationData$NO2 = as.numeric(stationData$NO2)
  stationData$O3 = as.numeric(stationData$O3)
  stationData$PM25 = as.numeric(stationData$PM25)
  stationData$AQHI <- with(stationData, (1000/10.4)*((exp(0.000537*O3) - 1)+(exp(0.000871*NO2) - 1) + (exp(0.000487*PM25) - 1)))
  stationData <- na.omit(stationData)
  stationData$week <- as.Date(paste(format(stationData$Date, "%U-%Y"), "-0", sep=""), "%U-%Y-%w")
  weeklyAvgAQHI <- setNames(aggregate(stationData$AQHI, FUN = mean, by = list(stationData$week)), c('week', 'AQHI'))
  weeklyAvgAQHI$stationName <- station
  allWeeklyAvgAQHI <- rbind(allWeeklyAvgAQHI, weeklyAvgAQHI)
}
allWeeklyAvgAQHI <- allWeeklyAvgAQHI[allWeeklyAvgAQHI$week >= as.Date("2017-01-01", "%F"), ]

allWeeklyAvgTemp <- setNames(data.frame(matrix(ncol = 3, nrow = 0)), c("date", "temp", "StationName"))
for(station in c("Burnaby North Eton", "Burnaby South", "North Vancouver Mahon Park", "North Burnaby Capitol Hill", "Vancouver International Airport #2")){
  stationData <- allWeatherData[, allWeatherData[1, ] == station | allWeatherData[1, ] == "Date"]
  stationData <- stationData[, stationData[2, ] == "TEMP_MEAN" | stationData[1, ] == "Date"]
  stationData[1, stationData[2,] == "TEMP_MEAN"] <- "TEMP_MEAN"
  names(stationData) <- stationData[1,]
  stationData = tail(stationData, -3)
  stationData$Date = as.Date(stationData$Date, "%m/%e/%Y")
  stationData$TEMP_MEAN = as.numeric(stationData$TEMP_MEAN)
  stationData$week <- as.Date(paste(format(stationData$Date, "%U-%Y"), "-0", sep=""), "%U-%Y-%w")
  weeklyAvgTemp <- setNames(aggregate(stationData$TEMP_MEAN, FUN = mean, by = list(stationData$week)), c('week', 'temp'))
  weeklyAvgTemp$stationName <- station
  allWeeklyAvgTemp <- rbind(allWeeklyAvgTemp, weeklyAvgTemp)
}
allWeeklyAvgTemp <- allWeeklyAvgTemp[allWeeklyAvgTemp$week >= as.Date("2017-01-01", "%F"), ]
allWeeklyAvgTemp[allWeeklyAvgTemp$week == as.Date("2021-10-10", "%F") & allWeeklyAvgTemp$stationName == "North Burnaby Capitol Hill", ]$temp = NA

write.csv(allWeeklyAvgAQHI,"./data/weeklyAvgAQHI.csv", row.names = TRUE)
write.csv(allWeeklyAvgTemp,"./data/weeklyAvgTemp.csv", row.names = TRUE)
write.table(allWeatherData,"./data/allWeatherData.csv", row.names = FALSE, col.names = FALSE, sep=',')


