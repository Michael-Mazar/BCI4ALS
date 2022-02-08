function f_Extract_ManualICAComp(EEG)
%% Still not working as intended
% Define max components to run for 
maxcomponents = 50; 
%% Run ICA
ica_EEG = pop_runica(EEG, 'extended', 1, 'interupt', 'on');
ica_EEG = eeg_checkset(ica_EEG, 'ica');
ica_EEG.comments = pop_comments(ica_EEG.comments,'','Performed ICA',1);

%% Add channel locations if not added yet
chan_loc_filename = 'chan_loc.locs';
eloc = readlocs(chan_loc_filename);
ica_EEG.chanlocs = eloc;

%% Manually Select which ICA Componenet to remove
EEG = pop_selectcomps(ica_EEG, 1:size(ica_EEG.icaweights, 1));
disp('Program paused, press a key...'); pause;
ica_EEG = pop_subcomp(ica_EEG);
ica_EEG = eeg_checkset( ica_EEG );

%% Rename and save
% Set name and save
ica_EEG.setname = [file.name(1:end-length(file_type)), '_prune'];
ica_EEG = pop_saveset(ica_EEG, 'filename', [ica_EEG.setname, '.set'], 'filepath', save_folder);
end