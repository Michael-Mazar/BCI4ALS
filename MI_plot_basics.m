function [] = MI_plot_basics(recordingFolder, MIData, channels_to_plot, trainingVec, EEG_chans, params)
%% Function description
% Input - 
% recordingFolder - string for the recordings files
% EEG_class_arr - A 
% Output - Visualizes and saves plot from the data
% Predefine some parameters: 
arguments
    recordingFolder string
    MIData double
    channels_to_plot double
    trainingVec double
    EEG_chans string
    params struct
end
% Create a folder to save figures in
figureFolder = strcat(recordingFolder, '\Figures\');
if not(isfolder(figureFolder ))
    mkdir(figureFolder );
end
% Plot ERP's across channels and data
flag = 1;
while flag
    f = input(['Which function to use?\n' ...
        '1: ERP\n' ...
        '2: CSP\n' ...
        '3: PSDs\n' ...
        '4: Spectogram\n' ...
        '5: None\n']);
    switch f
        case 1
            visualize_erp(MIData, channels_to_plot, trainingVec, EEG_chans)
        case 2
            visualize_csps(MIData,trainingVec)
        case 3
            psd_type = input(['Which PSD Type To Plot??\n' ...
                '1: Side-by-side\n' ...
                '2: Difference\n' ...
                ]);
            visualize_psds(MIData, trainingVec, channels_to_plot, EEG_chans, params,psd_type)
        case 4
            visualize_spectogram(MIData, trainingVec, channels_to_plot, EEG_chans, params)
        case 5
            flag = 0;
            disp('Skipped plotting')
        otherwise
            disp('Wrong choice');
            
    end
end
%% A function for visualizing ERP's
function [] = visualize_erp(MIData, channels_to_plot, trainingVec, EEG_chans)
    figure;
    sgtitle(['ERP Time Series For The Choosen Electrode']);
    n_rows = length(channels_to_plot); 
    n_cols = size(unique(trainingVec),2);
    classes = struct('left',MIData(trainingVec == 2,:,:),'right',MIData(trainingVec == 3,:,:));
    names = fieldnames(classes);
    subplots = 1:2:n_rows*n_cols;
    times = 1:size(MIData,3);
    for i = 1:length(channels_to_plot)
        channel_index = channels_to_plot(i);
        % Plot for left class
        subplot(n_rows,n_cols,subplots(i)); 
        plot_erp(classes.left, times, channel_index, EEG_chans,names(1))
        % Plot for right class
        subplot(n_rows,n_cols,subplots(i)+1);         
        plot_erp(classes.right, times, channel_index, EEG_chans,names(2))
    end    
end
%%
function [] = plot_erp(MIData, times, channel_index, EEG_chans, class_string)
    hold on
    h = plot(times, squeeze(MIData(:,channel_index,:)),'linew',.5);
    set(h,'color',[1 1 1]*.75)
    plot(times,squeeze(mean(MIData(:,channel_index,:),1)),'k','linew',3);
    title(class_string + " class ERP series for channel " + EEG_chans(channel_index,:))
    xlabel('Time (ms)'), ylabel('Activity')
    ylim([-60,60]); 
    hold off
end
%% A function for plotting CSP's:
function [] = visualize_csps(MIData, targetLabels)
    vizTrial = randi([1 floor(size(MIData,1)/3)],1); % Roll a random trial for which to visuallize CSPs !!!
    sprintf('Visualizing CSPs for %d ',vizTrial)
    % Seperate into right and left classes
    leftClass = MIData(targetLabels == 2,:,:);
    rightClass = MIData(targetLabels == 3,:,:);
    % aggregate all trials into one matrix
    overallLeft = [];
    overallRight = [];
    for trial=1:size(leftClass,1)
        overallLeft = [overallLeft squeeze(leftClass(trial,:,:))];
        overallRight = [overallRight squeeze(rightClass(trial,:,:))];
    end
    figure;
    subplot(1,2,1)      % show a single trial before CSP seperation
    scatter3(squeeze(leftClass(vizTrial,1,:)),squeeze(leftClass(vizTrial,2,:)),squeeze(leftClass(vizTrial,3,:)),'b'); hold on
    scatter3(squeeze(rightClass(vizTrial,1,:)),squeeze(rightClass(vizTrial,2,:)),squeeze(rightClass(vizTrial,3,:)),'g');
    title('Before CSP')
    legend('Left','Right')
    xlabel('channel 1')
    ylabel('channel 2')
    zlabel('channel 3')
    % find mixing matrix (W) for all trials
    [W, lambda, A] = csp(overallLeft, overallRight);
    [Wviz, lambdaViz, Aviz] = csp(squeeze(rightClass(vizTrial,:,:)), squeeze(leftClass(vizTrial,:,:)));
    % The main function which does all the work
    % apply mixing matrix on available data (for visualization)
    leftClassCSP = (Wviz'*squeeze(leftClass(vizTrial,:,:)));
    rightClassCSP = (Wviz'*squeeze(rightClass(vizTrial,:,:)));
    subplot(1,2,2)      % show a single trial aftler CSP seperation
    scatter3(squeeze(leftClassCSP(1,:)),squeeze(leftClassCSP(2,:)),squeeze(leftClassCSP(3,:)),'b'); hold on
    scatter3(squeeze(rightClassCSP(1,:)),squeeze(rightClassCSP(2,:)),squeeze(rightClassCSP(3,:)),'g');
    title('After CSP')
    legend('Left','Right')
    xlabel('CSP dimension 1')
    ylabel('CSP dimension 2')
    zlabel('CSP dimension 3')
    clear leftClassCSP rightClassCSP Wviz lambdaViz Aviz
end
%% Plot PSD's
function [] = visualize_psds(MIData, targetLabels, channels_to_plot, EEG_chans, params,psd_type)
%% Visual Feature Selection: Power Spectrum
% Observe changes in power spectrum - where are these changes observed in
% the different power spectrum 
% init cells for Power Spectrum display
    numClasses = size(unique(trainingVec),2);
    classes = unique(trainingVec);
    numChans = length(channels_to_plot);
    motorDataChan = {};
    welch = {};
    idxTarget = {};
    f = params.f;
    Fs = params.FS;
    window = params.window;
    noverlap = params.overlap;
    % create power spectrum figure:
    f1 = figure('name','PSD','NumberTitle','off');
    sgtitle(['Power Spectrum For The Choosen Electrode']);
    % compute power Spectrum per electrode in each class
    psd = nan(numChans,numClasses,2,1000); % init psd matrix
    for chan_i = 1:length(channels_to_plot)
        chan = channels_to_plot(chan_i);
        motorDataChan{chan} = squeeze(MIData(:,chan,:))';                   % convert the data to a 2D matrix fillers by channel
        nfft = 2^nextpow2(size(motorDataChan{chan},1));                     % take the next power of 2 length of the specific trial length
        welch{chan} = pwelch(motorDataChan{chan},window, noverlap, f, Fs);  % calculate the pwelch for each electrode
        figure(f1);
        subplot(numChans,1,chan_i)
        switch psd_type
            case 1
                plot_psd(f,idxTarget, targetLabels, welch, EEG_chans, chan,classes)
            case 2
                plot_psd_difference(f,idxTarget, targetLabels, welch, EEG_chans, chan)
            otherwise
                disp('No such PSD plot exists')
        end
    end
end
%% Plot PSD Side by side
function [] = plot_psd(f,idxTarget, targetLabels, welch, EEG_chans, chan,classes)
for class = classes
    idxTarget{class} = find(targetLabels == class);                 % find the target index
    plot(f, log10(mean(welch{chan}(:,idxTarget{class}), 2)));       % ploting the mean power spectrum in dB by each channel & class
    hold on
    ylabel([EEG_chans(chan,:)]);                                    % add name of electrode
end
end
%% Plot PSD difference
function [] = plot_psd_difference(f,idxTarget, targetLabels, welch, EEG_chans, chan)
idxTarget{2} = find(targetLabels == 2);                     % find the target index
psd_right = log10(mean(welch{chan}(:,idxTarget{2}), 2));
idxTarget{3} = find(targetLabels == 3);   
psd_left = log10(mean(welch{chan}(:,idxTarget{3}), 2));
plot(f, psd_right-psd_left);       % ploting the mean power spectrum in dB by each channel & class
hold on
ylabel([EEG_chans(chan,:)]);                                    % add name of electrode
end
%% Manually plot (surf) mean spectrogram for channels C4 + C3:
function [] = visualize_spectogram(MIData, targetLabels, channels_to_plot, EEG_chans, params)
numClasses = size(unique(targetLabels),2);
classes = unique(targetLabels);
numChans = length(channels_to_plot);
motorDataChan = {};
welch = {};
idxTarget = {};
f = params.f;
Fs = params.FS;
window = params.window;
noverlap = params.overlap;
vizChans = [1,2];             % INSERT which 2 channels you want to compare
for chan_i = 1:length(channels_to_plot)
    chan = channels_to_plot(chan_i);
    motorDataChan{chan} = squeeze(MIData(:,chan,:))';                   % convert the data to a 2D matrix fillers by channel
    nfft = 2^nextpow2(size(motorDataChan{chan},1));                     % take the next power of 2 length of the specific trial length
    for class = classes
        idxTarget{class} = find(targetLabels == class);                 % find the target index
        for trial = 1:length(idxTarget{class})                          % run over all concurrent class trials
            [s,spectFreq,t,psd] = spectrogram(motorDataChan{chan}(:,idxTarget{class}(trial)),window,noverlap,nfft,Fs);  % compute spectrogram on specific channel
            multiPSD(trial,:,:) = psd;
        end
        % compute mean spectrogram over all trials with same target
        totalSpect(chan,class,:,:) = squeeze(mean(multiPSD,1));
        clear multiPSD psd
    end
end
MI_plot_spectrogram(t,spectFreq,totalSpect,numClasses,vizChans,EEG_chans,classes)
end
end
