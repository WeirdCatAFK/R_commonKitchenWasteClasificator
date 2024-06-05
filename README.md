# R_image clasificator

A project that uses image identification and neural networks to classify common kitchen waste onto the categories aluminum or cardboard , trained on a public dataset

This project uses the next dataset:

Alistair King, www.kaggle.com/datasets/alistairking/recyclable-and-household-waste-classification

# Try the project

1.-To get the data run the image_manager.py with your kraggle.json credentials to get the dataset of this project

2.-To continue, well have to create an R dataframe so run dataframe_creator.r (Either numeric or otsu) to create it. It will create two dataframes, one called training_dataframe.rds, and another one called prediction_dataframe.rds. These dataframes will be used later

3.- Run the clasificacion_ANNS.r file to run the model (Take onto consideration this program uses a big ammount of RAM to run a proper model, check for at least 8gb of free RAM to create the model)
