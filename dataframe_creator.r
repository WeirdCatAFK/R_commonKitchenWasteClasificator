# Instalar las librerías si no están instaladas
if (!require(imager)) {
    print("Instalando la librería 'imager'...")
    install.packages("imager", dependencies = TRUE)
}
if (!require(dplyr)) {
    print("Instalando la librería 'dplyr'...")
    install.packages("dplyr", dependencies = TRUE)
}
if (!require(data.table)) {
    print("Instalando la librería 'data.table'...")
    install.packages("data.table", dependencies = TRUE)
}

# Cargar las librerías
print("Cargando las librerías...")
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

    # Extraer las matrices
    r_matrix <- as.matrix(R(img))
    g_matrix <- as.matrix(G(img))
    b_matrix <- as.matrix(B(img))

    # Calcular la luminancia manualmente
    luminance_matrix <- 0.299 * r_matrix + 0.587 * g_matrix + 0.114 * b_matrix

    list(r = r_matrix, g = g_matrix, b = b_matrix, luminance = luminance_matrix)
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

        # Crear un dataframe temporal con los datos de la imagen
        temp_df <- data.frame(
            file = basename(image_file),
            label = label,
            r_matrix = I(list(image_data$r)),
            g_matrix = I(list(image_data$g)),
            b_matrix = I(list(image_data$b)),
            luminance_matrix = I(list(image_data$luminance))
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

# Guardar el dataframe final en un archivo RDS
output_path_rds <- "dataframe.rds"
print(paste("Guardando el dataframe final en", output_path_rds))
saveRDS(final_df, output_path_rds)

# Mostrar un mensaje indicando que el guardado fue exitoso
print("Dataframe final guardado exitosamente en formato RDS.")
