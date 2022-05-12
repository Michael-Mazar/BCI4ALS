%% Recording parameters
numClasses = 3;
numTrials = 4;
% TODO: changed trialLength from 3 to 5 to debug Online code
trialLength = 5;  % remember to change times for bandpower!
waitList = [3, 1, 1, 1]; % init, ready, cue, next
startMarker = 1111;
markersList = [000, 99, startMarker, 9, 1001]; % startRec, endRec, startTrial, endTrial, baseline 
lslPath = 'C:\Toolboxes\labStreamingLayer';
eeglabPath = 'C:\Toolboxes\eeglab2021.1';
rootRecordingPath = 'D:\HUJI\BCI\recordings';
trainingImages{1} = imread('square.png','png'); 
trainingImages{2} = imread('arrow_left.png','png');
trainingImages{3} = imread('arrow_right.png','png');
%recordingFolder = 'C:\Users\Raz\BCI4ALS\Recordings\21_03_22'; % TODO: change back to'C:\Recordings\New_headset_raz\raz_merged';
%loaded_temp = load(strcat(recordingFolder,'\trainingVec.mat'));               % load the training vector (which target at which trial)
%trainingVec = loaded_temp.trainingVec;
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
%EEG_chans(12,:) = 'O01';
%EEG_chans(13,:) = 'O02';
%unused_channels = {'T8','PO3','PO4'}; % For 13 channels headset
unused_channels = {'T8','PO3','PO4','O2','O1'}; % For 11 channels headset
% class 1 is idle, 2 is left and 3 is right - for any change still need to
% change manually MI4 (lines 70-71 and 229-231
notchList = [50];  % check if also need 25!
highFilter = 40; % Was 50
lowFilter = 0.5; % Was 0.5
ICA_threshold = 0.8;
fs = 125; % openBCI sample rate
%% Feature extraction parameters
to_implement_zscore = 1; % 1 is true, otherwise false
how_many_features_to_select = 10;
how_many_test_for_class = 10;
vizTrial = 5; % what is this?
frequency_vec = 0.5:1:60;         % frequency vector - lowest:jump:highst
window = 40;                      % sample size window for pwelch
noverlap = 20;                    % number of sample overlaps for pwelch

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
    'Moment', true, ...
    'Edge', true', ...
    'Entropy', true, ...
    'Slope', true, ...
    'Intercept', true, ...
    'Mean_freq', true, ...
    'Obw', true, ...
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
    if(feature_setting.(fn{k}) && ~strcmp(fn{k}, 'Bands'))
        feature_headers{end+1} = fn{k};
    end
end
n_features = size(feature_headers, 2);
%%
% Parameters for M1
MI1params = struct('numTrials', numTrials, 'numClasses', numClasses, 'trialLength', trialLength, ...
    'waits', waitList, 'markers', markersList);
% Parameters for M2
MI2params = struct('highLim', highFilter, 'lowLim', lowFilter, 'notch', ...
    notchList, 'ICA_threshold', ICA_threshold, 'channelsNum', size(EEG_chans,1), ...
    'offline',1);

% Parameters for M4
MI4params = struct('select', how_many_features_to_select, 'test', ...
    how_many_test_for_class, 'FS', fs, 'vizTrial', vizTrial, 'z',...
    to_implement_zscore, 'f', frequency_vec, 'window', window, ...
    'overlap', noverlap, 'n_features', n_features);

