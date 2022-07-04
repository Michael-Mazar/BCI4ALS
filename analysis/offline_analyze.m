%% MI Offline Main Script
% This code is part of the BCI-4-ALS Course written by Asaf Harel
% (harelasa@post.bgu.ac.il) in 2021. You are free to use, change, adapt and
% so on - but please cite properly if published.
%% Refresh
clc; clear all; close all;
%% Load parameters from config
recordingFolder = 'C:\Users\micha\MATLAB\Projects\BCI4ALS_PROJECT\Data\7';
config_param
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

disp('Finished pre-processing pipeline. Press any key to continue...');
pause;
%% Visualize & Analyze preprocessed data:
% Review the recording

[gEEG, EEG_class_arr] = f_ExtractEpochedData(EEG_Arr, selected_dataset, 0);
f_Visualize_EEG(EEG_class_arr, recordingFolder, EEG_chans, gEEG); % Visualize base characteritics


disp('Review recording data. Press any key to continue...');
pause; close all;

%%
selected_dataset = 8; % Review dataset 
s_EEG = EEG_Arr(selected_dataset);
pop_eegplot(s_EEG)

%% Run MI3 (create MIData)
% Plaster solution instead of size(EEG_chans,1)
% Fix this 
[MIData] = MI3_segmentation(recordingFolder, fs, trialLength, startMarker, size(EEG_chans,1) );
disp('Finished segmenting the data. Press any key to continue...');
pause;
%% Filter out bad trials

% set trials indices to be remove (e.g., trials_to remove_incides = [1,
% 15];)
% [trials_to_remove_indices] = filter_trails(MIData,100);
trials_to_remove_indices = [];

if ~isempty(trials_to_remove_indices)
    [MIData, trainingVec] = remove_trials(recordingFolder, trials_to_remove_indices);
end

MI4params.vizTrial = 1;
MI4params.test = ceil(size(MIData, 1)/(3*3));
disp('Finished removing trials. Press any key to continue...');
disp(size(MIData))
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