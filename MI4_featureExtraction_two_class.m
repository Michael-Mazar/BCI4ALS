function [] = MI4_featureExtraction_two_class(recordingFolder, MIData, EEG_chans, targetLabels, bands, times, features_headers, params, feature_setting)
%% This function extracts features for the machine learning process.
% Starts by visualizing the data (power spectrum) to find the best powerbands.
% Next section computes the best common spatial patterns from all available
% labeled training trials. The next part extracts all learned features.
% This includes a non-exhaustive list of possible features (commented below).
% At the bottom there is a simple feature importance test that chooses the
% best features and saves them for model training.
%% This code is part of the BCI-4-ALS Course written by Asaf Harel
% (harelasa@post.bgu.ac.il) in 2021. You are free to use, change, adapt and
% so on - but please cite properly if published.
%% Load variables: 
Features2Select = params.select;                                           % number of featuers for feature selection
num4test = params.test;                                                   % define how many test trials after feature extraction
numClasses = length(unique(targetLabels));                      % set number of possible targets (classes)
Fs = params.FS;                                                       % openBCI Cyton+Daisy by Bluetooth sample rate
numChans = size(MIData,2);                                      % get number of channels from main data variable
%% Get CSP Features
leftClass = MIData(targetLabels == 2,:,:);
rightClass = MIData(targetLabels == 3,:,:);
% aggregate all trials into one matrix
overallLeft = [];
overallRight = [];
for trial=1:size(leftClass,1)
    overallLeft = [overallLeft squeeze(leftClass(trial,:,:))];
    overallRight = [overallRight squeeze(rightClass(trial,:,:))];
end
[W, lambda, A] = csp(overallLeft, overallRight);
%% calculate features
[MIFeatures] = feature_engineering(recordingFolder, MIData, bands, times, W, params, feature_setting);

%% Split to training and test sets
leftIdx = find(targetLabels == 2);                                  % find left trials
rightIdx = find(targetLabels == 3);      
% find right trials

testIdx = randperm(length(leftIdx),num4test);                       % picking test index randomly
testIdx = [leftIdx(testIdx) rightIdx(testIdx)];    % taking the test index from each class
testIdx = sort(testIdx);                                            % sort the trials

% split test data
FeaturesTest = MIFeatures(testIdx,:,:);     % taking the test trials features from each class
LabelTest = targetLabels(testIdx);          % taking the test trials labels from each class


%% THERES OVERLAP NOW
% split train data
FeaturesTrain = MIFeatures;
% FeaturesTrain (testIdx ,:,:) = [];          % delete the test trials from the features matrix, and keep only the train trials
LabelTrain = targetLabels;
% LabelTrain(testIdx) = [];                   % delete the test trials from the labels matrix, and keep only the train labels

%% Feature Selection (using neighborhood component analysis)
% which of the features provide the best explanation

class = fscnca(FeaturesTrain,LabelTrain);   % feature selection
save(strcat(recordingFolder,'\FeatureWeights.mat'),'class');

% sorting the weights in desending order and keeping the indexs
[wts,selected] = sort(class.FeatureWeights,'descend');
% taking only the specified number of features with the largest weights
SelectedIdx = selected(1:Features2Select);
FeaturesTrainSelected = FeaturesTrain(:,SelectedIdx);       % updating the matrix feature
FeaturesTest = FeaturesTest(:,SelectedIdx);                 % updating the matrix feature

% f_Visualize_FeatureSelect(class, features_headers, numChans, params.n_features);
% create mat
%%
% saving
save(strcat(recordingFolder,'\FeaturesTrain.mat'),'FeaturesTrain');
save(strcat(recordingFolder,'\FeaturesTrainSelected.mat'),'FeaturesTrainSelected');
save(strcat(recordingFolder,'\FeaturesTest.mat'),'FeaturesTest');
save(strcat(recordingFolder,'\SelectedIdx.mat'),'SelectedIdx');
save(strcat(recordingFolder,'\LabelTest.mat'),'LabelTest');
save(strcat(recordingFolder,'\LabelTrain.mat'),'LabelTrain');
save(strcat(recordingFolder,'\W.mat'),'W');
save(strcat(recordingFolder,'\SelectedIdx.mat'),'SelectedIdx');
disp('Successfuly extracted features!');

end