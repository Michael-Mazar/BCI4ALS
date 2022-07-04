% TODO: add description

%% Refresh
clc; clear; close all;

%% Load parameters from config
recordingFolder = 'C:\Users\micha\MATLAB\Projects\BCI4ALS_PROJECT\Data\New_age';
config_param
%% Run MI1
[recordingFolder, trainingVec] = MI1_offline_training(lslPath, rootRecordingPath, MI1params, trainingImages); % Removed classes and trial length
disp('Finished stimulation and EEG recording. Stop the LabRecorder and press any key to continue...');
pause;
%% Run MI2:
% for manually running - load to the workspace the relevant recordingFolder
% and its training vector - load(recordingFolder,'\trainingVec'))
% Custom recording folder definition - recordingFolder = 'C:\Recordings\New_headset_raz\nadav2_with_touch';
addpath(string(eeglabPath));     % lab streaming layer library
eeglab;
try 
    recordingFile = strcat(recordingFolder,'\EEG.XDF');
    EEG = pop_loadxdf(recordingFile, 'streamtype', 'EEG', 'exclude_markerstreams', {});
catch
    recordingFile = 'EEG.set';
    EEG = pop_loadset('filename', recordingFile ,'filepath', recordingFolder);
end
EEG.setname = 'MI_sub';
[EEG_Arr] = preprocess(EEG, recordingFolder, eeglabPath, unused_channels, unwanted_channels, MI2params);
close all;

%% Review the recording
s_EEG = EEG_Arr(6);
pop_eegplot(s_EEG)
disp('Finished pre-processing pipeline. Press any key to continue...');
pause;

%% Run MI3 (create MIData)
% Plaster solution instead of size(EEG_chans,1)
% Fix this 
[MIData] = MI3_segmentation(recordingFolder, fs, trialLength, startMarker, size(EEG_chans,1) );
disp('Finished segmenting the data. Press any key to continue...');
pause;

%% Run MI4 (Extract features and labels)
MI4_featureExtraction(recordingFolder, MIData, EEG_chans, trainingVec, bands, times, feature_headers, MI4params, feature_setting);
disp('Finished extracting features and labels. Press any key to continue...');
pause;

%% Load features
two_class_table = readtable('Combined_features_table_2class.txt');
three_class_table = readtable('Combined_features_table.txt');
disp('Loaded tables');
[trainedClassifier, validationAccuracy] = MI5_trainClassifier(two_class_table);
disp(strcat("Your accuracy is: ", string(validationAccuracy*100),' %'))
% %% Train a model using features and labels
% testresult = MI5_modelTraining(recordingFolder);
% disp('Finished training the model. The offline process is done!');

