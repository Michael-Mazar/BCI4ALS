import scipy.io
from sklearn import svm
import os
import pickle

# Change the default data folder (e.g., the one with MI4's output .mat files) here!
DATA_FOLDER=""

class Classifier():
    def __init__(self, recordings_folder, model_file_path="model"):
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

    def train_model(self, X, y):
        """
        Args:
            `X` - features
            `y` - labels
        Returns:
            A trained model over X and y
        """
        # Feel free to change the model
        clf = svm.SVC(kernel='linear').fit(X, y.T)
        return clf

    def predict_class(self, datapoint):
        """
        Get prediction's value for a single datapoint (trial's features)
        """
        if self.model is None:
            self.load_model()
        
        pred = self.model.predict(datapoint)
        return pred







