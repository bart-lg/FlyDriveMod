library("plyr")

fillMissingPoints <- function(inputData) {
  
  range <- c(min(inputData[,1]):max(inputData[,1]))
  
  missingPoints <- range[ !( range %in% inputData[,1] ) ]
  
  newData <- t( matrix( unlist( approx( inputData[,1], inputData[,2], xout = missingPoints ) ),
                     ncol = length(missingPoints), byrow = T ) ) 
  
  data <- rbind(inputData, newData)
  return( data[order(data[,1]),] )
  
}


### MORTALITY RATES

mortalityRates <- cbind(
  c(5, 6, 7, 8, 9,   10,  15,  20,  25, 30,  31, 32), # temperature
  c(1, 1, 1, 1, 0.7, 0.6, 0.3, 0.3,  0, 0.4,  1,  1) # mortalityRate
)
colnames(mortalityRates) <- c("temperature", "mortalityRate")

#plot(mortalityRates)
mortalityRates <- fillMissingPoints(mortalityRates)
#plot(mortalityRates)

write.csv(mortalityRates, file.path("params", "mortalityRates.csv"), row.names=FALSE)


### EGGS / FEMALE / DAY

eggsPerDay <- cbind(
  c(5, 6, 7, 8, 9,  10,   15,  20,   25,   30,  31, 32), # temperature
  c(0, 0, 0, 0, 0, 0.1, 0.29, 1.6, 2.09, 0.49,   0,  0) # eggsPerDay
)
colnames(eggsPerDay) <- c("temperature", "eggsPerDay")

#plot(eggsPerDay)
eggsPerDay <- fillMissingPoints(eggsPerDay)
#plot(eggsPerDay)

write.csv(eggsPerDay, file.path("params", "eggsPerDay.csv"), row.names=FALSE)


### LIFE STAGES

## FEMALE

# EGGS TO ADULT
femaleEggsToAdult <- cbind(
  c(10  , 14  , 18  , 22, 26  , 28 , 30), # temperature
  c(79.3, 28.8, 18.2, 14, 10.8, 9.9, 12) # duration
)
colnames(femaleEggsToAdult) <- c("temperature", "femaleEggsToAdult")
femaleEggsToAdult <- fillMissingPoints(femaleEggsToAdult)
write.csv(femaleEggsToAdult, file.path("params", "femaleEggsToAdult.csv"), row.names=FALSE)

# ADULT LONGEVITY
femaleAdultLongevity <- cbind(
  c(10, 14  , 18  , 22  , 26  , 28  , 30), # temperature
  c(35, 27.3, 18.2, 10.5, 12.8, 10.7, 2 ) # duration
)
colnames(femaleAdultLongevity) <- c("temperature", "femaleAdultLongevity")
femaleAdultLongevity <- fillMissingPoints(femaleAdultLongevity)
write.csv(femaleAdultLongevity, file.path("params", "femaleAdultLongevity.csv"), row.names=FALSE)


## MALE
## ATTENTION: LAST VALUES (temperature=30) ARE TAKEN FROM FEMALE DATA (no data for male)

# EGGS TO ADULT
maleEggsToAdult <- cbind(
  c(10  , 14  , 18  , 22, 26  , 28, 30), # temperature
  c(78.3, 28.7, 18.9, 14, 11.1, 10, 12) # duration
)
colnames(maleEggsToAdult) <- c("temperature", "maleEggsToAdult")
maleEggsToAdult <- fillMissingPoints(maleEggsToAdult)
write.csv(maleEggsToAdult, file.path("params", "maleEggsToAdult.csv"), row.names=FALSE)

# ADULT LONGEVITY
maleAdultLongevity <- cbind(
  c(10, 14  , 18  , 22  , 26  , 28  , 30), # temperature
  c(31, 20.8, 16.8, 13.2, 12.8, 10.1, 2 ) # duration
)
colnames(maleAdultLongevity) <- c("temperature", "maleAdultLongevity")
maleAdultLongevity <- fillMissingPoints(maleAdultLongevity)
write.csv(maleAdultLongevity, file.path("params", "maleAdultLongevity.csv"), row.names=FALSE)
