function [EEG, originalEEG, EEG_afterHigh, EEG_afterLow, EEG_afterBandPass, EEG_afterLap] = MI2_preprocess(recordingFolder)
%% Offline Preprocessing
% Assumes recorded using Lab Recorder.
% Make sure you have EEGLAB installed with ERPLAB & loadXDF plugins.

% [recordingFolder] - where the EEG (data & meta-data) are stored.

% Preprocessing using EEGLAB function.
% 1. load XDF file (Lab Recorder LSL output)
% 2. look up channel names - YOU NEED TO UPDATE THIS
% 3. filter data above 0.5 & below 40 Hz
% 4. notch filter @ 50 Hz
% 5. advanced artifact removal (ICA/ASR/Cleanline...) - EEGLAB functionality

%% This code is part of the BCI-4-ALS Course written by Asaf Harel
% (harelasa@post.bgu.ac.il) in 2021. You are free to use, change, adapt and
% so on - but please cite properly if published.

%% Some parameters (this needs to change according to your system):
addpath 'C:\Users\user\Documents\BCI4ALS\LabRecorder\M1 trails\10_11_21\No_Touch\2nd_try\fromdrive'           % update to your own computer path
eeglab;                                     % open EEGLAB 
highLim = 40;                               % filter data under 40 Hz
lowLim = 0.5;                               % filter data above 0.5 Hz
recordingFile = strcat(recordingFolder,'\EEG.XDF');

% (1) Load subject data (assume XDF)
EEG = pop_loadxdf(recordingFile, 'streamtype', 'EEG', 'exclude_markerstreams', {});
EEG.setname = 'MI_sub';

% (2) Update channel names - each group should update this according to
% their own openBCI setup.
EEG_chans(1,:) = 'C03';
EEG_chans(2,:) = 'C04';
EEG_chans(3,:) = 'C0Z';  
EEG_chans(4,:) = 'FC1';  %%HERE C03
EEG_chans(5,:) = 'FC2';  %%HERE C04
EEG_chans(6,:) = 'FC5';  %%HERE C03
EEG_chans(7,:) = 'F06';  %%HERE C04
EEG_chans(8,:) = 'CP1';  %%HERE C03
EEG_chans(9,:) = 'CP2';  %%HERE C04
EEG_chans(10,:) = 'CP5'; %%HERE C03
EEG_chans(11,:) = 'CP6'; %%HERE C04
EEG_chans(12,:) = 'O01';
EEG_chans(13,:) = 'O02';
% Irrelevant electrodes add more if there are
EEG_chans(14,:) = 'P03';
EEG_chans(15,:) = 'P03';
EEG_chans(16,:) = 'P03';


%% (3) Low-pass filter
originalEEG = EEG.data;
EEG = pop_eegfiltnew(EEG, 'hicutoff',highLim,'plotfreqz',1);    % remove data above
EEG = eeg_checkset( EEG );
EEG_afterHigh = EEG.data; % Return highpass

% (3) High-pass filter
EEG = pop_eegfiltnew(EEG, 'locutoff',lowLim,'plotfreqz',1);     % remove data under
EEG = eeg_checkset( EEG );
EEG_afterLow = EEG.data;

% (4) Notch filter - this uses the ERPLAB filter
EEG  = pop_basicfilter(EEG,  1:16 , 'Boundary', 'boundary', 'Cutoff',  50, 'Design', 'notch', 'Filter', 'PMnotch', 'Order',  180 );
EEG = eeg_checkset( EEG );
EEG_afterBandPass = EEG.data;

%% Advanced
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%% (5) Add advanced artifact removal functions %%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% (5) Laplacian filter

%%% Plots raw data
% figure;
% for channel_i = 1:10
%     title("Before Laplacian")
%     subplot(10,1,channel_i)
%     plot(1000:2000,EEG_afterLow(channel_i,1000:2000))
%     xlim([1000,2000])
%     ylabel(num2str(channel_i))
%     ylim([-200,200])
% 
% end



C03_ind = 1;
C03_neighbors_ind = [4,6,8,10];
C04_ind = 2;
C04_neighbors_ind = [5,7,9,11];
EEG_afterLapC_3 = spatial_laplace(EEG.data, C03_ind, C03_neighbors_ind);
EEG.data = EEG_afterLapC_3;
EEG_afterLap_C4 = spatial_laplace(EEG.data, C04_ind, C04_neighbors_ind);
EEG.data = EEG_afterLap_C4;

%%%Plots data after laplacian
% figure;
% for channel_i = 1:10
%     subplot(10,1,channel_i)
%     plot(1000:2000,EEG.data(channel_i,1000:2000))
%     xlim([1000,2000])
%     ylabel(num2str(channel_i))
%     ylim([-200,200])
%     title("After Laplacian")
% end



% (6) ICA Processing 
% Save the data into .mat variables on the computer
EEG_data = EEG.data;            % Pre-processed EEG data
EEG_event = EEG.event;          % Saved markers for sorting the data
save(strcat(recordingFolder,'\','cleaned_sub.mat'),'EEG_data');
save(strcat(recordingFolder,'\','EEG_events.mat'),'EEG_event');
save(strcat(recordingFolder,'\','EEG_chans.mat'),'EEG_chans');          
end
