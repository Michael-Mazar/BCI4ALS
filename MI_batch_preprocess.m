% A script which preprocesses several datasets together, 
% make sure to define which folders and parameter to preprocess below
%% Refresh
clc; clear; close all;
%% Load the variables
% Change to the relevant folder
recordingFolder = '.\Data\';                                                     % Run and extract the parameters
folders_to_preprocess = [7:8,12,14,16];
% folders_to_preprocess = [7:8,12,14,16,22:24,28:32];                              % Example datasets to preprocess
config_param
%% Verify data folder variable
if ~endsWith(recordingFolder ,'\')
    recordingFolder = strcat(recordingFolder,'\');
    disp('Added / to folder path for execution') 
end
% Create folder if missing
if ~exist(recordingFolder, 'dir')
    sprintf('Folder doesnt exist, created folder in %s ',recordingFolder)
else
    % Choose which feature extraction strategy to use:
    f = input(['Which function to use?\n' ...
        '1: Default\n' ...
        '2: No ASR\n' ...
        '3: No Laplace\n' ...
        '4: With ICA\n' ...
        '5: Just basic filters\n' ...
        '6: None\n']);
    switch f
        case 1
            MI2params.Laplace = 1;
            MI2params.ASR = 1;
        case 2
            MI2params.Laplace = 1;
            MI2params.ASR = 0;
        case 3
            MI2params.Laplace = 0;
            MI2params.ASR = 1;
        case 4
            MI2params.ICA = 1;
        case 5
            MI2params.Laplace = 0;
            MI2params.ASR = 0;
        case 6
            disp('Skipping protocol choice')
        otherwise
            error('No such preprocessing protocol exists, please enter one of the possible options')
    end
    % Run preprocessing protocol
    addpath(string(eeglabPath));     % lab streaming layer library
    eeglab;
    
    for i=folders_to_preprocess
        dataFolder = strcat(recordingFolder,string(i));
        loaded_temp = load(strcat(dataFolder,'\trainingVec.mat'));               % load the training vector (which target at which trial)
        trainingVec = loaded_temp.trainingVec;
        % Try loading the file
        try 
            dataFolder_dataset = strcat(dataFolder,'\EEG.XDF');
            disp(dataFolder_dataset)
            EEG = pop_loadxdf(dataFolder_dataset, 'streamtype', 'EEG', 'exclude_markerstreams', {});

        catch
            error('Error loading the files for %d data folder', i)
        end
        % Try preprocessing the file
        EEG.setname = 'MI_sub';
        preprocess(EEG, dataFolder, eeglabPath, unused_channels, MI2params);
        disp('Finished pre-processing the data.')
        [MIData] = MI3_segmentation(dataFolder, fs, trialLength, startMarker, size(EEG_chans,1));
        disp('Finished segmenting the data.');
        sprintf('Finished preprocessing pipeline for %d data folder', i)
        MI4_featureExtraction_two_class(dataFolder, MIData, EEG_chans, trainingVec, bands, times, feature_headers, MI4params, feature_setting);
        sprintf('Finished feature extraction pipeline for %d data folder', i)
        clear dataFolder dataFolder_dataset; close all;

    end
end

%% Preprocess all folders
function preprocess_loop(recordingFolder,folders_to_preprocess,eeglabPath,unused_channels, MI2params,...
                fs, trialLength, startMarker, EEG_chans, trainingVec,bands, times,feature_headers,MI4params,feature_setting)
    addpath(string(eeglabPath));     % lab streaming layer library
    eeglab;
    for i=folders_to_preprocess
        dataFolder = strcat(recordingFolder,string(i));
        % Try loading the file
        try 
            dataFolder_dataset = strcat(dataFolder,'\EEG.XDF');
            disp(dataFolder_dataset)
            EEG = pop_loadxdf(dataFolder_dataset, 'streamtype', 'EEG', 'exclude_markerstreams', {});

        catch
            error('Error loading the files for %d data folder', i)
        end
        % Try preprocessing the file
        EEG.setname = 'MI_sub';
        preprocess(EEG, dataFolder, eeglabPath, unused_channels, MI2params);
        disp('Finished pre-processing the data.')
        [MIData] = MI3_segmentation(dataFolder, fs, trialLength, startMarker, size(EEG_chans,1));
        disp('Finished segmenting the data.');
        sprintf('Finished preprocessing pipeline for %d data folder', i)
        MI4_featureExtraction_new(dataFolder, MIData, EEG_chans, trainingVec, bands, times, feature_headers, MI4params, feature_setting);
        sprintf('Finished feature extraction pipeline for %d data folder', i)
        clear dataFolder dataFolder_dataset; close all;

    end
end
%% Feature extraction function
function feature_extraction_protocol(folders_to_preprocess, MIData, EEG_chans, trainingVec, bands, times, feature_headers, MI4params, feature_setting)
    for i=folders_to_preprocess
        dataFolder = strcat(recordingFolder,string(i));
        MI4_featureExtraction_new(dataFolder, MIData, EEG_chans, trainingVec, bands, times, feature_headers, MI4params, feature_setting);
        disp('Finished extracting features and labels. Press any key to continue...');
    end
end