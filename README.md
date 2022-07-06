# BCI4ALS - HUJI - Team 51
## General

This repository contains the code for Motor Imagery pipeline, as part of the BCI4ALS course during the 2021-2022 academic year.

The code is a fork of Asaf Harel (harelasa@post.bgu.ac.il) [basic code for the BCI-4-ALS course](https://github.com/harelasaf/BCI4ALS-MI) which
was taken place in Ben Gurion University during 2020/2021. You are free to use, change, adapt and
so on - but please cite properly if published. 


✨  Team 51 contact details   ✨

%% TODO: add emails
- Michael Mazar (ADD email here)
- Nadav Am-Shalom (ADD email here)
- Raz Perry (ADD email here)
- Osher Maayan (osher.maayan@mail.huji.ac.il)

## Pre-requisites 
- Matlab R2021b or newer (for Python integration support) with the libLSL, OpenBCI, EEGLab with ERPLAB & loadXDF plugins installed (instruction are in the course's documentation).
- Python 3.7-3.9 (at the time of writing this document, Python 3.10 isn't supported by Matlab).

## Python dependencies installation 

Follow these instructions (tested on Windows 10 OS) for a one-time installation:

1. Open at terminal at the repository's directory
2. Run `python -m venv venv` (creating a virtual python environement)
3. Run `.\venv\Scripts\activate.bat` (activating the environment)
4. Run `pip install -r requirements.txt` (installing the requirments in the virtual environment)

## Inter-process integration
The Python GUI communicates with Matlab over TCP/IP: the Matlab runs a server to which the GUI client sends requets
## Intra-process integration
For Python classification, we call Python functions directly from Matlab. Please read the `README.md` file in the `/classification` directory

## Running instructions:
### Common to all flows

The following steps are common for all flows (Offline recordings, Online recording/prediction, etc.)

1. Note that the configuration parameters are defined in `config_params.m` which is called by other functions. Change the parameters if you need to. For example: the recorings output folder, trials length, etc.
2. Activate Python's virtual env by running `.\venv\Scripts\activate.bat`
3. Open OpenBCI and stream a recording

### Recording for offline training

1. Open all dependencies:
   - OpenBCI
   - Lab Recorder
   - % TODO: anything else?
2. Run `MI1_offline_training.m`

#### **Note**:
The output files are saved into the given `root_recording_folder/{subject_id}/{recording_time}` 

- `root_recording_folder/` is specified in `config_params.m`
- `{subject_id}` is specified as a user input before the recording begins
- `{recording_time}` is automatically created from the recording start time

### Recording with online feedback
Record (just like in the offline setting), but show prediction after each trial. Currently, the new recording **do not change the model** (but are saved and can used later to retrain the model). This can also serve a a base for *Co-adaptive learning* in the future. 

*functionality requires a pre-trained classifier* (model).

1. Run OpenBCI and start streaming
2. Run `MI_online_Learning.m`
### Recording for online prediction (prediction per trial)

*This functionality requires a pre-trained classifier* (`model` file in the `/classification` directory).

1. Open all dependencies (OpenBCI, etc.) 
2. Run `MI_online_predict.m` (this is the backend part, which runs a TCP server)
3. Run `python gui/main.py` (the frontend, GUI application); be sure that the virtual environment is activated!
4. In the GUI, click on the *prediction* button
5. In the *prediction* screen, click on *Start* . This will send a "start recording" request to the Matlab server, and will return a prediction (e.g., a number that represents "right", "left", "idle") to the GUI, which will then graphically present the relevant response (e.g., "Yes" or "No")

## Project Structure

The repository is structured from several directories. Below is a short description of the *main files* in each directory. Note that this is **not** a comperehsnive list of all of the repostiory files.

### **root** (the current directory)

- `config_params.m` - configures common parameters and loads common packages
- `main_offline.m` OR `MI1_offline_training.m` - %TODO: which one do we need?
  Runs the main offline flow (i.e., record, process data, segment, extract features and ) 
- `MI_batch_preprocess.m` - % TODO: add description here
- `MI_Online_Feedback.m` - Records trials similar to the offline flow. In addition, *the system's prediction is shown to the user after each trial* - hence the "online feedback". Notes:
1. Requirements: A trained model, feature weight matrix and selected features indices.
2. The trials are saved to file (like in the offline flow)
- `MI_Online_Prediction.m` - The backend (TCP/IP server) that records a trial and send the  model's prediction to the client (e.g., the Python GUI)
  
  *Requirements*: A trained model, feature weight matrix and selected features indices.

### **analysis** %TODO: add here
Different functions that may be helpful to analyze data, such as finding "bad" (noisy) trials, check the effect of different features, etc.

### **classification**
classification code. Offers two main functionalities: *train* (which trains ans saves a model) and *predict* (which uses the saved model to predict). This code is called by Matlab wrappers.

It's highly recommended to read the `README.md` file in this directory, to better understand how the Matlab-Python ingegration here works.

**IMPORTANT**:
1. In `classifier.py`, set the `DATA_FOLDER` variable to the directory with the `AllDataInFeatures.mat` and `trainingVec.mat` files
2. You can (and should) experiment with different classifier (e.g., svm, knn and so on) and then change the classifier class in `train_model` function in `classifier.py`
3. Tip: to determine which classifier to use, you can run the Python code independelty from Matlab and run lazyPredict/Hyper-parameters Grid/Bayes Search and so on.



Files:
- `classifier.py` - includes the main classification logic and exposes an interface for training a model and using a model to predict. By default, the trained model is saved to and loaded from the same path, under the name `model`. 
- `predict.py` - Given a datapoint (or more than one), returns the saved model's prediciton.
- `predict.m` - Matlab wrapper for `predict.py` 
- `train.py` - trains and saves a model based on the data in `DATA_FOLDER` (see note above). Returns the training result (training succeded/failed), and if succeeded - the model's accuracy score.
- `trainModel.m` - Matlab wrapper for `train.py` 
### **common** - ֵ%TODO: add here

### **data features and extraction** - ֵ%TODO: add here

### **gui** (Graphical User Interface)
Includes the code for the GUI. The two main files are:
  - `main.py`  - runs the GUI application, based on the Kivy library. Currently, the GUI shows some buttons and functionalities that are not implemented (but should be in the future).
  - `mimain.kv` - a configuration file for the GUI. Please see [Kivy documentation](https://kivy.org/doc/stable/guide/basic.html) for more details.

### **offlien pipeline** - ֵ%TODO: add here

### **processing** - ֵ%TODO: add here

### **resources**
Includes resource files (e.g., images, electrodes mapping file, etc.)
## Trobuleshooting

### Our offline classifier preforms very poorly
1. A look on the OpenBCI waves output can help us determine the amount of noise we have. The more
   noise, the less able will be our classifier. **Consider applying more suitable frequency filters or remove bad trials**
2. Click several times on the notch filter to bring it to 50hz, even if it is currently on 50hz.
   A look on the FFT around 50hz should reveal a negative peak. If you still see a peak, try replacing the bateries or
   move to another room. Try eliminiate all sources of noise such as electricity (e.g., turn off electric devices). Try to reposition the headset.
   Make sure you put the ear pieces on your ear lobes.

%%% TODO: add more troubleshooting advices

* Note: To remove the 25hz peak, you'll need to avoid using a charger and be far away from electronic devices.

## The dongle is pluged in but cannot connect to the headset.
1. Try replacing the batteries.

## Nothing works :(
1. Take a deep breath
2. Disconnect the dongle.
3. Close all programs.
4. Wait a bit!
5. Try again :)


We would like to thank to all the course staff: both the local (HUJI) and the national ones: Lahav foox(fooxl@post.bgu.ac.il), Asaf Harel(harelasa@post.bgu.ac.il), Or Rabani(orabani@campus.haifa.ac.il).

