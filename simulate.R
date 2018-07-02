library(tidyverse)

################Load the population to model
pop2017 <- read_csv("raw/pop2013-2017.csv") %>%
  gather(age, pop, 3:93) %>%
  filter(year == 2017) %>%
  mutate(age = sapply(str_split(age, " "), `[`, 1),
         age = ifelse(age == 90, "90+", age))

################Births
births <- subarray(
  collapseIterations(
    fetchBoth(filenameEst = "out/birthNormal.est",
              filenamePred = "out/birthNormal.pred",
              where = c("model", "likelihood", "mean")),
    probs = 0.75),
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
    fetchBoth(filenameEst = "out/deathNormal.est",
              filenamePred = "out/deathNormal.pred",
              where = c("model", "likelihood", "mean")),
    probs = 0.75),
  year > 2016)

#Change deaths to df
deaths <- rbind(as.data.frame(subarray(deaths, sex == "male")) %>% mutate(sex = "male", year = as.integer(rownames(deaths))),
                as.data.frame(subarray(deaths, sex == "female")) %>% mutate(sex = "female", year = as.integer(rownames(deaths)))) %>%
  gather(age, deathRate, 1:91)

################Roll forward one year

roll <- function (dat) {
  
  #Add number of births
  newBirths <- filter(dat, sex == "female") %>%
    mutate(age = ifelse(age < 50, age, "50+")) %>%
    group_by(year, age) %>%
    summarise(pop = sum(pop)) %>%
    ungroup() %>%
    inner_join(births, by = c("year", "age")) %>%
    mutate(births = birthRate * pop) %>%
    summarise(births = sum(births))
  
  #Remove dead and roll forward
  rolled <- left_join(dat, deaths, by = c("year", "age", "sex")) %>%
    group_by(year, sex) %>%
    mutate(pop = pop - (deathRate * pop),
           pop = lag(pop, 1)) %>%
    ungroup() %>%
    select(-deathRate)
  
  #Add new births, total born divided by two
  rolled[rolled$age == 0,]$pop <- rep(as.numeric(newBirths)/2, 2)
  
  #Increment the year by one
  rolled$year <- rolled$year + 1
  
  return(rolled)
  
}

rollMult <- function(dat) {
  years <- 2018:2028
  pops <- dat
  
  for (i in 1:length(years)) {
    latest <- filter(pops, year == max(year))
    pops <- rbind(pops, roll(latest))
  }
  
  return(pops)
}

high <- rollMult(pop2017)

saveRDS(high, "highPred.RDS")         
