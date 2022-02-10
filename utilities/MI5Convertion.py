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

model_filename = "model"

def get_split_by_matlab(recording_folder):  # call this function after running MI4
    x_train_file = r'FeaturesTrainSelected'
    y_train_file = r'LabelTrain'
    x_test_file = r'LabelTest'
    y_test_file = r'FeaturesTest'
    x_train = scipy.io.loadmat(os.path.join(recording_folder, x_train_file))[x_train_file]
    y_train = scipy.io.loadmat(os.path.join(recording_folder, y_train_file))[y_train_file]
    x_test = scipy.io.loadmat(os.path.join(recording_folder, x_test_file))[x_test_file]
    y_test = scipy.io.loadmat(os.path.join(recording_folder, y_test_file))[y_test_file]
    return x_train, y_train, x_test, y_test  # returned as numpy arrays



def get_all_data(recording_folder):
    X_file = r'AllDataInFeatures'
    y_file = r'trainingVec'
    X = scipy.io.loadmat(os.path.join(recording_folder, X_file))[X_file]
    y = scipy.io.loadmat(os.path.join(recording_folder, y_file))[y_file]
    return X, y  # returned as numpy arrays

def save_model(model):
    try:
        with open (model_filename, 'wb') as f:
            pickle.dump(model, f, protocol=5)
            print ("Saved model to file named {}".format(model_filename))
    except BaseException as e:
        print("Exception while trying to save model to file: {}".format(e))
    

def load_model():
    try:
        with open (model_filename, 'rb') as f:
            return pickle.load(f)
    except BaseException as e:
        print("Exception while trying to read model from file: {}".format(e))
    

def load_data(recording_folder, features_file_name, labels_file_name):
    features = scipy.io.loadmat(os.path.join(recording_folder, features_file_name))[features_file_name]
    labels = scipy.io.loadmat(os.path.join(recording_folder, labels_file_name))[labels_file_name]
    return features, labels  # returned as numpy arrays

def train(X_train, y_train):
    # Overwrites currently saved model!
    clf = svm.SVC(kernel='linear') 
    clf.fit(X_train, y_train)
    save_model(clf)

def predict_class(datapoint):
    """
    Get prediction's value for a single datapoint (trial's features)
    """
    clf = load_model()
    pred = clf.predict(datapoint)
    return pred[0]



if __name__ == '__main__':
    recording_folder = r'C:\Users\Raz\Study\Cognition_Science\BCI4ALS\Recordings\test\2'
    #X_train, y_train, X_test, y_test = get_split_by_matlab(recording_folder)
    X, y = get_all_data(recording_folder) # make sure dim are right
    X_train, X_test, y_train, y_test = train_test_split(X, y.T, test_size=.2, random_state=42)
    # fit all models
    # clf = LazyClassifier(predictions=True)
    # models, predictions = clf.fit(X_train, X_test, y_train, y_test)
    # print(models.iloc[:,:4])
    clf = svm.SVC(kernel='linear') 
    clf.fit(X_train, y_train)
    y_predicted = clf.predict(X_test)

    print("Accuracy:",metrics.accuracy_score(y_test, y_predicted))

    save_model(clf)
    
    ### Test loading
    clf2 = load_model()
    # y_pred_2 = clf2.predict(X_test)
    # print(np.array_equal(y_predicted, y_pred_2))
    # print("Accuracy:",metrics.accuracy_score(y_test, y_pred_2))
    
    print("hi")



