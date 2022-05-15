function [MIData, trainingVec] = balance_classes_after_trials_removal(MIData,trainingVec, smallestClassTrialsNum)
%% Balances data after trials removal
% Given the size of the class with the smallest number of trials
% (smallestClassSize), randomally choose trials for other classes to have
% the same size


idleIdx = find(trainingVec == 1); 
leftIdx = find(trainingVec == 2);
rightIdx = find(trainingVec == 3);   

% Randomally choose trials from all classes
newIdleIdx = sort(randsample(idleIdx, smallestClassTrialsNum));
newLeftIdx = sort(randsample(leftIdx, smallestClassTrialsNum));
newRightIdx = sort(randsample(rightIdx, smallestClassTrialsNum));

newIdxAll = [newIdleIdx newLeftIdx newRightIdx];
MIData = MIData(newIdxAll, :, :);
trainingVec = trainingVec(:, newIdxAll);


assert(sum(trainingVec == 1) == sum(trainingVec == 2) ...
            && sum(trainingVec == 2) == sum(trainingVec == 3));

assert(size(MIData,1) == sum(trainingVec == 1)*3) % 3 classes

end

