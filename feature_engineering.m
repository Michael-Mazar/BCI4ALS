function [MIFeatures] = feature_engineering(recordingFolder, MIData, bands, times, W, params, feature_setting)
%% This function extracts features for the machine learning process.
% Starts by visualizing the data (power spectrum) to find the best powerbands.
% Next section computes the best common spatial patterns from all available
% labeled training trials. The next part extracts all learned features.
% This includes a non-exhaustive list of possible features (commented below).
% At the bottom there is a simple feature importance test that chooses the
% best features and saves them for model training.
%% This code is part of the BCI-4-ALS Course written by Asaf Harel
% (harelasa@post.bgu.ac.il) in 2021. You are free to use, change, adapt and
% so on - but please cite properly if published.
%% check
numChans = size(MIData,2);                                      % get number of channels from main data variable
trials = size(MIData,1);                                        % get number of trials from main data variable
Fs = params.FS;                                                 % openBCI Cyton+Daisy by Bluetooth sample rate
welch = {};
f = params.f;
for chan = 1:numChans
%     pwelch_input = squeeze(MIData(:,chan,:))';
%     if trials > 1
%         % This condition is used to fix dimension issues
%         pwelch_input = pwelch_input';
%     end
    pwelch_res = pwelch(squeeze(MIData(:,chan,:))',params.window, params.overlap, f, Fs);  % calculate the pwelch for each electrode
    if trials == 1
        pwelch_res = pwelch_res';
    end
    welch{chan} = pwelch_res; 
end
%% Extract features 
if feature_setting.Bands
    numSpectralFeatures = length(bands);                        % how many features exist overall 
else
    numSpectralFeatures = 0;
end
MIFeaturesLabel = NaN(trials,numChans,numSpectralFeatures); % init features + labels matrix
for trial = 1:trials                                % run over all the trials 
    
    % CSP: using W computed above for all channels at once
    % Extrac the variance of CSP
    temp = var((W'*squeeze(MIData(trial,:,:)))');   % apply the CSP filter on the current trial EEG data
    CSPFeatures(trial,:) = temp(1:3);               % add the variance from the first 3 eigenvalues - the eigen values which explain the most of the data
    clear temp                                      % clear the variable to free it for the next loop
    
    for channel = 1:numChans                        % run over all the electrodes (channels)
        n = 1;                                      % start a new feature index
        % Find the power for each of frequencies defined earlier
        if feature_setting.Bands
            for feature = 1:numSpectralFeatures                 % run over all spectral band power features from the section above
                % Extract features: bandpower +-1 Hz around each target frequency
                floored_time_indices = floor(times{feature});
                %MIFeaturesLabel(trial,channel,n) = bandpower(squeeze(MIData(trial,channel,times{feature})),Fs,bands{feature});
                MIFeaturesLabel(trial,channel,n) = bandpower(squeeze(MIData(trial,channel,floored_time_indices)),Fs,bands{feature});
                n = n+1;            
            end
        end
        
        % NOVEL Features - an explanation for each can be found in the class presentation folder
        
        % Normalize the Pwelch matrix
        pfTot = sum(welch{channel}(:,trial));               % Total power for each trial
        normlizedMatrix = welch{channel}(:,trial)./pfTot;   % Normalize the Pwelch matrix by dividing the matrix in its sum for each trial
        
        if feature_setting.Root
            % Root Total Power
            MIFeaturesLabel(trial,channel,n) = sqrt(pfTot);     % Square-root of the total power
            n = n + 1;
        end
        
        if feature_setting.Moment
            % Spectral Moment
            MIFeaturesLabel(trial,channel,n) = sum(normlizedMatrix.*f'); % Calculate the spectral moment
            n = n + 1;
        end 
        
        if feature_setting.Edge
            % Spectral Edge
            probfunc = cumsum(normlizedMatrix);                 % Create matrix of cumulative sum
            % frequency that 90% of the power resides below it and 10% of the power resides above it
            valuesBelow = @(z)find(probfunc(:,z)<=0.9);         % Create local function
            % apply function to each element of normlizedMatrix
            fun4Values = arrayfun(valuesBelow, 1:size(normlizedMatrix',1), 'un',0);
            lengthfunc = @(y)length(fun4Values{y})+1;           % Create local function for length
            % apply function to each element of normlizedMatrix
            fun4length = cell2mat(arrayfun(lengthfunc, 1:size(normlizedMatrix',1), 'un',0));
            MIFeaturesLabel(trial,channel,n) = f(fun4length);   % Insert it to the featurs matrix
            n = n + 1;
        end 
        
        if feature_setting.Entropy
            % Spectral Entropy
            MIFeaturesLabel(trial,channel,n) = -sum(normlizedMatrix.*log2(normlizedMatrix)); % calculate the spectral entropy
            n = n + 1;
        end
        
        if feature_setting.Slope
            % Slope
            transposeMat = (welch{channel}(:,trial)');          % transpose matrix
            % create local function for computing the polyfit on the transposed matrix and the frequency vector
            FitFH = @(k)polyfit(log(f(1,:)),log(transposeMat(k,:)),1);
            % convert the cell that gets from the local func into matrix, perform the
            % function on transposeMat, the slope is in each odd value in the matrix
            % Apply function to each element of tansposeMat
            pFitLiner = cell2mat(arrayfun(FitFH, 1:size(transposeMat,1), 'un',0));
            MIFeaturesLabel(trial,channel,n)=pFitLiner(1:2 :length(pFitLiner));
            n = n + 1;
        end
        
        if feature_setting.Intercept
            % Intercept
            % the slope is in each double value in the matrix
            MIFeaturesLabel(trial,channel,n)=pFitLiner(2:2:length(pFitLiner));
            n= n + 1;
        end
        
        if feature_setting.Mean_freq
            % Mean Frequency
            % returns the mean frequency of a power spectral density (PSD) estimate, pxx.
            % The frequencies, f, correspond to the estimates in pxx.
            MIFeaturesLabel(trial,channel,n) = meanfreq(normlizedMatrix,f);
            n = n + 1;
        end
        
        if feature_setting.Obw
            % Occupied bandwidth
            % returns the 99% occupied bandwidth of the power spectral density (PSD) estimate, pxx.
            % The frequencies, f, correspond to the estimates in pxx.
            MIFeaturesLabel(trial,channel,n) = obw(normlizedMatrix,f);
            n = n + 1;
        end
        
        if feature_setting.Powerbw
            % Power bandwidth
            MIFeaturesLabel(trial,channel,n) = powerbw(normlizedMatrix,Fs);
            n = n + 1;
        end     
    end
end

% z-score all the features - make sure there are not outlier
if params.z == 1
    MIFeaturesLabel = zscore(MIFeaturesLabel);
end

% Reshape into 2-D matrix - with this data we label right or left hands 
MIFeatures = reshape(MIFeaturesLabel,trials,[]);
MIFeatures = [CSPFeatures MIFeatures];              % add the CSP features to the overall matrix
AllDataInFeatures = MIFeatures;
save(strcat(recordingFolder,'\AllDataInFeatures.mat'),'AllDataInFeatures');
end