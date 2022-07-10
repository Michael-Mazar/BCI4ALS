function MI_plot_features(recordingFolder, feature_setting, EEG_chans)
%% Function description:
% Input:
% recordingFolder - The location
% feature_setting - Which features were extracted (variable in config_file)
% EEG_chans - Which relevant EEG_chans to plot
% Output: Generates a heatmap of all features where colors represents
% weights, rows are for channels and columns are for features

%% Extract all relevant variables
FeaturesWeights = struct2cell(load(strcat(recordingFolder,'\FeatureWeights.mat')));
FeaturesWeights = FeaturesWeights{1};
num_channels = size(EEG_chans,1);
feature_headers = {};
fn = fieldnames(feature_setting);
for k=1:numel(fn)
    if(feature_setting.(fn{k}))
        feature_headers = {feature_headers fn{k}};
    end
end
feature_headers = feature_headers(~cellfun('isempty',feature_headers)); % Remove empty cells
num_features_per_channel = size(feature_headers,2);
%% Matrix visualization 
figure;
% weightMatrix = zeros(num_channels, num_features_per_channel);
weightMatrix = reshape(FeaturesWeights(4:end), num_features_per_channel, num_channels).';
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
