function [MIData, trainingVec] = remove_trials(recordingFolder, indices_to_remove, MIData, trainingVec)
% Removes trials for MIData

% Args:
%   MIData - Recording data
%   indices_to_remove - indices to remove from MIData
%   trainingVec - includes the labels (classes) of each trials

% Returns:
% MIData - the modified data (without the removed trials)
% trainingVec - the modified trainingVec (for the new number trials, after the removal)
removedIdleNum = sum(trainingVec(:, indices_to_remove) == 1);
removedLeftNum = sum(trainingVec(:, indices_to_remove) == 2);
removedRightNum = sum(trainingVec(:, indices_to_remove) == 3);

disp("Removing trials")
disp(sprintf("Number of removed IDLE trials: %d\n" + ...
                "Number of removed LEFT trials: %d\n" + ...
                "Number of removed RIGHT trials: %d\n", ...
                 removedIdleNum, removedLeftNum,removedRightNum));

% Remove bad trials
MIData(indices_to_remove, :, :) = [];
trainingVec(:, indices_to_remove) = [];

% Balance all classes
if ~(removedLeftNum == removedRightNum && removedRightNum == removedIdleNum)

    disp("Class imbalance after trials removal")

    classesTrialsNumToRemove = max([removedLeftNum, removedRightNum, removedIdleNum]) - [removedIdleNum, removedLeftNum, removedRightNum];

    % how many trials to remove from each class to balance classes

    [MIData, trainingVec] = balance_classes_after_trials_removal(MIData, ...
                                                                trainingVec, ...
                                                                classesTrialsNumToRemove);

end

disp(strcat("Total trial number after removal: ", int2str(size(MIData, 1))));

save(strcat(recordingFolder,'\trainingVec_after_removal.mat'), 'trainingVec');    
save(strcat(recordingFolder,'\MIData_after_removal.mat'), 'MIData');

disp("Done removing trials ")
end

