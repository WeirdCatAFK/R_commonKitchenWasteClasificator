library(tidyverse)
library(neuralnet) # rna
library(GGally) # visualizaciones

data <- readRDS("training_dataframe.rds")
pred <- readRDS("prediction_dataframe.rds")

print(head(data))

