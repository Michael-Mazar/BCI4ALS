import numpy as np
from classification.classifier import Classifier, DATA_FOLDER

"""
Input: `datapoints` argument is passed by the MATLAB code when this script is called
Output: The MATALB reads the value of the `predicition` variable after this script is exexcuted
"""

if __name__ == '__main__':
    classifier = Classifier(recordings_folder=DATA_FOLDER)
    
    classifier.load_model()
    datapoints = np.array(datapoints)

    if datapoints.ndim == 1:
        datapoints = datapoints.reshape(1, -1)
    
    prediction = classifier.predict_class(datapoints)

