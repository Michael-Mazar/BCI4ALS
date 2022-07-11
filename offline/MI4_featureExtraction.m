function [] = MI4_featureExtraction(recordingFolder, MIData, EEG_chans, targetLabels, bands, times, features_headers, params, feature_setting)
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
%% Visual Feature Selection: Power Spectrum
% Observe changes in power spectrum - where are these changes observed in
% the different power spectrum 
% init cells for Power Spectrum display
motorDataChan = {};
welch = {};
idxTarget = {};
f = params.f;
window = params.window;
noverlap = params.overlap;
vizChans = [1,2];             % INSERT which 2 channels you want to compare
% create power spectrum figure:
f1 = figure('name','PSD','NumberTitle','off');
sgtitle(['Power Spectrum For The Choosen Electrode']);

% compute power Spectrum per electrode in each class
psd = nan(numChans,numClasses,2,1000); % init psd matrix
for chan = 1:numChans
    motorDataChan{chan} = squeeze(MIData(:,chan,:))';                   % convert the data to a 2D matrix fillers by channel
    nfft = 2^nextpow2(size(motorDataChan{chan},1));                     % take the next power of 2 length of the specific trial length
    welch{chan} = pwelch(motorDataChan{chan},window, noverlap, f, Fs);  % calculate the pwelch for each electrode
    figure(f1);
    subplot(numChans,1,chan)
    for class = 1:numClasses
        idxTarget{class} = find(targetLabels == class);                 % find the target index
        plot(f, log10(mean(welch{chan}(:,idxTarget{class}), 2)));       % ploting the mean power spectrum in dB by each channel & class
        hold on
        ylabel([EEG_chans(chan,:)]);                                    % add name of electrode
        for trial = 1:length(idxTarget{class})                          % run over all concurrent class trials
            [s,spectFreq,t,psd] = spectrogram(motorDataChan{chan}(:,idxTarget{class}(trial)),window,noverlap,nfft,Fs);  % compute spectrogram on specific channel
            multiPSD(trial,:,:) = psd;
        end
        
        % compute mean spectrogram over all trials with same target
        totalSpect(chan,class,:,:) = squeeze(mean(multiPSD,1));
        clear multiPSD psd
    end
end

% manually plot (surf) mean spectrogram for channels C4 + C3:
mySpectrogram(t,spectFreq,totalSpect,numClasses,vizChans,EEG_chans)

%% Common Spatial Patterns
% create a spatial filter using available EEG & labels
% begin by splitting into two classes:
leftClass = MIData(targetLabels == 2,:,:);
rightClass = MIData(targetLabels == 3,:,:);
% aggregate all trials into one matrix
overallLeft = [];
overallRight = [];
for trial=1:size(leftClass,1)
    overallLeft = [overallLeft squeeze(leftClass(trial,:,:))];
    overallRight = [overallRight squeeze(rightClass(trial,:,:))];
end

vizTrial = 2;       % cherry-picked!
figure;
subplot(1,2,1)      % show a single trial before CSP seperation
scatter3(squeeze(leftClass(vizTrial,1,:)),squeeze(leftClass(vizTrial,2,:)),squeeze(leftClass(vizTrial,3,:)),'b'); hold on
scatter3(squeeze(rightClass(vizTrial,1,:)),squeeze(rightClass(vizTrial,2,:)),squeeze(rightClass(vizTrial,3,:)),'g');
title('Before CSP')
legend('Left','Right')
xlabel('channel 1')
ylabel('channel 2')
zlabel('channel 3')
% find mixing matrix (W) for all trials
[W, lambda, A] = csp(overallLeft, overallRight);
[Wviz, lambdaViz, Aviz] = csp(squeeze(rightClass(vizTrial,:,:)), squeeze(leftClass(vizTrial,:,:)));
% The main function which does all the work
% apply mixing matrix on available data (for visualization)
leftClassCSP = (Wviz'*squeeze(leftClass(vizTrial,:,:)));
rightClassCSP = (Wviz'*squeeze(rightClass(vizTrial,:,:)));

subplot(1,2,2)      % show a single trial aftler CSP seperation
scatter3(squeeze(leftClassCSP(1,:)),squeeze(leftClassCSP(2,:)),squeeze(leftClassCSP(3,:)),'b'); hold on
scatter3(squeeze(rightClassCSP(1,:)),squeeze(rightClassCSP(2,:)),squeeze(rightClassCSP(3,:)),'g');
title('After CSP')
legend('Left','Right')
xlabel('CSP dimension 1')
ylabel('CSP dimension 2')
zlabel('CSP dimension 3')

clear leftClassCSP rightClassCSP Wviz lambdaViz Aviz

%% calculate features
[MIFeatures] = feature_engineering(recordingFolder, MIData, bands, times, W, params, feature_setting);
%% Split to training and test sets

idleIdx = find(targetLabels == 1);                                  % find idle trials
leftIdx = find(targetLabels == 2);                                  % find left trials
rightIdx = find(targetLabels == 3);      
% find right trials

testIdx = randperm(length(idleIdx),num4test);                       % picking test index randomly
testIdx = [idleIdx(testIdx) leftIdx(testIdx) rightIdx(testIdx)];    % taking the test index from each class
testIdx = sort(testIdx);                                            % sort the trials

% split test data
FeaturesTest = MIFeatures(testIdx,:,:);     % taking the test trials features from each class
LabelTest = targetLabels(testIdx);          % taking the test trials labels from each class

% split train data
FeaturesTrain = MIFeatures;
FeaturesTrain (testIdx ,:,:) = [];          % delete the test trials from the features matrix, and keep only the train trials
LabelTrain = targetLabels;
LabelTrain(testIdx) = [];                   % delete the test trials from the labels matrix, and keep only the train labels

%% Feature Selection (using neighborhood component analysis)
% which of the features provide the best explanation

class = fscnca(FeaturesTrain,LabelTrain);   % feature selection
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

%% Save table for original 3 Features
% Save a table for the whole features
Combined_features_mat = [LabelTrain' FeaturesTrainSelected; LabelTest' FeaturesTest];
Combined_features_table = array2table(Combined_features_mat);
Combined_features_table.Properties.VariableNames(1) = {'Class'};
Combined_features_table.Class = categorical(Combined_features_table.Class,1:3,{'Idle' 'Left','Right'});
writetable(Combined_features_table);

end