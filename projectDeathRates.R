library(tidyverse)
library(demest)

#Setup
deathCounts <- read_csv("raw/deathCounts.csv") %>%
  gather(age, deaths, 3:93) %>%
  filter(year >= 2013)

popCounts <- read_csv("raw/pop2013-2017.csv") %>%
  gather(age, pop, 3:93) %>%
  mutate(age = ifelse(age == "1 years", "1 year", age))

deaths <- left_join(deathCounts, popCounts, by = c("year", "age", "sex"))

y <- xtabs(deaths ~ year + age + sex, data=deaths) %>%
  Counts(dimscales = c(year = "Intervals"))

exposed <- xtabs(pop ~ year + age + sex, data=deaths) %>%
  Counts(dimscales = c(year = "Intervals"))

#Model
model.binom <- Model(y ~ Binomial(mean ~ sex * age * year),
                     age ~ DLM(error = Error(robust = TRUE)),
                     jump = 0.075)

ests <- "out/deathBinomial.est"

estimateModel(model = model.binom,
              y = y,
              exposure = exposed,
              filename = ests,
              nBurnin = 20000,
              nSim = 80000,
              nChain = 4,
              nThin = 100)

fetchSummary(ests)

#Forecast
preds <- "out/deathBinomial.pred"

predictModel(filenameEst = ests,
             filenamePred = preds,
             n = 11)
