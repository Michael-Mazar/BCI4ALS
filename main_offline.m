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

%% Run MI3 (create MIData)
% Plaster solution instead of size(EEG_chans,1)
% Fix this 
[MIData] = MI3_segmentation(recordingFolder, fs, trialLength, startMarker, size(EEG_chans,1) );
disp('Finished segmenting the data. Press any key to continue...');
pause;

%% Run MI4 (Extract features and labels)
MI4_featureExtraction_two_class(recordingFolder, MIData, EEG_chans, trainingVec, bands, times, feature_headers, MI4params, feature_setting);
%MI4_featureExtraction(recordingFolder, MIData, EEG_chans, trainingVec, bands, times, feature_headers, MI4params, feature_setting);
disp('Finished extracting features and labels. Press any key to continue...');
pause;