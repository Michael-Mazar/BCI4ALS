%function MI_Online_Learning(recordingFolder)
%% Refresh
clc; clear; close all;
%% Parameters
config_param
dataFolder = 'D:\HUJI\BCI\BCI4ALS\data';
addpath(string(lslPath));     % lab streaming layer library
addpath(string(lslPath) + '\bin'); % lab streaming layer bin

addpath(string(eeglabPath)); 
eeglab;

% Setup Python interperter
% TODO: consider adding Python interperter path to config_params
pyenv('Version','D:\HUJI\BCI\BCI4ALS\pythonTest\venv\Scripts\python.exe');

% Paradigm
InitWait = waitList(1);             % before trials prep time
readyLength = waitList(2);                        % time "ready" on screen
cueLength = waitList(3);                          % time for each cue
nextLength = waitList(4);                         % time "next" on screen
% MI4 results
load(strcat(dataFolder,'\W.mat')); %load W for csp
load(strcat(dataFolder,'\SelectedIdx.mat')); %load indexes of selected features
% online params
online_trails = 6;
feedback_returns = 5;
buffer = [];
ALL_FEATURES = [];
myPrediction = [];                                  % predictions vector
decCount = 0;
successCount = 0;
numChans = size(EEG_chans,1);


onlineTrainingVecAllClasses = prepareTraining(online_trails,MI1params.numClasses);    % vector with the conditions for each trial

% Keep only relevant classes for online prediciton (e.g., Left and Right)
% IDLE = 1, LEFT = 2, RIGHT = 3
predictionClasses = [2, 3];
trainingVectorIndices = find(ismember(onlineTrainingVecAllClasses, predictionClasses));
onlineTrainingVec = onlineTrainingVecAllClasses(predictionClassesIndices);

%{
%their params:
params.feedbackFlag = 1;            % 1-with feedback, 0-no feedback
params.Fs = 125;                    % openBCI sample rate % Fs = 300;  % Wearable Sensing sample rate
params.bufferLength = 5;            % how much data (in seconds) to buffer for each classification
params.numVotes = 3;                % how many consecutive votes before classification?
params.numConditions = 3;           % possible conditions - left/right/idle 
params.leftImageName = 'arrow_left.jpeg';
params.rightImageName = 'arrow_right.jpeg';
params.squareImageName = 'square.jpeg';
params.numTrials = 5;               % number of trials overall
params.trialTime = 240;             % duration of each trial in seconds
params.bufferPause = 0.2;           % pause before first pull.chunk
params.startTrialMarker = 111;      % marker sent to command outlet to indicate start of trial
params.commandLeft = -1;            % left command
params.commandRight = 1;            % right command
params.commandIdle = 0;             % idle command
params.readyLength = 1.5;           % time (s) showing "Ready" on screen
params.cueLength = 1;               % time (s) showing the cue before trial start
params.endTrial = 999;              % marker sent to command outlet to indicate end of process
iteration = 0;                                      % iteration counter
motorData = [];                                     % post-laPlacian matrix
%}

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


