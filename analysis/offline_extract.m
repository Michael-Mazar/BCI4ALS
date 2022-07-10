% (1) Make sure the selected datasets in Data in the folder were already
% preprocessed up to MI3
% A script which does the following 
% - Combines all extracted datasets in Data folder via MI_combineDataset
% - Edit and removes trials if necassery through MI_edit_dataset
% - Plots dataset features according to command selection
% - Extracts Features
%% Refresh
clc; clear all; close all;
%%
recordingFolder = 'C:\Users\micha\MATLAB\Projects\BCI4ALS_PROJECT\Data\combined';                          % Define destination folder for saving new trainingVec
config_param                                                        % Run and extract the parameters
dataset = [7:8,12,14,16];                                          % Define which datasets to combine (What each number means is in excel)
folder = 'C:\Users\micha\MATLAB\Projects\BCI4ALS_PROJECT\Data';      % Define target folder which contains all hana's recordings
[MIData, trainingVec] = MI_combineDataset(dataset, folder);          % Combine MIData
%% Edit MI Data
[MIData, trainingVec] = MI_edit_dataset(recordingFolder, MIData, trainingVec, [4:11], []);
%%
MI_plot_basics(recordingFolder, MIData, [1:3], trainingVec, EEG_chans, MI4params)
%% Run MI4 (Extract features and labels)
MI4params.z = 1;
MI4_featureExtraction_new(recordingFolder, MIData, EEG_chans, trainingVec, bands, times, feature_headers, MI4params, feature_setting);
disp('Finished extracting features and labels. Press any key to continue...');