function [EEG_Arr] = preprocess(EEG, recordingFolder, eeglab_dir, unused_channels, params) 
%% Preprocessing
% a b c ??
%% Some parameters (this needs to change according to your system):
addpath(string(eeglab_dir));
eeglab;                                     % open EEGLAB 
highLim = params.highLim;                               % filter data under 40 Hz
lowLim = params.lowLim;                               % filter data above 0.5 Hz
% montage_ulracotext_path = 'montage_ultracortex.ced';
% standard_electrodes_locations_file = strcat(eeglab_dir, '\\plugins\\dipfit\\standard_BEM\\elec\\standard_1005.elc');
    
% Load channels locations
chan_loc_filename = 'chan_loc.locs';
eloc = readlocs(chan_loc_filename);
EEG.chanlocs = eloc;

% Remove unused channels
EEG = pop_select( EEG, 'nochannel', unused_channels);
EEG = eeg_checkset( EEG );


%% (3) Low-pass filter
% Save the initial EEG
originalEEG = EEG;
originalEEG.data = EEG.data;

% (2) Low Pass Filter 
EEG = pop_eegfiltnew(EEG, 'hicutoff',highLim,'plotfreqz',1);    % remove data above
EEG = eeg_checkset( EEG );
EEG_afterHigh = EEG;
EEG_afterHigh.data = EEG.data; % Return highpass

% (3) High-pass filter
EEG = pop_eegfiltnew(EEG, 'locutoff',lowLim,'plotfreqz',1);     % remove data under
EEG = eeg_checkset( EEG );
% Save after high pass
EEG_afterLow = EEG;
EEG_afterLow.data = EEG.data; 

% (4) Notch filter - this uses the ERPLAB filter
% *Increases the processing time??
for x = params.notch
    EEG  = pop_basicfilter(EEG,  1:params.channelsNum , 'Boundary', 'boundary', 'Cutoff', x, 'Design', 'notch', 'Filter', 'PMnotch', 'Order',  180 );
end
EEG = eeg_checkset( EEG );
% Save after bandpass
EEG_afterBandPass = EEG;
EEG_afterBandPass.data = EEG.data;

% (5) Laplacian filter
C03_ind = 1;
C03_neighbors_ind = [4,6,8,10];
C04_ind = 2;
C04_neighbors_ind = [5,7,9,11];
EEG_afterLapC_3 = laplacian_1d_filter(EEG.data, C03_ind, C03_neighbors_ind);
EEG.data = EEG_afterLapC_3;
EEG_afterLap_C4 = laplacian_1d_filter(EEG.data, C04_ind, C04_neighbors_ind);
EEG.data = EEG_afterLap_C4;
% Save Laplacian Structure
EEG_AfterLap = EEG;

% (6) ICA Processing
EEG_AfterICA = clean_ica_components(EEG, params.ICA_threshold);
EEG_Arr = [originalEEG, EEG_afterHigh, EEG_afterLow, EEG_afterBandPass, EEG_AfterLap, EEG_AfterICA];

% Save the data into .mat variables on the computer
EEG_data = EEG.data;            % Pre-processed EEG data
if params.offline == 1
    EEG_event = EEG.event;          % Saved markers for sorting the data
    save(strcat(recordingFolder,'\','EEG_events.mat'),'EEG_event'); 
    save(strcat(recordingFolder,'\','cleaned_sub.mat'),'EEG_data');
end
end