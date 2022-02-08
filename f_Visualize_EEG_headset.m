function f_Visualize_EEG_headset(EEG_Arr,EEG_n)
%% Initialize parameters
n_row = 3;
epoch_interval = [0 5];
%% Decide on a EEG dataset in a particular stage
switch EEG_n
    case 1
        s_EEG = EEG_Arr(1);
        disp('Selected original EEG data before any filtering') 
    case 2
        s_EEG = EEG_Arr(2);
        disp('Selected EEG data after high pass filter')
    case 3
        s_EEG = EEG_Arr(3);
        disp('Selected EEG data after low pass fitlers')
    case 4
        s_EEG = EEG_Arr(4);
        disp('Selected EEG data after bandpass fitlers')
    case 5
        s_EEG = EEG_Arr(5);
        disp('Selected EEG data after laplacian filters')
    case 6
        s_EEG = EEG_Arr(6);
        disp('Selected EEG data after ICA filter')
    otherwise
        disp('No dataset specified or invalid selection, going with the default')
end
%% Plot EEG Channel Stream Data
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

%Save into an array
EEG_class_arr = [rightEEG, leftEEG, idleEEG];
%% Load channel location into EEG structure
figure();
% Define range of frequencies
alpha_lowerFreq  = 8; % Hz
alpha_higherFreq = 13; % Hz
beta_lowerFreq = 13;
beta_higherFreq = 30;
for i = 1:length(EEG_class_arr)
    slc_EEG = EEG_class_arr(i);
    meanPowerMicroV = zeros(slc_EEG.nbchan,1);
    for channelIdx = 1:slc_EEG.nbchan
        [psdOutDb(channelIdx,:), freq] = spectopo(slc_EEG.data(channelIdx, :), 0, slc_EEG.srate, 'plot', 'off','verbose', 'off');
        lowerFreqIdx    = find(freq==alpha_lowerFreq);
        higherFreqIdx   = find(freq==alpha_higherFreq);
        meanPowerMicroV(channelIdx) = mean(10.^((psdOutDb(channelIdx, lowerFreqIdx:higherFreqIdx))/10), 2);
    end
    subplot(n_row,3,i+3)
    topoplot(meanPowerMicroV, slc_EEG.chanlocs)
    title('Alpha (7-13 Hz) Power ')
    cbarHandle = colorbar;
    set(get(cbarHandle, 'title'), 'string', '(uV^2/Hz)')
    
    % Repeat for Beta
    meanPowerMicroV = zeros(slc_EEG.nbchan,1);
    for channelIdx = 1:slc_EEG.nbchan
        [psdOutDb(channelIdx,:), freq] = spectopo(slc_EEG.data(channelIdx, :), 0, slc_EEG.srate, 'plot', 'off', 'verbose', 'off');
        lowerFreqIdx    = find(freq==beta_lowerFreq);
        higherFreqIdx   = find(freq==beta_higherFreq);
        meanPowerMicroV(channelIdx) = mean(10.^((psdOutDb(channelIdx, lowerFreqIdx:higherFreqIdx))/10), 2);
    end
    subplot(n_row,3,i+6)
    topoplot(meanPowerMicroV, slc_EEG.chanlocs)
    title('Beta band (7-30 Hz)')
    cbarHandle = colorbar;
    set(get(cbarHandle, 'title'), 'string', '(uV^2/Hz)')
end
end