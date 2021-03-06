# BCI4ALS - HUJI - Team 31
## General

This repository contains the code for our team's implementation's of Motor Imagery pipeline, as part of the BCI4ALS course during the 2021-2022 academic year. 
We strived to create an interactive GUI for mentor alongside online prediction of motor imagery for the corresponding YES/NO response. This project also contain offline analysis pipeline and online feedback pipeline towards motor imagery training. Finally, we included a variety of analysis functions for better understanding the motor imagery signal.

https://user-images.githubusercontent.com/73441199/178137940-794c8a49-2a74-4f92-991e-9ef693c5c363.mp4

The code is a fork of Asaf Harel (harelasa@post.bgu.ac.il) [basic code for the BCI-4-ALS course](https://github.com/harelasaf/BCI4ALS-MI) which
was taken place in Ben Gurion University during 2020/2021. You are free to use, change, adapt and
so on - but please cite properly if published. 

✨  Team 51 contact details   ✨

- Michael Mazar (Michael.Mazar@mail.huji.ac.il)
- Nadav Am-Shalom (TODO: ADD email here)
- Raz Perry (raz.perry@mail.huji.ac.il)
- Osher Maayan (osher.maayan@mail.huji.ac.il)

## Important note
The following instructions and the code files were tested on Windows 10 OS. Different operating systems may require some changes.

## Pre-requisites 
- Matlab R2021b or newer (for Python integration support) with the libLSL, OpenBCI, EEGLab with ERPLAB & loadXDF plugins installed (instruction are in the course's documentation).
- Python 3.7-3.9 (at the time of writing this document, Python 3.10 isn't supported by Matlab).
- Make sure datasets are organized in the subfolder of Data for some of the function to work

## Python dependencies installation 

Follow these instructions for a one-time installation:

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
2. Run `main_offline.m`

### Performing Offline analysis
1. Make sure the recording are located under Data folder and numerically numbered
2. Before running script `batch_offline.m` make sure to specify configurations
   - Specify which dataset to run pipeline on
   - Specify which channels and trials to remove from combined dataset
   - Other relevant parameters can be specified in `config_param.m` file
3. Run `batch_offline.m`: This will perform offline analysis in batch. 
4. Run classification using with `classifier.py`, make sure to specify target 'Data/combined' folder in .py file

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
- `main_offline.m` - runs the full offline flow: record trails, preprocess, segment, extract features and train a classifier
- `MI1_offline_training.m` - Record trials for offline use
- `MI_batch_preprocess.m` -  Preprocess several datasets together
- `MI_Online_Feedback.m` - Records trials similar to the offline flow. In addition, *the system's prediction is shown to the user after each trial* - hence the "online feedback". Notes:
1. Requirements: A trained model, feature weight matrix and selected features indices.
2. The trials are saved to file (like in the offline flow)
- `MI_Online_Prediction.m` - The backend (TCP/IP server) that records a trial and send the  model's prediction to the client (e.g., the Python GUI)
  
  *Requirements*: A trained model, feature weight matrix and selected features indices.

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

### **data features**
- `feature_engineering.m` -This function extracts features for the machine learning process.
% Starts by visualizing the data (power spectrum) to find the best powerbands.
### **gui** (Graphical User Interface)
Includes the code for the GUI. The two main files are:
  - `main.py`  - runs the GUI application, based on the Kivy library. Currently, the GUI shows some buttons and functionalities that are not implemented (but should be in the future).
  - `mimain.kv` - a configuration file for the GUI. Please see [Kivy documentation](https://kivy.org/doc/stable/guide/basic.html) for more details.

### **offline** 
This folder contains function for offline analysis of datasets, combinining or editing datasets or function for running the offline pupeline:
Different functions that may be helpful to analyze data, such as finding "bad" (noisy) trials, check the effect of different features, etc:
Offline pipeline functions
   - `batch_offline.m`: Runs many of the function below, preprocesses selected datasets, combines them and then extracts features that could be classified using either python function specified above or matlab classification functions
   - `MI_combineDataset.m`:  Combines MIData variables of EEG datasets (After MI3 segmentation) based on selection of which folders from the Data folders
   - `MI_edit_dataset.m`: Edits MIData sets by removing trials or EEG channels according to personal selection
   - `MI3_segmentation.m`: A function for segmentation of dataset after preprocessing
   - `MI4_featureExtraction.m`: Performs feature extraction on a dataset with three classes
   - `MI4_featureExtraction_two_class.m`: Performs feature extraction on a data with two classes
   - `MI5_modelTraining.m`:  Trains a linear model based on provided dataset
   - `MI5_trainClassifier.m`:  Trains a matlab SVM classifier based on provided dataset
For analysis
   - `MI_plot_basics.m`: EEG Plot including PSDs, Spectograms, CSPs, and ERPs
   - `MI_plot_features`: Creates heatmap matrix for weights after features selection as a function of channel and feature
   - `MI_plot_spectrogram.m`: Auxilary spectogram plotting function 

We reccomend running the script 'batch_offline' as it incorporates all the analysis functions for convenience on data

### **processing** 
Includes several function for preprocessing MI Datasets
   - `preprocess`: the main preprocessing function, containing various preprocessing steps including low pass, high pass, notch, laplace, ASR and ICA. the file is ran from the main offline pipeline and is configured according to config_params, which allows for skipping some preprocessing steps
   - `clean_ica_components`: cleans irrelevant ICA component determined by a defined threshold and using automatic ICA EEGLAB package 
   - `laplacian_1d_filter`: Performs laplace filter on C3 and C4 electrodes though adjacent electrodes. Note: CZ electrode is not used in this filter
   - `filter_trial`: A function for filtering unwanted trials according to specified criteria
   - `remove_trial`: A function which removes trials manually
   - `sortElectrode`: Sorts electrodes data for further segmentation

### **resources**
Includes resource files (e.g., images, electrodes mapping file, etc.)

- `chan_loc.locs` - mapping between channels (electrodes) and their physical locations on the headset. Used to process the data in Matlab.
- `montage_ultracortex.ced` - mapping bewtween electore numbers and their labels. Used in EEGLab/Lab Recorder (Please see the course's recording guide for more details)
## Troubleshooting

### Our offline classifier preforms poorly
1. A look on the OpenBCI waves output can help us determine the amount of noise we have. The more
   noise, the less able will be our classifier. **Consider applying more suitable frequency filters or remove bad trials**
2. Click several times on the notch filter to bring it to 50hz, even if it is currently on 50hz.
   A look on the FFT around 50hz should reveal a negative peak. If you still see a peak, try replacing the bateries or
   move to another room. Try eliminiate all sources of noise such as electricity (e.g., turn off electric devices). Try to reposition the headset.
   Make sure you put the ear pieces on your ear lobes.

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

