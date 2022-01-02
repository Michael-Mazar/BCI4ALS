function [trainingVec] = prepareTraining(numTrials,numConditions)
%% return a random vector of 1's, 2's and 3's in the length of numTrials
trainingVec = (1:numConditions);
trainingVec = repmat(trainingVec,1,numTrials);
trainingVec = trainingVec(randperm(length(trainingVec)));

%% check for unwanted patterns
MAX_TRY = 10;% try to fix maximum of 10 times
thresh = 3;
for i = 1:1:MAX_TRY 
    changed = 0;
    repet = 1;
    cur_repet = trainingVec(1); % the current class
    for j = 2:1:length(trainingVec)
        if (trainingVec(j) == cur_repet) %% see if same as last
            repet = repet + 1; %% adds one to repet if 
            if (repet == thresh)
                changed = 1;
                break;
            end 
        else
            cur_repet = trainingVec(j);
            repet = 1;
        end
    end
    if (changed == 0) %% nothing changed
        break;
    else %% try new permutation
        trainingVec = trainingVec(randperm(length(trainingVec)));
    end
end