function [EEG_Arr] = preprocess(EEG, recordingFolder, eeglab_dir, unused_channels, params) 
%% Preprocessing
%% Some parameters (this needs to change according to your system):
addpath(string(eeglab_dir));
if params.plot == 1
    eeglab;                                     % open EEGLAB 
else
    eeglab nogui;
end
highLim = params.highLim;                               % filter data under 40 Hz
lowLim = params.lowLim;                               % filter data above 0.5 Hz
    
% Load channels locations
chan_loc_filename = 'chan_loc.locs';
eloc = readlocs(chan_loc_filename);
EEG.chanlocs = eloc;

%% (1) Remove unused channels
EEG = pop_select( EEG, 'nochannel', unused_channels);
EEG = eeg_checkset( EEG );

%% Save original data
originalEEG = EEG;
originalEEG.data = EEG.data;

%% (2) Low Pass Filter 
EEG = pop_eegfiltnew(EEG, 'hicutoff',highLim,'plotfreqz',params.plot);    % remove data above
EEG = eeg_checkset( EEG );
EEG_afterHigh = EEG;
EEG_afterHigh.data = EEG.data; % Return highpass

%% (3) High-pass filter
EEG = pop_eegfiltnew(EEG, 'locutoff',lowLim,'plotfreqz',params.plot);     % remove data under
EEG = eeg_checkset( EEG );
% Save after high pass
EEG_afterLow = EEG;
EEG_afterLow.data = EEG.data; 

%% (4) Notch filter - this uses the ERPLAB filter
% *Increases the processing time??
EEG  = pop_basicfilter(EEG,  1:params.channelsNum , 'Boundary', 'boundary', 'Cutoff', 25, 'Design', 'notch', 'Filter', 'PMnotch', 'Order',  100 );
EEG  = pop_basicfilter(EEG,  1:params.channelsNum , 'Boundary', 'boundary', 'Cutoff', 50, 'Design', 'notch', 'Filter', 'PMnotch', 'Order',  180 );
EEG = eeg_checkset( EEG );
% Save after bandpass
EEG_afterBandPass = EEG;
EEG_afterBandPass.data = EEG.data;

%% (5) ASR Processing - Clean EEG Data with Clean_raw automatic artifact rejection
if params.ASR
    EEG = clean_artifacts(EEG,'WindowCriterion','off','LineNoiseCriterion','off','ChannelCriterion','off');
    EEG = eeg_checkset( EEG );
    if params.plot == 1
        vis_artifacts(EEG,EEG_afterBandPass);
        disp('Review changes after ASR..')
        pause;
    end
else 
    disp('Skipping ASR Preprocessing....')
end

EEG_AfterAR = EEG;

%% (6) Laplacian filter
if params.Laplace
    C03_ind = 1;
    C03_neighbors_ind = [4,6,8,10];
    C04_ind = 2;
    C04_neighbors_ind = [5,7,9,11];
    EEG_afterLapC_3 = laplacian_1d_filter(EEG.data, C03_ind, C03_neighbors_ind);
    EEG.data = EEG_afterLapC_3;
    EEG_afterLap_C4 = laplacian_1d_filter(EEG.data, C04_ind, C04_neighbors_ind);
    EEG.data = EEG_afterLap_C4;
    EEG = eeg_checkset( EEG );
    if params.plot == 1
        vis_artifacts(EEG,EEG_AfterAR);
        disp('Review changes after Laplacian..')
        pause;
    end
else
    disp('Skipping Laplacian integration')
end

EEG_AfterLap = EEG;

%% (7) Remove unwanted channels:
% EEG = pop_select( EEG, 'nochannel', unwanted_channels);
EEG = eeg_checkset(EEG );
EEG_AfterChannelRemoval = EEG;
% EEG_AfterChannelRemoval.data = EEG;

% TODO: do we need this? - Q for michael
% EEG = pop_clean_rawdata(EEG);
% EEG = clean_artifacts(EEG,'WindowCriterion','off','ChannelCriterion','off');
% EEG = pop_autorej(EEG, 'nogui', 'on', 'eegplot', 'on'); - Require data epoc
% Insert for Manual cleaning here
%% (9) ICA Processing
% Manual - May require editing functions/sigprocfunc/icadefs.m under EEGLAB
% folder by adding EEGOPTION_PATH = userpath (See Makoto Processing line)
% because ICAACT is empty

if params.ICA
    EEG = clean_ica_components(EEG, params.ICA_threshold);
    EEG = eeg_checkset( EEG );
    if params.plot == 1
      vis_artifacts(EEG, EEG_AfterLap);
      disp('Review changes after ICA..')
      pause;
    end
else
    disp('Skipping ICA Preprocessing..')

% EEG might not have changed here if params.ICA==false
EEG_AfterICA = EEG;



%% Save all the data
EEG_Arr = [originalEEG, EEG_afterHigh, EEG_afterLow, EEG_afterBandPass, EEG_AfterAR, EEG_AfterLap, EEG_AfterChannelRemoval, EEG_AfterICA];
% Save the data into .mat variables on the computer
EEG_data = EEG.data;            % Pre-processed EEG data
if params.offline == 1
    EEG_event = EEG.event;          % Saved markers for sorting the data
    save(strcat(recordingFolder,'\','EEG_events.mat'),'EEG_event'); 
    save(strcat(recordingFolder,'\','cleaned_sub.mat'),'EEG_data');
end
end