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
disp('Finished stimulatireon and EEG recording. Stop the LabRecorder and press any key to continue...');
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
% Review the recording
s_EEG = EEG_Arr(6);
pop_eegplot(s_EEG)
disp('Finished pre-processing pipeline. Press any key to continue...');
pause;

%% Visualize & Analyze preprocessed data:
[gEEG, EEG_class_arr] = f_ExtractEpochedData(EEG_Arr, 6, 0);
f_Visualize_EEG(EEG_class_arr); % Visualize base characteritics

%% Visualize ERD/ERS
for EEG_class = EEG_class_arr
    f_Visualize_EEG_interactive(EEG_class) % EEGLAB Interactive plots
end

% EEGLAB Headset plots
disp('Finished reviewing data preprocessed...');
pause;
%% Run MI3 (create MIData)
% Plaster solution instead of size(EEG_chans,1)
% Fix this 
[MIData] = MI3_segmentation(recordingFolder, fs, trialLength, startMarker, size(EEG_chans,1) );
disp('Finished segmenting the data. Press any key to continue...');
% pause;

%% Filter out bad trials

% set trials indices to be remove (e.g., trials_to remove_incides = [1,
% 15];)
trials_to_remove_indices = [];

if ~isempty(trials_to_remove_indices)
    [MIData, trainingVec] = remove_trials(recordingFolder, trials_to_remove_indices, MIData, trainingVec);
end

%% Run MI4 (Extract features and labels)
MI4_featureExtraction(recordingFolder, MIData, EEG_chans, trainingVec, bands, times, feature_headers, MI4params, feature_setting);
disp('Finished extracting features and labels. Press any key to continue...');
pause;

trials_to_remove_indices = [8,10,18,22]; % FC2 is a bad channel; 
if ~isempty(trials_to_remove_indices)
    [MIData, trainingVec] = remove_trials(recordingFolder, trials_to_remove_indices);
end