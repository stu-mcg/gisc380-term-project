library('lubridate')
library('xts')
library('ggplot2')
library('stringr')

convertToSeconds <- function(speedString){
  kmTime <- strptime(speedString, format = "%M:%S")
  kmSeconds <- (minute(kmTime) * 60) + second(kmTime)
  return(kmSeconds)
}

leaderboards <- list.files(path = "./data/stravaLeaderboards")
segments <- read.csv('./data/stravaSegments.csv')
allDailyAvg <- setNames(data.frame(matrix(ncol = 3, nrow = 0)), c("date", "pdiff", "segmentId"))
allWeeklyAvg <- setNames(data.frame(matrix(ncol = 3, nrow = 0)), c("date", "pdiff", "segmentId"))
allMonthlyAvg <- setNames(data.frame(matrix(ncol = 3, nrow = 0)), c("date", "pdiff", "segmentId"))

for(i in 1:nrow(segments)){
  data <- read.csv(paste('./data/stravaLeaderboards/', leaderboards[i], sep=''))
  data$date <- as.Date(data$date, "%b %d, %Y")
  data$kmSeconds <- convertToSeconds(data$speed)
  data <- na.omit(data)
  data$segmentId = str_split(leaderboards[i], "[.]", simplify = TRUE) [1,1]
  
  avg = mean(data$kmSeconds)
  data$kmSecondsPDiff = (data$kmSeconds - avg)/ avg
  data$week <- as.Date(paste(format(data$date, "%U-%Y"), "-0", sep=""), "%U-%Y-%w")
  data$month <- as.Date(paste(format(data$date, "%Y-%m"), "-1", sep=""), "%Y-%m-%d")
  dailyAvg <- setNames(aggregate(data$kmSecondsPDiff, FUN = mean, by = list(data$date)), c('date', 'pdiff'))
  dailyAvg$segmentId <- data$segmentId[1]
  weeklyAvg <- setNames(aggregate(data$kmSecondsPDiff, FUN = mean, by = list(data$week)), c('week', 'pdiff'))
  weeklyAvg$segmentId <- data$segmentId[1]
  monthlyAvg <- setNames(aggregate(data$kmSecondsPDiff, FUN = mean, by = list(data$month)), c('month', 'pdiff'))
  monthlyAvg$segmentId <- data$segmentId[1]
  
  plot(kmSeconds ~ date, data, ylab = "seconds/km")
  plot(pdiff ~ date, dailyAvg, ylab = "% diff", type="l", main = paste(data$segmentId[1], ' Daily Avg', sep=""))
  abline(0, 0, col="red")
  plot(pdiff ~ week, weeklyAvg, ylab = "% diff", type="l", main = paste(data$segmentId[1], ' Weekly Avg', sep=""))
  abline(0, 0, col="red")
  plot(pdiff ~ month, monthlyAvg, ylab = "% diff", type="l", main = paste(data$segmentId[1], ' Monthly Avg', sep=""))
  abline(0, 0, col="red")
  
  allDailyAvg <- rbind(allDailyAvg, dailyAvg)
  allWeeklyAvg <- rbind(allWeeklyAvg, weeklyAvg)
  allMonthlyAvg <- rbind(allMonthlyAvg, monthlyAvg)
}
allWeeklyAvg <- allWeeklyAvg[allWeeklyAvg$week >= as.Date("2017-01-01", "%F"), ]

write.csv(allDailyAvg,"./data/allSegmentsDailyAvg.csv", row.names = TRUE)
write.csv(allWeeklyAvg,"./data/allSegmentsWeeklyAvg.csv", row.names = TRUE)
write.csv(allMonthlyAvg,"./data/allSegmentsMonthlyAvg.csv", row.names = TRUE)
