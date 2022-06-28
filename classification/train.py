import numpy as np
from sklearn.model_selection import train_test_split
from sklearn import svm
from sklearn import metrics
from classifier import Classifier, DEFAULT_RECORDING_FOLDER

"""
Triggers model training
The saved model is saved to for future use (e.g., prediction)

Inputs: none
Outputs: none
Affects: Saves a model to a file
"""

if __name__ == '__main__':
    X_file = r'AllDataInFeatures'
    y_file = r'trainingVec'
    
    classifier = Classifier(recordings_folder=DEFAULT_RECORDING_FOLDER)
    X_train, y_train, X_test, y_test = classifier.read_train_test_data()

    ### Split training data to training and validation
    # X_train, X_validation, y_train, y_validation = train_test_split(X_train, y_train.T, test_size=.2, random_state=42)
    
    ### fit all models
    # clf = LazyClassifier(predictions=True)
    # models, predictions = clf.fit(X_train, X_test, y_train, y_test)
    # print(models.iloc[:,:4])
    
    # TODO: after we choose a model, we should move these lines to the Classifier
    clf = svm.SVC(kernel='linear') 
    clf.fit(X_train, y_train.T)
    
    # y_validation_predicted = clf.predict(X_validation)
    # print("Validation accuracy:",metrics.accuracy_score(y_validation, y_validation_predicted))
    
    y_test_predicted = clf.predict(X_test) 
    print("Test accuracy:",metrics.accuracy_score(y_test.T, y_test_predicted))

    classifier.save_model(clf)

    result = "Success"