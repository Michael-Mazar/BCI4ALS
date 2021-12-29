%% MI Offline Main Script
% This code is part of the BCI-4-ALS Course written by Asaf Harel
% (harelasa@post.bgu.ac.il) in 2021. You are free to use, change, adapt and
% so on - but please cite properly if published.
clc; clear; close all;
%% Init paramters - make sure all relevant to your paradigma and workspace
subject_experiment_number_today = 1;
EEG_chans(1,:) = 'C03';
EEG_chans(2,:) = 'C04';
EEG_chans(3,:) = 'C0Z';
EEG_chans(4,:) = 'FC1';
EEG_chans(5,:) = 'FC2';
EEG_chans(6,:) = 'FC5';
EEG_chans(7,:) = 'F06';
EEG_chans(8,:) = 'CP1';
EEG_chans(9,:) = 'CP2';
EEG_chans(10,:) = 'CP5';
EEG_chans(11,:) = 'CP6';
EEG_chans(12,:) = 'O01';
EEG_chans(13,:) = 'O02';
numClasses = 3;
numTrials = 20;
trialLength = 3;  % remember to change times for bandpower!
waitList = [3, 1, 1, 1]; % init, ready, cue, next
startMarker = 1111;
markersList = [000, 99, startMarker, 9, 1001]; % startRec, endRec, startTrial, endTrial, baseline  
lslPath = 'C:\Users\Raz\Study\Cognition_Science\BCI4ALS\liblsl-Matlab';
eeglabPath = 'C:\Users\Raz\Study\Cognition_Science\BCI4ALS\eeglab2021.1';
rootRecordingPath = 'C:\Users\Raz\Study\Cognition_Science\BCI4ALS\Recordings';
% class 1 is idle, 2 is left and 3 is right - for any change still need to
% change manually MI4 (lines 70-71 and 229-231
classes{1} = imread('square.jpeg','jpeg'); 
classes{2} = imread('arrow_left.jpeg','jpeg');
classes{3} = imread('arrow_right.jpeg','jpeg');  
notchList = [50];  % check if also need 25!
highFilter = 40;
lowFilter = 0.5;
ICA = 0.8;
unused_channels = {'T8','PO3','PO4'}; % channels to remove
fs = 125; % openBCI sample rate

%% Run MI1
MI1params = struct('numTrials', numTrials, 'numClasses', numClasses, 'count', subject_experiment_number_today, 'trialLength', trialLength, 'waits', waitList, 'markers', markersList);
[recordingFolder, trainingVec] = MI1_offline_training(lslPath, rootRecordingPath, classes, trialLength, MI1params);
disp('Finished stimulation and EEG recording. Stop the LabRecorder and press any key to continue...');
pause;
%% Run MI2+MI3 (create MIData) - re-run manually for processing more data from same person
% for manually running - load to the workspace the relevant recordingFolder
% and its training vector - load(recordingFolder,'\trainingVec'))
MI2params = struct('highLim', highFilter, 'lowLim', lowFilter, 'notch', notchList, 'ICA', ICA, 'channelsNum', size(EEG_chans,1));
MI2_preprocess(recordingFolder, eeglabPath, unused_channels, MI2params);
disp('Finished pre-processing pipeline. Press any key to continue...');
[MIData] = MI3_segmentation(recordingFolder, fs, trialLength, startMarker, size(EEG_chans,1));
disp('Finished segmenting the data. Press any key to continue...');
pause;
%% Merge Data - Optional!
% change manually the folder for the new processed data (folder with MIData and trainingVec)
% after each run the merge data will be MIData and trainingVec variables in
% the workspace - to save it, save manuallt at the end (after combine all)
newPath = 'C:\Users\Raz\Study\Cognition_Science\BCI4ALS\Recordings\test\1';
data1 = MIData;
data2 = load(strcat(string(newPath),'\MIData.mat')).MIData;                 
MIData = cat(1,data1,data2);
trainvec1 = trainingVec;
trainvec2 = load(strcat(string(newPath),'\trainingVec')).trainingVec;
trainingVec = cat(2,trainvec1,trainvec2);
%% Init params for MI4 (features selection)
to_implement_zscore = 1; % 1 is true, otherwise false
how_many_features_to_select = 10;
how_many_test_for_class = 10;
vizTrial = 5; % what is this?
% change bands and times according to graphs (spectogram, ?)
bands{1} = [15.5,18.5];
bands{2} = [8,10.5];
bands{3} = [10,15.5];
bands{4} = [17.5,20.5];
bands{5} = [12.5,30];
% make sure times in the trial length range!
times{1} = (0.5*fs : 2*fs);
times{2} = (2*fs : 2.75*fs);
times{3} = (2.5*fs : size(MIData,3));
times{4} = (1*fs : 1.75*fs);
times{5} = (1.75*fs : 2.25*fs);
% origin parameters:
% bands: [15.5,18.5], [8,10.5], [10,15.5], [17.5,20.5], [12.5,30]
% times: (1:3), (3:4.5), (4.25:size(MIData,3)), (2:2.75), (2.5:4)
%% Run MI4 (Extract features and labels)
MI4params = struct('select', how_many_features_to_select, 'test', how_many_test_for_class, 'FS', fs, 'vizTrial', vizTrial, 'z', to_implement_zscore);
MI4_featureExtraction(recordingFolder, MIData, EEG_chans, trainingVec, bands, times ,MI4params);
disp('Finished extracting features and labels. Press any key to continue...');
pause;
%% Train a model using features and labels
testresult = MI5_modelTraining(recordingFolder);
disp('Finished training the model. The offline process is done!');

