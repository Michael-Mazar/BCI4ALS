%% Recording parameters
clc; clear; close all;
subject_experiment_number_today = 1;
numClasses = 3;
numTrials = 20;
trialLength = 3;  % remember to change times for bandpower!
waitList = [3, 1, 1, 1]; % init, ready, cue, next
startMarker = 1111;
markersList = [000, 99, startMarker, 9, 1001]; % startRec, endRec, startTrial, endTrial, baseline 
lslPath = 'C:\Users\mazar\Documents\MATLAB\Michael Mazar\dependencies\liblsl-Matlab';
eeglabPath = 'C:\Users\mazar\Documents\MATLAB\Michael Mazar\dependencies\eeglab2021.0';
rootRecordingPath = 'C:\Recordings';
recordingFolder = 'C:\Recordings\New_headset_raz\raz_merged';
classes{1} = imread('square.jpeg','jpeg'); 
classes{2} = imread('arrow_left.jpeg','jpeg');
classes{3} = imread('arrow_right.jpeg','jpeg');
loaded_temp = load(strcat(recordingFolder,'\trainingVec.mat'));               % load the training vector (which target at which trial)
trainingVec = loaded_temp.trainingVec;
%% Preprocessing parameters
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
EEG_chans(12,:) = 'O01'; % Might need to remove this
EEG_chans(13,:) = 'O02'; % Might need to remove this
unused_channels = {'T8','PO3','PO4'}; % For 13 channels headset
% unused_channels = {'T8','PO3','PO4','O2','O1'}; % For 11 channels headset
% class 1 is idle, 2 is left and 3 is right - for any change still need to
% change manually MI4 (lines 70-71 and 229-231
notchList = [50];  % check if also need 25!
highFilter = 30; % Was 50
lowFilter = 4; % Was 0.5
ICA = 0.8;
fs = 125; % openBCI sample rate
%% Feature extraction parameters
to_implement_zscore = 1; % 1 is true, otherwise false
how_many_features_to_select = 6;
how_many_test_for_class = 10;
vizTrial = 5; % what is this?
% change bands and times according to graphs (spectogram, ?)
bands{1} = [5,10];
bands{2} = [8,17];
% bands{3} = [10,15.5];
% bands{4} = [17.5,20.5];
% bands{5} = [12.5,30];
% make sure times in the trial length range!
times{1} = (0.5*fs : 2*fs);
times{2} = (2*fs : 2.75*fs);
% times{3} = (2.5*fs : 3*fs);
% times{4} = (1*fs : 1.75*fs);
% times{5} = (1.75*fs : 2.25*fs);
%% Define which features to select:
feature_setting = struct(...
    'Bands', true, ...
    'Root', true, ...
    'Moment', false, ...
    'Edge', false', ...
    'Entropy', false, ...
    'Slope', false, ...
    'Intercept', false, ...
    'Mean_freq', true, ...
    'Obw', false, ...
    'Powerbw', true);
feature_headers ={};
if feature_setting.Bands
    for i=1:length(bands)
        tmp_str = string(bands{i}(1)) + '-' + string(bands{i}(2)) + ' band';
        feature_headers{end+1} = tmp_str; 
    end 
end
fn = fieldnames(feature_setting);
for k=1:numel(fn)
    if(feature_setting.(fn{k}))
        feature_headers{end+1} = fn{k};
    end
end
n_features = size(feature_headers, 2);
%%
% Parameters for M1
MI1params = struct('numTrials', numTrials, 'numClasses', numClasses, 'count', ...
    subject_experiment_number_today, 'trialLength', trialLength, 'waits',...
    waitList, 'markers', markersList);
% Parameters for M2
MI2params = struct('highLim', highFilter, 'lowLim', lowFilter, 'notch', ...
    notchList, 'ICA', ICA, 'channelsNum', size(EEG_chans,1));
% Parameters for M4
MI4params = struct('select', how_many_features_to_select, 'test', ...
    how_many_test_for_class, 'FS', fs, 'vizTrial', vizTrial, 'z',...
    to_implement_zscore);