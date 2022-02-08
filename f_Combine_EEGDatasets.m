function [EEG] = f_Combine_EEGDatasets(recordingPaths)
% Example input
% recordingPaths = {'C:\Recordings\New_headset_raz\raz1_touch' ;
% 'C:\Recordings\New_headset_raz\raz2_touch'}
%% Load first dataset
recordingFolder = recordingPaths{1};
recordingFile = strcat(recordingFolder,'\EEG.XDF');
EEG = pop_loadxdf(recordingFile, 'streamtype', 'EEG', 'exclude_markerstreams', {});
loadedVector = load(strcat(recordingFolder,'\trainingVec.mat'));
trainingVec = loadedVector.trainingVec; 
clear recordingFolder recordingFile 
%% Merge with sets in recordigns
for i=2:length(recordingPaths)
  recordingFolder = recordingPaths{i};
  % Merge EEG Datasets
  recordingFile = strcat(recordingFolder,'\EEG.XDF');
  EEG_add = pop_loadxdf(recordingFile, 'streamtype', 'EEG', 'exclude_markerstreams', {});
  EEG = pop_mergeset(EEG,EEG_add);
  % Merge Training Vectors
  loadedVector = load(strcat(recordingFolder,'\trainingVec.mat'));
  trainVec_add = loadedVector.trainingVec; 
  trainingVec = [trainingVec trainVec_add];
end
EEG = eeg_checkset( EEG );
%% Save as new dataset.
% Add option for file path
EEG = pop_saveset(EEG, 'filename', ['EEG.set']);
save('trainingVec.mat', 'trainingVec');
end