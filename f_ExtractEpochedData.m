function [gEEG,EEG_class_arr] = f_ExtractEpochedData(EEG_Arr, selection, flag_bl)
%% Initialize parameters
epoch_interval = [-1 5];
Baseline_interval = [-1 0];
%% Select EEG
switch selection
    case 1
        s_EEG = EEG_Arr(selection);
        disp('Selected original EEG data before any filtering') 
    case 2
        s_EEG = EEG_Arr(selection);
        disp('Selected EEG data after high pass filter')
    case 3
        s_EEG = EEG_Arr(selection);
        disp('Selected EEG data after low pass fitlers')
    case 4
        s_EEG = EEG_Arr(selection);
        disp('Selected EEG data after bandpass fitlers')
    case 5
        s_EEG = EEG_Arr(selection);
        disp('Selected EEG data after ASR Filter')
    case 6
        s_EEG = EEG_Arr(selection);
        disp('Selected EEG data after laplacian filters')
    case 7
        s_EEG = EEG_Arr(selection);
        disp('Selected EEG data after channel removal')
    case 8
        s_EEG = EEG_Arr(selection);
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


eventClass = {'right','left','idle'};
for i=1:length(eventClass)
    classLabel = eventClass{i};
    idx = find(strcmp({s_EEG.event.type},classLabel));
    flag=0;
    for j=1:length(idx)
       if flag==1
           [s_EEG.event(idx(j)).type] = strcat(classLabel,'_second');
       end
       flag=mod(flag+1,2);
    end
end


%% Extract epochs
% OUTEEG = pop_epoch(EEG); % pop-up a data entry window
% The third value is how much time before and after we extract the epoch
name = 'Combined';
gEEG = pop_epoch(s_EEG, {'left','right','idle'}, epoch_interval, 'newname', strcat(name,' data'), ...
'epochinfo', 'yes');
gEEG.comments = pop_comments(gEEG.comments,'','Epoched for left trial -1000 ms seconds to 5000 ms',1);
gEEG = eeg_checkset(gEEG);


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

end