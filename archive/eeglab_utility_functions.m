%% Extract channel location files
channel_names = {'C3','C4','CZ','FC1',...
    'FC2','FC5','F6','CP1', 'CP2',...
    'CP5','CP6','O1','O2'};
chanlocs = struct('labels', channel_names);
pop_chanedit( chanlocs );

%% Load channel location into EEG structure
eloc = readlocs(chan_loc_filename);
EEG.chanlocs = eloc;

%% Change event labels
% Obtain all unique event types
uniqueEventTypes = unique({EEG.event.type}');
old_event_labels = {'0.000000000000000', '1.000000000000000','1001.000000000000','1111.000000000000',...
    '2.000000000000000','3.000000000000000','9.000000000000000','99.00000000000000'};
new_event_labels =  {'srtRc', 'left', 'baseline', 'srtTr',...
    'right', 'idle', 'endTr', 'endRc'};
allEvents = {EEG.event.type}';
for i=1:length(old_event_labels)
    example1Idx = strcmp(allEvents, old_event_labels{i});
   [EEG.event(example1Idx).type] = deal(new_event_labels{i});
end

%% Extract epochs
% OUTEEG = pop_epoch(EEG); % pop-up a data entry window
% The third value is how much time before and after we extract the epochs
name = 'test_eeg_data'
leftEEG = pop_epoch(EEG, {'left'}, [-1 5], 'newname', strcat(name,'_epochs'), ...
'epochinfo', 'yes');
leftEEG.comments = pop_comments(leftEEG.comments,'','Epoched for left trials from -1000 ms seconds to 5000 ms',1);
leftEEG = eeg_checkset(leftEEG);
% Do so for the right data
rightEEG = pop_epoch(EEG, {'right'}, [-1 5], 'newname', strcat(name,'_epochs'), ...
'epochinfo', 'yes');
rightEEG .comments = pop_comments(leftEEG.comments,'','Epoched for left trials from -1000 ms seconds to 5000 ms',1);
rightEEG = eeg_checkset(rightEEG );


%% Plot channel eeg stream data
montage_file = 'montage_ultracortex.ced';
chan_loc_filename = 'chan_loc.locs';
epochStartTime = -5000;
epochEndTime = 5000;
EEG=pop_chanedit(EEG, 'lookup',montage_file,'load',{montage_file 'filetype' 'autodetect'});
EEG=pop_chanedit(EEG, 'lookup','C:\Users\mazar\Documents\MATLAB\Michael Mazar\dependencies\eeglab2021.0\plugins\dipfit4.3\standard_BESA\standard-10-5-cap385.elp');
EEG = eeg_checkset( EEG );
pop_eegplot( EEG, 1, 1, 1);

%% Plot Time-series evolution
%  For interactive option run  - pop_topoplot(EEG)
%  This is headplot for a single right trial, as an example
pop_topoplot(EEG, 1, [17000:1000:25000] ,'MI_sub',[1 9] ,0,'electrodes','on');

%% Plot Specto
% [spectopo_outputs, freqs]= pop_spectopo(EEG, 1, [], 'EEG' , 'winsize' , 512, ...
% 'plot', 'on', 'freqrange',[0 30],'electrodes','on', 'overlap', 0);
pop_spectopo(EEG);

%% Plot time-frequency decomposition
% Not sure what this function does
figure; metaplottopo( EEG.data, 'plotfunc', 'newtimef', 'chanlocs', EEG.chanlocs, 'plotargs', ...
                   {EEG.pnts, [EEG.xmin EEG.xmax]*1000, EEG.srate, [0], 'plotitc', 'off', 'ntimesout', 50, 'padratio', 1});
%% Simple 2-D movie
% Missing chan loc to work
% Above, convert latencies in ms to data point indices
pnts1 = round(eeg_lat2point(18000/1000, 1, EEG.srate, [EEG.xmin EEG.xmax]));
pnts2 = round(eeg_lat2point( 25000/1000, 1, EEG.srate, [EEG.xmin EEG.xmax]));
scalpERP = mean(EEG.data(:,pnts1:pnts2),3);

% Smooth data
for iChan = 1:size(scalpERP,1)
    scalpERP(iChan,:) = conv(scalpERP(iChan,:) ,ones(1,5)/5, 'same');
end

% 2-D movie
figure; [Movie,Colormap] = eegmovie(scalpERP, EEG.srate, EEG.chanlocs, 'framenum', 'off', 'vert', 0, 'startsec', -0.1, 'topoplotopt', {'numcontour' 0});
seemovie(Movie,-5,Colormap);

% save movie
vidObj = VideoWriter('erpmovie2d.mp4', 'MPEG-4');
open(vidObj);
writeVideo(vidObj, Movie);
close(vidObj);
                             
               
%% Plot ERP Image:
% Still doesn't work, consistently tells
figure; metaplottopo( OUTEEG.data, 'plotfunc', 'erpimage', 'chanlocs', EEG.chanlocs, 'plotargs', ...
         { eeg_getepochevent( EEG, {'rt'},[],'latency') linspace(EEG.xmin*1000, EEG.xmax*1000, EEG.pnts) '' 10 0 });
               
%% Plot ERPS 
pop_newtimef(EEG, 1, 2, [1000,2000], 0); % do not pop-up window

%% Plot ERP Image:
figure; metaplottopo( OUTEEG.data, 'plotfunc', 'erpimage', 'chanlocs', OUTEEG.chanlocs, 'plotargs', ...
         { eeg_getepochevent( OUTEEG, {'rt'},[],'latency') linspace(OUTEEG.xmin*1000, OUTEEG.xmax*1000, OUTEEG.pnts) '' 10 0 });