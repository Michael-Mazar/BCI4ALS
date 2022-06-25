function [MIData, trainingVec] = MI_edit_dataset(recordingFolder, MIData, trainingVec, channels_to_remove, trials_to_remove)
% A function which edits the dataset by removing trials or removing channels
%  - recordingFolder: The recording location containing the MIData
%  - MIData: MIData dataset as extracted with MI3
%  - channels_to_remove: An array specifying which cahnnels to remove 
%  - trials_to_remove: An array specifying which trials to remove
%%  Remove channels
if ~isempty(channels_to_remove)
    if isa(channels_to_remove,'double')
        MIData(:, channels_to_remove, :) = [];
        disp("Removed select channels")
    else
        error('Channels array must be an array with integer filled within range and within bounds')
    end
else
    disp('No channels were removed, channel indices were empty')
end
%% Remove trials
if ~isempty(trials_to_remove)
    removedIdleNum = sum(trainingVec(:, trials_to_remove) == 1);
    removedLeftNum = sum(trainingVec(:, trials_to_remove) == 2);
    removedRightNum = sum(trainingVec(:, trials_to_remove) == 3);
    disp("Removing trials")
    disp(sprintf("Number of removed IDLE trials: %d\n" + ...
                    "Number of removed LEFT trials: %d\n" + ...
                    "Number of removed RIGHT trials: %d\n", ...
                     removedIdleNum, removedLeftNum,removedRightNum));
    
    % Remove bad trials
    MIData(trials_to_remove, :, :) = [];
    trainingVec(:, trials_to_remove) = [];

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
else
    disp('No trials removed, trial indices were empty')
end
%% Save MIData and trainingVec
save(strcat(recordingFolder,'\trainingVec_after_removal.mat'), 'trainingVec');    
save(strcat(recordingFolder,'\MIData_after_removal.mat'), 'MIData');
disp("Done editing.")
end
