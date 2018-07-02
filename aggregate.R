dat <- rbind(readRDS("lowPred.RDS") %>%
               mutate(projection = "low"),
             readRDS("midPred.RDS") %>%
               mutate(projection = "mid"),
             readRDS("highPred.RDS") %>%
               mutate(projection = "high")
             )

dat.graph <- group_by(dat, projection, year) %>%
  summarise(pop = sum(pop)) %>%
  spread(projection, pop)

ggplot(dat.graph, aes(x=year, y=mid)) +
  geom_line() +
  geom_ribbon(aes(ymin=low, ymax=high), alpha=0.2, fill="red") +
  theme_classic() +
  labs(title = "Rough projection of Māori population",
       y= "Population count",
       x= "Year")