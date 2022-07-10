% (1) Make sure the selected datasets in Data in the folder were already
% preprocessed up to MI3
% A script which does the following 
% - Combines all extracted datasets in Data folder via MI_combineDataset
% - Edit and removes trials if necassery through MI_edit_dataset
% - Plots dataset features according to command selection
% - Extracts Features
%% Refresh
clc; clear all; close all;
%% Batch preprocess
config_param
MI_batch_preprocess
%% Define parameters for batch offlien
recordingFolder = '.\Data\combined';                          % Define destination folder for saving new trainingVec
config_param                                                        % Run and extract the parameters
channels_to_plot = [1:3];
channels_to_remove=[4:11];
trials_to_remove=[];
dataset = [7:8,12,14,16];                                            % Define which datasets to combine (What each number means is in excel)
folder = '.\Data';      % Define target folder which contains all hana's recordings
[MIData, trainingVec] = MI_combineDataset(dataset, folder);          % Combine MIData
%% Edit MI Data
% Removes either trials or channels
[MIData, trainingVec] = MI_edit_dataset(recordingFolder, MIData, trainingVec,channels_to_remove , trials_to_remove);
%%
MI_plot_basics(recordingFolder, MIData, channels_to_plot, trainingVec, EEG_chans, MI4params)
%% Run MI4 (Extract features and labels). To extract features from combined dataset
MI4params.z = 1;
MI4_featureExtraction_two_class(recordingFolder, MIData, EEG_chans, trainingVec, bands, times, feature_headers, MI4params, feature_setting);
disp('Finished extracting features and labels.');