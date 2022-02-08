%% MOTOR IMAGERY Training Scaffolding 
% This code creates a training paradigm with (#) classes on screen for
% (#) numTrials. Before each trial, one of the targets is cued (and remains
% cued for the entire trial).This code assumes EEG is recorded and streamed
% through LSL for later offline preprocessing and model learning.
% This code is part of the BCI-4-ALS Course written by Asaf Harel
% (harelasa@post.bgu.ac.il) in 2021. You are free to use, change, adapt and
% so on - but please cite properly if published.
%% Parameters
config_params
addpath(string(lslPath));     % lab streaming layer library
addpath(string(lslPath) + '\bin'); % lab streaming layer bin
numTrials = MI1params.numTrials;           % 5 number of trials - set number of training trials per class (the more classes, the more trials per class)
numClasses = MI1params.numClasses;         % set number of possible classes
trialLength = MI1params.trialLength;                        % each trial length in seconds 
% wait: init, ready, cue, next
InitWait = MI1params.waits(1);             % before trials prep time
readyLength = MI1params.waits(2);                        % time "ready" on screen
cueLength = MI1params.waits(3);                          % time for each cue
nextLength = MI1params.waits(4);                         % time "next" on screen
% Training Vector
trainingVec = prepareTraining(numTrials,numClasses);    % vector with the conditions for each trial
% MI4 results
load(strcat(recordingFolder,'\W.mat')); %load W for csp
load(strcat(recordingFolder,'\SelectedIdx.mat')); %load indexes of selected features
% online params
buffer = [];
iteration = 0;
prediction = [];
decCount = 0;                                       
%% open stream
disp('Loading the Lab Streaming Layer library...');
lib = lsl_loadlib();                    % load the LSL library
disp('Opening Marker Stream...');
info = lsl_streaminfo(lib,'MarkerStream','Markers',1,0,'cf_string','myuniquesourceid23443');
outletStream = lsl_outlet(info);        % create an outlet stream using the parameters above
disp('Resolving an EEG Stream...');
result = {};
lslTimer = tic;
while isempty(result) && toc(lslTimer) < params.resolveTime % FIXME add some stopping condition
    result = lsl_resolve_byprop(lib,'type','EEG'); 
end
disp('Success resolving!');
EEG_Inlet = lsl_inlet(result{1});

% asaf also read first data before: (why needed??)
pause(0.2);                          % give the system some time to buffer data
cur_data = EEG_Inlet.pull_chunk();   % get a chunk from the EEG LSL stream to get the buffer going
%% Screen Setup 
monitorPos = get(0,'MonitorPositions'); % monitor position and number of monitors
monitorN = size(monitorPos, 1);
choosenMonitor = 1;                     % which monitor to use TODO: make a parameter                                 
if choosenMonitor < monitorN            % if no 2nd monitor found, use the main monitor
    choosenMonitor = 1;
    disp('Another monitored is not detected, using main monitor.')
end
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
%% Start Training
totalTrials = length(trainingVec);
text(0.5,0.5 ,...                               % important for people to prepare
    ['System is calibrating.' newline 'The training session will begin shortly.'], ...
    'HorizontalAlignment', 'Center', 'Color', 'white', 'FontSize', 40);
pause(InitWait)
cla
for trial = 1:totalTrials
    currentClass = trainingVec(trial);          % What class is it?    
    % Cue before ready
    image(flip(trainingImage{currentClass}, 1), 'XData', [0.25, 0.75],...
        'YData', [0.25, 0.75 * ...
        size(trainingImage{currentClass},1)./ size(trainingImage{currentClass},2)])
    pause(cueLength);                           % Pause for cue length
    cla                                         % Clear axis
    % Ready
    text(0.5,0.5 , 'Ready',...
        'HorizontalAlignment', 'Center', 'Color', 'white', 'FontSize', 40);
    pause(readyLength);                         % Pause for ready length
    cla                                         % Clear axis
    % Show image of the corresponding label of the trial
    image(flip(trainingImage{currentClass}, 1), 'XData', [0.25, 0.75],...
        'YData', [0.25, 0.75 * ...
        size(trainingImage{currentClass},1)./ size(trainingImage{currentClass},2)])    
    %% here add new things
    buffer = [];
    start = tic;
    while toc(start) < 200 % how much returns needed for the same cue??
        itertation = iteration + 1;
        cur_data = EEG_Inlet.pull_chunk();
        pause(0.1);
        if ~isempty(cur_data)
            buffer = [buffer, cur_data];
        else
            disp(strcat('no data to pull in trial', num2str(trial), 'after', num2str(toc(start)), 'sec'), 'iteration', num2str(iteration));
        end
        if size(buffer,2) <= trialLength*Fs
            disp('not enough data :(');
        else
            decCount = decCount + 1;
            block = [buffer];
            MI2params.offline = 0;
            [EEG_arr] = preprocess(block, recordingFolder, eeglabPath, unused_channels, MI2params);
            EEG_data = EEG_arr(6);
            MIData = [];
            for channel=1:numChans
                MIData(1, channel, :) = EEG_data(channel, :);
            end
            [MIFeatures] = feature_engineering(recordingFolder, MIData, bands, times, W, MI4params, feature_setting);
            FeaturesSelected = MIFeatures(:,SelectedIdx);
            save(strcat(recordingFolder,'\', 'features_dec_', num2str(decCount), '.mat'),'EEG_data');
            % run predict
            % update GUI - feedaback
            % retratining?
            % save prediction? features? new model?
            buffer = [];
        end
    end
    
    % Display "Next" trial text
    text(0.5,0.5 , 'Next',...
        'HorizontalAlignment', 'Center', 'Color', 'white', 'FontSize', 40);
    % Display trial count
    text(0.5,0.2 , strcat('Trial #',num2str(trial + 1),' Out Of : '...
        ,num2str(totalTrials)),...
        'HorizontalAlignment', 'Center', 'Color', 'white', 'FontSize', 40);
    pause(nextLength);                          % Wait for next trial
    cla                                         % Clear axis
    
end

%% End of experiment
disp('Finished');
save(strcat(recordingFolder,'trainingVec.mat'),'trainingVec');