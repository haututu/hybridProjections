#Format test population and merge on skeleton to patch gaps.
pop2017.preSmooth <- read_csv("raw/trust.csv") %>%
  mutate(age = ifelse(age >= 90, "90+", age),
         sex = ifelse(sex == "M", "male", ifelse(sex == "F", "female", NA))) %>%
  group_by(age, sex) %>%
  summarise(pop = n()) %>%
  ungroup() %>%
  right_join(skeleton, by=c("sex", "age")) %>%
  mutate(pop = ifelse(is.na(pop), mean(pop, na.rm=TRUE), pop),
         year = 2017,
         source = "trust") %>%
  select(year, sex, age, pop, source)

pop2017.maori <- read_csv("raw/pop2013-2017.csv") %>%
  gather(age, pop, 3:93) %>%
  filter(year == 2017) %>%
  mutate(age = sapply(str_split(age, " "), `[`, 1),
         age = ifelse(age == 90, "90+", age),
         source = "maori")

preSmooth <- rbind(pop2017.preSmooth, pop2017.maori) %>%
  xtabs(pop ~ age + sex + source, data=.) %>%
  Counts()

imputed <- complete(mice(pop2017.preSmooth), 1) %>%
  xtabs(pop ~ age + sex, data=.) %>%
  Counts()

#Model
model.basic <- Model(y ~ Normal(mean ~ sex * age),
                     age ~ DLM(trend = Trend(scale = HalfT(scale = 0.2))))

ests <- "out/popSmooth.est"

estimateModel(model = model.basic,
              y = imputed,
              filename = ests,
              nBurnin = 5000,
              nSim = 10000,
              nChain = 4,
              nThin = 10)

fetchSummary(ests)

collapseIterations(fetch(ests, where = c("model", "likelihood", "mean")),
                   probs = 0.5)
