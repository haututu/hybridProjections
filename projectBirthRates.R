library(tidyverse)
library(demest)

#Setup
births <- read_csv("raw/births.csv") %>%
  gather(age, rate, 2:41) %>%
  mutate(rate = rate/1000) %>%
  filter(year >= 1996) %>%
  xtabs(rate ~ age + year, data=.) %>%
  Values(dimscales = c(year = "Intervals"))

#Model
birth.model <- Model(y ~ Normal(mean ~ age * year))

ests <- "out/birthNormal.est"
  
estimateModel(model = birth.model,
              y = births,
              filename = ests,
              nBurnin = 2000,
              nSim = 10000,
              nChain = 4,
              nThin = 4)

fetchSummary(ests)

#Forecast
preds <- "out/birthNormal.pred"

predictModel(filenameEst = ests,
             filenamePred = preds,
             n = 11)

rates.both <- fetchBoth(filenameEst = ests,
                         filenamePred = preds,
                         where = c("model", "likelihood", "mean"))
