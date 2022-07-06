%% Refresh
clc; clear; close all;
%% Parameters
config_param
dataFolder = 'C:\Users\Raz\GitRepos\BCI4ALS\data\combined';
addpath(string(lslPath));     % lab streaming layer library
addpath(string(lslPath) + '\bin'); % lab streaming layer bin
addpath(string(eeglabPath)); 
eeglab nogui;
% Setup Python interperter
% TODO: consider adding Python interperter path to config_params
try
    pyenv('Version',string(pyEnvPath));
catch
    disp('Catched');
end

% Paradigm
InitWait = waitList(1);             % before trials prep time
readyLength = waitList(2);                        % time "ready" on screen
cueLength = waitList(3);                          % time for each cue
nextLength = waitList(4);                         % time "next" on screen
% MI4 results
load(strcat(dataFolder,'\W.mat')); %load W for csp
load(strcat(dataFolder,'\SelectedIdx.mat')); %load indexes of selected features
% online params
online_trails = 3;
feedback_returns = 1;
buffer = [];
ALL_FEATURES = [];
myPrediction = [];                                  % predictions vector
decCount = 0;
successCount = 0;
onlineTrainingVecAllClasses = prepareTraining(online_trails,MI1params.numClasses);    % vector with the conditions for each trial

% Keep only relevant classes for online prediciton (e.g., Left and Right)
% IDLE = 1, LEFT = 2, RIGHT = 3
predictionClasses = [2, 3];
trainingVectorIndices = find(ismember(onlineTrainingVecAllClasses, predictionClasses));
onlineTrainingVec = onlineTrainingVecAllClasses(trainingVectorIndices);

numChans = size(EEG_chans,1);
MI2params.offline = 0;
MI2params.plot = 0;
MI4params.offline = 0;
%params.feedbackFlag = 1;            % 1-with feedback, 0-no feedback
%params.numVotes = 3;                % how many consecutive votes before classification?

