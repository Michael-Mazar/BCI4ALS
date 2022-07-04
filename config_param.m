%% Include sub-folders
addpath('analysis\');
addpath('common\');
addpath('files\');
addpath('offline pipeline\');
addpath('processing\');

%% Recording parameters
numClasses = 2;
numTrials = 20;
trialLength = 5;  % remember to change times for bandpower!
waitList = [20, 1.5, 1.5, 1.5]; % init, ready, cue, next
startMarker = 1111;
markersList = [000, 99, startMarker, 9, 1001]; % startRec, endRec, startTrial, endTrial, baseline 
lslPath = 'C:\Users\Raz\BCI4ALS\liblsl-Matlab';
eeglabPath = 'C:\Users\Raz\BCI4ALS\eeglab2021.1';
pyEnvPath = 'C:\Users\Raz\anaconda3\envs\BCI\python.exe';
rootRecordingPath = 'C:\Users\Raz\BCI4ALS\Recordings';
%rootRecordingPath = recordingFolder;
trainingImages{1} = imread('square.png','png'); 
trainingImages{2} = imread('arrow_left.png','png');
trainingImages{3} = imread('arrow_right.png','png');
%recordingFolder = 'C:\Users\Raz\BCI4ALS\Recordings\21_03_22'; % TODO: change back to'C:\Recordings\New_headset_raz\raz_merged';
try
    loaded_temp = load(strcat(recordingFolder,'\trainingVec.mat'));               % load the training vector (which target at which trial)
    trainingVec = loaded_temp.trainingVec;
catch
     disp('No trainingVec yet?')
end
%% Preprocessing parameters
unused_channels = {'T8','PO3','PO4','O2','O1'}; % For 11 channels headset
all_channels = {'C03','C04','C0Z','FC1','FC2','FC5','FC6','CP1','CP2','CP5','CP6'};
% unwanted_channels = {'FC1','FC2','FC5','FC6','CP1','CP2','CP5','CP6'};
unwanted_channels = {''};
intersect_channels = setdiff(all_channels,unwanted_channels);
for i=1:length(intersect_channels)
    EEG_chans(i,:) = intersect_channels{i};
end
% EEG_chans(1,:) = 'C03';
% EEG_chans(2,:) = 'C04';
% EEG_chans(3,:) = 'C0Z';
% EEG_chans(4,:) = 'FC1';
% EEG_chans(5,:) = 'FC2';
% EEG_chans(6,:) = 'FC5';
% EEG_chans(7,:) = 'FC6';
% EEG_chans(8,:) = 'CP1';
% EEG_chans(9,:) = 'CP2';
% EEG_chans(10,:) = 'CP5';
% EEG_chans(11,:) = 'CP6';
% %EEG_chans(12,:) = 'O01';
% %EEG_chans(13,:) = 'O02';
%unused_channels = {'T8','PO3','PO4'}; % For 13 channels headset

% class 1 is idle, 2 is left and 3 is right - for any change still need to
% change manually MI4 (lines 70-71 and 229-231
notchList = [50,25];  % check if also need 25!
highFilter = 40; % Was 50
lowFilter = 0.5; % Was 0.5
ICA_threshold = 1;
fs = 125; % openBCI sample rate
%% Feature extraction parameters
to_implement_zscore = 1; % 1 is true, otherwise false
how_many_features_to_select = 10; % Was 10
how_many_test_for_class = 5;
vizTrial = 5; % what is this?
frequency_vec = 0.5:1:60;         % frequency vector - lowest:jump:highst
window = 40;                      % sample size window for pwelch
noverlap = 20;                    % number of sample overlaps for pwelch

% change bands and times according to graphs (spectogram, ?)
bands{1} = [2,10];
bands{2} = [2,10];
bands{3} = [2,10];
% bands{4} = [17.5,20.5];
% bands{5} = [20.5,22];
% Make sure times in the trial length range!
times{1} = (0.3*fs : 1*fs);
times{2} = (1.7*fs : 2.4*fs);
times{3} = (2.7*fs : 3.7*fs);
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
    'Intercept', false, ... %why false? becuase online?
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
    notchList, 'ICA_threshold', ICA_threshold, 'channelsNum', size(all_channels,2), ...
    'plot',1,'offline',1,'ASR',0,'Laplace',1,'ICA',0);

% Parameters for M4
MI4params = struct('select', how_many_features_to_select, 'test', ...
    how_many_test_for_class, 'FS', fs, 'vizTrial', vizTrial, 'z',...
    to_implement_zscore, 'f', frequency_vec, 'window', window, ...
    'overlap', noverlap, 'n_features', n_features, 'offline', 1);

