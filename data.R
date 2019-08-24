library(tm)
library(data.table)


unigram <- readRDS("unigram.rds")
bigram <- readRDS("bigram.rds")
trigram <- readRDS("trigram.rds")
swear <- readRDS("swear.rds")

trigram <- data.table(trigram)
bigram <- data.table(bigram)