library(tidyverse)
library(neuralnet)

# Read training data
training_df <- readRDS("training_dataframe.rds")

# Convert label to binary encoding: aluminum = 0, cardboard = 1
training_df$label <- ifelse(training_df$label == "aluminum", 0, 1)

print("Making model")
model <- neuralnet(
  label ~ luminance_vector + r_vector + g_vector + b_vector,
  data = training_df,
  hidden = 2,
  linear.output = FALSE
)

# Read prediction data
prediction_df <- readRDS("prediction_dataframe.rds")

print("Making predictions with the new data")
predictions <- predict(model, newdata = prediction_df)

# Convert predictions back to original labels
predicted_labels <- ifelse(predictions <= 0.5, "aluminum", "cardboard")

# Display the first 10 predictions
head(predicted_labels)
