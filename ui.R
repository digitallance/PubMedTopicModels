library(shiny)

shinyUI(fluidPage(

  # Application title
  titlePanel("PubMed Article Topics"),

  p("This application analyzes topics from PubMed articles related to the Dupuytren's Contracture disease. The text corpus consists of a set of 317 biomedical journal abstracts."),
  p("Document text is processed with the 'tm' library functions, including common English stop word removal. Topics are generated with the Latent Dirichlet Allocation (LDA) algorithm from the 'topicmodels' library."),
  p("The user can select the number of topics to extract, the number of topic terms to display (ranked by importance to the topic), and the number of documents to sample for the topics. Since the topic model computation can take a noticeable amount of time, the maximum number of documents sampled is 50."),
  p("Topics are presented on a heatmap, with rows representing individual articles, and columns the topics. Heatmap colors represent the probability of each topic being found in each article. Documents are sorted based on hierarchical clustering."),
  hr(),
  
  # Sidebar with a slider input for number of bins
  sidebarLayout(
    sidebarPanel(
      sliderInput("ntopics",
                  "Number of topics:",
                  min = 1,
                  max = 5,
                  value = 3),
      sliderInput("nterms",
                  "Number of topic terms to display:",
                  min = 1,
                  max = 9,
                  value = 5),
      sliderInput("ndocs",
                  "Number of random documents for topic analysis:",
                  min = 1,
                  max = 50,
                  value = 10),
      
      submitButton('Submit')
    
    ),

    # Show a plot of the generated distribution
    mainPanel(
      
      h4('Number of topics:'),
      verbatimTextOutput("ntopics"),
      h4('Number of topic terms:'),
      verbatimTextOutput("nterms"),
      h4('Number of documents:'),
      verbatimTextOutput("ndocs"),
      
    #  verbatimTextOutput("test"),
      
      
      
      plotOutput("topicPlot")
    )
  )
))
