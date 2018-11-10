# Purpose
First it should be stated that this is a _rough_ approach to population forecasting.
In saying that, it could be a good way to make the best of a bad situation. One in which we have missing data, a single population count, or particularly noisy data.

# How it works

## Birth rates and mortality rates
Currently the model uses Maori population birth and death rates then forecasts them using the `demest` package. A bayesian demography package that you can read more about [here](https://github.com/StatisticsNZ/demest).
The plan is that you can also use custom birth/death rates and model them against larger populations to get more accurate forecasting.

## Base population
The base population is a dataframe of counts by single year of age and sex. 
A lot of iwi and small populations are in the position where they cannot easily get time-series of population counts.
It may be that multiple years can be used in the future but then it would probably make sense to use a slightly different approach anyway.

## Projecting
Simulation the population is relatively simple:
1. Mortality and birth rates are applied to get estimated deaths and births
2. Deaths are subtracted from population
3. The population is rolled forward one year
3. Births are added in the now

## Accounting for error
You can manually adjust the percentiles from the posterior estimates of birth/death forecasts to give error.
Long term I want to automatically sample posterior samples and build a distribution that way.

## Missing data
Yet to be implemented is the ability for multiple imputation of missing age or sex data.
Then the model runs over each imputed dataset and averages results to account for missing data.

# How to crank the handle
In order to run the simulation in its present state you must use the following scripts in roughly given order:

1. projectBirthRates.R
2. projectDeathRates.R
3. simulate.R
4. mcmcDiagnostics.R (optional scrappy code)
5. aggregate.R (summarises projections for graphing)

**NB:** No data is included with this project so you will need your own rates/population to do projections.
