
library(shiny)
library(tm)
library(topicmodels)
library(gplots)
library(RColorBrewer)

##  set up a color palette to emphasize high correlation pairs
my_palette <- colorRampPalette(c("black","cyan"))(n=20)

##  load data text
filenames <- list.files(path="data/",pattern="*.txt")
filepaths <- paste("data/", filenames, sep="")
files <- lapply(filepaths,readLines)

##  create corpus from file data
docs <- Corpus(VectorSource(files))
docs <-tm_map(docs,content_transformer(tolower))

##  remove potentially problematic symbols
toSpace <- content_transformer(function(x, pattern) { return (gsub(pattern, " ", x))})
docs <- tm_map(docs, toSpace, "©")
docs <- tm_map(docs, toSpace, '"')
docs <- tm_map(docs, toSpace, "-")
docs <- tm_map(docs, toSpace, '"')

##  remove punctuation
docs <- tm_map(docs, removePunctuation)
##  strip digits
docs <- tm_map(docs, removeNumbers)
##  remove stopwords
docs <- tm_map(docs, removeWords, stopwords("english"))

docs <- tm_map(docs, toSpace, "'")

##  remove whitespace
docs <- tm_map(docs, stripWhitespace)

myStopwords <- c('can', 'author', 'authors', 'doi', 'pmid', 'pubmed', 'index',
                 'medline', 'whether', 'may', 'gox', 'pmcid', 'pmc',
                 'one', 'two', 'copyright', 'epub', 'eur', 'vol')

docs <- tm_map(docs, removeWords, myStopwords)


shinyServer(function(input, output) {
  
  ##  input$ntopics
  output$ntopics <- renderPrint({input$ntopics})
  
  ##  input$nterms
  output$nterms <- renderPrint({input$nterms})
  
  ##  input$ndocs
  output$ndocs <- renderPrint({input$ndocs})
  
  output$topicPlot <- renderPlot({
    
    #Stem document
    #docs <- tm_map(docs, stemDocument)
    n.docs <- length(docs)
    #n.user.docs <- input$ndocs

    idx <- c(1:n.docs)
    idx.subset <- sample(idx,size=input$ndocs, replace=FALSE)
    
    docs.subset <- docs[idx.subset]
    #docs.subset <- sample(docs, size=n.user.docs, replace=FALSE)
    #output$test <- renderPrint({docs.subset[[1]]$content})
    
    dtm <- DocumentTermMatrix(docs.subset)

    burnin <- 2000
    iter <- 1000
    thin <- 500
    seed <-list(2016,10,30,01,18)
    nstart <- 5
    best <- TRUE
  
    k <- input$ntopics
  
    ldaOut <-LDA(dtm, k, method="Gibbs",
                 control=list(nstart=nstart, seed=seed, best=best,
                              burnin=burnin, iter=iter, thin=thin))
    
    
    ldaOut.topics <- as.matrix(topics(ldaOut))
    
    ldaOut.terms <- as.matrix(terms(ldaOut, input$nterms))
    
    topicProbabilities <- as.data.frame(ldaOut@gamma)
    
  
    col.paste <- function(x) {
      paste(x, collapse=',\n')
    }
    my.labCol <- apply(ldaOut.terms, 2, col.paste)
    
    my.labRow <- filenames[idx.subset]
    
    ##  draw heatmap
    heatmap.2(as.matrix(topicProbabilities), 
              Colv=FALSE,
              labCol=my.labCol,
              labRow=my.labRow,
              srtCol=0,
              adjCol=c(0.5,1),
              cexCol=1.2,
              cexRow=1.2,
              main="Topics",          # heat map title
              notecol="black",        # change font color of cell labels to black
              density.info="none",    # turn off density plot inside color legend
              trace="column",         # turn off trace lines inside the heatmap
              tracecol="orange",
              margins=c(12,9),        # widen margins around plot
              col=my_palette,         # choose color palette
              keysize=1.,             # size of color legend image
              key.par=list(cex=0.7),  # key text size
              key.xlab="Probability", # color key axis label
              dendrogram="none",      # no dendrogram,
              sepcolor="white",
              colsep=c(1:k),
              sepwidth=c(.01,.01)
    )

  }, height=800, width=600)

})
