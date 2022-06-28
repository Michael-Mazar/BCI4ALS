% TODO: add a short description

%% Refresh
clc; clear all; close all;
%%
recordingFolder = 'C:\Users\Raz\GitRepos\BCI4ALS\Data\combined';    % Define destination folder for saving new trainingVec
config_param                                                        % Run and extract the parameters
% Define which datasets to combine                                              
dataset = [7:8,12,14,16,22:24];
datasetsFolder = 'C:\Users\Raz\GitRepos\BCI4ALS\Data';     % Define target folder which contains all hana's recordings
[MIData, trainingVec] = f_combineDataset(dataset, folder);          % Combine MIData
datasets_to_plot = [1:3];
MI_plot_basics(recordingFolder, MIData, datasets_to_plot, trainingVec, EEG_chans, MI4params) 

%% Run MI4 (Extract features and labels)
MI4params.z = 1;
MI4_featureExtraction_new(recordingFolder, MIData, EEG_chans, trainingVec, bands, times, feature_headers, MI4params, feature_setting);
disp('Finished extracting features and labels. Press any key to continue...');

% TODO: do we need this?
%% Load features
% two_class_table = readtable('Combined_features_table_2class.txt');
% three_class_table = readtable('Combined_features_table.txt');
% disp('Loaded tables');
% [trainedClassifier, validationAccuracy] = MI5_trainClassifier(two_class_table);
% disp(strcat("Your accuracy is: ", string(validationAccuracy*100),' %'))
% %% Train a model using features and labels
% testresult = MI5_modelTraining(recordingFolder);
% disp('Finished training the model. The offline process is done!');