%% Recording location
% Define recording folder location and create the folder:
subID = input('Please enter subject ID/Name: ');    % prompt to enter subject ID or name
subFolder = strcat(rootRecordingPath, '\', num2str(subID));
if not(isfolder(subFolder))
    mkdir(subFolder);
end
% Get current date
dt = datetime('now');
dt.Format = 'dd-MMM-yyyy-HH-mm';
todayFolder = strcat(subFolder, '\', string(dt));
if not(isfolder(todayFolder))
    mkdir(todayFolder);
end
recordingFolder = strcat(todayFolder, '\Online');
mkdir(recordingFolder);


%% open stream
disp('Loading the Lab Streaming Layer library...');
lib = lsl_loadlib();                    % load the LSL library
disp('Opening Marker Stream...');
info = lsl_streaminfo(lib,'MarkerStream','Markers',1,0,'cf_string','myuniquesourceid23443');
outletStream = lsl_outlet(info);        % create an outlet stream using the parameters above
disp('Resolving an EEG Stream...');
result = {};
lslTimer = tic;
while isempty(result)
    result = lsl_resolve_byprop(lib,'type','EEG'); 
end
disp('Success resolving!');
EEG_Inlet = lsl_inlet(result{1});

%% Screen Setup 
monitorPos = get(0,'MonitorPositions'); % monitor position and number of monitors
choosenMonitor = 1;                     % which monitor to use                              
figurePos = monitorPos(choosenMonitor, :);  % get choosen monitor position
figure('outerPosition',figurePos);          % open full screen monitor
MainFig = gcf;                              % get the figure and axes handles
hAx  = gca;
set(hAx,'Unit','normalized','Position',[0 0 1 1]); % set the axes to full screen
set(MainFig,'menubar','none');              % hide the toolbar   
set(MainFig,'NumberTitle','off');           % hide the title
set(hAx,'color', 'black');                  % set background color
hAx.XLim = [0, 1];                          % lock axes limits
hAx.YLim = [0, 1];
hold on

dimMainLR = 0.3;
heightMainLR = 0.35;
dimMainIdle = 0.5;
heightMainIdle = 0.25;
axTrial(1) = axes('Position',[(1-dimMainIdle)/2, heightMainIdle, dimMainIdle, dimMainIdle]);
axTrial(2) = axes('Position',[(1-dimMainLR)/2, heightMainLR, dimMainLR, dimMainLR]);
axTrial(3) = axes('Position',[(1-dimMainLR)/2, heightMainLR, dimMainLR, dimMainLR]);
for ii = 1:length(axTrial)
    set(axTrial(ii),'color', 'black'); 
    set(axTrial(ii), 'visible', 'off');
end
axFinish = axTrial(1);
dimClass = 0.4;
axClasses = [];
axClasses(1) = axes('Position',[(1-dimMainIdle)/2 (heightMainIdle+dimMainIdle-0.1)/2, dimClass, dimClass]);
axClasses(2) = axes('Position',[0.01 (heightMainLR+dimMainLR)/2-0.01, dimClass, dimClass]);
axClasses(3) = axes('Position',[(1-dimClass-0.01) (heightMainLR+dimMainLR)/2-0.01, dimClass, dimClass]);
for ii = 1:length(axClasses)
    set(axClasses(ii),'color', 'black'); 
    set(axClasses(ii), 'visible', 'off');
end
axes(hAx)

%% This is the main online script
onlineNumTrials = length(onlineTrainingVec);
text(0.5,0.5 ,...                               % important for people to prepare
    ['System is calibrating.' newline 'The training session will begin shortly.'], ...
    'HorizontalAlignment', 'Center', 'Color', 'white', 'FontSize', 40);
pause(InitWait)
cla
for trial = 1:onlineNumTrials
    currentClass = onlineTrainingVec(trial);
    % next cue
    text(0.5,0.5 , 'Next',...
        'HorizontalAlignment', 'Center', 'Color', 'white', 'FontSize', 40);
    pause(nextLength);
    cla
    image(flip(trainingImages{currentClass}, 1), 'XData', [0.25, 0.75],...
    'YData', [0.25, 0.75 * ...
    size(trainingImages{currentClass},1)./ size(trainingImages{currentClass},2)])
    pause(cueLength);                           % Pause for cue length
    cla                                         % Clear axis
    % ready cue
    text(0.5,0.5 , 'Ready',...
        'HorizontalAlignment', 'Center', 'Color', 'white', 'FontSize', 40);        
    pause(readyLength);                         % Pause for ready length
    cur_data = EEG_Inlet.pull_chunk();   % refresh chunk
    pause(0.1);
    cla                                         % Clear axis
    % Show image of the corresponding label of the trial
    image(flip(trainingImages{currentClass}, 1), 'XData', [0.25, 0.75],...
        'YData', [0.25, 0.75 * ...
        size(trainingImages{currentClass},1)./ size(trainingImages{currentClass},2)])    
    
    trialStart = tic;
    buffer = [];
    while size(buffer,2) <= trialLength*fs
        cur_data = EEG_Inlet.pull_chunk();
        pause(0.1);
        if ~isempty(cur_data)
            buffer = [buffer, cur_data];
        else
            disp(strcat('no data to pull in trial', num2str(trial), 'after', num2str(toc(trialStart)), 'seconds'));
        end
    end
    % end trial - start processing
    cla                                         % Clear axis
    text(0.5,0.5 , 'Processing',...
        'HorizontalAlignment', 'Center', 'Color', 'white', 'FontSize', 40);
    EEG = pop_importdata('dataformat', 'matlab', 'nbchan', numChans, 'data', buffer, 'srate', fs, 'pnts', 0, 'xmin', 0);
    
    % TODO: Consider checking if trial is valid, meaning if its amplitutdes, standard deviations
    % etc, are within the expected range
    
    decCount = decCount + 1;
    [EEG_arr] = preprocess(EEG, recordingFolder, eeglabPath, unused_channels, MI2params);
    EEG_data = EEG_arr(end).data;
    MIData = [];
    for channel=1:numChans
        MIData(1, channel, :) = EEG_data(channel, :);
    end
    [MIFeatures] = feature_engineering(recordingFolder, MIData, bands, times, W, MI4params, feature_setting);
    FeaturesSelected = MIFeatures(:, SelectedIdx);
    ALL_FEATURES = [ALL_FEATURES FeaturesSelected]; % all data to save in the end of recordings
    myPrediction(decCount) = predict(FeaturesSelected);
    cla
    if myPrediction(decCount) == currentClass
        successCount = successCount + 1;
        text(0.5,0.65 , 'Prediction was right!',...
            'HorizontalAlignment', 'Center', 'Color', 'white', 'FontSize', 40);
    else
        text(0.5,0.65 , 'Prediction was wrong',...
            'HorizontalAlignment', 'Center', 'Color', 'white', 'FontSize', 40);
    end
    image(flip(trainingImages{myPrediction(decCount)}, 1), 'XData', [0.25, 0.75],...
    'YData', [0.05, 0.55 * ...
    size(trainingImages{myPrediction(decCount)},1)./ size(trainingImages{myPrediction(decCount)},2)])
    pause(4);
    cla
    % TODO: add co-adaptive after X trials
end
% finish recording
save(strcat(recordingFolder, '\', 'online_trainingVec.mat'),'onlineTrainingVec');
save(strcat(recordingFolder,'\', 'online_all_features.mat'),'ALL_FEATURES');
text(0.5,0.5 ,...                               % important for people to prepare
    [num2str(successCount) ' trials succeed out of' ' ' num2str(onlineNumTrials) ' ' 'trials'...
    newline 'Precentage is' ' ' num2str(100*(successCount/onlineNumTrials)) '%'], ...
    'HorizontalAlignment', 'Center', 'Color', 'white', 'FontSize', 40);
pause(8);
disp('Finished')