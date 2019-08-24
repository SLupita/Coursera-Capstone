generateSampleData <- function(ratio){
    sample_data <- list()
    
    for(i in 1:3){
        # First select a fraction ratio of the text
        sample_size <- rbinom(length(corpus[[i]]),1,prob=ratio)
        sample_data[[i]] <- corpus[[i]][sample_size==1]
    }
    
    sample_data
}


removeProfanity <- function(text){
    for(i in 1:length(swear)){ 
        text <- gsub(swear[i],"*",text, perl=TRUE) 
    }
    return(text)
}

clean <- function(input) {
    # input <- removePunctuation(input)
    input <- removeNumbers(input)
    input <- stripWhitespace(input)
    input <- tolower(input) 
    input <- removeProfanity(input)
}


##########################################################################################################
# This function is used to extract terms.
# Input: "A B C"
# Output: firstTerms  lastTerm
#         "A B"       "C"
separateTerms = function(x){
    # Pre-allocate
    firstTerms = character(length(x))
    lastTerm = character(length(x))

    for(i in 1:length(x)){
        posOfSpaces = gregexpr("\\s", x[i])[[1]]
        posOfLastSpace = posOfSpaces[length(posOfSpaces)]
        firstTerms[i] = substr(x[i], 1, posOfLastSpace-1)
        lastTerm[i] = substr(x[i], posOfLastSpace+1, nchar(x[i]))
    }

    list(firstTerms=firstTerms, lastTerm=lastTerm)
}


getLastTerms = function(inputString, num){
    # Preprocessing
    inputString = gsub("[[:space:]]+", " ", str_trim(tolower(inputString)))
    
    # Now, ready!
    words = unlist(strsplit(inputString, " "))
    
    # if (length(words) < num){
    #     print("Number of Last Terms: Insufficient!")
    # }
    
    from = length(words)-num+1
    to = length(words)
    tempWords = words[from:to]
    
    paste(tempWords, collapse=" ")
}




# the objective of this function is find the most probable word in a n-gram dataframe , given a group of n last words

find_in_grams <- function(lastW, n) {
    lastW <- clean(lastW)

    # subset 'n-gram' dataframe to find the most probable occurrences 
    if(n==2)
        dfsub = trigram[firstWords == lastW]
    else
        if(n==1)
        dfsub <- bigram[firstWord == lastW]
    
    if(nrow(dfsub) > 0) {
        # if matches, return the 3 top Words
        top3words <- head(dfsub$lastWord,3)
        msg <<- sprintf("Next word was predicted with %1d-gram dataframe.",(n+1))
        return(stripWhitespace(top3words))
    }
    else{
        n <- n-1;
        
        if(n > 0) { 
            lastW <- getLastTerms(lastW,1)
            find_in_grams(lastW, n)
        }
        else {
            msg <<- paste("Next word not found in 2 or 3-grams dataframes.\nReturning the",3,"most frequent words of uni-gram.")
            return(top_n(unigram, 3, n)$word)
        }
    }
}


predict_model <- function(user_input) {
    return(find_in_grams(getLastTerms(user_input, 2), n=2) )
}
