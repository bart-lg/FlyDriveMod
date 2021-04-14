# FlyDriveMod

FlyDriveMod is an individual based (agent based) model for the simulation of a [Drosophila suzukii](https://en.wikipedia.org/wiki/Drosophila_suzukii) population using [NetLogo](https://ccl.northwestern.edu/netlogo/) as a multi-agent programmable modeling environment. 

![Teaser_V19](https://user-images.githubusercontent.com/23704254/114712271-33eb9400-9d30-11eb-941e-c2a2b62be3c5.gif)

#### Environment

The environment represents a cherry field with five rows of ten cherry trees surrounded by a ring of wildberry plants. Cherries are grown linearly within a configurable growing period, whereby mean and standard deviation of the cherry amounts per tree can be set. To provide a survivable habitat a limited amount of wildberries is constantly available for egg laying. If wildberries get occupied, the plants grow a new wildberry each day until a certain limit per plant is reached. The number of wildberries per plant can be set in the model configuration. A value setting of 20 wildberries per plant, 200 mean cherries per tree with a standard deviation of 10, 105 for the cherries growth start day and a cherry growth period of 60 days is recommended. The number of simulated years can be specified in the model configuration.

#### Initial Population and Gene Drive Releases

Starting with an initial wildtype population, further gene drive populations can be released either in an one time or periodic release. Three different release locations (center, corner-trees, wildberry-plants) as well as three different gender types (female only, male only, mixed) can be set. An equilibrium test over several years using the stated settings showed a recommendation of 550 for the initial population of flies.

#### Ticks and Grid Cells

Drosophila suzukii flies cover distances up to 15 meters per day. Therefore, a day is divided into 15 so called ticks calculating the behaviours of the flies and plants and the movements of the flies for every tick. On every tick the flies move one meter in a random direction, except flies which are attracted by someone/something. The environment is divided into a grid of 1x1 square meter cells. Plants and flies within a grid cell can interact with each other. Flies can move to a neighbour cell each tick. Since no migration functionality is implemented yet, the environmental boundaries act like a wall.

#### Stationary and Adult Flies

Flies are divided into stationary (covering non full-grown states: egg, larva, pupa, immature-adult) and adult flies, while stationary flies stay at the location where the egg has been laid and adult flies move one meter every tick. The temperature dependent development duration of stationary flies is defined in the appropriate csv file (femaleEggsToAdult.csv and maleEggsToAdult.csv). The durations for certain temperatures are taken from experiment results in the literature and the durations for the missing temperature values in between had been interpolated. Further temperature dependent parameters with interpolated data provided by csv files are the adult longevity (femaleAdultLongevity.csv and maleAdultLongevity.csv) and the mortality rate (mortalityRates.csv). Due to computation reasons mortality affect the flies only in the first tick of the day. The code for generating the csv files (including data interpolation) can be found in generate-parameters.R.

#### Sensing Range

The flight directions of the flies can be influenced by their sensing range of 15 cells. If no male flies are within the cell of a fertile female fly, the nearest male fly gets attracted for the next tick movement. Female flies with developed eggs are looking for cherries or wildberries (preferring cherries over wildberries) within their sensing range.

#### Mating, Fitness, Genotypes

At every tick fertile female and male flies mate if possible before the flies start to move. Flies can only mate, if they are located on the same grid cell. Male and female flies contain certain fitness values depending on their genotype. For every fertile female a random float number between 0 and 1 is generated in the beginning of the mating process. A random fertile male fly with a fitness value equal or above the random number is picked for mating. Now, a second random float number between 0 and 1 is generated for mating succession. If the female's fitness value is equal or above the second random number, the mating succeeds with a result of 33 eggs carried by the female. Male flies can only mate once per tick, irrespective of whether or not the mating succeeded. The development of eggs takes two days before they can be laid. The frequency of egg laying is temperature dependent and defined by experiment results in the literature. The interpolated values are stored in eggsPerDay.csv in the params folder. After all eggs have been laid the female fly becomes unfertile for the following two days (immature-state). The generation counter for the eggs is 1 + generation counter of mother.

The genotypes of the flies within this model consist of two alleles. Possible values for each allele are P for plus/wildtype, R for resistant and M for modified. Based on the literature the following fitness values are assigned for the different genotypes: PP 1.0, PR 1.0, RR 1.0, MM 0.35, MP 0.72, MR 0.72. Different fitness values can be assigned in the model configuration. The genotype of each egg consists of one random allele of each parent. In this model eggs containing a wildtype and no modified allele get liquidated by mothers containing an M allele. Eggs of the genotype RR have a chance/probability to survive the liquidation expressed in a resistance rate, which can be set in the model configuration (based on literature a value of 0.07 is recommended). The initial population consists of flies of the genotypes PP and RR. The ratio of resistant flies in the initial population can be set in the model configuration (based on literature a value of 0.78 is recommended).

#### Off-season

Within off-season due to low temperature, the flies switch to a freezing state. Following the results of experiments in the literature, 50% of all adult flies get killed over the winter. All undeveloped stationary flies get killed as well. To preserve a fertile population the off-season killing affects female and male flies in the same ratio. Following the results of experiments in the literature, 41% of female flies with eggs (standard deviation 3%) preserve their eggs during the winter. The age of adult flies surviving the winter period is set to zero at the beginning of the new season. Fly season starts at a 10-day-mean temperature of 11° C while it ends at a 10-day-mean temperature of 10° C.

#### Weather data

Several model parameters are temperature dependent. To smooth temperature fluctuations, a 10-day-mean temperature value gets calculated every tick, on which the model parameters rely. For the current model version the hourly temperature measures of the Stockton Metropolitan Airport (California, USA) of the year 2010 provided by the [US National Centers For Environmental Information of the National Oceanic and Atmospheric Administration (NOAA)](https://www.ncdc.noaa.gov/cdo-web/) had been used. The hourly data has been thinned out to 15 values per day according to the number of ticks per day. Since the model reads the temperature data from a csv file, the temperature data set can be replaced by a different data set providing 15 temperature values per day (in °C). The following model parameters are temperature dependent: start and end of season, female/male longevity of adult flies, development duration for stationary female/male flies, frequency of egg laying, mortality rates.

#### Result outputs

The results and configurations of the simulations are stored in two separate csv files. The model configuration containing all relevant model parameter as well as the version number of the model are stored in a file with the name suffix config-output.csv. Before the suffix the datetime of the simulation start as well as the random seed for multiple runs is specified in the file names. All relevant model variables are stored for every tick in a file with the name suffix output.csv (stored variables: tick, date, temperature, 10d-mean-temperature, season, season-number, max-cherries, grown-cherries, occupied-cherries, grown-wildberries, occupied-wildberries, stationary-flies, adult-flies, female-flies, female-flies-partner-search, female-flies-with-eggs, male-flies, total/stationary/adult flies for all genotypes, oldest-fly, upgraded-flies, current-eggs-per-day, current-eggs-per-tick, eggs-layed, poisoned-eggs, current-female-stat-duration, current-female-adult-longevity, current-male-stat-duration, current-male-adult-longevity, stat-mortality-rate, adult-mortality-rate, killed-female-adult-longevity, killed-male-adult-longevity, killed stationary/adult flies due to daily mortality for every genotype, min-generation, max-generation, min/max generation for every genotype).

#### Random seeds

Simulations can be run manually or automatically in a so called BehaviorSpace, in which certain combinations of input parameters can be executed. Every parameter set can be executed multiple times to determine the distribution in the outcome due to stochastic events. In this case the model takes care of using different random seeds for the multiple runs. Each run gets a unique behaviorspace-run-number, which is used to set the random seed at the beginning of the simulation.

#### Self-Verification

Since it is impossible to validate the model based on field measurements, particular attention had been paid on the verification of the model. An extensive self verification module had been developed for this model, which can be activated by clicking the test button in the model GUI. The following functionalities are covered by the self test: start of season, end of season, upgrade of stationary to adult flies, genotype generation for new eggs, cherry growing, wildberry growing, reading of weather data, calculation of 10 day mean temperature, release of gene drive flies, determination of temperature dependent mortality rates / eggs per day rates / stationary duration / longevity of adult flies, killing of flies due to mortality rates, off-season killing of flies, calculation of eggs per tick rate, egg development duration, cherry/wildberry attraction affecting female flies, female attraction affecting male flies, egg laying process, fitness impacts, gene drive releases, fertilization, male mating interval, immature state after egg laying.

#### Versioning

All version steps starting with a basic version (v0.100) are uploaded on GitHub. Therefore, the performed code adaptions can be retraced for a better code understanding.

