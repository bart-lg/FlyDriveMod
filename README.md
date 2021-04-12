# FlyDriveMod

FlyDriveMod is an individual based (agent based) model for the simulation of a [Drosophila suzukii](https://en.wikipedia.org/wiki/Drosophila_suzukii) population using [NetLogo](https://ccl.northwestern.edu/netlogo/) as a multi-agent programmable modeling environment. 

The environment represents a cherry field with five rows of ten cherry trees surrounded by a ring of wildberry plants. Cherries are grown linearly within a configurable growing period, whereby mean and standard deviation of the cherry amounts per tree can be set. To provide a survivable habitat a limited amount of wildberries is constantly available for egg laying. If wildberries get occupied, the plants grow a new wildberry each day until a certain limit per plant is reached. The number of wildberries per plant can be set in the model configuration. A value setting of 20 wildberries per plant, 200 mean cherries per tree with a standard deviation of 10 and 105 for the cherries growth start day with a growth period of 60 is recommended. An equilibrium test over several years using the stated settings showed a recommendation of 550 for the initial population of flies.

Starting with an initial wildtype population, further gene drive populations can be released either in an one time or periodic release. Three different release locations (center, corner-trees, wildberry-plants) as well as three different gender types (female only, male only, mixed) can be set.

The number of simulated years can be specified. Drosophila suzukii flies cover distances up to 15 meters per day. Therefore, a day is divided into 15 ticks calculating the behaviours of the flies and plants and the movements of the flies for every tick. The environment is divided into a grid of 1x1 square meter cells. Plants and flies within a grid cell can interact with each other. Flies can move to a neighbour cell each tick. Since no migration functionality is implemented yet, the environmental boundaries act like a wall.

Flies are divided into stationary (covering non full-grown states: egg, larva, pupa, immature-adult) and adult flies, while stationary flies stay at the location where the egg has been laid and adult flies move 1 meter every tick. The temperature dependent development duration of stationary flies is defined in the appropriate csv file (femaleEggsToAdult.csv and maleEggsToAdult.csv). The durations for certain temperatures are taken from experiment results in the literature and the durations for the missing temperature values in between had been interpolated. Another temperature dependent parameters with interpolated data provided by csv files are the adult longevity (femaleAdultLongevity.csv and maleAdultLongevity.csv) and the mortality rate (mortalityRates.csv). Due to computation reasons mortality affect the flies only in the first tick of the day. The code for generating the csv files (including data interpolation) can be found in generate-parameters.R.

The flight directions of the flies can be influenced by their sensing distance of 15 cells. If no male flies are within the cell of a fertile female fly, the nearest male fly gets attracted for the next tick movement. Female flies with developed eggs are looking for cherries or wildberries (preferring cherries over wildberries) within their sensing distance.

At every tick fertile female and male flies mate if possible before the flies start to move. Flies can only mate, if they are located on the same grid cell. Male and female flies contain certain fitness values depending on their genotype. For every fertile female a random float number between 0 and 1 is generated in the beginning of the mating process. A random fertile male fly with a fitness value equal or above the random number is picked for mating. Now, a second random float number between 0 and 1 is generated for mating succession. If the female's fitness value is equal or above the second random number, the mating succeeds with a result of 33 eggs carried by the female. Male flies can only mate once per tick, irrespective of whether or not the mating succeeded. The development of eggs takes two days before they can be laid. The frequency of egg laying is temperature dependent and defined by experiment results in the literature. The interpolated values are stored in eggsPerDay.csv in the params folder. After all eggs have been laid the female fly becomes unfertile for the following two days (immature-state). The generation counter for the eggs is 1 + generation counter of mother.

The genotypes of the flies within this model consist of two alleles. Possible values for each allele are P for plus/wildtype, R for resistant and M for modified. Based on the literature the following fitness values are assigned for the different genotypes: PP 1.0, PR 1.0, RR 1.0, MM 0.35, MP 0.72, MR 0.72. Different fitness values can be assigned in the model configuration. The genotype of each egg consists of one random allele of each parent. In this model eggs containing a wildtype and no modified allele get liquidated. Eggs of the genotype RR have a chance/probability to survive the liquidation expressed in a resistance rate, which can be set in the model configuration (based on literature a value of 0.07 is recommended). The initial population consists of flies of the genotypes PP and RR. The ratio of resistant flies in the initial population can be set in the model configuration (based on literature a value of 0.78 is recommended).

Within off-season due to low temperature, the flies switch to a freezing state. Following the results of experiments in the literature, 50% of all adult flies get killed over the winter. All undeveloped stationary flies get killed as well. To preserve a fertile population the off-season killing affects female and male flies in the same ratio. Following the results of experiments in the literature, 41% of female flies with eggs (standard deviation 3%) preserve their eggs during the winter. The age of adult flies surviving the winter period is set to zero at the beginning of the new season. Fly season starts at a 10-day-mean temperature of 11° C while it ends at a 10-day-mean temperature of 10° C.

csv outputs

Several model parameters are temperature dependent. To smooth temperature fluctuations, a 10-day-mean temperature value gets calculated every tick, on which the model parameters rely. For the current model version the hourly temperature measures of the Stockton Metropolitan Airport (California, USA) of the year 2010 provided by the [US National Centers For Environmental Information of the National Oceanic and Atmospheric Administration (NOAA)](https://www.ncdc.noaa.gov/cdo-web/) had been used. The hourly data has been thinned out to 15 values per day according to the number of ticks per day. Since the model reads the temperature data from a csv file, the temperature data set can be replaced by a different data set providing 15 temperature values per day (in °C). The following model parameters are temperature dependent: start and end of season, female/male longevity of adult flies, development duration for stationary female/male flies, frequency of egg laying, mortality rates.

random seed for mutliple runs

self-test

Video

## Usage

Installation and start

## Versioning

Tags for different code adaptions

## Self-test

## Flow charts


