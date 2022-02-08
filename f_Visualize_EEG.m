function f_Visualize_EEG(EEG_array, EEG_n, flag_bl)
%% Initialize parameters
epoch_interval = [-1 3];
Baseline_interval = [-1 0];
n_class = 3;
n_row = 5;
n_columns = 3;
%% Decide on a EEG dataset in a particular stage
switch EEG_n
    case 1
        s_EEG = EEG_array(1);
        disp('Selected original EEG data before any filtering') 
    case 2
        s_EEG = EEG_array(2);
        disp('Selected EEG data after high pass filter')
    case 3
        s_EEG = EEG_array(3);
        disp('Selected EEG data after low pass fitlers')
    case 4
        s_EEG = EEG_array(4);
        disp('Selected EEG data after bandpass fitlers')
    case 5
        s_EEG = EEG_array(5);
        disp('Selected EEG data after laplacian filters')
    case 6
        s_EEG = EEG_array(6);
        disp('Selected EEG data after ICA filter')
    otherwise
        disp('No dataset specified or invalid selection, going with the default')
end

%% Change event labels
% Obtain all unique event types
uniqueEventTypes = unique({s_EEG.event.type}');
old_event_labels = {'0.000000000000000', '1.000000000000000','1001.000000000000','1111.000000000000',...
    '2.000000000000000','3.000000000000000','9.000000000000000','99.00000000000000'};
new_event_labels =  {'srtRc', 'left', 'baseline', 'srtTr',...
    'right', 'idle', 'endTr', 'endRc'};
allEvents = {s_EEG.event.type}';
for i=1:length(old_event_labels)
    example1Idx = strcmp(allEvents, old_event_labels{i});
   [s_EEG.event(example1Idx).type] = deal(new_event_labels{i});
end

%% Extract epochs
% OUTEEG = pop_epoch(EEG); % pop-up a data entry window
% The third value is how much time before and after we extract the epochs
name = 'Left Class';
leftEEG = pop_epoch(s_EEG, {'left'}, epoch_interval, 'newname', strcat(name,' data'), ...
'epochinfo', 'yes');
leftEEG.comments = pop_comments(leftEEG.comments,'','Epoched for left trials from -1000 ms seconds to 5000 ms',1);
leftEEG = eeg_checkset(leftEEG);

% Extract right epochs
name = 'Right Class';
rightEEG = pop_epoch(s_EEG, {'right'}, epoch_interval, 'newname', strcat(name,' data'), ...
'epochinfo', 'yes');
rightEEG .comments = pop_comments(leftEEG.comments,'','Epoched for left trials from -1000 ms seconds to 5000 ms',1);
rightEEG = eeg_checkset(rightEEG );

% Extract left epochs
name = 'Idle Class';
idleEEG = pop_epoch(s_EEG, {'idle'}, epoch_interval, 'newname', strcat(name,' data'), ...
'epochinfo', 'yes');
idleEEG.comments = pop_comments(idleEEG.comments,'','Epoched for left trials from -1000 ms seconds to 5000 ms',1);
idleEEG = eeg_checkset(idleEEG);

%% Remove baseline activity if flagged
if flag_bl
    rightEEG = pop_rmbase(rightEEG, Baseline_interval);
    leftEEG = pop_rmbase(leftEEG, Baseline_interval);
    idleEEG = pop_rmbase(idleEEG, Baseline_interval);
end
% Store in a structure
EEG_class_arr = [rightEEG, leftEEG, idleEEG];
% ... clear variable rightEEG and etc..

%% Plot ERP Data in the time domain
figure; 
for i = 1:length(EEG_class_arr)
    subplot(n_row,n_columns,i);
    slc_EEG = EEG_class_arr(i);   
    % Plot ERP Data for C3 Channel 
    hold on
    h = plot(slc_EEG.times,squeeze(slc_EEG.data(1,:,:)),'linew',.5);
    set(h,'color',[1 1 1]*.75)
    plot(slc_EEG.times,squeeze(mean(slc_EEG.data(1,:,:),3)),'k','linew',3);
    xlabel('Time (ms)'), ylabel('Activity')
    title('ERP from channel C3')
    hold off
    
    subplot(n_row,n_columns,i+3);
    slc_EEG = EEG_class_arr(i);   
    % Plot ERP Data for C3 Channel 
    hold on
    h = plot(slc_EEG.times,squeeze(slc_EEG.data(2,:,:)),'linew',.5);
    set(h,'color',[1 1 1]*.75)
    plot(slc_EEG.times,squeeze(mean(slc_EEG.data(2,:,:),3)),'k','linew',3);
    xlabel('Time (ms)'), ylabel('Activity')
    title('ERP from channel C4')
    hold off
    
    % Plot ERP Data for C4 Channel: 
end 
%% Plot PSD of C4 vs C3 Channels under different epochs
for i = 1:length(EEG_class_arr)
    subplot(n_row,n_columns,i+6);
    hold on;
    slc_EEG = EEG_class_arr(i);
    [spectra_C3,freqs_C3] = spectopo(slc_EEG.data(1,:), 0, slc_EEG.srate, 'winsize', slc_EEG.srate, 'nfft', slc_EEG.srate, 'plot', 'off','verbose','off'); % For channel 1 (C3)
    [spectra_C4,freqs_C4] = spectopo(slc_EEG.data(2,:), 0, slc_EEG.srate, 'winsize', slc_EEG.srate, 'nfft', slc_EEG.srate, 'plot', 'off','verbose','off'); % For channel 2 (C4)
    plot(freqs_C3, spectra_C3);
    plot(freqs_C4, spectra_C4);
    legend({'C3 Channel', 'C4 Channel'})
    title(strcat(slc_EEG.setname,' - PSD Plot'))
    ylabel('PSD (mV^2/Hz)')
    xlabel('Frequency (Hz)')
end
%% Plot Spectograms
for i = 1:length(EEG_class_arr)
    slc_EEG = EEG_class_arr(i);
    % Extract for channel C3
    [frex_C3,tf_C3] = f_Extract_TimeFreq(slc_EEG, 1);
    % Extract for channel C4
    [frex_C4,tf_C4] = f_Extract_TimeFreq(slc_EEG, 2);
    % show a map of the time-frequency power
    % Plot for C3:
    subplot(n_row ,n_columns,i+9);
    contourf(slc_EEG.times,frex_C3,tf_C3,40,'linecolor','none')
    xlabel('Time (ms)'), ylabel('Frequency (Hz)')
    title(strcat(slc_EEG.setname,' - C3 Spectogram'))
    % Plot for C4
    subplot(n_row,n_columns,i+12);
    contourf(slc_EEG.times,frex_C4,tf_C4,40,'linecolor','none')
    xlabel('Time (ms)'), ylabel('Frequency (Hz)')
    title(strcat(slc_EEG.setname,' - C4 Spectogram'))
end

%%
% This example code compares PSD in dB (left) vs. uV^2/Hz (right) rendered as scalp topography (setfile must be loaded.)
end