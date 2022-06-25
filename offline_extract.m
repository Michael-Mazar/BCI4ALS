%% Running requirements
% Requirements: 
% To run this script make sure you are in the BCI4ALS folder and cloned the
% michael_version repository from github
%% Refresh
clc; clear all; close all;
%%
% recordingFolder = 'C:\Users\micha\Documents\Recordings\Michael_MI_NEW\combined';
recordingFolder = 'C:\Users\micha\MATLAB\Projects\BCI4ALS_PROJECT\Data\combined';                          % Define destination folder for saving new trainingVec
config_param                                                        % Run and extract the parameters
% dataset =[2:5,7,8];
% dataset =[2:9];
% dataset = [22:24,28:32];
% dataset = [7:8,12,14,16];                                          % Define which datasets to combine (What each number means is in excel)
dataset = [7:8,12,14,16,22:24,28:32];
% folder = 'C:\Users\micha\Documents\Recordings\Michael_MI_NEW';
folder = 'C:\Users\micha\MATLAB\Projects\BCI4ALS_PROJECT\Data';      % Define target folder which contains all hana's recordings
[MIData, trainingVec] = MI_combineDataset(dataset, folder);          % Combine MIData
%% Edit MI Data
% [MIData, trainingVec] = MI_edit_dataset(recordingFolder, MIData, trainingVec, [4:11], []);
%%
MI_plot_basics(recordingFolder, MIData, [1:3], trainingVec, EEG_chans, MI4params)
%% Run MI4 (Extract features and labels)
MI4params.z = 1;
MI4_featureExtraction_new(recordingFolder, MIData, EEG_chans, trainingVec, bands, times, feature_headers, MI4params, feature_setting);
disp('Finished extracting features and labels. Press any key to continue...');

%% Load features
% two_class_table = readtable('Combined_features_table_2class.txt');
% three_class_table = readtable('Combined_features_table.txt');
% disp('Loaded tables');
% [trainedClassifier, validationAccuracy] = MI5_trainClassifier(two_class_table);
% disp(strcat("Your accuracy is: ", string(validationAccuracy*100),' %'))
% %% Train a model using features and labels
% testresult = MI5_modelTraining(recordingFolder);
% disp('Finished training the model. The offline process is done!');

