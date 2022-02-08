function f_Visualize_EEG_interactive(EEG_Arr,EEG_n)
%% Inputs: 
% EEG_arr - A structure containing different EEGLAB Structures (Different stages)
% e - The select EEGLAB Structure
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
%% Load channel location into EEG structure
% montage_file = 'montage_ultracortex.ced';
chan_loc_filename = 'chan_loc.locs';
eloc = readlocs(chan_loc_filename);
s_EEG.chanlocs = eloc;
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
pop_eegplot(s_EEG, 1, 1, 1);
%% Visualize artefact rejection
vis_artifacts(EEG_Arr(4),EEG_Arr(5))
% %% Plot topoplot
% pop_topoplot(EEG, 0,1:length(EEG.chanlocs),EEG.setname,[2 4],0,'electrodes','on');
% % saveas(figure(1), [plot_folder, EEG.setname], 'png')
% % close(figure(1))
%% Plot Time-series evolution
%  For interactive option run  - pop_topoplot(EEG)
%  This is headplot for a single right trial, as an example
% pop_topoplot(s_EEG, 1, [17000:1000:25000] ,'MI_sub',[1 9] ,0,'electrodes','on');

%% Plot ERP Image
% figure; metaplottopo( s_EEG.data, 'plotfunc', 'newtimef', 'chanlocs', s_EEG.chanlocs, 'plotargs', ...
%                    {s_EEG.pnts, [s_EEG.xmin s_EEG.xmax]*1000, s_EEG.srate, [0], 'plotitc', 'off', 'ntimesout', 50, 'padratio', 1});

%% 
pop_newtimef(s_EEG, 1, 2, [1000,2000], 0); % do not pop-up window
               
% %% Time Frequency plot on all electrodes
% for elec = 1:s_EEG.nbchan
%     [ersp,itc,powbase,times,freqs,erspboot,itcboot] = pop_newtimef(s_EEG, ...
%     1, elec, [s_EEG.xmin s_EEG.xmax]*1000, [3 0.5], 'maxfreq', 50, 'padratio', 16, ...
%     'plotphase', 'off', 'timesout', 60, 'alpha', .05, 'plotersp','off', 'plotitc','off');
%     if elec == 1  % create empty arrays if first electrode
%         allersp = zeros([ size(ersp) s_EEG.nbchan]);
%         allitc = zeros([ size(itc) s_EEG.nbchan]);
%         allpowbase = zeros([ size(powbase) s_EEG.nbchan]);
%         alltimes = zeros([ size(times) s_EEG.nbchan]);
%         allfreqs = zeros([ size(freqs) s_EEG.nbchan]);
%         allerspboot = zeros([ size(erspboot) s_EEG.nbchan]);
%         allitcboot = zeros([ size(itcboot) s_EEG.nbchan]);
%     end;
%     allersp (:,:,elec) = ersp;
%     allitc (:,:,elec) = itc;
%     allpowbase (:,:,elec) = powbase;
%     alltimes (:,:,elec) = times;
%     allfreqs (:,:,elec) = freqs;
%     allerspboot (:,:,elec) = erspboot;
%     allitcboot (:,:,elec) = itcboot;
% end;
% % Plot a tftopo() figure summarizing all the time/frequency transforms
% figure;
% tftopo(allersp,alltimes(:,:,1),allfreqs(:,:,1),'mode','ave','limits', ...
% [nan nan nan 35 -1.5 1.5],'signifs', allerspboot, 'sigthresh', [6], 'timefreqs', ...
% [400 8; 350 14; 500 24; 1050 11], 'chanlocs', s_EEG.chanlocs);

%% Unused functions
               % %% Simple 2-D movie
% % Missing chan loc to work
% % Above, convert latencies in ms to data point indices
% pnts1 = round(eeg_lat2point(18000/1000, 1, EEG.srate, [EEG.xmin EEG.xmax]));
% pnts2 = round(eeg_lat2point( 25000/1000, 1, EEG.srate, [EEG.xmin EEG.xmax]));
% scalpERP = mean(EEG.data(:,pnts1:pnts2),3);
% 
% % Smooth data
% for iChan = 1:size(scalpERP,1)
%     scalpERP(iChan,:) = conv(scalpERP(iChan,:) ,ones(1,5)/5, 'same');
% end
% 
% % 2-D movie
% figure; [Movie,Colormap] = eegmovie(scalpERP, EEG.srate, EEG.chanlocs, 'framenum', 'off', 'vert', 0, 'startsec', -0.1, 'topoplotopt', {'numcontour' 0});
% seemovie(Movie,-5,Colormap);
% % save movie
% vidObj = VideoWriter('erpmovie2d.mp4', 'MPEG-4');
% open(vidObj);
% writeVideo(vidObj, Movie);
% close(vidObj);
                         
               %% Plot channel eeg stream data
% epochStartTime = -5000;
% epochEndTime = 5000;
% EEG=pop_chanedit(EEG, 'lookup',montage_file,'load',{montage_file 'filetype' 'autodetect'});
% EEG=pop_chanedit(EEG, 'lookup','C:\Users\mazar\Documents\MATLAB\Michael Mazar\dependencies\eeglab2021.0\plugins\dipfit4.3\standard_BESA\standard-10-5-cap385.elp');
% EEG = eeg_checkset( EEG );                     
%% Plot ERP Image:
% Still doesn't work, consistently tells
% figure; metaplottopo( OUTEEG.data, 'plotfunc', 'erpimage', 'chanlocs', EEG.chanlocs, 'plotargs', ...
%          { eeg_getepochevent( EEG, {'rt'},[],'latency') linspace(EEG.xmin*1000, EEG.xmax*1000, EEG.pnts) '' 10 0 });
               
%% Plot ERPS 
% pop_newtimef(EEG, 1, 2, [1000,2000], 0); % do not pop-up window
% 
%% Plot ERP Image:
% figure; metaplottopo( OUTEEG.data, 'plotfunc', 'erpimage', 'chanlocs', OUTEEG.chanlocs, 'plotargs', ...
end