function [EEG] = f_Combine_EEGDatasets(path, recordingPaths)
%% Function Description:
% Input:
% path: The destination folder for which to save new trainingVector and  merged EEG dataset
% recordingPaths: Folders containing recording (EEG.xdf + trainingVector)
% Output: Creates merged trainingVector and EEG dataset in specified
% folder, this will serve as new recordingFolder for pipeline
% Example input and console run:
% %% Recording Paths array
% > recordingPaths = {'C:\Users\micha\MATLAB\Projects\BCI4ALS_PROJECT\Data\second_meeting_06_04\10_54',...
%     'C:\Users\micha\MATLAB\Projects\BCI4ALS_PROJECT\Data\second_meeting_06_04\11_03',...
%     'C:\Users\micha\MATLAB\Projects\BCI4ALS_PROJECT\Data\second_meeting_06_04\11_13'};
% > path =
% 'C:\Users\micha\MATLAB\Projects\BCI4ALS_PROJECT\Data\combined_recordings\combined_all'
% > f_Combine_EEGDatasets(path, recordingPaths)
% 

% recordingPaths = {'C:\Users\micha\MATLAB\Projects\BCI4ALS_PROJECT\Data\Hana_recombine\Fifth meeting - 11-05\1',...
%         'C:\Users\micha\MATLAB\Projects\BCI4ALS_PROJECT\Data\Hana_recombine\Fifth meeting - 11-05\2',...
%         'C:\Users\micha\MATLAB\Projects\BCI4ALS_PROJECT\Data\Hana_recombine\Fifth meeting - 11-05\3',...
%         'C:\Users\micha\MATLAB\Projects\BCI4ALS_PROJECT\Data\Hana_recombine\Fourth meeting - 02-05\1',...
%          'C:\Users\micha\MATLAB\Projects\BCI4ALS_PROJECT\Data\Hana_recombine\Fourth meeting - 02-05\2',...
%          'C:\Users\micha\MATLAB\Projects\BCI4ALS_PROJECT\Data\Hana_recombine\Fourth meeting - 02-05\3',...
%          'C:\Users\micha\MATLAB\Projects\BCI4ALS_PROJECT\Data\Hana_recombine\Fourth meeting - 02-05\4',...
%          'C:\Users\micha\MATLAB\Projects\BCI4ALS_PROJECT\Data\Hana_recombine\Fourth meeting - 02-05\5',...
%          'C:\Users\micha\MATLAB\Projects\BCI4ALS_PROJECT\Data\Hana_recombine\Fourth meeting - 02-05\6',...
%          'C:\Users\micha\MATLAB\Projects\BCI4ALS_PROJECT\Data\Hana_recombine\Fourth meeting - 02-05\7',...
%          'C:\Users\micha\MATLAB\Projects\BCI4ALS_PROJECT\Data\Hana_recombine\Third meeting - 13-04\Hana_recording_1',...
%          'C:\Users\micha\MATLAB\Projects\BCI4ALS_PROJECT\Data\Hana_recombine\Third meeting - 13-04\Hana_recording_2',...
%          'C:\Users\micha\MATLAB\Projects\BCI4ALS_PROJECT\Data\Hana_recombine\Third meeting - 13-04\Hana_recording_3',...
%          'C:\Users\micha\MATLAB\Projects\BCI4ALS_PROJECT\Data\Hana_recombine\Second meeting - 06-04\10_54',...
%          'C:\Users\micha\MATLAB\Projects\BCI4ALS_PROJECT\Data\Hana_recombine\Second meeting - 06-04\11_03',...
%          'C:\Users\micha\MATLAB\Projects\BCI4ALS_PROJECT\Data\Hana_recombine\Second meeting - 06-04\11_13',...
% };
% path = 'C:\Users\micha\MATLAB\Projects\BCI4ALS_PROJECT\Data\Hana_recombine\combined';


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
EEG = pop_saveset(EEG, 'filename', strcat(path,'EEG.set'));
save(strcat(path,'trainingVec.mat'), 'trainingVec');
end