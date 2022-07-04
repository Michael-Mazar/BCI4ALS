function [res] = find_feature(channels_amount, features_per_channel, feature_index)

% the first features outside the loop
if feature_index <= 3
    res = 'CSP ' + string(feature_index);
    return
end
 
for i = 1:channels_amount
    if i*features_per_channel >= feature_index-3
        mode_res = mod(feature_index-3, features_per_channel);
        if mode_res > 0
            feature = mode_res;
        else
            feature = features_per_channel;
        end
        res = 'channel ' + string(i) + ' feature ' + string(feature);
        return
    end
end
        