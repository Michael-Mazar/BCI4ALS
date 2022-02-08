%%


%% Previous attempt to classify CSP
CSP_Mat = [targetLabels' CSPFeatures]
CSP_Table = array2table(CSP_Mat);
T.Properties.VariableNames(1:4) = {'Class','1st Eigenvalue','2nd Eigenvalue','3rd Eigenvalue'}
writetable(CSP_Table);
% Default heading for the columns will be A1, A2 and so on. 
% You can assign the specific headings to your table in the following manner
temp = readtable('CSP_Table.txt')
%% Read the features & labels 
FeaturesTrain = cell2mat(struct2cell(load(strcat(recordingFolder,'\CSPTrain.mat'))));   % features for train set
LabelTrain = cell2mat(struct2cell(load(strcat(recordingFolder,'\LabelTrain'))));                % label vector for train set

% Label vector
LabelTest = cell2mat(struct2cell(load(strcat(recordingFolder,'\LabelTest'))));      % label vector for test set
FeaturesTest = cell2mat(struct2cell(load(strcat(recordingFolder,'\CSPTest.mat'))));    

testPrediction = classify(FeaturesTest,FeaturesTrain,LabelTrain,'linear');          % classify the test set using a linear classification object (built-in Matlab functionality)
W = LDA(FeaturesTrain,LabelTrain);                                                  % train a linear discriminant analysis weight vector (first column is the constants)

% Test data
% test prediction from linear classifier
test_results = (testPrediction'-LabelTest);                                         % prediction - true labels = accuracy
test_results = (sum(test_results == 0)/length(LabelTest))*100;
disp(['test accuracy - ' num2str(test_results) '%'])