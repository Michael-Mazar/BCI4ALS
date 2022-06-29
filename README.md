# BCI4ALS - HUJI - Team 51
## General

This repository contains the code for Motor Imagery pipeline, as part of the BCI4ALS course during the 2021-2022 academic year.

The code is a fork of Asaf Harel (harelasa@post.bgu.ac.il) [basic code for the course BCI-4-ALS ](https://github.com/harelasaf/BCI4ALS-MI) which
was taken place in Ben Gurion University during 2020/2021. You are free to use, change, adapt and
so on - but please cite properly if published. 


✨  Team 51 contact details   ✨

- Michael Mazar (ADD email here)
- Nadav Am-Shalom (ADD email here)
- Raz Perry (ADD email here)
- Osher Maayan (osher.maayan@mail.huji.ac.il)

## Project Structure

The repository is structured into XXX directories:

### **gui** (Graphical User Interface)
Includes the code for the GUI. The two main files are:
  - `main.py`  - runs the GUI application, based on the Kivy library. Currently, the GUI shows some buttons and functionalities that are not implemented (but should be in the future).
  - `mimain.kv` - a configuration file for the GUI. Please see [Kivy documentation](https://kivy.org/doc/stable/guide/basic.html) for more details.
### **classification**
Python-based classification code. Offers two main functionalities: *train* (which trains ans saves a model) and *predict* (which uses the saved model to predict). This code is called by Matlab.
### **common**
code that is used by different parts of the system (e.g., data preprocessing).

### **data_analysis**
Different functions that may be helpful to analyze data, such as finding "bad" (noisy) trials, check the effect of different features, etc.

- Offline- Matlab code used for offline training.
- Online- Matlab code used for online training.
- Python- Python code that works with the online Matlab code.
- Headset54- Materials regarding the headset wiring and additional guiding materials, etc...
- NewHeadsetRecordingsOmri- Recording from the new headset on Omri(Our mentor), we managed to reach with all three recordings 66%-70% accurecy with onlyPowerBands=0 and 57%-70% with onlyPowerBands=1. These recordings were created
in the home of Omri where there are many inteferences and noise. The classifier is the SVM RBF.
- NewHeadsetRecordingsAssaf- Recordings from the new headset on Assaf, we managed to reach with all the recordings 60%-86% in my house where there are many inteferences and noise with onlyPowerBands=0 and 30%-60% with onlyPowerBands=1. The classifier is the SVM RBF.
- OldHeadsetRecordings- Recordings from the old headset. We managed to get with the old headset at Noa's house where the training took place at a very quiet location with not many inteferences most of the time 60%-96% combining both offline and online recording and with onlyPowerBands=0. Please
note that the code now don't support these recordings and the channel mapping has changed, i.e. the laplacian is wrong and we omit channels that existed here. To reach best results with old recording, we recommend to go back in history of the repository and look for old recordings, the preprocess files the matchs them, the
channels that were removed and the recordings that were used. The classifier is the SVM RBF.
- Documents- Important documents including but not limited to- A general guide and where to go next, UX and video, Product specification document and more...


## Pre-requisites 
- Matlab R2021b or newer (for python support) with the libLSL, OpenBCI, EEGLab with ERPLAB & loadXDF plugins installed
- Python 3.7-3.9 (at the time of writing this document, Python 3.10 isn't supported by Matlab)

## Python dependencies installation 

Follow these instructions (tested on Windows 10 OS) for a one-time installation:

1. Open at terminal at the repository's directory
2. Run `python -m venv venv` (creating a virtual python environement)
3. Run `.\venv\Scripts\activate.bat`
4. Run `pip install -r requirements.txt` to install the requirments in the virtual environment

## Pyton-Matlab integration

### Inter-process integration
The Python GUI communicates with Matlab via TCP/IP: the Matlab runs a server to which the GUI client sends requets
### Intra-process integration
For Python classification, we call Python functions directly from Matlab. Please read the `README.md` file in the `/classification` directory




-----

This part of the code is responsible for recording raw EEG data from the headset, preprocess it, segment it, extract features and
train a classifier.

1. MI1_Training.m- Code for recording new training sessions.
2. MI2_Preprocess.m- Function to preprocess raw EEG data.
3. MI3_SegmentData.m- Function that segments the preprocessed data into chunks.
4. MI4_ExtractFeatures.m- Function to extract features from the segmented chunks.
5. MI5_LearnModel.m- Function to train a classifer based on the features extracted earlier.
6. trainModelScript.m- A script that aides in running functions 2-5 in a batch. It also
 helps to use the aggregation featurs of function 4 and helps to combine both raw and features-only
 data. Features only data is created when co-training on an online session. The aggregation features
 allows to aggregate multiple recording into one training dataset.
4. prepareTraining.m- Prepare a training vector for training.

### Online

This part of the code is responsible for loading the classifier that was trained in the offline section, record raw EEG data, preprocess it, extract features and
make a prediction using the classifier. Additionally, it saves the features to use for training later(co-learning) and sends the predictions to the python interface using
TCP/IP. The communication part of the code is really simple and sends chunks of data to the python code, until it recives the string "next", in which it sends the next portion of data.

1. MI_Online_Learning.m- A script used to co-train or run the application of the online session.
   That is, co-train using feedback or run only the target application(no feedback, only predictions to application output).
2. PreprocessBlock.m- Simillar to the offline phase, this function preprocess online chunk.
3. ExtractFeaturesFromBlock.m- Simillar to the offline phase, this function extract features from the preprocessed chunk.
4. prepareTraining.m- Prepare a training vector for co-learning.

### Python

The python code is seperated into two files, both communicate with the matlab code using TCP/IP. A feedback file which is used for co-learning, and ui file which is used
for the actual application used by the mentor.

1. feedback.py- Script that runs the co-learning feedback application. The Matlab code creates the labels for the co-learning session, sends them to the python code which will present to the user what to imagine and depending on the prediction made in the matlab code, will move a red rectangle to the appropriate side.
2. UI.py- Script that runs the actual application. As in the feedback script, the Matlab code will sends the prediction to the python code. However, as this is the real application no labels exist. Instead, three colums will be presented to the user and depending on the prediction made in the matlab code, the appropriate column will be filled. When a threshold will be passed(voting), the action regarding that column will execute. The right column is used to signal for help(shows a help sign and sounds an alarm) while the left column is used to open another interface to allow to pick yes or no response.

## Headset54

1. IMG_1065.MOV- Or Rabani(orabani@campus.haifa.ac.il) explains how to position the headset.
2. IMG_1060.jpg - IMG_1064.jpg- Images of how to position the headset.

## Recordings

The general structure of the recordings directory are as follows:

1. In each recording directory are many Test directories. Each one corresponds to a testing session. Each session includes 5 trial per target- i.e. 15 trials in total.
2. The EEG.xdf is the recording captured by the lab recorder from the eeg stream and the marker stream.
3. The AllDataInFeatures.mat is the features generated by the MI4_ExtractFeatures.m and run by trainModelScript.m, i.e. aggregating all previous Test folder data in to one training set features. The companion file
to this is the AllDataInLabels.mat which is the labels for each trial.
4. The Mdl.mat is the model created by MI5_LearnModel.m and run by trainModelScript.m, i.e. training an svm rbf model from the aggregated training set features of all previous and the current folder.
5. The EEG_chans.mat is a file containing the channels that were included in the preprocess step, created by MI2_Preprocess.m and run by trainModelScript.m.
6. The SelectedIdx.mat is the selected features for the training set that were chosen from AllDataInFeatures.mat, this is created also by MI4_ExtractFeatures.m. You will need this in the online training to select the correct features. We don't
have to worry about this in the online phase most of the time as the Mdl.mat and SelectedIdx.mat reside in the same folder and therefore when setting the recording folder in MI_Online_Learning.m to the appropiate location it will pick correctly both files.
7. The trainingVec.mat is the vector containing the labels during the training phase. It is created by MI1_Training.m.
8. The MIData.mat is the segmented raw data file that is created after the preprocess step. It is created by MI3_SegmentData.m.


## Running instructions
TODO: add more info here


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

*This functionality requires a pre-trained classifier* (model).

1. Open all dependencies (OpenBCI, etc.) 
2. Run `MI_online_predict.m` (this is the backend part, which runs a TCP server)
3. Run `python gui/main.py` (the frontend, GUI application); be sure that the virtual environment is activated!
4. In the GUI, click on the *prediction* button
5. In the *prediction* screen, click on *Start* . This will send a "start recording" request to the Matlab server, and will return a prediction (e.g., a number that represents "right", "left", "idle") to the GUI, which will then graphically present the relevant response (e.g., "Yes" or "No")

***

For more info, see the documentation located in each code file and the docs file in the documents folder.

### Trobuleshooting

#### Our offline classifier preforms very poorly
1. A look on the OpenBCI waves output can help us determine the amount of noise we have. The more
   noise, the less able will be our classifier. **Consider applying more suitable frequency filters or remove bad trials**
2. **Make sure to clean the ear pieces with alcohol**
3. Click several times on the notch filter to bring it to 50hz, even if it is currently on 50hz.
   A look on the FFT around 50hz should reveal a negative peak. If you still see a peak, try replacing the bateries or
   move to another room. Try eliminiate all sources of noise such as electricity (e.g., turn off electric devices). Try to reposition the headset.
   Make sure you put the ear pieces on your ear lobes.

%%% TODO: add more troubleshooting advices

* Note: To remove the 25hz peak, you'll need to avoid using a charger and be far away from electronic devices.

### The dongle is pluged in but cannot connect to the headset.
1. Try replacing the batteries.

### Nothing works :(
1. Take a deep breath
2. Disconnect the dongle.
3. Close all programs.
4. Wait a bit!
5. Try again :)


We would like to thank to all the course staff: both the local (HUJI) and the national ones: Lahav foox(fooxl@post.bgu.ac.il), Asaf Harel(harelasa@post.bgu.ac.il), Or Rabani(orabani@campus.haifa.ac.il).

