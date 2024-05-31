# Instalar las librerías si no están instaladas
if (!require(imager)) {
    install.packages("imager", dependencies = TRUE)
}
if (!require(dplyr)) {
    install.packages("dplyr", dependencies = TRUE)
}
if (!require(data.table)) {
    install.packages("data.table", dependencies = TRUE)
}

# Cargar las librerías
library(imager)
library(dplyr)
library(data.table)

# Definir las rutas a las carpetas
aluminum_path <- "training_data/aluminum"
cardboard_path <- "training_data/cardboard"

# Función para leer las imágenes y extraer las matrices de luminancia, R, G y B
extract_image_data <- function(image_path) {
    # Leer la imagen
    img <- load.image(image_path)

    # Redimensionar la imagen a 64x64
    img_resized <- imager::resize(img, 32, 32)

    # Obtener las matrices de color de canal
    r_matrix <- as.matrix(R(img_resized))
    g_matrix <- as.matrix(G(img_resized))
    b_matrix <- as.matrix(B(img_resized))

    # Calcular la luminancia manualmente
    luminance_matrix <- 0.299 * r_matrix + 0.587 * g_matrix + 0.114 * b_matrix

    list(luminance = luminance_matrix, r = r_matrix, g = g_matrix, b = b_matrix)
}

# Función para calcular el umbral de Otsu adaptado al rango [0, 1]
otsu_thresholding <- function(matrix) {
    hist_data <- hist(matrix, plot = FALSE, breaks = seq(0, 1, length.out = 257)) # 256 bins for [0, 1]
    counts <- hist_data$counts
    bins <- hist_data$mids

    total <- sum(counts)
    sumB <- 0
    wB <- 0
    maximum <- 0.0
    sum1 <- sum(bins * counts)
    for (i in 1:length(counts)) {
        wB <- wB + counts[i]
        wF <- total - wB
        if (wB == 0 || wF == 0) {
            next
        }
        sumB <- sumB + bins[i] * counts[i]
        mB <- sumB / wB
        mF <- (sum1 - sumB) / wF
        between <- wB * wF * (mB - mF) * (mB - mF)
        if (between > maximum) {
            level <- bins[i]
            maximum <- between
        }
    }
    return(level)
}

# Función para convertir matrices a vectores binarios usando el umbral de Otsu
convert_to_binary_vector <- function(matrix) {
    threshold <- otsu_thresholding(matrix)
    as.integer(c(matrix > threshold))
}


# Función para procesar las imágenes en una carpeta
process_images <- function(folder_path, label) {
    # Obtener la lista de archivos de imagen
    image_files <- list.files(folder_path, pattern = "\\.png$", full.names = TRUE)
    print(paste("Procesando", length(image_files), "imágenes en la carpeta", folder_path))

    # Crear un dataframe vacío
    df <- data.frame()

    # Procesar cada imagen
    for (image_file in image_files) {
        print(paste("Procesando imagen:", image_file))
        image_data <- extract_image_data(image_file)

        # Convertir las matrices de luminancia, R, G y B a vectores binarios usando Otsu
        luminance_vector <- convert_to_binary_vector(image_data$luminance)
        r_vector <- convert_to_binary_vector(image_data$r)
        g_vector <- convert_to_binary_vector(image_data$g)
        b_vector <- convert_to_binary_vector(image_data$b)

        # Crear un dataframe temporal con los datos de la imagen
        temp_df <- data.frame(
            file = basename(image_file),
            label = label,
            luminance_vector = (c(luminance_vector)),
            r_vector = (c(r_vector)),
            g_vector = (c(g_vector)),
            b_vector = (c(b_vector))
        )

        # Agregar el dataframe temporal al dataframe principal
        df <- bind_rows(df, temp_df)
    }

    df
}

# Procesar las imágenes de ambas carpetas
print("Procesando imágenes de aluminio...")
aluminum_df <- process_images(aluminum_path, "aluminum")
print("Procesando imágenes de cartón...")
cardboard_df <- process_images(cardboard_path, "cardboard")

# Combinar ambos dataframes
print("Combinando dataframes...")
final_df <- bind_rows(aluminum_df, cardboard_df)

# Dividir el dataframe en 75% entrenamiento y 25% predicción
set.seed(123) # Fijar la semilla para reproducibilidad
train_indices <- sample(seq_len(nrow(final_df)), size = 0.75 * nrow(final_df))
training_df <- final_df[train_indices, ]
prediction_df <- final_df[-train_indices, ]

# Guardar los dataframes en archivos separados
output_path_train <- "training_dataframe.rds"
output_path_pred <- "prediction_dataframe.rds"
print(paste("Guardando el dataframe de entrenamiento en", output_path_train))
saveRDS(training_df, output_path_train)
print(paste("Guardando el dataframe de predicción en", output_path_pred))
saveRDS(prediction_df, output_path_pred)

# Mostrar un mensaje indicando que el guardado fue exitoso
print("Dataframes guardados exitosamente en formato RDS.")
