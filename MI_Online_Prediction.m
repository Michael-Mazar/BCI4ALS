%% MOTOR IMAGERY Training Scaffolding 
%% Refresh
clc; clear; close all;
%% Parameters
recordingFolder = 'C:\Users\Raz\BCI4ALS\Recordings\ONLINE_TEST';
config_param 
dataFolder = 'C:\Users\Raz\GitRepos\BCI4ALS\data\combined';
addpath(string(lslPath));     % lab streaming layer library
addpath(string(lslPath) + '\bin'); % lab streaming layer bin
addpath(string(eeglabPath)); 
eeglab nogui;

% Setup Python interperter
% TODO: consider adding Python interperter path to config_params
try
    pyenv('Version','C:\Users\Raz\anaconda3\envs\BCI\python.exe');

catch e
    disp(e);
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
online_trails = 1;
feedback_returns = 1;
buffer = [];
ALL_FEATURES = [];
myPrediction = [];                                  % predictions vector
decCount = 0;
successCount = 0;
onlineTrainingVec = prepareTraining(online_trails,MI1params.numClasses);    % vector with the conditions for each trial
numChans = size(EEG_chans,1);
MI2params.offline = 0;
MI2params.plot = 0;
MI4params.offline = 0;

%% Start LSL
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

%% Start TCP connection
HOST="localhost";
PORT=12345;
CONNECTION_TIMEOUT = 60 * 30; % in seconds

% apllication_python=1;

disp('Starting TCP server...');
server = tcpserver(HOST, PORT, "Timeout", CONNECTION_TIMEOUT);
fprintf('TCP server started on %s, port %d \n', server.ServerAddress, server.ServerPort);

%% Start Training
RUN_SERVER = true;

while RUN_SERVER
    request = readline(server);
    if request=="START"
        cur_data = EEG_Inlet.pull_chunk();
        pause(0.1);
        trialStart = tic;
        buffer = [];
        while size(buffer,2) <= trialLength*fs
            cur_data = EEG_Inlet.pull_chunk();
            pause(0.1);
            if ~isempty(cur_data)
                buffer = [buffer, cur_data];
            else
                disp(strcat('no data to pull after ', num2str(toc(trialStart)), 'seconds'));
            end
        end
% 
        EEG = pop_importdata('dataformat', 'matlab', 'nbchan', numChans,...
                        'data', buffer, 'srate', fs, 'pnts', 0, 'xmin', 0);

        decCount = decCount + 1;
        [EEG_arr] = preprocess(EEG, recordingFolder, eeglabPath, unused_channels, MI2params);
        EEG_data = EEG_arr(end).data;
        MIData = [];
        for channel=1:numChans
            MIData(1, channel, :) = EEG_data(channel, :);
        end
        [MIFeatures] = feature_engineering(recordingFolder, MIData, bands, times, W, MI4params, feature_setting);
%     
%         % TODO: remove the following line
%         SelectedIdx = 1:10;
        FeaturesSelected = MIFeatures(:, SelectedIdx);
        %%% If Matlab doing predict:
        
%         features = randi(5,1,10);
        prediction = predict(FeaturesSelected);
    
        write(server, int2str(prediction), "string");     
    

    % TODO: re-consider whether we need the STOP functionallity
    elseif request=="STOP"
        RUN_SERVER = false;
        disp("Stop request acknowledged");
        continue;
       
    else
        resp = sprintf("Unknown request type: %s", request);
        write(server, resp, "string");
    end
end
    

%% End of experiment
disp('Finished');