import os
import shutil
import opendatasets as od

dataset = "https://www.kaggle.com/datasets/alistairking/recyclable-and-household-waste-classification/data"

od.download(dataset)


def copy_images_with_enumeration_from_folders(src_dirs, dst_dir):
    # Crear el directorio de destino si no existe
    if not os.path.exists(dst_dir):
        os.makedirs(dst_dir)

    current_index = 1  # Iniciar la enumeración desde 1

    # Iterar sobre las carpetas de origen
    for src_dir in src_dirs:
        # Obtener la lista de archivos de la carpeta actual y ordenarla
        files = sorted(os.listdir(src_dir))

        # Copiar archivos de la carpeta actual al directorio de destino con enumeración
        for filename in files:
            src_path = os.path.join(src_dir, filename)
            dst_path = os.path.join(dst_dir, f"Image_{current_index}.png")
            shutil.copyfile(src_path, dst_path)
            current_index += 1  # Incrementar el índice para la próxima imagen


aluminum = [
    "recyclable-and-household-waste-classification/images/images/aluminum_food_cans/default",
    "recyclable-and-household-waste-classification/images/images/aluminum_food_cans/real_world",
    "recyclable-and-household-waste-classification/images/images/aluminum_soda_cans",
    "recyclable-and-household-waste-classification/images/images/aluminum_soda_cans",
]
aluminum_output = "training_data/aluminum"

cardboard = [
    "recyclable-and-household-waste-classification/images/images/cardboard_boxes/default",
    "recyclable-and-household-waste-classification/images/images/cardboard_boxes/real_world",
    "recyclable-and-household-waste-classification/images/images/cardboard_packaging/default",
    "recyclable-and-household-waste-classification/images/images/cardboard_packaging/real_world",
]
cardboard_output = "training_data/cardboard"

copy_images_with_enumeration_from_folders(aluminum, aluminum_output)
