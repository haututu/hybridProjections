library(tidyverse)
library(demest)



###########Setup
#Birth rates
birthRates <- read_csv("raw/births.csv") %>%
  gather(age, rate, 2:41) %>%
  mutate(rate = rate/1000) %>%
  filter(year >= 2013) %>%
  mutate(age = sapply(str_split(age, " "), `[`, 1),
         age = ifelse(age == 50, "50+", age))

#Population counts
pop <- read_csv("raw/pop2013-2017.csv") %>%
  gather(age, pop, 3:93) %>%
  filter(sex == "female") %>%
  select(-sex) %>%
  mutate(age = sapply(str_split(age, " "), `[`, 1),
         age = ifelse(age >= 50, "50+", age)) %>%
  group_by(year, age) %>%
  summarise(pop = sum(pop))

#Merge exposed population with birth rates
births <- inner_join(birthRates, pop, by = c("year", "age")) %>%
  mutate(births = as.integer(pop*rate))

#Demographic arrays for modelling
y <- xtabs(births ~ age + year, data=births) %>%
  Counts(dimscales = c(year = "Intervals"))

exposed <- xtabs(pop ~ age + year, data=births) %>%
  Counts(dimscales = c(year = "Intervals"))

#Model
birth.model <- Model(y ~ Binomial(mean ~ age + year),
                     age ~ DLM(error = Error(robust = TRUE)),
                     jump = 0.045)

ests <- "out/birthBinomial.est"
  
estimateModel(model = birth.model,
              y = y,
              exposure = exposed,
              filename = ests,
              nBurnin = 5000,
              nSim = 60000,
              nChain = 4,
              nThin = 30)

fetchSummary(ests)

#Forecast
preds <- "out/birthBinomial.pred"

predictModel(filenameEst = ests,
             filenamePred = preds,
             n = 11)

