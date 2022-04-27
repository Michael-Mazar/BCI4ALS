%% MI Offline Main Script
% This code is part of the BCI-4-ALS Course written by Asaf Harel
% (harelasa@post.bgu.ac.il) in 2021. You are free to use, change, adapt and
% so on - but please cite properly if published.
%% Refresh
clc; clear; close all;
%% Load parameters from config
config_param
%% Run MI1
[recordingFolder, trainingVec] = MI1_offline_training(lslPath, rootRecordingPath, MI1params, trainingImages); % Removed classes and trial length
disp('Finished stimulation and EEG recording. Stop the LabRecorder and press any key to continue...');
pause;
%% Run MI2:
% for manually running - load to the workspace the relevant recordingFolder
% and its training vector - load(strcat(recordingFolder,'\trainingVec.mat'))
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
[EEG_Arr] = preprocess(EEG, recordingFolder, eeglabPath, unused_channels, MI2params);
close all;
% Visualize base characteritics
f_Visualize_EEG(EEG_Arr, 5, 0)
% EEGLAB Interactive plots
%f_Visualize_EEG_interactive(EEG_Arr, 5)
% EEGLAB Headset plots
%f_Visualize_EEG_headset(EEG_Arr,5)
disp('Finished pre-processing pipeline. Press any key to continue...');
% pause;

%% Run MI3 (create MIData)
[MIData] = MI3_segmentation(recordingFolder, fs, trialLength, startMarker, size(EEG_chans,1));
disp('Finished segmenting the data. Press any key to continue...');
% pause;

%% Filter out bad trials

% set trials indices to be remove (e.g., trials_to remove_incides = [1,
% 15];)
trials_to_remove_indices = [1]; 

if ~isempty(trials_to_remove_indices)
    [MIData, trainingVec] = remove_trials(recordingFolder, trials_to_remove_indices, trainingVec);
end

%% Run MI4 (Extract features and labels)
MI4_featureExtraction(recordingFolder, MIData, EEG_chans, trainingVec, bands, times, feature_headers, MI4params, feature_setting);
disp('Finished extracting features and labels. Press any key to continue...');
pause;
%% Load features
two_class_table = readtable('Combined_features_table_2class.txt');
three_class_table = readtable('Combined_features_table.txt');
disp('Loaded tables');
% %% Train a model using features and labels
% testresult = MI5_modelTraining(recordingFolder);
% disp('Finished training the model. The offline process is done!');