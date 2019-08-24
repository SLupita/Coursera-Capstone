## Author: Lupita Sahu
## The entire code used to download, clean and manipulate the data
## are present here.


# Loading the libraries
library(tm)
library(tidytext)
library(tidyverse)
source("functions.R")

## Loading the data
dl <- tempfile()
download.file("https://d396qusza40orc.cloudfront.net/dsscapstone/dataset/Coursera-SwiftKey.zip", dl)

unzip(dl, exdir=".")
sub.folders <- list.dirs("./final", recursive=TRUE)[-1]

## Extracting English data only
list_of_files <- list.files(sub.folders[1], recursive = TRUE, full.names = TRUE)
corpus <- sapply(list_of_files, function(f) readLines(f, encoding="UTF-8"))
closeAllConnections()
remove(dl)

## Create pfonanity data table
swear <- readLines("FB_bad_word.txt")


## Modifying the Corpus data
titles <- c("blogs","news","twitter")
names(corpus) <- titles

# Remove numbers and swear words from corpus
for(i in seq_along(titles)) {
    corpus[[i]] <- removeProfanity(corpus[[i]])
    corpus[[i]] <- removeNumbers(corpus[[i]])
}

## Create a sample with 5% data. After performing all the
## required analysis and code validation, we will
## finally remove this and use the entire corpus
corpus <- generateSampleData(0.05)

####### word seggregation #######
unigram <- tibble()

## Individual words ##

for(i in seq_along(titles)) {
    
    clean <- tibble(x = seq_along(corpus[[i]]),
                    text = corpus[[i]]) %>%
        unnest_tokens(word, text, strip_punct = TRUE) %>%
        
        mutate(source = titles[i]) %>%
        select(source, everything())
    
    unigram <- rbind(unigram, clean)
}
rm(clean)

unigram$source <- factor(unigram$source, levels = rev(titles))

#  Removing stop words, single letters
unigram <- unigram %>%           
    filter(!str_detect(word, "^[a-z]{1}$")) %>%  #Removing single letters
    anti_join(stop_words)                        #Removing stop words

#Removing more meaningless words
mystopwords <- tibble(word = c("lol", "rt", "st","im"))
unigram <- unigram %>% anti_join(mystopwords)

#Considering only the top 5 most frequent words from unigram
unigram <- unigram %>% dplyr::count(word, sort = TRUE) %>% top_n(5)


### Calculate bigram ###
bigram <- tibble()

for(i in seq_along(titles)) {
    
    clean <- tibble(x = seq_along(corpus[[i]]),
                    text = corpus[[i]]) %>%
        unnest_tokens(word, text, token = "ngrams", n = 2) %>%
        mutate(source = titles[i]) %>%
        select(source, everything())
    
    bigram <- rbind(bigram, clean)
}

rm(clean)

bigram$source <- factor(bigram$source, levels = rev(titles))

# Removing na values
bigram <- bigram %>% filter(!is.na(bigram$word))

## Word separation
bigram <- bigram %>%
    select(word) %>%
    count(word, sort = TRUE) %>%
    separate(word, c("firstWord", "lastWord"), sep = " ")

# Removing bigrams with low occurences
bigram <- bigram %>% filter(n>2)

# Saving the bigram which will be used further
saveRDS(bigram, "bigram_final.rds")

bigram_table <- data.table(bigram_counts)


### Calculate trigram ###
trigram <- tibble()

for(i in seq_along(titles)) {
    
    clean <- tibble(x = seq_along(corpus[[i]]),
                    text = corpus[[i]]) %>%
        unnest_tokens(word, text, token = "ngrams", n = 3) %>%
        mutate(source = titles[i]) %>%
        select(source, everything())
    
    trigram <- rbind(trigram, clean)
}

rm(clean)

trigram$source <- factor(trigram$source, levels = rev(titles))


# Removing na values
trigram <- trigram %>% filter(!is.na(trigram$word))

trigram <- trigram %>%
    select(word) %>%
    count(word, sort=TRUE) %>%
    separate(word, c("word1", "word2", "word3"), sep = " ")

## Removing phrases of low occurences
trigram <- trigram %>% filter(n>1)

## Making the trigram data ready to be used our prediction model
trigram <- trigram %>%
    mutate(firstWords=paste(word1,word2), lastWord=word3) %>% 
    select(firstWords, lastWord, n)

### Calculate fourgram ###
## Fourgrams were not used as my system could not handle such 
## huge computation and R studio crashed

# fourgram <- tibble()
# 
# for(i in seq_along(titles)) {
# 
#         clean <- tibble(x = seq_along(corpus[[i]]),
#                         text = corpus[[i]]) %>%
#              unnest_tokens(word, text, token = "ngrams", n = 4) %>%
#              mutate(source = titles[i]) %>%
#              select(source, everything())
# 
#         fourgram <- rbind(fourgram, clean)
# }
# rm(clean)
# 
# fourgram <- fourgram %>% filter(!is.na(fourgram$word))
# 
# fourgram$source <- factor(fourgram$source, levels = rev(titles))
# 
# fourgram <- fourgram %>% 
        # select(word) %>%
        # count(word, sort=TRUE) 
# 
# fourgram <- fourgram %>% separate(word, c("word1", "word2", "word3","word4"), sep = " ")
# 
# 
# fourgram <- fourgram %>%
#        mutate(firstWords=paste(word1,word2,word3), lastWord=word4) %>%
#        select(firstWords, lastWord, n)