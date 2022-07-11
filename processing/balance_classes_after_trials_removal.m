function [MIData, trainingVec] = balance_classes_after_trials_removal(MIData,trainingVec, classesTrialsNumToRemove)
%% Balances data after trials removal
% Given the size of the class with the smallest number of trials
% (smallestClassSize), randomally choose trials for other classes to have
% the same size


idleIdx = find(trainingVec == 1); 
leftIdx = find(trainingVec == 2);
rightIdx = find(trainingVec == 3);   

idleNumBeforeBalance = sum(trainingVec == 1); 
leftNumBeforeBalance = sum(trainingVec == 2);
rightNumBeforeBalance = sum(trainingVec == 3);  

newIdleTrialsNum = max([0, idleNumBeforeBalance - classesTrialsNumToRemove(1)]);
newLeftTrialsNum = max([0 , leftNumBeforeBalance - classesTrialsNumToRemove(2)]);
newRightTrialsNum = max([0, rightNumBeforeBalance - classesTrialsNumToRemove(3)]);

% Randomally choose trials from all classes
newIdleIdx = sort(randsample(idleIdx, newIdleTrialsNum));
newLeftIdx = sort(randsample(leftIdx, newLeftTrialsNum));
newRightIdx = sort(randsample(rightIdx, newRightTrialsNum));

newIdxAll = [newIdleIdx newLeftIdx newRightIdx];
MIData = MIData(newIdxAll, :, :);
trainingVec = trainingVec(:, newIdxAll);


% The foolowing assertions only work for 3 classes - remove or change them if using 2
% classes
assert(sum(trainingVec == 1) == sum(trainingVec == 2) ...
            && sum(trainingVec == 2) == sum(trainingVec == 3));

assert(size(MIData,1) == sum(trainingVec == 1)*3) 

end

