function f_Visualize_FeatureSelect(class, features_headers, num_channels, num_features_per_channel)
%% Matrix visualization 
figure;
% weightMatrix = zeros(num_channels, num_features_per_channel);
weightMatrix = reshape(class.FeatureWeights(4:end), num_features_per_channel, num_channels).';
channel_names = {'C03','C04','C0Z','FC1',...
    'FC2','FC5','F06','CP1', 'CP2',...
    'CP5','CP6','O01','O02'};
imagesc(weightMatrix);
xticks([1:num_features_per_channel])
yticks([1:num_channels])
xticklabels(features_headers)
xtickangle(70)
% yticklabels(channel_names{1:num_channels})
title('Feature matrix visualization')
% Set up where it will show x, y, and value in status line.
impixelinfo;
% Get the current colormap
cmap = colormap;

%%
% Plot the feature weights 
figure()
plot(class.FeatureWeights,'ro')
grid on
xlabel('Feature index')
ylabel('Feature weight')
