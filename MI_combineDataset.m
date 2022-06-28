function [MIData, trainingVec] = MI_combineDataset(datasets, folder)
% Requires that datasets are numerically numbered by intergers and contain
% MIData and trainingVec in each of their folders
% In:
%   datasets   : Datasets containing numbers for which datasets to combine
%   folder     : Path to the data folder containing the numerically
%   labelled folders
%
% Out:
%   MIData     : The combined datasets of datasets specified in input variable. 
%   trainingVec: The combined training vec on all datasets
% Use example: 
% > folder = 'C:\Users\micha\MATLAB\Projects\BCI4ALS_PROJECT\Data'
% > datasets = [6,7]
% > [MIData, trainingVec] = f_combineDataset(datasets, folder)
% Load initial MIData

recordingFile = sprintf('%s\\%s', folder, string(datasets(1)));

% Load initial MIDAta
MIData_temp = load(strcat(recordingFile,'\MIData.mat'));
MIData = MIData_temp.MIData; 

% Load initial training
loadedVector = load(strcat(recordingFile,'\trainingVec.mat'));
trainingVec =  loadedVector.trainingVec; 

% Load initial CSP
CSPFeatures = cell2mat(struct2cell(load(strcat(recordingFile,'\CSPFeatures.mat'))));

for i=2:length(datasets)
  % Merge EEG Datasets
    recordingFile = sprintf('%s\\%s', folder, string(datasets(i)));
    MIData_temp = load(strcat(recordingFile,'\MIData.mat'));
    loadedMIData = MIData_temp.MIData; 
    MIData = cat(1,MIData,loadedMIData);
  % Merge Training Vectors
  loadedVector = load(strcat(recordingFile,'\trainingVec.mat'));
  trainVec_add = loadedVector.trainingVec; 
  trainingVec = [trainingVec trainVec_add];
  
  % Merge CSP's
  CSPFeatures_add = cell2mat(struct2cell(load(strcat(recordingFile,'\CSPFeatures.mat'))));
  CSPFeatures = cat(1,CSPFeatures,CSPFeatures_add);

end
% Save everything
save(strcat(folder,'\combined\trainingVec.mat'), 'trainingVec');
save(strcat(folder,'\combined\MIData.mat'), 'MIData');
save(strcat(folder,'\combined\CSPFeatures.mat'), 'CSPFeatures');

end