function [trials_to_remove_indices] = filter_trails(MIData,input_range)
% function to filter bad trails from the data set
% Inputs:
% * MIData - Data set after MI3 function.
% * input_range - input range in micro volts (uv), keep values in this range.

% Output:
% trials_to_remove_indices - list of trails to remove

num_trails = length(MIData(:,1,1));
electrode_num = length(MIData(1,:,1));
Mean_values = zeros(electrode_num,num_trails);
threshold = input_range; % Might change between mentors and physical environments
trials_to_remove_indices =  [];
for i = 1:1:num_trails
    for j = 1:1:electrode_num
        Mean_values(j,i) = mean(abs(MIData(i,j,:)));
        if (Mean_values(j,i) > threshold)
            trials_to_remove_indices = [trials_to_remove_indices, i];
            break;
        end
    end
end

%% for other uses we can use this code
% % first find all avg and then filter, if we want the avg values of each
% trails and electrode we should use this


% threshhold = 100;
% for j = 1:1:electrode_num
%     for i=1:1:num_trails
%         Mean_values(j,i) = mean(abs(MIData(i,j,:)));
%     end
% end
% 
% trials_to_remove_indices =  [];
% for i = 1:1:num_trails
%     for j = 1:1:electrode_num
%         fprintf('col index = %d, row index = %d, value = %f\n', i,j,Mean_values(j,i));
%         if (Mean_values(j,i) > threshold)
%             trials_to_remove_indices = [trials_to_remove_indices, i];
%             break;
%         end
%     end
% end

% % find the avg of all the trails per electrode, and the avg of all
% % electrode per trial

% Mean_of_trails = zeros(electrode_num,1);
% Mean_of_electrodes = zeros(num_trails,1);
% for j = 1:1:11
%     Mean_of_trails(j,1) = abs(mean(Mean_values(j,:)));
% end
% for i = 1:1:num_trails
%     Mean_of_electrodes(i,1) = mean(abs(Mean_values(:,i)));
% end

