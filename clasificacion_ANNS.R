library(tidyverse)
library(neuralnet)

# Leer los datos de entrenamiento
training_df <- readRDS("training_dataframe.rds")

# Convertir la etiqueta a codificación binaria: aluminio = 0, cartón = 1
training_df$label <- ifelse(training_df$label == "aluminum", 0, 1)

print("Creando el modelo")
model <- neuralnet(
  label ~ luminance_vector + r_vector + g_vector + b_vector,
  data = training_df,
  hidden = 2,
  linear.output = FALSE
)

print("Entrenando el modelo")
trained_model <- train(model)

# Leer los datos de predicción
prediction_df <- readRDS("prediction_dataframe.rds")


print("Haciendo predicciones con los nuevos datos")
predictions <- predict(trained_model, newdata = prediction_df)

# Convertir las predicciones a etiquetas originales
predicted_labels <- ifelse(predictions <= 0.5, "aluminum", "cardboard")

# Leer los datos de prueba con las etiquetas reales
test_df <- readRDS("test_dataframe.rds")

# Comparar las predicciones con las etiquetas reales
comparison <- data.frame(
  predicted = predicted_labels,
  actual = test_df$label
)

# Calcular el porcentaje de predicciones correctas
success_rate <- sum(comparison$predicted == comparison$actual) / nrow(comparison) * 100

# Crear un gráfico de pastel
pie_data <- table(comparison$predicted == comparison$actual)
labels <- c("Predicciones Correctas", "Predicciones Erróneas")
colors <- c("green", "red")

pie(pie_data, labels = labels, col = colors, main = paste("Porcentaje de Predicciones Exitosas: ", success_rate, "%"))
