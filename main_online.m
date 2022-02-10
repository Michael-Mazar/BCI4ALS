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
% Training Vector
trainingVec = prepareTraining(numTrials,numClasses);    % vector with the conditions for each trial
% MI4 results
load(strcat(recordingFolder,'\W.mat')); %load W for csp
load(strcat(recordingFolder,'\SelectedIdx.mat')); %load indexes of selected features
% online params
buffer = [];
ALL_FEATURES = [];
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

%% Start connection
HOST = 'localhost';
PORT = 50007;
disp('Connecting to python script!');
t = tcpclient(HOST, PORT);
disp('Connected to Python GUI');

% TODO: consider sending the cue vector to the GUI

%% Start Training
totalTrials = length(trainingVec);
for trial = 1:totalTrials
    %currentClass = trainingVec(trial); - no use for now, maybe later in retraining    
    buffer = [];
    start = tic;
    while toc(start) < 100 % how much returns needed for the same cue??
        cur_data = EEG_Inlet.pull_chunk();
        pause(0.1);
        if ~isempty(cur_data)
            buffer = [buffer, cur_data];
        else
            disp(strcat('no data to pull in trial', num2str(trial), 'after', num2str(toc(start)), 'seconds'));
        end
        if size(buffer,2) <= trialLength*Fs
            disp('need more data');
            continue
        end
        % buffer to features
        MI2params.offline = 0;
        [EEG_arr] = preprocess([buffer], recordingFolder, eeglabPath, unused_channels, MI2params);
        EEG_data = EEG_arr(6);
        MIData = [];
        for channel=1:numChans
            MIData(1, channel, :) = EEG_data(channel, :);
        end
        [MIFeatures] = feature_engineering(recordingFolder, MIData, bands, times, W, MI4params, feature_setting);
        FeaturesSelected = MIFeatures(:,SelectedIdx);
        ALL_FEATURES = [ALL_FEATURES FeaturesSelected];
        save(strcat(recordingFolder,'\', 'online_trial_features.mat'),'EEG_data');
        
        % notify GUI that features are saved to disk 
        write(t, "next"); 
        break
    end
    % Wait for signal FROM GUI to continue to the next trial
    wait_for_message = 1;
    while (wait_for_message)
        msg_length = t.NumBytesAvailable;
        if msg_length > 0
            bytes = read(t);
            %[bytes, count] = read(t, [1, t.BytesAvailable]);
            disp('Got it!!');
            wait_for_message = 0;
            % Check if messsage == "end"/"stop"
            disp(char(bytes))                  
        end
    end
    %consider if retraining should be here - after X trials (when
    %trial&x==0)
end
% retraining
save(strcat(recordingFolder, '\', 'online_trainingVec.mat'),'trainingVec');
save(strcat(recordingFolder,'\', 'online_all_features.mat'),'ALL_FEATURES');
write(t, "train"); % signel for retraining the model (all features saved)
% start new session?

%% End of experiment
disp('Finished');