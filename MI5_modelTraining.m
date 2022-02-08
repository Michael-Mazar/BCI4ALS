function [test_results] = MI5_modelTraining(recordingFolder)
% MI5_LearnModel_Scaffolding outputs a weight vector for all the features
% using a simple multi-class linear approach.
% Add your own classifier (SVM, CSP, DL, CONV, Riemann...), and make sure
% to add an accuracy test.

%% This code is part of the BCI-4-ALS Course written by Asaf Harel
% (harelasa@post.bgu.ac.il) in 2021. You are free to use, change, adapt and
% so on - but please cite properly if published.

%% Read the features & labels 

FeaturesTrain = cell2mat(struct2cell(load(strcat(recordingFolder,'\FeaturesTrainSelected.mat'))));   % features for train set
LabelTrain = cell2mat(struct2cell(load(strcat(recordingFolder,'\LabelTrain'))));                % label vector for train set

% label vector
LabelTest = cell2mat(struct2cell(load(strcat(recordingFolder,'\LabelTest'))));      % label vector for test set
load(strcat(recordingFolder,'\FeaturesTest.mat'));                                  % features for test set

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%% Split to train and validation sets %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% test data
testPrediction = classify(FeaturesTest,FeaturesTrain,LabelTrain,'linear');          % classify the test set using a linear classification object (built-in Matlab functionality)
W = LDA(FeaturesTrain,LabelTrain);                                                  % train a linear discriminant analysis weight vector (first column is the constants)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%% Add your own classifier %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% lin_svm = fitcsvm(FeaturesTrain, LabelTrain);
% y_svm = zeros(size(FeaturesTest));
% % 
% 
% 
% cd(config.svm_toolbox);
% % s 0: C-SVM
% % t 0: linear; 1: polynomial; 2: rbf; 3: sigmoid
% cmd = ['-q -s 0 -t 2 -g ', num2str(2^log2g), '-c ', num2str(2^log2c),'-b 0'];
% model = svmtrain(TrainClass, TrainData, cmd);
% [TestPredict, accuracy,~] = svmpredict(TestClass,TestData,model,'-b 0');
% 
% TestAcc = accuracy(1,1);
% %TrainPredict = classify(TrainData,TrainData,TrainClass);
% %TestPredict = classify(TestData,TrainData,TrainClass);
% [TrainPredict, accuracy,~] = svmpredict(TrainClass,TrainData,model,'-b 0');
% TrainAcc = accuracy(1,1);
% 
% 
% for x=1:length(cnt)
%     y_svm(x) = test_svm(single(cnt(x,:)),S,T,lin_svm);
% end
% 
% 
% 
% % loss = eval_mcr(y_svm(indices),true_y(indices));
% k = compute_cohens_k(true_y(indices), y_svm(indices));
% fprintf('The linear svm mis-classification rate on the test set is %.2f percent & kappa = %.3f\n',100*loss, k);
%% Test data
% test prediction from linear classifier
test_results = (testPrediction'-LabelTest);                                         % prediction - true labels = accuracy
test_results = (sum(test_results == 0)/length(LabelTest))*100;
disp(['test accuracy - ' num2str(test_results) '%'])

save(strcat(recordingFolder,'\TestResults.mat'),'test_results');                    % save the accuracy results
save(strcat(recordingFolder,'\WeightVector.mat'),'W');                              % save the model (W)

end