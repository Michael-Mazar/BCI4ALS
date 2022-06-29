

## Set up Python environment inside a Matlab script

(E.g., if the the Python virtual env is in `.\venv`):

`pyenv('Version','\.venv\Scripts\python.exe')`

## Train
pyrunfile("Classifier.py", action="train")

## Predict
load(strcat(recordingFolder, '\FeaturesTrainSelected.mat'))
or
load(strcat(recordingFolder, '\FeaturesTrainSelected.mat'))

prediction = pyrunfile("Classifier.py", "prediciton", action="predict", datapoints=FeaturesTest);
## Convert to a Matlab object
prediction = uint8(double(prediction))

## More info:
https://www.mathworks.com/help/matlab/ref/pyenv.html
https://www.mathworks.com/help/matlab/ref/pyrunfile.html


