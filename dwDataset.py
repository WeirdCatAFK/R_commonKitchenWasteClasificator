import pandas as pd
import os
import opendatasets as od

dataset = 'https://www.kaggle.com/datasets/alistairking/recyclable-and-household-waste-classification/data'

od.download(dataset)
