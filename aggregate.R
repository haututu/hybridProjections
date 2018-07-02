dat <- rbind(readRDS("lowPred.RDS") %>%
               mutate(projection = "low"),
             readRDS("midPred.RDS") %>%
               mutate(projection = "mid"),
             readRDS("highPred.RDS") %>%
               mutate(projection = "high")
             )

datBinom <- rbind(readRDS("lowPredBinom.RDS") %>%
                    mutate(projection = "low"),
                  readRDS("midPredBinom.RDS") %>%
                    mutate(projection = "mid"),
                  readRDS("highPredBinom.RDS") %>%
                    mutate(projection = "high")
                  )

dat.graph <- group_by(dat, projection, year) %>%
  summarise(pop = sum(pop)) %>%
  spread(projection, pop) %>%
  mutate(source = "normal")

datBinom.graph <- group_by(datBinom, projection, year) %>%
  summarise(pop = sum(pop)) %>%
  spread(projection, pop) %>%
  mutate(source = "binom")

bind.graph <- rbind(dat.graph, datBinom.graph)

ggplot(bind.graph, aes(x=year, y=mid, group=source, fill=source)) +
  geom_line(aes(color=source)) +
  geom_ribbon(aes(ymin=low, ymax=high), alpha=0.2) +
  theme_classic() +
  labs(title = "Rough projection of Māori population",
       y= "Population count",
       x= "Year"
       )
