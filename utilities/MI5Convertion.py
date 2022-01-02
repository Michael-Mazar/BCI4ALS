#!/usr/bin/env python
# coding: utf-8


import scipy.io
import numpy as np
import os


def get_data(recording_folder):  # call this function after running MI4
    x_train_file = r'FeaturesTrainSelected'
    y_train_file = r'LabelTrain'
    x_test_file = r'LabelTest'
    y_test_file = r'FeaturesTest'
    x_train = scipy.io.loadmat(os.path.join(recording_folder, x_train_file))[x_train_file]
    y_train = scipy.io.loadmat(os.path.join(recording_folder, y_train_file))[y_train_file]
    x_test = scipy.io.loadmat(os.path.join(recording_folder, x_test_file))[x_test_file]
    y_test = scipy.io.loadmat(os.path.join(recording_folder, y_test_file))[y_test_file]
    return x_train, y_train, x_test, y_test  # returned as numpy arrays


if __name__ == '__main__':
    """
    raz check:
    recording_folder = r'C:\Users\Raz\Study\Cognition_Science\BCI4ALS\Recordings\261221\Sub11'
    x_train, y_train, x_test, y_test = get_data(recording_folder)
    """

