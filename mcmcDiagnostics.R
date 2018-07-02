library(coda)

draws <- fetchMCMC(ests, where = c("model", "likelihood", "prob"))

plot(draws, ask = TRUE, smooth = FALSE)
