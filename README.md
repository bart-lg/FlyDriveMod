# FlyDriveMod

FlyDriveMod is an individual based (agent based) model for the simulation of a [Drosophila suzukii](https://en.wikipedia.org/wiki/Drosophila_suzukii) population using [NetLogo](https://ccl.northwestern.edu/netlogo/) as a multi-agent programmable modeling environment. 

The environment represents a cherry field with five rows of ten cherry trees surrounded by a ring of wildberry plants. Cherries are grown linearly within a configurable growing period, whereby mean and standard deviation of the cherry amounts per tree can be set. To provide a survivable habitat a limited amount of wildberries is constantly available for egg laying. If wildberries get occupied, the plants grow a new wildberry each day until a certain limit per plant is reached.

Starting with an initial wildtype population, further gene drive populations can be released either in an one time or periodic release. Three different release locations (center, corner-trees, wildberry-plants) as well as three different gender types (female only, male only, mixed) can be set.

The number of simulated years can be specified. Drosophila suzukii flies cover distances up to 15 meters per day. Therefore, a day is divided into 15 ticks calculating the behaviours of the flies and plants and the movements of the flies for every tick. The environment is divided into a grid of 1x1 square meter cells. Plants and flies within a grid cell can interact with each other. Flies can move to a neighbour cell each tick.

Several model parameters are temperature dependent. To smooth temperature fluctuations, a 10-day-mean temperature value gets calculated every tick, on which the model parameters rely. For the current model version the hourly temperature measures of the Stockton Metropolitan Airport (California, USA) of the year 2010 provided by the [US National Centers For Environmental Information of the National Oceanic and Atmospheric Administration (NOAA)](https://www.ncdc.noaa.gov/cdo-web/) had been used. The hourly data has been thinned out to 15 measurements per day according to the number of ticks per day. Since the model reads the temperature data from a csv file, the temperature data set can be replaced by a different data set providing 15 temperature values per day (in °C). The following model parameters are temperature dependent: start and end of season, female/male longevity of adult flies, development duration for stationary female/male flies, frequency of egg laying, mortality rates.

## Usage

## Versioning

## Self-test


