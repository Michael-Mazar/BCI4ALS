from sklearn.model_selection import train_test_split
from sklearn import svm
from sklearn import metrics
from classification.classifier import Classifier, DATA_FOLDER

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
    
    classifier = Classifier(recordings_folder=DATA_FOLDER)
    X_train, y_train, X_test, y_test = classifier.read_train_test_data()

    clf = classifier.train_model(X_train, y_train)
    y_test_predicted = clf.predict(X_test) 
    print("Test accuracy:",metrics.accuracy_score(y_test.T, y_test_predicted))

    classifier.save_model(clf)

    result = "Success"