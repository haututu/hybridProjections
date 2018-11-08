#Running the simulate.R script but with a small population to test output

################Load the population to model
#Create a skeleton population
skeleton <- data.frame(age = rep(0:90, 2),
                       sex = c(rep("male", 91), rep("female", 91))
                       ) %>%
  mutate(age = ifelse(age == 90, "90+", age))

#Format test population and merge on skeleton to patch gaps.
pop2017 <- read_csv("raw/trust.csv") %>%
  mutate(age = ifelse(age >= 90, "90+", age),
         sex = ifelse(sex == "M", "male", ifelse(sex == "F", "female", NA))) %>%
  group_by(age, sex) %>%
  summarise(pop = n()) %>%
  ungroup() %>%
  right_join(skeleton, by=c("sex", "age")) %>%
  mutate(pop = ifelse(is.na(pop), 0, pop),
    #pop = ifelse(is.na(pop), mean(pop, na.rm=TRUE), pop),
    year = 2017)

################Births
births <- subarray(
  collapseIterations(
    fetchBoth(filenameEst = "out/birthBinomial.est",
              filenamePred = "out/birthBinomial.pred",
              where = c("model", "likelihood", "prob")),
    probs = 0.5),
  year > 2016)

#Change births to df
births <- as.data.frame(births) %>%
  mutate(age = rownames(births)) %>%
  gather(year, birthRate, 1:12) %>%
  mutate(birthRate = ifelse(birthRate <= 0, 1e-10, birthRate),
         year = as.integer(year))

################Deaths
deaths <- subarray(
  collapseIterations(
    fetchBoth(filenameEst = "out/deathBinomial.est",
              filenamePred = "out/deathBinomial.pred",
              where = c("model", "likelihood", "prob")),
    probs = 0.5),
  year > 2016)

#Change deaths to df
deaths <- rbind(as.data.frame(subarray(deaths, sex == "male")) %>% mutate(sex = "male", year = as.integer(rownames(deaths))),
                as.data.frame(subarray(deaths, sex == "female")) %>% mutate(sex = "female", year = as.integer(rownames(deaths)))) %>%
  gather(age, deathRate, 1:91)

################Simulate pop
high <- rollMult(pop2017)

saveRDS(high, "midPredBinom.RDS")  
