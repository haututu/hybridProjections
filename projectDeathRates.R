library(tidyverse)
library(demest)

#Setup
deathCounts <- read_csv("raw/deathCounts.csv") %>%
  gather(age, deaths, 3:93) %>%
  filter(year >= 2013)

popCounts <- read_csv("raw/pop2013-2017.csv") %>%
  gather(age, pop, 3:93) %>%
  mutate(age = ifelse(age == "1 years", "1 year", age))

deathRates <- left_join(deathCounts, popCounts, by = c("year", "age", "sex")) %>%
  mutate(rate = deaths / pop)

deaths <- select(deathRates, year, age, sex, rate) %>%
  xtabs(rate ~ year + age + sex, data=.) %>%
  Values(dimscales = c(year = "Intervals"))

#Model
model.norm <- Model(y ~ Normal(mean ~ age * sex * year))

ests <- "out/deathNormal.est"

estimateModel(model = model.norm,
              y = deaths,
              filename = ests,
              nBurnin = 2000,
              nSim = 20000,
              nChain = 4,
              nThin = 4)

fetchSummary(ests)

#Forecast
preds <- "out/deathNormal.pred"

predictModel(filenameEst = ests,
             filenamePred = preds,
             n = 11)

rates.both <- fetchBoth(filenameEst = ests,
                        filenamePred = preds,
                        where = c("model", "likelihood", "mean"))
