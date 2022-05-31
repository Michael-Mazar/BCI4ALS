Requirments: Python 3.8 (or newer)

One time installation (virtual env + packages):
python -m venv venv
.\venv\Scripts\activate.bat
pip install -r requirements.txt

In Matlab: 
Set Python exectuable to the virtual env's executable:
pyenv('Version','D:\HUJI\BCI\BCI4ALS\pythonTest\venv\Scripts\python.exe')

## More info:
https://www.mathworks.com/help/matlab/ref/pyenv.html
https://www.mathworks.com/help/matlab/ref/pyrunfile.html

% pyenv('Version','C:\Users\comet\.virtualenvs\BCI4ALS-uqqTTYtU\Scripts\python.exe')


# Train
pyrunfile("train.py")

# Predict
load(strcat(recordingFolder, '\FeaturesTrainSelected.mat'));
or
load(strcat(recordingFolder, '\FeaturesTrainSelected.mat'));

prediction = pyrunfile("predict.py", "prediciton", datapoints=FeaturesTest);

# Convert to a Matlab object
prediction = uint8(double(prediction))

