library(tidyverse)
library(neuralnet)

# Check if required libraries are installed
stopifnot(requireNamespace("tidyverse", quietly = TRUE))
stopifnot(requireNamespace("neuralnet", quietly = TRUE))

# Load data
training_df <- readRDS("training_dataframe.rds")
prediction_df <- readRDS("prediction_dataframe.rds")
test_df <- readRDS("prediction_dataframe.rds")

if (all(c("luminance_vector", "r_vector", "g_vector", "b_vector", "label") %in% colnames(training_df))) {
  cat("Training dataframe loaded successfully.\n")
} else {
  stop("Training dataframe is missing required columns.\n")
}

if (all(c("luminance_vector", "r_vector", "g_vector", "b_vector") %in% colnames(prediction_df))) {
  cat("Prediction dataframe loaded successfully.\n")
} else {
  stop("Prediction dataframe is missing required columns.\n")
}

if (all(c("luminance_vector", "r_vector", "g_vector", "b_vector", "label") %in% colnames(test_df))) {
  cat("Test dataframe loaded successfully.\n")
} else {
  stop("Test dataframe is missing required columns.\n")
}

# Convert the label to binary coding: aluminum = 0, carton = 1
training_df$label <- as.numeric(factor(training_df$label, levels = c("aluminum", "carton"), labels = c(0, 1)))

# Ensure all vectors are numeric
training_df <- training_df %>%
  mutate(across(c(luminance_vector, r_vector, g_vector, b_vector), as.numeric))

prediction_df <- prediction_df %>%
  mutate(across(c(luminance_vector, r_vector, g_vector, b_vector), as.numeric))

test_df <- test_df %>%
  mutate(across(c(luminance_vector, r_vector, g_vector, b_vector), as.numeric))

# Remove any NA values
training_df <- na.omit(training_df)
prediction_df <- na.omit(prediction_df)
test_df <- na.omit(test_df)

cat("Creating the model\n")
model <- tryCatch({
  neuralnet(
    label ~ luminance_vector + r_vector + g_vector + b_vector,
    data = training_df,
    hidden = 3,
    act.fct = "logistic",
    linear.output = FALSE
  )
}, error = function(e) {
  cat("Error creating the model:\n")
  print(e)
  NULL
})

if (!is.null(model)) {
  cat("Model created successfully.\n")
  cat("Training the model\n")
  trained_model <- model
  
  # Convert the input variables to numeric vectors
  prediction_df$luminance_vector <- as.numeric(prediction_df$luminance_vector)
  prediction_df$r_vector <- as.numeric(prediction_df$r_vector)
  prediction_df$g_vector <- as.numeric(prediction_df$g_vector)
  prediction_df$b_vector <- as.numeric(prediction_df$b_vector)
  
  # Prepare the data for prediction
  prediction_input <- prediction_df %>%
    select(luminance_vector, r_vector, g_vector, b_vector) %>%
    as.matrix()
  
  predictions <- compute(trained_model, prediction_input)
  
  # Get predicted labels
  predicted_labels <- ifelse(predictions$net.result <= 0.5, "aluminum", "cardboard")
  
  comparison <- data.frame(
    predicted = predicted_labels,
    actual = test_df$label
  )
  
  success_rate <- sum(comparison$predicted == comparison$actual) / nrow(comparison) * 100
  windows()
  cat("Creating a pie chart\n")
  pie_data <- table(comparison$predicted == comparison$actual)
  labels <- c("Predictions Correct", "Predictions Incorrect")
  colors <- c("green", "red")
  
  pie(pie_data, labels = labels, col = colors, main = paste("Prediction Success Rate: ", success_rate, "%"))
}