%% Start connection to python
% HOST = 'localhost';
% PORT = 50007;
% disp('Connecting to python script!');
% t = tcpclient(HOST, PORT);
% disp('Connected to Python GUI');
% TODO: consider sending the cue vector to the GUI

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
for trial = 1:onlineNumTrials
    %command_Outlet.push_sample(startMarker);
    currentClass = onlineTrainingVec(trial);
    % next cue
    text(0.5,0.5 , 'Next',...
        'HorizontalAlignment', 'Center', 'Color', 'white', 'FontSize', 40);
    %outletStream.push_sample(Baseline);         % needed??
    pause(nextLength);
    cla
    image(flip(trainingImages{currentClass}, 1), 'XData', [0.25, 0.75],...
    'YData', [0.25, 0.75 * ...
    size(trainingImages{currentClass},1)./ size(trainingImages{currentClass},2)])
    %outletStream.push_sample(currentClass);     % needed??
    pause(cueLength);                           % Pause for cue length
    cla                                         % Clear axis
    % ready cue
    text(0.5,0.5 , 'Ready',...
        'HorizontalAlignment', 'Center', 'Color', 'white', 'FontSize', 40);        
    %outletStream.push_sample(Baseline);         % needed??
    pause(readyLength);                         % Pause for ready length
    % asaf also read first data before: (why needed??)
    cla                                         % Clear axis
    % Show image of the corresponding label of the trial
    image(flip(trainingImages{currentClass}, 1), 'XData', [0.25, 0.75],...
        'YData', [0.25, 0.75 * ...
        size(trainingImages{currentClass},1)./ size(trainingImages{currentClass},2)])    
    cur_data = EEG_Inlet.pull_chunk();   % get a chunk from the EEG LSL stream to get the buffer going
    pause(0.1);
    %outletStream.push_sample(currentClass);     % class label
    
    trialStart = tic;
    buffer = [];
    % In their code the repeat same class X times (one by one) - if we
    % want to do this we need to change this while loop (to toc(trialStart)
    % < feedback_returns*trialLength) and insert below&above code
    while size(buffer,2) <= trialLength*fs
        cur_data = EEG_Inlet.pull_chunk();
        pause(0.1);
        if ~isempty(cur_data)
            buffer = [buffer, cur_data];
        else
            disp(strcat('no data to pull in trial', num2str(trial), 'after', num2str(toc(start)), 'seconds'));
        end
    end
    % end trial - start process
    cla                                         % Clear axis
    text(0.5,0.5 , 'Processing',...
        'HorizontalAlignment', 'Center', 'Color', 'white', 'FontSize', 40);
    EEG = pop_importdata('dataformat', 'matlab', 'nbchan', numChans, 'data', buffer, 'srate', fs, 'pnts', 0, 'xmin', 0);
    %outletStream.push_sample(endTrial);         % needed???
    decCount = decCount + 1;
    MI2params.offline = 0;
    [EEG_arr] = preprocess(EEG, recordingFolder, eeglabPath, unused_channels, MI2params);
    EEG_data = EEG_arr(6).data;
    MIData = [];
    for channel=1:numChans
        MIData(1, channel, :) = EEG_data(channel, :);
    end
    [MIFeatures] = feature_engineering(recordingFolder, MIData, bands, times, W, MI4params, feature_setting);

    % TODO: remove the following line
    SelectedIdx = 1:10;
    FeaturesSelected = MIFeatures(:, SelectedIdx);

    ALL_FEATURES = [ALL_FEATURES FeaturesSelected]; % all data to save in the end of recordings
    %%% If Matlab doing predict:
    %myPrediction(decCount) = trainedModel.predictFcn(FeaturesSelected); % TODO: load trained model!!

    myPrediction(decCount) = predict(ALL_FEATURES);

    % TODO: REMOVE THE randsample AFTER FINISHING TESTING THE ONLINE FLOW!
%     myPrediction(decCount) = randsample(predictionClasses, 1);
    cla
    if myPrediction(decCount) == currentClass
        successCount = successCount + 1;
        text(0.5,0.5 , 'Prediction was right!',...
            'HorizontalAlignment', 'Center', 'Color', 'white', 'FontSize', 40);
        pause(1);
    else
        text(0.5,0.5 , 'Prediction was wrong :(',...
            'HorizontalAlignment', 'Center', 'Color', 'white', 'FontSize', 40);
        pause(1);
    end
    cla                                         % Clear axis
    image(flip(trainingImages{myPrediction(decCount)}, 1), 'XData', [0.25, 0.75],...
    'YData', [0.25, 0.75 * ...
    size(trainingImages{myPrediction(decCount)},1)./ size(trainingImages{myPrediction(decCount)},2)])
    hold on % replace to pause?
            
    %{ 
    %%% If python doing precidt:
    save(strcat(recordingFolder,'\', 'online_trial_features.mat'),'EEG_data');
    write(t, "next"); % notify python data is ready
    %Wait for signal to continue to the next feedback
    wait_for_message = 1;
    while (wait_for_message)
        msg_length = t.NumBytesAvailable;
        if msg_length > 0
            bytes = read(t);
            %[bytes, count] = read(t, [1, t.BytesAvailable]);
            disp('Got it!!');
            wait_for_message = 0;
            % Check if messsage == "feedback"
            disp(char(bytes))                  
        end
    end
    %}
    
    %%% TODO: add co-adaptive after X trials
end
% finish recording
%command_Outlet.pushSample(endRecrding);
save(strcat(recordingFolder, '\', 'online_trainingVec.mat'),'trainingVec');
save(strcat(recordingFolder,'\', 'online_all_features.mat'),'ALL_FEATURES');
text(0.5,0.2 , strcat(num2str(successCount),' trials succeed Out Of '...
        ,num2str(onlineNumTrials), ' trials'),...
        'HorizontalAlignment', 'Center', 'Color', 'white', 'FontSize', 40);
pause(2);
cla
text(0.5,0.2 , strcat('Precentage is ',...
    num2str(100*(successCount/onlineNumTrials)),'%'),...
    'HorizontalAlignment','Center', 'Color', 'white', 'FontSize', 40);
pause(2);
disp('Finished')