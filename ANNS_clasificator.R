if (!require(tidyverse)) {
  install.packages("tidyverse", dependencies = TRUE)
}
if (!require(neuralnet)) {
  install.packages("neuralnet", dependencies = TRUE)
}
if (!require(ggplot2)) {
  install.packages("ggplot2", dependencies = TRUE)
}
if (!require(pROC)) {
  install.packages("pROC", dependencies = TRUE)
}

# Check if required libraries are installed
stopifnot(requireNamespace("tidyverse", quietly = TRUE))
stopifnot(requireNamespace("neuralnet", quietly = TRUE))
stopifnot(requireNamespace("pROC", quietly = TRUE))

# Load data
training_df <- readRDS("training_dataframe.rds")
test_df <- readRDS("test_dataframe.rds")

if (all(c("luminance_vector", "r_vector", "g_vector", "b_vector", "label") %in% colnames(training_df))) {
  cat("Training dataframe loaded successfully.\n")
} else {
  stop("Training dataframe is missing required columns.\n")
}

if (all(c("luminance_vector", "r_vector", "g_vector", "b_vector", "label") %in% colnames(test_df))) {
  cat("Test dataframe loaded successfully.\n")
} else {
  stop("Test dataframe is missing required columns.\n")
}

# Convert the label to binary coding: aluminum = 0, cardboard = 1
training_df$label <- as.numeric(factor(training_df$label, levels = c("aluminum", "cardboard"), labels = c(0, 1)))
test_df$label     <- as.numeric(factor(test_df$label, levels = c("aluminum", "cardboard"), labels = c(0, 1)))

# Ensure all vectors are numeric
training_df <- training_df %>%
  mutate(across(c(luminance_vector, r_vector, g_vector, b_vector), as.numeric))

test_df <- test_df %>%
  mutate(across(c(luminance_vector, r_vector, g_vector, b_vector), as.numeric))

# Remove any NA values
training_df <- na.omit(training_df)
test_df <- na.omit(test_df)

cat("Creating the model\n")
model <- tryCatch(
  {
    neuralnet(
      label ~ luminance_vector + r_vector + g_vector + b_vector,
      data = training_df,
      hidden = c(40, 40, 40, 40),
      act.fct = "logistic",
      linear.output = FALSE,
      likelihood = TRUE
    )
  },
  error = function(e) {
    cat("Error creating the model:\n")
    print(e)
    NULL
  }
)

if (!is.null(model)) {
  cat("Model created successfully.\n")
  cat("Training the model\n")
  
  # Prepare the data for prediction
  test_input <- test_df %>%
    select(luminance_vector, r_vector, g_vector, b_vector) %>%
    as.matrix()
  
  predictions <- compute(model, test_input)
  
  # Convert predictions to binary labels
  predicted_labels <- ifelse(predictions$net.result > 0.5, 1, 0)
  
  # Confusion matrix
  actual_labels <- test_df$label
  confusion_matrix <- table(Predicted = predicted_labels, Actual = actual_labels)
  print(confusion_matrix)
  
  # Convert labels back to original categorical values
  predicted_labels_categorical <- factor(predicted_labels, levels = c(0, 1), labels = c("aluminum", "cardboard"))
  actual_labels_categorical <- factor(actual_labels, levels = c(0, 1), labels = c("aluminum", "cardboard"))
  
  # Plot ROC curve
  roc_obj <- roc(actual_labels, predictions$net.result)
  auc_value <- auc(roc_obj)
  
  plot(roc_obj, col = "blue", main = paste("ROC Curve (AUC =", round(auc_value, 2), ")"))
  abline(a = 0, b = 1, col = "red", lty = 2)
  
  cat("Model evaluation complete.\n")
} else {
  cat("Model creation failed. No evaluation was performed.\n")
}

