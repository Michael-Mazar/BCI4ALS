#!/usr/bin/env python
# coding: utf-8


import scipy.io
import numpy as np
import os

# from lazypredict.Supervised import LazyClassifier
from sklearn.model_selection import train_test_split
from sklearn import svm
from sklearn import metrics
import pickle

class Classifier():
    def __init__(self, recordings_folder, model_file_path="pythonTest/model"):
        self.recordings_folder = recordings_folder
        self.model_file_path = model_file_path
        self.model = None
    
    def read_train_test_data(self):  # call this function after running MI4
        x_train_file = r'FeaturesTrainSelected'
        y_train_file = r'LabelTrain'
        x_test_file = r'FeaturesTest'
        y_test_file = r'LabelTest'
        x_train = scipy.io.loadmat(os.path.join(self.recordings_folder, x_train_file))[x_train_file]
        y_train = scipy.io.loadmat(os.path.join(self.recordings_folder, y_train_file))[y_train_file]
        x_test = scipy.io.loadmat(os.path.join(self.recordings_folder, x_test_file))[x_test_file]
        y_test = scipy.io.loadmat(os.path.join(self.recordings_folder, y_test_file))[y_test_file]
        return x_train, y_train, x_test, y_test  # returned as numpy arrays

    def read_dataset(self, featuresFileName, labelsFileName):
        X = scipy.io.loadmat(os.path.join(self.recordings_folder, featuresFileName))[featuresFileName]
        y = scipy.io.loadmat(os.path.join(self.recordings_folder, labelsFileName))[labelsFileName]
        return X, y  # returned as numpy arrays

    def save_model(self, model):
        try:
            with open (self.model_file_path, 'wb') as f:
                pickle.dump(model, f, protocol=5)
                print ("Saved model to file named {}".format(self.model_file_path))
        except BaseException as e:
            print("Exception while trying to save model to file{}: \n Exception:{}".format(self.model_file_path, e))
            raise e
        

    def load_model(self):
        try:
            with open (self.model_file_path, 'rb') as f:
                self.model = pickle.load(f)
        except BaseException as e:
            print("Exception while trying to read model from file {}: \n Exception:{}".format(self.model_file_path, e))
            raise e
        

    def load_data(self, features_file_name, labels_file_name):
        features = scipy.io.loadmat(os.path.join(self.recordings_folder, features_file_name))[features_file_name]
        labels = scipy.io.loadmat(os.path.join(self.recordings_folder, labels_file_name))[labels_file_name]
        return features, labels  # returned as numpy arrays

    def trained_model(self, X_train, y_train):
        clf = svm.SVC(kernel='linear').fit(X_train, y_train)
        return clf

    def predict_class(self, datapoint):
        """
        Get prediction's value for a single datapoint (trial's features)
        """
        if self.model is None:
            self.load_model()
        
        pred = self.model.predict(datapoint)
        return pred

RECORDING_FOLDER = r'D:/HUJI/BCI/BCI4ALS/data/'

if __name__ == '__main__':

    classifier = Classifier(recordings_folder=RECORDING_FOLDER)

    if action == "train":
        X_file = r'AllDataInFeatures'
        y_file = r'trainingVec'
        # X, y = classifier.read_dataset(X_file, y_file) # make sure dim are right
        
        X_train, y_train, X_test, y_test = classifier.read_train_test_data()

        ### Split training data to training and validation
        # X_train, X_validation, y_train, y_validation = train_test_split(X_train, y_train.T, test_size=.2, random_state=42)
        
        ### fit all models
        # clf = LazyClassifier(predictions=True)
        # models, predictions = clf.fit(X_train, X_test, y_train, y_test)
        # print(models.iloc[:,:4])
        
        clf = svm.SVC(kernel='linear') 
        clf.fit(X_train, y_train.T)
        
        # y_validation_predicted = clf.predict(X_validation)
        # print("Validation accuracy:",metrics.accuracy_score(y_validation, y_validation_predicted))
        
        y_test_predicted = clf.predict(X_test) 
        print("Test accuracy:",metrics.accuracy_score(y_test.T, y_test_predicted))

        classifier.save_model(clf)

        result = "Success"
    
    elif action == "predict":
        classifier.load_model()
        datapoints = np.array(datapoints)

        if datapoints.ndim == 1:
            datapoints = datapoints.reshape(1, -1)
        
        prediciton = classifier.predict_class(datapoints)
    
    else:
        print("Unsupported action: {}\nSupported actions are: 'train' and 'predict'".format(action))




